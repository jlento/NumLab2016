# Batch job resource request specifications

ntasks=2
nthreads=2
rtime=10
partition=test

# Set up input files

sdir=${USERAPPL}/oifs/src
ver=oifs38r1
cd ${WRKDIR}
tar --strip-components=1 -x -f ${sdir}/${ver}.t*gz ${ver}/t21test
cd t21test

# Modify fort.4 namelist

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
export -f fixfort4
fixfort4 NPROC=${ntasks} LREFOUT=true NSTOP=144

# Se the number OpenMP threads

export OMP_NUM_THREADS=${nthreads}

# Create a batch job script and submit it

sbatch -n ${ntasks} -c ${nthreads} -t ${rtime} -p ${partition} <<EOF
#!/bin/bash
srun ${OIFS_DEST_DIR}/oifs/bin/master.exe -e epc8
EOF
