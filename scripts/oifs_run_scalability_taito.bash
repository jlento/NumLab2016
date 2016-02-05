export OMP_NUM_THREADS=1
sbatch -N 1 --exclusive  -t ${rtime} -p ${partition} <<EOF
#!/bin/bash
for ntasks in 1 2 4 8 16; do
    fixfort4 NPROC=\${ntasks} LREFOUT=false NSTOP=6
    srun -n \${ntasks} -o out.\${ntasks} \
        ${OIFS_DEST_DIR}/oifs/bin/master.exe -e epc8
done
EOF
