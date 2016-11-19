#!/bin/bash
rm liveplot.dat
rm liveplot.tmp

echo "Initiasing data. Please wait 10 seconds..."

./resetStats.sh > /dev/null
sleep 5

getdata()
{
    while [ 1 ]
    do
        ./getStats.sh | ./liveplot.pl
#        cat liveplot.dat
        sleep 5
    done
}

getdata &
# allow a couple of datapoints to arrive before plotting
sleep 5

echo "Here comes the plot..."
gnuplot liveplot.gnu

# kill getdata when we exit
kill -- -$$

