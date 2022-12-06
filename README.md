This is an unfinished piece of work that I used to analyze NetCDF files for possible compression following Klöwer et al. 2021[0]

So far it only considers 3d/4d 32bit vars and gives bad output for everything else (e.g. int masks etc.). 

The result is a plot similar to figure 2 of the original paper and also a list of arguments that can be used in ncks.

> **Warning**
> This code is still in very early stages and contains many bugs! Don't use it for anything serious!

### usage
```
./check_compression.jl <netcdf_file>
```



[0]
Klöwer, M., Razinger, M., Dominguez, J.J. et al. Compressing atmospheric data into its real information content. Nat Comput Sci 1, 713–724 (2021). https://doi.org/10.1038/s43588-021-00156-2
https://www.nature.com/articles/s43588-021-00156-2
