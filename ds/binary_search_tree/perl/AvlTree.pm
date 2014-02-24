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
    if (not BinarySearchTree::has_left_child($node)) {
        if (not BinarySearchTree::has_right_child($node)) {
            # the node is a leaf
            $node->{factor} = BALANCED;
            return $node;
        }

        $node->{factor} = RIGHT_HEAVY;
        return $node;
    }
    
    if (not BinarySearchTree::has_right_child($node)) {
        $node->{factor} = LEFT_HEAVY;
        return $node;
    }

    if (abs($node->{left}{factor}) == abs($node->{right}{factor})) {
        $node->{factor} = BALANCED;
        return $node;
    }

    if ($node->{left}{factor} == 0) {
        $node->{factor} = RIGHT_HEAVY;
        return $node;
    }

    $node->{factor} = LEFT_HEAVY;
    return $node;

    return $node;
}; # calc_factor_by_children

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
            $parent->{factor} += LEFT_HEAVY;

            if ($parent->{factor} > LEFT_HEAVY) {
                my $prev_factor = $prev->{factor};

                if (BinarySearchTree::is_right_child($prev)) {
                    # the LR case
                    BinarySearchTree::left_rotate($node);
                    BinarySearchTree::right_rotate($parent);

                    if ($prev_factor == LEFT_HEAVY) {
                        $parent->{factor} = RIGHT_HEAVY;
                        $node->{factor} = BALANCED;
                        $prev->{factor} = BALANCED;
                    } elsif ($prev_factor == RIGHT_HEAVY) {
                        $parent->{factor} = BALANCED;
                        $node->{factor} = LEFT_HEAVY;
                        $prev->{factor} = BALANCED;
                    } else {
                        $parent->{factor} = BALANCED;
                        $node->{factor} = BALANCED;
                        $prev->{factor} = BALANCED;
                    }
                } else {
                    # the LL case
                    BinarySearchTree::right_rotate($parent);

                    $parent->{factor} = BALANCED;
                    $node->{factor} = BALANCED;
                }

                last;
            } # if
        } else {
            $parent->{factor} += RIGHT_HEAVY;
            
            if ($parent->{factor} < RIGHT_HEAVY) {
                my $prev_factor = $prev->{factor};

                if (BinarySearchTree::is_left_child($prev)) {
                    # the RL case
                    BinarySearchTree::right_rotate($node);
                    BinarySearchTree::left_rotate($parent);

                    if ($prev_factor == RIGHT_HEAVY) {
                        $parent->{factor} = LEFT_HEAVY;
                        $node->{factor} = BALANCED;
                        $prev->{factor} = BALANCED;
                    } elsif ($prev_factor == LEFT_HEAVY) {
                        $parent->{factor} = BALANCED;
                        $node->{factor} = RIGHT_HEAVY;
                        $prev->{factor} = BALANCED;
                    } else {
                        $parent->{factor} = BALANCED;
                        $node->{factor} = BALANCED;
                        $prev->{factor} = BALANCED;
                    }
                } else {
                    # the RR case
                    BinarySearchTree::left_rotate($parent);

                    $parent->{factor} = BALANCED;
                    $node->{factor} = BALANCED;
                }

                last;
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

my $in = [100, 50, 75, 60, 65, 25, 150, 175, 12, 200, 1, 2, 3, 4, 5, 6, 7, 8, 9];
my $tree = __PACKAGE__->new(sub { $_[0] <=> $_[1] });

for my $i (@$in) {
    print STDERR "$i\n";
    $tree->insert($i);
    dump($tree->{root});
} # for

1;

__END__
