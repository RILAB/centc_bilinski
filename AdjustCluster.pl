#!/usr/bin/perl
#Script to read in data frame with subgenome and cluster size and combine based on criteria
use strict; #use warnings;

die "usage: AdjustCluster.pl <Dist Cutoff> <clust size>" unless @ARGV==2;

my $distcut = $ARGV[0];
my $clustsize = $ARGV[1];

open(orig, "<ClusterNeighbors_forscript.csv");
#open(out, ">out_$distcut.$clustsize");

my @bpcentc;
my @distnext;
my @subgenome;
my @cluster;

while(<orig>){
	if ($_ =~ m/Cluster/){
		@cluster = split(/,/, $_);
	}
#	if ($_ =~ m/Chr/){
#		my @chr = split(/,/, $_);
#	}
#	if ($_ =~ m/Start/){
#		my @Start = split(/,/, $_);
#	}
#	if ($_ =~ m/Stop/){
#		my @Stop = split(/,/, $_);
#	}
#	if ($_ =~ m/Average/){
#		my @Average = split(/,/, $_);
#	}
	if ($_ =~ m/BPCentC/){
		@bpcentc = split(/,/, $_);
	}	
	if ($_ =~ m/DistancetoNext/){
		@distnext = split(/,/, $_);
	}	
	if ($_ =~ m/Subgenome/){
		@subgenome = split(/,/, $_);
	}	
}

my $sub0 = 0;
my $sub1 = 0;
my $sub2 = 0;
my $bpsub0 = 0;
my $bpsub1 = 0;
my $bpsub2 = 0;
my $sumbp = 0;
my $pos = 0;
my $crap = 0;


foreach my $ID (@distnext) {
	if ($distnext[$pos] =~ m/Distance/){#skip first column
		$sumbp=0;
		$pos++;
	} elsif ($distnext[$pos] =~ m/NA/){ #NA is end of chr, add up current tally to subgenome
		if ($subgenome[$pos] == 0) { #add bp to its total subgenome bp and its count to subgenome count
					$bpsub0 = $bpsub0 + $sumbp;
					$sub0++;
				}
				if ($subgenome[$pos] == 1) {
					$bpsub1 = $bpsub1 + $sumbp;
					$sub1++;
				}
				if ($subgenome[$pos] == 2) {
					$bpsub2 = $bpsub2 + $sumbp;
					$sub2++;
				}
		$sumbp=0; #end of chromosome, reset total bp
		$pos++; #move to next cluster
	} else { 
		my $tempbp = $bpcentc[$pos]; #set tempbp to the current position bp
		if ($distnext[$pos] >= $distcut) { #if the current cluster is far away from next one
			$sumbp = $sumbp + $tempbp;  #add its value to the running total
			if ($sumbp >= $clustsize) { #if the current total is bigger than our cluster size of interest
				if ($subgenome[$pos] == 0) { #add bp to its total subgenome bp and its count to subgenome count
					$bpsub0 = $bpsub0 + $sumbp;
					$sub0++;
				}
				if ($subgenome[$pos] == 1) {
					$bpsub1 = $bpsub1 + $sumbp;
					$sub1++;
				}
				if ($subgenome[$pos] == 2) {
					$bpsub2 = $bpsub2 + $sumbp;
					$sub2++;
				}
			$sumbp = 0; #reset sumbp so you can move to next cluster
			}
		}		
		elsif($distnext[$pos] <= $distcut) { #if distance is less than our cutoff, its tandem, and total up
			$sumbp = $sumbp + $tempbp;
		}
		$pos++;
	}
}

print "Sub0: $sub0  bp: $bpsub0\nSub1: $sub1  bp: $bpsub1\nSub2: $sub2  bp: $bpsub2\n";
my $bptot = $bpsub0 + $bpsub1 + $bpsub2;
print "Total bp: $bptot\n";

#foreach (@cluster){
#	print "$_\n";
#}
	
	
	
			