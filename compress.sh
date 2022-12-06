#!/usr/bin/env bash

# bash strict mode 
set -euo pipefail
IFS=$'\n\t'


input="./b.e12.B1850C5_CN.f19_g16.38i21g21o.B4.pop.h.5165-11.nc"
output_default="./b.e12.B1850C5_CN.f19_g16.38i21g21o.B4.pop.h.5165-11_defaultcompression_9keepbits_zst.nc"
output_klower="./b.e12.B1850C5_CN.f19_g16.38i21g21o.B4.pop.h.5165-11_defaultcompression_9keepbits_klower_zst.nc"
output_lossless="./b.e12.B1850C5_CN.f19_g16.38i21g21o.B4.pop.h.5165-11_lossless_zst.nc"
output_lossless_deflate="./b.e12.B1850C5_CN.f19_g16.38i21g21o.B4.pop.h.5165-11_lossless_deflate.nc"
output_none="./b.e12.B1850C5_CN.f19_g16.38i21g21o.B4.pop.h.5165-11_nocompression.nc"

# -7 netcdf4 classic
# --baa=8 bit round
# default applys to everything that is not explicitly given after that
# --cmp='shf|zst' shuffle and zstandard compression (lossless)

#ncks -7 --cmp='shf|dfl' ${input}  ${output_lossless_deflate}
#ncks -7 --cmp='shf|zstd' ${input}  ${output_lossless}
#ncks -7 --baa=8 --ppc default=9 --cmp='shf|zstd' ${input}  ${output_default}
ncks -7  --cmp='none' ${input}  ${output_none}
exit
ncks -7 --baa=8 --ppc default=9 \
--ppc RESID_T=3 \
--ppc VSUBM=23 \
--ppc HDIFT=1 \
--ppc IOFF_F=3 \
--ppc UVEL=3 \
--ppc HLS_SUBM=1 \
--ppc XBLT=4 \
--ppc WISOP=1 \
--ppc SFWF=3 \
--ppc ROFF_F=3 \
--ppc ADVT_SUBM=1 \
--ppc SSH=4 \
--ppc KVMIX=1 \
--ppc HBLT=3 \
--ppc IFRAC=12 \
--ppc LWDN_F=7 \
--ppc TAUX2=3 \
--ppc HDIFS=1 \
--ppc ADVT_ISOP=1 \
--ppc HMXL=4 \
--ppc TLT=2 \
--ppc TAUY2=2 \
--ppc TAUX=3 \
--ppc ADVS=1 \
--ppc QSW_HTP=5 \
--ppc VNT=1 \
--ppc SHF_QSW=8 \
--ppc VNS_ISOP=1 \
--ppc XMXL=5 \
--ppc LWUP_F=7 \
--ppc RESID_S=3 \
--ppc TBLT=3 \
--ppc VDC_S=3 \
--ppc MELTH_F=3 \
--ppc IAGE=8 \
--ppc UET=1 \
--ppc SNOW_F=3 \
--ppc TEMP=9 \
--ppc VNS_SUBM=23 \
--ppc EVAP_F=4 \
--ppc PV=1 \
--ppc SV=1 \
--ppc QFLUX=3 \
--ppc INT_DEPTH=4 \
--ppc WVEL2=1 \
--ppc VVEL2=3 \
--ppc PREC_F=3 \
--ppc HOR_DIFF=3 \
--ppc FW=3 \
--ppc TPOWER=3 \
--ppc VDC_T=3 \
--ppc TMXL=8 \
--ppc RHO_VINT=17 \
--ppc UVEL2=3 \
--ppc dTEMP_POS_2D=3 \
--ppc VVEL=3 \
--ppc DIA_DEPTH=4 \
--ppc TFW_S=3 \
--ppc VVC=3 \
--ppc SALT=16 \
--ppc VNT_SUBM=23 \
--ppc TAUY=2 \
--ppc SSH2=3 \
--ppc USUBM=23 \
--ppc Q=1 \
--ppc SENH_F=3 \
--ppc MELT_F=3 \
--ppc SU=1 \
--ppc VISOP=1 \
--ppc KVMIX_M=1 \
--ppc VNT_ISOP=1 \
--ppc ADVS_SUBM=1 \
--ppc ADVT=1 \
--ppc TFW_T=3 \
--ppc WSUBM=3 \
--ppc BSF=3 \
--ppc SALT_F=3 \
--ppc SHF=3 \
--ppc dTEMP_NEG_2D=2 \
--ppc UISOP=1 \
--ppc ADVS_ISOP=1 \
--ppc VNS=1 \
--ppc WTS=1 \
--ppc SFWF_WRST=3 \
--ppc UES=1 \
--ppc QSW_HBL=5 \
--ppc WTT=1 \
--ppc RHO=12 \
--cmp='shf|zstd' ${input}  ${output_klower}
