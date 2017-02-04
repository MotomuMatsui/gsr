#!/usr/bin/env perl

use strict;

my($in, $out) = @ARGV;

open MAT, "<", $in;
open NWK, ">", $out;

my %sep;
my %tr;
my $id = 1;
while(<MAT>){
    chomp;
    my @l = split;

    my($new, $old);
    for(@l){
	$new = $_;
	$sep{$new}{$old}++ if $old && $old != $new;
	$old = $new;
    }

    $tr{$l[-1]} = $id;

    $id++;
}

my $nwk = "(1)";
for my $n(sort{$a <=> $b} keys %tr){

    my $old = (
	       map{$_->[0]}
	       sort{$b->[1]<=>$a->[1]}
	       map{[$_, $sep{$n}{$_}]}
	       keys %{$sep{$n}}
	      )[0];

    if($old){
	my $sub = '('.$old.','.$n.')';
	$nwk =~ s/(\D)$old(\D)/$1$sub$2/;
    }
}

for my $n(keys %tr){
    $nwk =~ s/([^n\d])$n(\D)/$1n$tr{$n}$2/;
}
$nwk =~ s/n//g;
$nwk =~ s/^\(//;
$nwk =~ s/\)$//;

print NWK "$nwk;";
