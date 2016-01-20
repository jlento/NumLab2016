#!/bin/bash
#SBATCH -N 1 --exclusive -t 15 -p test

url=https://raw.githubusercontent.com/jlento/NumLab2016/master/bin
source <(curl -s ${url}/oifs_env_gnu_taito.bash)
sdir=${USERAPPL}/oifs/src
ver=oifs38r1v04
cd ${WRKDIR}
tar xf --strip-components=1 ${sdir}/${ver}.tar.gz ${ver}/t21test
cd t21test
fixfort4() {
    local name value prog=""
    for arg in "$@"; do
        name="${arg%%=*}"
	value=$(printf %q "${arg#*=}")
	value="${value//\//\/}"
        prog="s/(^|[ ,])(${name} *=)[^,]*/\\1\\2 ${value}/"$'\n'"$prog"
    done
    sed -i -r -e "$prog" fort.4
}

for ntasks in $(seq 1 16); do
    fixfort4 NPROC=${ntasks}
    srun -n ${ntasks} ${MY_OIFS_EXE} > out.${ntasks}
done
