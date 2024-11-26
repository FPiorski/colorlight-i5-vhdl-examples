#!/usr/bin/bash

usage1="Usage: $0 number_of_runs output_file"
usage2="Usage: $0 input_file"

if [ $# -lt 1 ]
then
    echo $usage1
    echo "or"
    echo $usage2
    exit 1
fi

fn=$1
if [ $# -eq 2 ]
then
    fn=$2
    echo "Preforming $1 runs"
    echo -n "" > $fn

    for i in $(seq 1 1 $1)
    do
        rm *_out.config
        r=$(make just_pnr 2>&1 | grep "Max frequency for clock" | grep "w_tmds_clk" | tail -n1)
        echo "Run $i: $r"
        m=$(echo $r | grep -Eo '[+-]?[0-9]+([.][0-9]+)?' | head -n1)
        echo "$m" >> $fn
    done
fi

awk '{for(i=1;i<=NF;i++) {sum[i] += $i; sumsq[i] += ($i)^2}}
      END {for (i=1;i<=NF;i++)
        {printf "Data points: %i; Average: %f; Standard deviation: %f \n",
        NR, sum[i]/NR, sqrt((sumsq[i]-sum[i]^2/NR)/NR)}}' $fn

gnuplot --persist -e "filename='$fn'" hist.gp
