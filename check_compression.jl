using NetCDF, PyPlot, BitInformation, ColorSchemes, Statistics, StatsBase



#ncfile = NetCDF.open("./glaciaconda/ex_MSO_clim_dT_mprange_stddyn.nc")
# ncfile = NetCDF.open("./glaciaconda/ex_MSO_clim_dT_ctrl_mprange_clemdyn_NHEM_20km_continue.nc")
# ncfile = NetCDF.open("./glaciaconda/datasets/CESM/LGM_NOVEG/spin_up_21ka_CESM_noveg.cam.h0.0551to0600_clim.nc")
ncfile = NetCDF.open(ARGS[1])

# nvars = ncfile.vars.count
nvars = 0
# count possible variables
for (varname, varvalue) in ncfile.vars
    # only consider 3d variables
    if varvalue.ndim == 3 
        global nvars = nvars +1
    end
    if (varvalue.ndim == 4 && length(varvalue) == 7372800 )
        global nvars = nvars +1
    end
end


nbits = 32

IC = fill(0.0,nvars,nbits)
varnames = fill("",nvars)

ncells = 0 # number of cells in model 

i = 1
    for (varname, varvalue) in ncfile.vars
    # only consider 3d variables
    if (varvalue.ndim == 3 || varvalue.ndim == 4 )
        print(varname)
        print(" ")
        print(typeof(varvalue))
        print(" ")
        if varvalue.ndim == 3
            var_subset = varvalue[:,:,end] # for 3d vars
            print("3d ")
        elseif length(varvalue) == 7372800
            print("4d ")
            var_subset = varvalue[:,:,end,end] # for 4d vars
        else
            print("weird ")
            continue
        end
        global ncells = length(var_subset)
        bitinf = bitinformation(var_subset, dim=1)#
        keepbits = argmax(cumsum(bitinf)/sum(bitinf) .>= 0.99) - 9    # subtract 9 to count mantissa bits
        println(keepbits)
        IC[i, :] = bitinf
        varnames[i] = varname
        global i = i + 1
    else
        # IC[i, :] .= 0
        println(varname)
    end
end

ICfilt = copy(IC)
for i in 1:nvars
    ic = ICfilt[i,:]
    p = BitInformation.binom_confidence(ncells,0.99)  # get chance p for 1 (or 0) from binom distr
    M₀ = 1 - entropy([p,1-p],2)                            # free entropy of random 50/50 at trial size
    threshold = max(M₀,1.5*maximum(ic[end-3:end]))         # in case the information never drops to zero
                                                           # use something a bit bigger than maximum 
                                                           # of the last 4 bits
    insigni = (ic .<= threshold) .& (collect(1:length(ic)) .> 9)
    ICfilt[i,insigni] .= floatmin(Float64)
end

# find bits with 99/100% of information
ICcsum = cumsum(ICfilt,dims=2)
ICcsum_norm = copy(ICcsum)
for i in 1:nvars
    ICcsum_norm[i,:] ./= ICcsum_norm[i,end]
end

inflevel = 0.99
infbits = [argmax(ICcsum_norm[i,:] .> inflevel) for i in 1:nvars]
infbits100 = [argmax(ICcsum_norm[i,:] .> 0.999999999) for i in 1:nvars];

print("infbits")
print(infbits)

infbits_sorted = infbits
infbits100_sorted = infbits100

