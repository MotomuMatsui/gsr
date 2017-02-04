#!/usr/bin/env perl

use strict;

my($input, $fst, $txt) = @ARGV;

open RAW, "<", $input;
open FST, ">", $fst;
open TXT, ">", $txt;

local $/ = "\n>";
my $id = 1;
while(<RAW>){
    chomp;
    my ($head, $seq) = split /\n/, $_, 2;
    $head =~ s/^>//;
    $seq  =~ s/[^a-zA-Z]//g;
    $seq  =~ tr/bzBZ/deDE/;
    $seq  =~ s/[xXuU]//g;

    my @head = split /\|/, $head;

    printf TXT "%s", $id;
    printf TXT "\t%s", $_ for @head;
    printf TXT "\n";

    printf FST ">%s\n%s\n", $id, $seq;

    $id ++;
}
