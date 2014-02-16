#!/usr/bin/env perl

use strict;
use warnings;

require "binary_search_tree.pm";

my $tree = BinarySearchTree->new(sub { $_[0] <=> $_[1]; });
$tree->insert(10);
$tree->insert(5);
$tree->insert(9);
$tree->insert(15);
$tree->insert(4);
$tree->insert(9);
$tree->insert(21);
$tree->insert(1);
$tree->insert(19);
$tree->insert(20);
$tree->insert(18);
$tree->in_order(sub { printf "%d\n", $_[0] });

my $rand_tree = BinarySearchTree->new(sub { $_[0] <=> $_[1]; });
for my $i (1..100) {
    $rand_tree->insert(rand(1000));
    print "-" x 80, "\n";
    $rand_tree->in_order(sub { printf "%d\n", $_[0] });
} # for
