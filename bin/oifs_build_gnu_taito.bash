# Bash options
set -ex

# Helper functions
die() { echo "$@" 1>&2 ; exit 1; }

# Variable definitions
oifsver=oifs38r1

# Overridable variable definition with default values
: ${builddir:=${TMPDIR:=/tmp}}

# Script's arguments processing
tarball=${1:?}
shift
test -f "${tarball}" || \
    die "OpenIFS source tar ball should be the first argument"

# Unpack original source tar ball
mkdir -p ${builddir}
cd $_
tar xvf ${tarball}

# MKL link line tool setup
mkltool=${MKLROOT}/tools/mkl_link_tool
mklopts="-c gnu_f -o gomp"

# OpenIFS build type
OIFS_BUILD="opt"

# OpenIFS install root
OIFS_DEST_DIR="${USERAPPL}/oifs/gnu-${OIFS_BUILD}"

# Compile options
OIFS_FFLAGS="-O2 -fconvert=big-endian -fopenmp
             $(${mkltool} -opts ${mklopts} 2>/dev/null)"

# Generic link options
OIFS_LFLAGS="-fopenmp"

# BLAS and LAPACK link options and grib-api root directory
OIFS_LAPACK_LIB="$(2>/dev/null ${mkltool} -libs ${mklopts})"
OIFS_GRIB_API_DIR="$GRIB_API_DIR"

# Export all variables OIFS_*
export $(compgen -A variable OIFS_)

# Run the build
cd ${builddir}/${oifsver}/make
../fcm/bin/fcm make -v --new -j4 -f oifs_conv.cfg
