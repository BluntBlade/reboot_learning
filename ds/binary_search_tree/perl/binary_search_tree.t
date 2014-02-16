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
$tree->insert(12);
$tree->in_order(sub { printf "%d\n", $_[0] });

my $predecessor = BinarySearchTree::predecessor($tree->{root});
printf "the predecessor of the root is %d\n", $predecessor->{data};

$predecessor = BinarySearchTree::predecessor($predecessor);
printf "the predecessor of the predecessor of the root is %d\n", $predecessor->{data};

my $successor = BinarySearchTree::successor($tree->{root});
printf "the successor of the root is %d\n", $successor->{data};

$successor = BinarySearchTree::successor($successor);
printf "the successor of the successor of the root is %d\n", $successor->{data};

exit 0;

my $rand_tree = BinarySearchTree->new(sub { $_[0] <=> $_[1]; });
for my $i (1..100) {
    $rand_tree->insert(rand(1000));
    print "-" x 80, "\n";
    $rand_tree->in_order(sub { printf "%d\n", $_[0] });
} # for
