#!/usr/bin/env perl

use strict;

my(
    $ssg, # Sequence similarity graph
    $scl, # Graph Splitting output
    $nwk, # GS tree
    $ept, # Edge Perturbation output
    $epn, # GS tree with EP values
    $ep,  # Edge Perturbation program (R script)
    $sc2nwk_EP, # matrix-to-newick Converter
    $dup  # duplication number
) = @ARGV;

# Reading GS Tree (newick format)
open GS, $nwk;
my $gs_nwk; {
    local $/ = "";
    $gs_nwk = <GS>;
    chomp $gs_nwk;
    $gs_nwk =~ s/\:[^\,\)\;]+//g;
    $gs_nwk =~ s/\;//;
}
my $branch = &branch($gs_nwk);

# Edge Perturbation
if($dup > 0){
    open OUTPUT, ">", $ept;
    
    for(1..$dup){
        my $rand   = 1e15 * rand;
        my $p_raw = $nwk."_".$rand.'_cl.txt';
        
        system("R --slave --args $ssg $p_raw < $ep > /dev/null");
        
        # Topological alignment
        open MAT, $p_raw;
        my %cluster;
        my %sep;
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
                
                push @{$cluster{$_+1}{$new}}, $id;
            }
            
            $tr{$l[-1]} = $id;
            
            $id++;
        }

        my @match;
        for my $n(sort{$a <=> $b} keys %tr){
            
            next if $n == 1;
            
            my $old = (
                map{$_->[0]}
                sort{$b->[1]<=>$a->[1]}
                map{[$_, $sep{$n}{$_}]}
                keys %{$sep{$n}}
                )[0];
            
            my $before = join("-", sort{$a<=>$b}@{$cluster{$n-1}{$old}});
            my $afterR = join("-", sort{$a<=>$b}@{$cluster{ $n }{ $n }});
            my $afterL; {
                my %afterR;
                for(@{$cluster{$n}{$n}}){
                    $afterR{$_} = 1;
                }
                my @afterL;
                for(@{$cluster{$n-1}{$old}}){
                    push @afterL, $_ unless $afterR{$_};
                }
                $afterL = join("-", sort{$a<=>$b}@afterL);
            }
            
            if($n==2){
                push @match, ($branch->{$afterL} && $branch->{$afterR})? 1: 0;
                push @match, ($branch->{$afterL} && $branch->{$afterR})? 1: 0;
            }
            else{
                push @match, ($branch->{$afterL})? 1: 0;
                push @match, ($branch->{$afterR})? 1: 0;
            }
        }

        printf OUTPUT "%s\n", join(" ", @match);
        
        unlink $p_raw;
    }
    
    system("perl $sc2nwk_EP $scl $ept $epn");
}
else{
    system("cp $nwk $epn");
}

sub branch{
    my $nwk    = shift;
    my $branch = shift;

    if($nwk =~ /\,/){
        my($l, $r) = &partition($nwk);

        $branch->{&nwk2seq($l)} = 1;
        $branch->{&nwk2seq($r)} = 1;

        $branch = &branch($l, $branch) if $l =~ /\,/;
        $branch = &branch($r, $branch) if $r =~ /\,/;
    }

    return $branch;
}

sub nwk2seq{
    my $nwk = shift;
    my @nwk = split /[\(\)\,]+/, $nwk;
    shift @nwk if $#nwk > 0;

    return join('-', sort{$a<=>$b}@nwk);
}

sub partition{
    my $nwk = shift;
    $nwk =~ s/^\(//;
    $nwk =~ s/\)$//;

    my @nwk = split //, $nwk;
    my @l;

    my $mode = ($nwk[0]  eq '(')? "normal": "sole";

    my $s = 0;
    my $c = 0;
    for(@nwk){
        ++ $c if /\(/;
        -- $c if /\)/;

        $l[$s] .= $_;

        $s=1 if($mode eq "normal" && $c == 0);
        $s=1 if($mode eq "sole"   && $_ eq ",");
    }

    my ($l, $r) = @l;
    $l =~ s/^\,//;
    $r =~ s/^\,//;
    $l =~ s/\,$//;
    $r =~ s/\,$//;

    return($l, $r);
}
