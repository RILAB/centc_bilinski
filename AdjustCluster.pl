#!/usr/bin/perl
#Script to read in data frame with subgenome and cluster size and combine based on criteria
#for i in {1..20}; do BP=$(( $i*1000 )); perl AdjustCluster.pl $BP 10000;  done
#code to execute it for a lot of diff distances
use strict; 
use warnings;

die "usage: AdjustCluster.pl <Dist Cutoff> <clust size>" unless @ARGV==2;

my $distcut = $ARGV[0];
my $clustsize = $ARGV[1];

open(ORIG, "<ClusterNeighbors_forscript.csv");
#open(out, ">out_$distcut.$clustsize");

my @file=<ORIG>;
my @cluster = split(/,/, $file[0]);
my @bpcentc = split(/,/, $file[5]);
my @distnext = split(/,/, $file[6]);
my @subgenome = split(/,/, $file[7]);
close ORIG;

my @clustersub = (); # array for clusters in each subgenome
my @bpsub = (); # array for bp in each subgenome
my $sumbp = 0;
my $pos = 0;

foreach my $i (1..$#distnext) { #walk through distance array, start from 1 not 0
	$sumbp += $bpcentc[$i];
	if ( ($distnext[$i]=~m/NA/ ) || ($distnext[$i] >= $distcut) || ( $subgenome[$i] != $subgenome[$i-1]) ) {  #lots of ors, needs to meet these criteria		
		if ($sumbp >= $clustsize) { #is it bigger than current cluster size
			$bpsub[$subgenome[$i]]+=$sumbp; #add to either 0 first or second part
			$clustersub[$subgenome[$i]]++;
			#print "$cluster[$i]\t$sumbp\n"; # added to subgenome $subgenome[$i]\n";
		}
		$sumbp = 0; #reset sumbp so you can move to next cluster
	}		
}

for my $j (0..2){
	print "$bpsub[$j]\t$clustersub[$j]\t";
}
print "\n";