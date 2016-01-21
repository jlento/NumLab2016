# Bash options
set -ex

# Helper functions

# In case of fatal error
die() { echo "$@" 1>&2 ; exit 1; }

# Compiler suite
compiler_suite() {
    case "$(2>&1 module -t list intel/ gcc/)" in
        intel*)
	    echo intel
            ;;
        gcc*)
	    echo gnu
            ;;
	*)
	    die "No compiler module loaded?"
	    ;;
    esac
}

# Script's arguments processing
tarball=${1:?}
test -f "${tarball}" || \
    die "OpenIFS source tar ball should be the first argument"

# Build directory root
: ${builddir:=${TMPDIR:=/tmp}}

# Unpack original source tar ball
mkdir -p ${builddir}
cd $_
tar xvf ${tarball}

# MKL link line tool setup
mkltool=${MKLROOT}/tools/mkl_link_tool
case "$(compiler_suite)" in
    gnu)
	mklopts="-c gnu_f -o gomp"
	;;
    intel)
	mklopts="-c intel_f -o iomp5"
	;;
esac

# OpenIFS compiler
OIFS_COMP="$(compiler_suite)"

# OpenIFS build type
OIFS_BUILD="opt"

# OpenIFS install root
OIFS_DEST_DIR="${USERAPPL}/oifs/$(compiler_suite)-${OIFS_BUILD}"

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
cd ${builddir}/$(basename ${tarball%%.*})/make
../fcm/bin/fcm make -v --new -j4 -f oifs_conv.cfg
