#!/usr/bin/env perl

use strict;

my($in1, $in2, $out) = @ARGV;

open MAT, "<", $in1;
open EP,  "<", $in2;
open NWK, ">", $out;

my @res;
my $num = 0;
while(<EP>){
    chomp;
    my @l = split /\s+/;

    for my $pos(0..$#l){
	$res[$pos] += $l[$pos];
    }
    $num ++;
}

$res[$_] /= $num for 0..$#res;

my %sep;
my @num;
my %tr;
my $id = 1;
while(<MAT>){
    chomp;
    my @l = split;

    my($new, $old);
    for(0..$#l){
	$new = $l[$_];
	$sep{$new}{$old}++ if $old && $old != $new;
	$old = $new;

	$num[$_][$new]++;
    }

    $tr{$l[-1]} = $id;
    $id++;
}

my $nwk = "(1)";
my $sc = 0;
for my $n(sort{$a <=> $b} keys %tr){

    my $old = (
	       map{$_->[0]}
	       sort{$b->[1]<=>$a->[1]}
	       map{[$_, $sep{$n}{$_}]}
	       keys %{$sep{$n}}
	      )[0];

    my $sub;
    if($n==2){
	if($num[$sc-1][$old] - $num[$sc][$n] >= 2 && $num[$sc][$n] >= 2){
	    $sub = '('.$old.':['.sprintf("%.0f", $res[$sc*2]*100).'],'.$n.')';
	}
	else{
	    $sub = '('.$old.','.$n.')';
	}
    }
    elsif($n>2){
	if($num[$sc-1][$old] - $num[$sc][$n] >= 2 && $num[$sc][$n] >= 2){
	    $sub = '('.$old.':['.sprintf("%.0f", $res[$sc*2]*100).'],'.$n.':['.sprintf("%.0f", $res[$sc*2+1]*100).'])';
	}
	elsif($num[$sc-1][$old] - $num[$sc][$n] >= 2){
	    $sub = '('.$old.':['.sprintf("%.0f", $res[$sc*2]*100).'],'.$n.')';
	}
	elsif($num[$sc][$n] >= 2){
	    $sub = '('.$old.','.$n.':['.sprintf("%.0f", $res[$sc*2+1]*100).'])';
	}
	else{
	    $sub = '('.$old.','.$n.')';
	}
    }

    $nwk =~ s/([^\d\[])$old([^\d\]])/$1$sub$2/;
    $sc++;
}

for my $n(keys %tr){
    $nwk =~ s/([^n\d\[])$n([^\d\]])/$1n$tr{$n}$2/;
}
$nwk =~ s/n//g;
$nwk =~ s/^\(//;
$nwk =~ s/\)$//;

print NWK "$nwk;";
