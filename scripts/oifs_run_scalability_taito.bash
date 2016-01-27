for ntasks in $(seq 1 16); do
    fixfort4 NPROC=${ntasks}
    srun -n ${ntasks} ${oifs} > out.${ntasks}
done
