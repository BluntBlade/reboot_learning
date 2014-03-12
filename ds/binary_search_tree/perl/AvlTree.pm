#!/usr/bin/env perl

package AvlTree;

use strict;
use warnings;

use BinarySearchTree;

use constant ROOT        => BinarySearchTree::ROOT;
use constant LEFT_CHILD  => BinarySearchTree::LEFT_CHILD;
use constant RIGHT_CHILD => BinarySearchTree::RIGHT_CHILD;

use constant BALANCED    => 0;
use constant LEFT_HEAVY  => +1;
use constant RIGHT_HEAVY => -1;

sub rebalance_after_inserted {
    my $node                      = shift;
    my $inserted_before_this_time = shift;

    if ($inserted_before_this_time) {
        return;
    }

    $node->{factor} = BALANCED;

    my $prev = undef;
    while (not $node->is_root()) {
        my $parent = $node->{parent};

        if ($node->is_left_child()) {
            $parent->{factor} += LEFT_HEAVY;

            if ($parent->{factor} > LEFT_HEAVY) {
                my $prev_factor = $prev->{factor};

                if ($prev->is_right_child()) {
                    # the LR case
                    $node->rotate_to_left();
                    $parent->rotate_to_right();

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
                    $parent->rotate_to_right();

                    $parent->{factor} = BALANCED;
                    $node->{factor} = BALANCED;
                }

                last;
            } # if
        } else {
            $parent->{factor} += RIGHT_HEAVY;
            
            if ($parent->{factor} < RIGHT_HEAVY) {
                my $prev_factor = $prev->{factor};

                if ($prev->is_left_child()) {
                    # the RL case
                    $node->rotate_to_right();
                    $parent->rotate_to_left();

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
                    $parent->rotate_to_left();

                    $parent->{factor} = BALANCED;
                    $node->{factor} = BALANCED;
                }

                last;
            } # if
        } # if

        if ($node->is_root()) {
            last;
        }

        $prev = $node;
        $node = $node->{parent};
    } # while
} # rebalance_after_inserted

sub rebalance_after_deleted {
    my $deleting_node = shift;
    my $deleted_node  = shift;
    my $deleted_pos   = shift;

    if ($deleted_pos == ROOT) {
        return;
    }

    my $prev     = $deleted_node;
    my $prev_pos = $deleted_pos;
    my $node     = $deleted_node->{parent};
    while (1) {
        if ($prev_pos == LEFT_CHILD) {
            $node->{factor} -= LEFT_HEAVY;
        } else {
            $node->{factor} -= RIGHT_HEAVY;
        }

        if ($node->{factor} > LEFT_HEAVY) {
            ### lean to left too much
            ### unbalancing
 
            my $left_child = $node->{left};
            my $has_left_child = $left_child->has_left_child();
            my $has_right_child = $left_child->has_right_child();

            if ($has_left_child) {
                $node->rotate_to_right();

                if ($has_right_child) {
                    $node->{factor} = LEFT_HEAVY;
                    $left_child->{factor} = RIGHT_HEAVY;
                } else {
                    $node->{factor} = BALANCED;
                    $left_child->{factor} = BALANCED;
                }

                $node = $left_child;
            } elsif ($has_right_child) {
                my (undef, $lr_grandchild) = $left_child->rotate_to_left();
                $node->rotate_to_right();

                $node->{factor} = BALANCED;
                $left_child->{factor} = BALANCED;
                $lr_grandchild->{factor} = BALANCED;

                $node = $lr_grandchild;
            }
        } elsif ($node->{factor} < RIGHT_HEAVY) {
            ### lean to right too much
            ### unbalancing

            my $right_child = $node->{right};
            my $has_right_child = $right_child->has_right_child();
            my $has_left_child = $right_child->has_left_child();

            if ($has_right_child) {
                $node->rotate_to_left();

                if ($has_left_child) {
                    $node->{factor} = RIGHT_HEAVY;
                    $right_child->{factor} = LEFT_HEAVY;
                } else {
                    $node->{factor} = BALANCED;
                    $right_child->{factor} = BALANCED;
                }

                $node = $right_child;
            } elsif ($has_right_child) {
                my (undef, $rl_grandchild) = $right_child->rotate_to_right();
                $node->rotate_to_right();

                $node->{factor} = BALANCED;
                $right_child->{factor} = BALANCED;
                $rl_grandchild->{factor} = BALANCED;

                $node = $rl_grandchild;
            }
        }

        if ($node->is_root()) {
            ### it is the root 
            last;
        }

        if ($node->{factor} == BALANCED) {
            $prev = $node;
            $prev_pos = $node->is_left_child() ? LEFT_CHILD : RIGHT_CHILD;
            $node = $node->{parent};
            next;
        }

        # rebalanced
        last;
    } # while
} # rebalance_after_deleted

our @ISA = qw(BinarySearchTree);

sub insert {
    my $self = shift;
    my $data = shift;

    my @ret  = $self->BinarySearchTree::insert($data);
    return rebalance_after_inserted(@ret);
} # insert

sub delete {
    my $self = shift;
    my $data = shift;

    my @ret  = $self->BinarySearchTree::delete($data);
    return rebalance_after_deleted(@ret);
} # delete

1;

__END__
