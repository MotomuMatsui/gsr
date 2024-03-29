#!/usr/bin/env perl

use strict;

my($in, $out) = @ARGV;

open IN,  "<", $in;
open OUT, ">", $out;

my %blast;
my %entry;
while(<IN>){
    my ($x, $y, $evalue, $bit) = (split /\t/)[0,1,10,11];

    $blast{$x}{$y} = ($blast{$x}{$y} >= $bit)? $blast{$x}{$y}: $bit;

    $entry{$x} = 1;
    $entry{$y} = 1;
}

my @entry = sort{$a <=> $b}keys %entry;
my $last  = $entry[-1];

for my $x(@entry){
    for my $y(@entry){
	my $x_y = $blast{$x}{$y};
	my $y_x = $blast{$y}{$x};
	my $x_x = $blast{$x}{$x};
	my $y_y = $blast{$y}{$y};

	my $cmp  = ($x_y >= $y_x)? $x_y: $y_x;
	my $self = ($x_x >= $y_y)? $x_x: $y_y;

	my $ans  = ($x == $y)?  1 :
	           ($self > 0)? $cmp/$self: 0;

        printf OUT "%.5f", $ans;
	printf OUT ($y==$last)? "\n": " ";
    }
}
