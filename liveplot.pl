#!/opt/local/bin/perl -w

use strict;
use warnings;

use Storable;

my $TMP_FILE = 'liveplot.tmp';
my $DAT_FILE = 'liveplot.dat';
my $TIME_STEP = 5;


#Retrieve the byte hash from last invocation
my %oldBytes;
%oldBytes = %{retrieve($TMP_FILE)} if -e $TMP_FILE;

while(<>)
{
    last if $_ =~ /statList/; # don't do anything until we get to the statList array
}

my %bytes;

while(<>)
{
    last if $_ =~ /;/; # finish at the end of the statList array
    #Otherwise, pasrse each row which has content: index, IP, MAC, packets, bytes, etc.
    my @fields = split /, /;
#    print "$fields[1]\t$fields[4]\n";
    @bytes{substr $fields[1], 1, -1} = $fields[4];
}

#print "\nMap\n";
#print "$_ $bytes{$_}\n" for (sort keys %bytes);

#store for next invocation
store \%bytes, $TMP_FILE;

#calculate delta between old bytes and this bytes
my %deltaBytes;
for (keys %bytes)
{
    if(exists $oldBytes{$_})
    {
        $deltaBytes{$_} = ($bytes{$_} - $oldBytes{$_}) / (1024 * $TIME_STEP);
    }
    else
    {
        $deltaBytes{$_} = $bytes{$_} / (1024 * $TIME_STEP);
    }
}

#print "\nDelta\n";
#print "$_ $deltaBytes{$_}\n" for (sort keys %deltaBytes);

# Write or update the gnuplot dat file
my $datf; # file handle
my @dat;  # file contents

if(-e $DAT_FILE)
{
    open($datf, '<', $DAT_FILE);
    $dat[0] = [ split " ", <$datf> ]; # header contains all the ips
    shift @{ $dat[0] }; # get rid of the "time" column
    for(my $i = 1; <$datf>; $i++)
    {
        $dat[$i] = [ split ];
        shift @{ $dat[$i] }; # get rid of the "time" column
    }
    close($datf);
}
else # from existing dat file so start from scratch
{
    @dat[0] = [ sort keys %deltaBytes ];
}

#insert the new data
unshift @dat, $dat[0]; #make room at the start but preseve the header row
$dat[1] = [ () ]; #blank new row

for my $i ( 0 .. $#{$dat[0]} )
{
    #print "pushing value ($deltaBytes{$dat[0][$i]}) for key ($dat[0][$i]).\n";
    push @{ $dat[1] }, $deltaBytes{$dat[0][$i]};
}

pop @dat if $#dat > 21; # limit to last 21 values + header row

open $datf, '>', $DAT_FILE;

for my $i ( 0 .. $#dat )
{
    if($i == 0)
    {
        print { $datf } "time(s) ";
    }
    else
    {
        print { $datf } ($i-1)*$TIME_STEP . " ";
    }

    for my $j ( 0 .. $#{$dat[$i]} ) # oh Perl...
    {
        print { $datf } "$dat[$i][$j] ";
        #print "$dat[$i][$j] ";
    }
    print { $datf } "\n";
    #print "\n";
}

close $datf;

