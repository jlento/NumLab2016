# Load environment modules
module purge
module load python-env/2.7.10 hdf5-serial/1.8.15
module load netcdf4-serial/4.3.3.1 grib-api/1.14.2

# Full path name to the OpenIFS executable
export MY_OIFS_EXE=$USERAPPL/oifs/gnu-opt/bin/master.exe
