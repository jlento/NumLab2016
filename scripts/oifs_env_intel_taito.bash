# Load environment modules
module purge
module load intel/16.0.0 intelmpi/5.1.1 mkl/11.3.0
module load hdf5-par/1.8.15 netcdf4/4.3.3.1
module load grib-api/1.14.2

# MKL link line tool setup
mklopts="-c intel_f -o iomp5"
mkltool() {
    local mode="$1"
    shift
    local mklopts="$@"
    local mklcmd=${MKLROOT}/tools/mkl_link_tool
    echo "$($mklcmd $mode $mklopts 2> /dev/null | tr '()' '{}')"
}

# OpenIFS compiler
OIFS_COMP="intel_mkl"

# OpenIFS build type
OIFS_BUILD="opt"

# OpenIFS install root
OIFS_DEST_DIR="${USERAPPL}/oifs/intel-opt"

# Compile options
OIFS_FFLAGS="-O1 -convert big_endian -openmp $(mkltool -opts ${mklopts})"

# Generic link options
OIFS_LFLAGS="-openmp"

# BLAS and LAPACK link options and grib-api root directory
OIFS_LAPACK_LIB="$(mkltool -libs ${mklopts})"
OIFS_GRIB_API_DIR="$GRIB_API_DIR"

# Export all variables OIFS_*
export $(compgen -A variable OIFS_)
