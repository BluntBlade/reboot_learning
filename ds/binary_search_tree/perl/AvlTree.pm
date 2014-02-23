#!/usr/bin/env perl

package AvlTree;

use strict;
use warnings;

use BinarySearchTree;

use constant BALANCED    => 0;
use constant LEFT_HEAVY  => +1;
use constant RIGHT_HEAVY => -1;

my $calc_factor_by_children = sub {
    my $node = shift;
    if (BinarySearchTree::has_left_child($node)) {
        if (BinarySearchTree::has_right_child($node)) {
            my $factor = $node->{left}{factor} + $node->{right}{factor};
            if ($factor == 0 || abs($factor) == 2) {
                $node->{factor} = BALANCED;
            } else {
                $node->{factor} = $factor;
            }
        } else {
            $node->{factor} = $node->{left} + LEFT_HEAVY;
        }
    } if (BinarySearchTree::has_right_child($node)) {
        $node->{factor} = $node->{right} + RIGHT_HEAVY;
    }

    $node->{factor} = BALANCED;
    return $node;
}; # calc_factor_by_children

sub rebalance_after_insert {
    my $node                      = shift;
    my $inserted_before_this_time = shift;

    if ($inserted_before_this_time) {
        return;
    }

    $node->{factor} = BALANCED;

    my $prev = { factor => BALANCED };
    while (not BinarySearchTree::is_root($node)) {
        my $parent = $node->{parent};

        if (BinarySearchTree::is_left_child($node)) {
            if (not BinarySearchTree::has_right_child($parent)) {
                $parent->{factor} = LEFT_HEAVY + abs($node->{factor});
            } else {
                if (abs($node->{factor}) == abs($parent->{right}{factor})) {
                    $parent->{factor} = BALANCED;
                } elsif ($node->{factor} != BALANCED) {
                    $parent->{factor} = LEFT_HEAVY + abs($prev->{factor});
                } else {
                    $parent->{factor} = RIGHT_HEAVY - abs($prev->{factor});
                }
            } # if
            
            if ($parent->{factor} > LEFT_HEAVY) {
                if (BinarySearchTree::is_right_child($prev)) {
                    # the LR case
                    my (undef, $right_child) = BinarySearchTree::left_rotate($node);
                    $calc_factor_by_children->($node);
                    $calc_factor_by_children->($right_child);
                    $node = $right_child;
                }

                # the LL case
                my (undef, $left_child) = BinarySearchTree::right_rotate($parent);
                $calc_factor_by_children->($parent);
                $calc_factor_by_children->($left_child);
            } # if
        } else {
            if (not BinarySearchTree::has_left_child($parent)) {
                $parent->{factor} = RIGHT_HEAVY - abs($node->{factor});
            } else {
                if (abs($node->{factor}) == abs($parent->{left}{factor})) {
                    $parent->{factor} = BALANCED;
                } elsif ($node->{factor} != BALANCED) {
                    $parent->{factor} = RIGHT_HEAVY - abs($prev->{factor});
                } else {
                    $parent->{factor} = LEFT_HEAVY + abs($prev->{factor});
                }
            }
            
            if ($parent->{factor} < RIGHT_HEAVY) {
                if (BinarySearchTree::is_left_child($prev)) {
                    # the RL case
                    my (undef, $left_child) = BinarySearchTree::right_rotate($node);
                    $calc_factor_by_children->($node);
                    $calc_factor_by_children->($left_child);
                    $node = $left_child;
                }

                # the RR case
                my (undef, $right_child) = BinarySearchTree::left_rotate($parent);
                $calc_factor_by_children->($parent);
                $calc_factor_by_children->($right_child);
            } # if
        } # if

        if (BinarySearchTree::is_root($node)) {
            last;
        }

        $prev = $node;
        $node = $node->{parent};
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

my $in = [100, 50, 75, 60, 65, 25, 150, 175, 12, 200, 1, 2, 3];
my $tree = __PACKAGE__->new(sub { $_[0] <=> $_[1] });

for my $i (@$in) {
    print STDERR "$i\n";
    $tree->insert($i);
    dump($tree->{root});
} # for

1;

__END__
