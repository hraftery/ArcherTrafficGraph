# Life Traffic Graph for TP-Link Archer C7 routers

These scripts provides a live graph of network traffic passing through a TP-Link Archer C7 AC1750.

After years living with a Billion that has a live network graph in its standard web interface, I've moved to an Archer C7 and miss the graph dearly. Whenever there's a speed issue or a download quota issue the first thing I want to do is jump on to the router and see which device is slamming it. The Archer C7 web interface does provide some numerical statistics, but they are extremely difficult to make sense of since there's no sense of progress over time or relative magnitude.

So today I set about giving the Archer a graph. This is what I've hacked together. It's extremely rough, but the results are terrific and I figure with the community's help it could be so much better.

## Dependencies

   * Unix environment (developed on OS X, likely fine on Linux)
   * gnuplot
   * Perl
   * curl

## Quick Start

   1. Run `liveplot.sh` from the command line.
   1. Wait for the graph to appear.
   1. If the graph appears, then hallelujah, you're done.
   1. In the extremely likely scenario that it doesn't, keep reading.

## Troubleshooting

   * All scripts have to be executable. This ought to do it:
      * `chmod +x liveplot.sh liveplot.pl getStats.sh resetStats.sh`
   * The router's IP address is hardcoded. If yours is not 192.168.0.1, then update `getStats.sh` and `resetStats.sh`.
   * I haven't figured out the router's authentication method, so it's hardcoded for now.
       * Browse to your router's webpage and sniff the network traffic (eg. in Wireshark).
       * Look for the HTTP GET packet sent to the router after you login.
       * Copy both the first part of the URL after the IP address, and the Cookie string.
           * Eg. the "VXKQJFBBBVYUWYEA" from "http://192.168.0.1/VXKQJFBBBVYUWYEA/userRpm/..."
           * Eg. the "Authorization=Basic%20YWRtaW46MjEyMzJmMjk3YTU3YTVhNzQzODk0YTBlNGE4MDFmYzM%3D" from "Cookie:"
           * Don't get too excited that I just gave away my password.
       * Paste the results into both `getStats.sh` and `resetStats.sh`
       * Try `liveplot.sh` again.

## How It Works

`liveplot.sh` is the entry point. It first runs `resetStats.sh` which makes a curl request to the router which mimics pressing the "Reset Statistics" button. Then, every 5 seconds it runs `getStats.sh`, which is effectively what the browser does when you're viewing the statistics page. The resulting HTML page is piped to `liveplot.pl` which parses it and finds the array of statistics. From that it pulls out all the IP addresses and their total bytes (I ignored "current" bytes because it doesn't seem reliable).

`liveplot.pl` then compares the total bytes to the total bytes from last time it was run (which are stored in `liveplot.tmp`. It then calculates the delta and writes the results to `liveplot.dat`, pushing any old data back in time.

Meanwhile `liveplot.sh` runs gnuplot in parallel, which executes `liveplot.gnu`. It reads `liveplot.dat`, plots it and then repeats every 5 seconds.

All together this little concert pops up a gnuplot window (running in AquaTerm on my machine) which shows the average kB/s, every 5 seconds for the last 100 seconds, for all IP addresses the router knows about.

## Contact

I welcome all comments, suggestions, bug fixes and stories of use.

Heath Raftery
<a href="mailto:heath@newie.ventures">heath@newie.ventures</a>
