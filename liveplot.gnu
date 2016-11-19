datafile = 'liveplot.dat'
stats datafile skip 1 nooutput
set xrange [0:100]
set autoscale y
set xlabel "Time (s)"
set ylabel "kB/s"
plot for [IDX=2:STATS_columns] datafile using 1:IDX with lines t columnheader(IDX)
pause 5
reread