infbitsx_sorted = copy(vec(hcat(infbits_sorted,infbits_sorted)'))
infbitsx100_sorted = copy(vec(hcat(infbits100_sorted,infbits100_sorted)'))
infbitsy_sorted = copy(vec(hcat(Array(0:nvars-1),Array(1:nvars))'));

# smb = ncfile.vars["climatic_mass_balance"][:,:,:]
# thk = ncfile.vars["velsurf_mag"][:,:,:]
# smb = ncfile.vars["PRECC"][:,:,:]
# thk = ncfile.vars["TREFHT"][:,:,:]


# bitinf_thk = bitinformation(thk,dim=2)
# bitinf_smb = bitinformation(smb,dim=2)


# Now we want to find the bits that are needed to preserve at least p% of total information, 
# which is sum(bitinf), the sum of information across all bit positions. 
# As we only aim to discard mantissa bits, the partial sum of information is always calculated 
# from the sign bit to last the mantissa bit that is kept (the keepbits). The first bit for which 
# the sum contains 99% of more of the total information is then the last bit that we want to keep.
#
# keepbits_thk = argmax(cumsum(bitinf_thk)/sum(bitinf_thk) .>= 0.99) - 9    # subtract 9 to count mantissa bits
# keepbits_smb = argmax(cumsum(bitinf_smb)/sum(bitinf_smb) .>= 0.99) - 9    # subtract 9 to count mantissa bits

# println(keepbits_thk)
# println(keepbits_smb)


# plotting
ICnan = copy(IC)
ICnan[iszero.(IC)] .= NaN;
#
#thk_nan = copy(bitinf_thk)
#thk_nan[iszero.(thk_nan)] .= NaN;
#

# print command for compression
for i in 1:length(infbits_sorted)
    print(varnames[i])
    print("=")
    print(infbits_sorted[i] - 9)  # offset because we dont want mantissa??
    println(" \\")
end


cmap = ColorMap(ColorSchemes.turku.colors).reversed()

fig,ax1 = subplots(1,1,figsize=(8,10),sharey=true)

tight_layout(rect=[0.06,0.08,0.93,0.98])
pos = ax1.get_position()
cax = fig.add_axes([pos.x0,0.06,pos.x1-pos.x0,0.02])

pcm = ax1.pcolormesh(ICnan,vmin=0,vmax=1; cmap)

cbar = colorbar(pcm,cax=cax,orientation="horizontal")
cbar.set_label("information content [bit]")

ax1.plot(vcat(infbits_sorted,infbits_sorted[end]),Array(0:nvars),"C1",ds="steps-pre",zorder=10,label="99% of\ninformation")

# grey shading
ax1.fill_betweenx(infbitsy_sorted,infbitsx_sorted,fill(32,length(infbitsx_sorted)),alpha=0.4,color="grey")
ax1.fill_betweenx(infbitsy_sorted,infbitsx100_sorted,fill(32,length(infbitsx_sorted)),alpha=0.1,color="c")
ax1.fill_betweenx(infbitsy_sorted,infbitsx100_sorted,fill(32,length(infbitsx_sorted)),alpha=0.3,facecolor="none",edgecolor="c")

ax1.set_title("Real bitwise information content",loc="left",fontweight="bold")
ax1.set_xlim(0,32)
ax1.set_ylim(nvars,0)

ax1.set_yticks(Array(1:nvars).-0.5)

# ax1.text(infbits_sorted[1]+0.1,0.8,"$(infbits[1]-9) mantissa bits",fontsize=8,color="saddlebrown")
# for i in 2:nvars
#     ax1.text(infbits_sorted[i]+0.1,(i-1)+0.8,"$(infbits_sorted[i]-9)",fontsize=8,color="saddlebrown")
# end

ax1.text(infbits_sorted[1]+0.1,0.8,"$(infbits[1]-9) mantissa bits",fontsize=8,color="saddlebrown")
for i in 2:nvars
    ax1.text(infbits_sorted[i]+0.1,(i-1)+0.8,"$(infbits_sorted[i]-9)",fontsize=8,color="saddlebrown")
end
ax1.set_yticklabels(varnames)
ax1.axvline(1,color="k",lw=1,zorder=3)
ax1.axvline(9,color="k",lw=1,zorder=3)

ax1.set_xticks([1,9])
ax1.set_xticks(vcat(2:8,10:32),minor=true)
ax1.set_xticklabels([])
ax1.text(0,nvars+2.2,"sign",rotation=90)
ax1.text(2,nvars+2.2,"exponent bits",color="darkslategrey")
ax1.text(10,nvars+2.2,"mantissa bits")

for i in 1:8
    ax1.text(i+.5,nvars+0.9,"$i",ha="center",fontsize=7,color="darkslategrey")
end

for i in 1:23
    ax1.text(8+i+.5,nvars+0.9,"$i",ha="center",fontsize=7)
end


##ax1.plot(vcat(keepbits_thk,keepbits_smb),Array(0:2),"C1",ds="steps-pre",zorder=10,label="99% of\ninformation")

##imshow(hcat(bitinf_thk, bitinf_smb, )'; cmap)
#ax1.set_yticks(0:1,["Ice thickness","surface mass balance"])           # label y ticks

show()
