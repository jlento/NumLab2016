# Bash options
set -ex

# Script's arguments processing
tarball=$1
if [[ ! -f "${tarball}" ]]; then
    1>&2 echo "OpenIFS source tar ball should be the first argument"
    exit 1
fi

# Build directory root
: ${builddir:=${TMPDIR:=/tmp}}

# Unpack original source tar ball
mkdir -p ${builddir}
cd $_
tar xf ${tarball}

# Patch source
url=https://raw.githubusercontent.com/jlento/NumLab2016/master/scripts
find $(basename ${tarball%%.*}) -name sufa.F90 \
    -execdir bash -c "patch -p4 < <(curl -s $url/sufa.patch)" \;

# Run the build
cd ${builddir}/$(basename ${tarball%%.*})/make
../fcm/bin/fcm make -v --new -j4 -f oifs_conv.cfg
