#!/usr/bin/env perl

package AvlTree;

use strict;
use warnings;

use BinarySearchTree;

use constant BALANCED    => 0;
use constant LEFT_HEAVY  => +1;
use constant RIGHT_HEAVY => -1;

sub rebalance_after_insert {
    my $node                      = shift;
    my $inserted_before_this_time = shift;

    if ($inserted_before_this_time) {
        return;
    }

    $node->{factor} = BALANCED;

    my $prev = undef;
    while (not BinarySearchTree::is_root($node)) {
        my $parent = $node->{parent};

        if (BinarySearchTree::is_left_child($node)) {
            if (not BinarySearchTree::has_right_child($parent)) {
                $parent->{factor} = LEFT_HEAVY + abs($node->{factor});
            } else {
                my $factor_sum = $node->{factor} + $parent->{right}{factor};
                if ($factor_sum == 0 || abs($factor_sum) == 2) {
                    $parent->{factor} = BALANCED;
                } else {
                    $parent->{factor} = $factor_sum;
                }
            } # if
            
            if ($parent->{factor} > LEFT_HEAVY) {
                if (BinarySearchTree::is_right_child($prev)) {
                    # the LR case
                    BinarySearchTree::left_rotate($node);
                }

                # the LL case
                BinarySearchTree::right_rotate($parent);
            } # if
        } else {
            if (not BinarySearchTree::has_left_child($parent)) {
                $parent->{factor} = RIGHT_HEAVY - abs($node->{factor});
            } else {
                my $factor_sum = $node->{factor} + $parent->{left}{factor};
                if ($factor_sum == 0 || abs($factor_sum) == 2) {
                    $parent->{factor} = BALANCED;
                } else {
                    $parent->{factor} = $factor_sum;
                }
            }
            
            if ($parent->{factor} < RIGHT_HEAVY) {
                if (BinarySearchTree::is_left_child($prev)) {
                    # the RL case
                    BinarySearchTree::right_rotate($node);
                }

                # the RR case
                BinarySearchTree::left_rotate($parent);
            } # if
        } # if

        $prev = $node;
        $node = $parent;
    } # while
} # rebalance_after_insert

our @ISA = qw(BinarySearchTree);

sub insert {
    my $self = shift;
    my $data = shift;

    my @ret  = $self->BinarySearchTree::insert($data);
    return rebalance_after_insert(@ret);
} # insert

use Data::Dump qw(dump);

my $in = [100, 50, 75];
my $tree = __PACKAGE__->new(sub { $_[0] <=> $_[1] });

for my $i (@$in) {
    print STDERR "$i\n";
    $tree->insert($i);
    dump($tree->{root});
} # for

1;

__END__
