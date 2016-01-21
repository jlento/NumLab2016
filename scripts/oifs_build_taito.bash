# Bash options
set -ex

# Helper functions

# In case of fatal error
die() { echo "$@" 1>&2 ; exit 1; }

# Figure out compiler suite from loaded modules
compiler_suite() {
    [[ "$LOADEDMODULES" =~ (^|:)(gcc|intel)/ ]]
    case "${BASH_REMATCH[2]}" in
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
tar xf ${tarball}

# Patch source
url=https://raw.githubusercontent.com/jlento/NumLab2016/master/scripts
for f in $(find . -name sufa.F90); do
    pushd .
    cd $(dirname $f)
    patch -s -f -p4 < <(curl -s ${url}/sufa.patch)
    popd
done

# MKL link line tool setup
mkltool() {
    local mode="$1"
    local mklcmd=${MKLROOT}/tools/mkl_link_tool
    local mklopts
    case "$(compiler_suite)" in
	gnu)
	    mklopts="-c gnu_f -o gomp"
	    ;;
	intel)
	    mklopts="-c intel_f -o iomp5"
	    ;;
    esac
    echo "$($mklcmd $mode $mklopts 2> /dev/null | tr '()' '{}')"
}

# OpenIFS compiler
OIFS_COMP="$(compiler_suite)"

# OpenIFS build type
OIFS_BUILD="opt"

# OpenIFS install root
OIFS_DEST_DIR="${USERAPPL}/oifs/$(compiler_suite)-${OIFS_BUILD}"

# Compile options
case "$(compiler_suite)" in
    gnu)
	OIFS_FFLAGS="-O2 -fconvert=big-endian -fopenmp $(mkltool -opts)"
	;;
    intel)
	OIFS_FFLAGS="-O2 -convert big_endian -fopenmp $(mkltool -opts)"
	;;
esac

# Generic link options
OIFS_LFLAGS="-fopenmp"

# BLAS and LAPACK link options and grib-api root directory
OIFS_LAPACK_LIB="$(mkltool -libs)"
OIFS_GRIB_API_DIR="$GRIB_API_DIR"

# Export all variables OIFS_*
export $(compgen -A variable OIFS_)

# Run the build
cd ${builddir}/$(basename ${tarball%%.*})/make
../fcm/bin/fcm make -v --new -j4 -f oifs_conv.cfg
