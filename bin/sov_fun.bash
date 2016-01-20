sov () {
    sinfo -N -h -o '%5n %T' "$@" | uniq -w 5 | awk '
      {s="?"}
      /idle/{s="-"}
      /mixed/{s="x"}
      /allocated/{s="X"}
      {printf s}
      int(NR/10)==NR/10{printf " "}
      int(NR/50)==NR/50{print ""}
      int(NR/500)==NR/500{print ""}
      END{print ""}'
}
