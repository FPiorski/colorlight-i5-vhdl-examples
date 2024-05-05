set style histogram
binwidth=5
bin(x,width)=width*floor(x/width)

set boxwidth 0.85*binwidth
set style fill solid 0.3

stats filename prefix "A" nooutput

set title sprintf("Max w\\\_clk\\\_tmds frequency histogram, %d data points", A_records);
set xlabel "Frequency [MHz]"
set ylabel "No. of occurances"

plot filename using (bin($1,binwidth)):(1.0) smooth freq with boxes title ''
