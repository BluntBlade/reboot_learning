#!/usr/bin/env perl

use strict;
use warnings;

package RBTree::Node;

our @ISA = qw(BinarySearchTree::Node);

use constant BLACK => 0;
use constant RED   => 1;

sub paint_as_black {
    my $self = shift;
    if (defined($self)) {
        $self->{color} = BLACK;
    }
} # paint_as_black

sub paint_as_red {
    my $self = shift;
    if (defined($self)) {
        $self->{color} = RED;
    }
} # paint_as_red

package RBTree;

use BinarySearchTree;

use constant ROOT        => BinarySearchTree::ROOT;
use constant LEFT_CHILD  => BinarySearchTree::LEFT_CHILD;
use constant RIGHT_CHILD => BinarySearchTree::RIGHT_CHILD;

sub is_black {
    my $self = shift;
    return ((!defined($self)) || $self->{color} == RBTree::Node::BLACK);
} # is_black

sub is_red {
    my $self = shift;
    return (defined($self) && $self->{color} == RBTree::Node::RED);
} # is_red

sub rebalance_after_inserted {
    my @ret = @_;

    my $node                      = shift;
    my $inserted_before_this_time = shift;

    if ($inserted_before_this_time) {
        return @ret;
    }

    $node->paint_as_red();

    while (1) {
        if ($node->is_root()) {
            ### case 1
            $node->paint_as_black();
            return @ret;
        }

        my $parent = $node->{parent};
        if (is_black($parent)) {
            ### case 2
            return @ret;
        }

        my $grand_parent = $parent->{parent};
        if ($parent->is_left_child()) {
            my $right_uncle = $grand_parent->{right};

            if (is_red($right_uncle)) {
                ### case 3
                $parent->paint_as_black();
                $right_uncle->paint_as_black();
                $grand_parent->paint_as_red();

                $node = $grand_parent;
                next;
            }

            if ($node->is_right_child()) {
                ### case 4
                ($node, $parent) = $parent->rotate_to_left();
            }

            ### case 5
            $grand_parent->rotate_to_right();
            $grand_parent->paint_as_red();
            $parent->paint_as_black();

            last;
        } else {
            my $left_uncle = $grand_parent->{left};

            if (is_red($left_uncle)) {
                ### case 3
                $parent->paint_as_black();
                $left_uncle->paint_as_black();
                $grand_parent->paint_as_red();

                $node = $grand_parent;
                next;
            }

            if ($node->is_left_child()) {
                ### case 4
                ($node, $parent) = $parent->rotate_to_right();
            }

            ### case 5
            $grand_parent->rotate_to_left();
            $grand_parent->paint_as_red();
            $parent->paint_as_black();

            last;
        } # if
    } # while

    return @ret;
} # rebalance_after_inserted

sub rebalance_after_deleted {
    my @ret = @_;

    my $deleting_node = shift;
    my $deleted_node  = shift;
    my $deleted_pos   = shift;

    if ($deleted_pos == ROOT || is_red($deleted_node)) {
        return;
    }

    my $parent = $deleted_node->{parent};
    my $child  = $parent->{$deleted_pos};
    if (is_black($deleted_node)) {
        if (is_red($child)) {
            $child->paint_as_black();
            return @ret;
        }
    }

    my $pos = $deleted_pos;
    while (1) {
        ### case 1
        if (defined($child) && $child->is_root()) {
            return @ret;
        }

        if ($pos == LEFT_CHILD) {
            my $right_uncle = $parent->{right};

            ### case 2
            if (is_red($right_uncle)) {
                $parent->paint_as_red();
                $right_uncle->paint_as_black();
                $parent->rotate_to_left();

                $right_uncle = $parent->{right};
            }

            ### case 3
            if (is_black($parent) && is_black($right_uncle)) {
                if (is_black($right_uncle->{left}) && is_black($right_uncle->{right})) {
                    $right_uncle->paint_as_red();

                    $child  = $parent;
                    $parent = $child->{parent};
                    if ($child->is_root()) {
                        next;
                    }
                    $pos    = ($parent->has_left_child() && $child == $parent->{left}) ? LEFT_CHILD : RIGHT_CHILD;
                    next;
                }
            }

            ### case 4
            if (is_red($parent) && is_black($right_uncle)) {
                if (is_black($right_uncle->{left}) && is_black($right_uncle->{right})) {
                    $right_uncle->paint_as_red();
                    $parent->paint_as_black();
                    last;
                }
            }

            ### case 5
            if (is_black($right_uncle)) {
                if (is_red($right_uncle->{left}) && is_black($right_uncle->{right})) {
                    $right_uncle->paint_as_red();
                    $right_uncle->{left}->paint_as_black();
                    $right_uncle->rotate_to_right();

                    $right_uncle = $parent->{right};
                }
            }

            ### case 6
            $right_uncle->{color} = $parent->{color};
            $parent->paint_as_black();
            $right_uncle->{right}->paint_as_black();

            $parent->rotate_to_left();
            last;
        } else {
            my $left_uncle = $parent->{left};

            ### case 2
            if (is_red($left_uncle)) {
                $parent->paint_as_red();
                $left_uncle->paint_as_black();
                $parent->rotate_to_right();

                $left_uncle = $parent->{left};
            }

            ### case 3
            if (is_black($parent) && is_black($left_uncle)) {
                if (is_black($left_uncle->{right}) && is_black($left_uncle->{left})) {
                    $left_uncle->paint_as_red();

                    $child  = $parent;
                    $parent = $child->{parent};
                    if ($child->is_root()) {
                        next;
                    }
                    $pos    = ($parent->has_right_child() && $child == $parent->{right}) ? RIGHT_CHILD : LEFT_CHILD;
                    next;
                }
            }

            ### case 4
            if (is_red($parent) && is_black($left_uncle)) {
                if (is_black($left_uncle->{right}) && is_black($left_uncle->{left})) {
                    $left_uncle->paint_as_red();
                    $parent->paint_as_black();
                    last;
                }
            }

            ### case 5
            if (is_black($left_uncle)) {
                if (is_red($left_uncle->{right}) && is_black($left_uncle->{left})) {
                    $left_uncle->paint_as_red();
                    $left_uncle->{right}->paint_as_black();
                    $left_uncle->rotate_to_left();

                    $left_uncle = $parent->{left};
                }
            }

            ### case 6
            $left_uncle->{color} = $parent->{color};

            $parent->paint_as_black();
            $left_uncle->{left}->paint_as_black();

            $parent->rotate_to_right();
            last;
        }
    } # while
    return @ret;
} # rebalance_after_deleted

our @ISA = qw(BinarySearchTree);

sub new_node {
    my $self = shift;
    my $data = shift;
    return RBTree::Node->new($data);
} # new_node

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
