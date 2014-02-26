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
                    BinarySearchTree::rotate_to_left($node);
                    BinarySearchTree::rotate_to_right($parent);

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
                    BinarySearchTree::rotate_to_right($parent);

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
                    BinarySearchTree::rotate_to_right($node);
                    BinarySearchTree::rotate_to_left($parent);

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
                    BinarySearchTree::rotate_to_left($parent);

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

sub rebalance_after_delete {
    my $deleting_node = shift;
    my $deleted_node  = shift;
    my $deleted_pos   = shift;

    if ($deleted_pos == BinarySearchTree::ROOT) {
        return;
    }

    my $prev     = $deleted_node;
    my $prev_pos = $deleted_pos;
    my $node     = $deleted_node->{parent};
    while (1) {
        if ($prev_pos == BinarySearchTree::LEFT_CHILD) {
            $node->{factor} -= LEFT_HEAVY;
        } else {
            $node->{factor} -= RIGHT_HEAVY;
        }

        if ($node->{factor} > LEFT_HEAVY) {
            ### lean to left too much
            ### unbalancing
 
            my $left_child = $node->{left};
            my $has_left_child = BinarySearchTree::has_left_child($left_child);
            my $has_right_child = BinarySearchTree::has_right_child($left_child);

            if ($has_left_child) {
                BinarySearchTree::rotate_to_right($node);

                if ($has_right_child) {
                    $node->{factor} = LEFT_HEAVY;
                    $left_child->{factor} = RIGHT_HEAVY;
                } else {
                    $node->{factor} = BALANCED;
                    $left_child->{factor} = BALANCED;
                }

                $node = $left_child;
            } elsif ($has_right_child) {
                my (undef, $lr_grandchild) = BinarySearchTree::rotate_to_left($left_child);
                BinarySearchTree::rotate_to_right($node);

                $node->{factor} = BALANCED;
                $left_child->{factor} = BALANCED;
                $lr_grandchild->{factor} = BALANCED;

                $node = $lr_grandchild;
            }
        } elsif ($node->{factor} < RIGHT_HEAVY) {
            ### lean to right too much
            ### unbalancing

            my $right_child = $node->{right};
            my $has_right_child = BinarySearchTree::has_right_child($right_child);
            my $has_left_child = BinarySearchTree::has_left_child($right_child);

            if ($has_right_child) {
                BinarySearchTree::rotate_to_left($node);

                if ($has_left_child) {
                    $node->{factor} = RIGHT_HEAVY;
                    $right_child->{factor} = LEFT_HEAVY;
                } else {
                    $node->{factor} = BALANCED;
                    $right_child->{factor} = BALANCED;
                }

                $node = $right_child;
            } elsif ($has_right_child) {
                my (undef, $rl_grandchild) = BinarySearchTree::rotate_to_right($right_child);
                BinarySearchTree::rotate_to_right($node);

                $node->{factor} = BALANCED;
                $right_child->{factor} = BALANCED;
                $rl_grandchild->{factor} = BALANCED;

                $node = $rl_grandchild;
            }
        }

        if (BinarySearchTree::is_root($node)) {
            ### it is the root 
            last;
        }

        if ($node->{factor} == BALANCED) {
            $prev = $node;
            $prev_pos = BinarySearchTree::is_left_child($node) ? BinarySearchTree::LEFT_CHILD
                                                               : BinarySearchTree::RIGHT_CHILD
                                                               ;
            $node = $node->{parent};
            next;
        }

        # rebalanced
        last;
    } # while
} # rebalance_after_delete

our @ISA = qw(BinarySearchTree);

sub insert {
    my $self = shift;
    my $data = shift;

    my @ret  = $self->BinarySearchTree::insert($data);
    return rebalance_after_insert(@ret);
} # insert

sub delete {
    my $self = shift;
    my $data = shift;

    my @ret  = $self->BinarySearchTree::delete($data);
    return rebalance_after_delete(@ret);
} # delete

use Data::Dump qw(dump);

my $in = [100, 50, 75, 60, 65, 25, 150, 175, 12, 200, 1, 2, 3, 4, 5, 6, 7, 8, 9];
my $tree = __PACKAGE__->new(sub { $_[0] <=> $_[1] });

for my $i (@$in) {
    print STDERR "$i\n";
    $tree->insert($i);
    dump($tree->{root});
    print STDERR "-" x 80, "\n";
} # for

print STDERR "=" x 80, "\n";

for my $i (@$in) {
    print STDERR "$i\n";
    $tree->delete($i);
    dump($tree->{root});
    print STDERR "-" x 80, "\n";
} # for

1;

__END__
