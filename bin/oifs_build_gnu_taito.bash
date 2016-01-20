# Bash options
set -ex

# Helper functions
die() { echo "$@" 1>&2 ; exit 1; }

# Variable definitions
oifsver=oifs38r1v04

# Overridable variable definition with default values
: ${builddir:=${TMPDIR:=/tmp}}

# Script's arguments processing
srcdir=${1:=.}
test -f "${srcdir}/${oifsver}.tar.gz" || \
    die "Give the path to the OpenIFS source tar ball as the first argument"

# Unpack original source tar ball
mkdir -p ${builddir}
cd $_
tar xvf ${srcdir}/${oifsver}.tar.gz

# Patches
test -f ${srcdir}/sufa.patch && patch -p0 < ${srcdir}/sufa.patch || :

# MKL link line tool setup
mkltool=${MKLROOT}/tools/mkl_link_tool
mklopts="-c gnu_f -o gomp"

# OpenIFS build type
OIFS_BUILD="opt"

# Compile options
OIFS_FFLAGS="-O2 -fconvert=big-endian -fopenmp
             $(2>/dev/null ${mkltool} -opts ${mklopts})"

# Generic link options
OIFS_LFLAGS="-fopenmp"

# BLAS and LAPACK link options and grib-api root directory
OIFS_LAPACK_LIB="$(2>/dev/null ${mkltool} -libs ${mklopts})"
OIFS_GRIB_API_DIR="$GRIB_API_DIR"

# Export all variables OIFS_*
export $(compgen -A variable OIFS_)

# Run the build
cd ${builddir}/${oifsver}/make
../fcm/bin/fcm make -v --new -j4 -f oifs.cfg

# Copy the executables from the temporary build dir
mkdir -p $(dirname ${MY_OIFS_EXE})
cp gnu-opt/oifs/bin/*  $(dirname ${MY_OIFS_EXE})
