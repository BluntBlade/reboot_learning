#!/usr/bin/env perl

package RBTree;

use strict;
use warnings;

use BinarySearchTree;

use constant ROOT        => BinarySearchTree::ROOT;
use constant LEFT_CHILD  => BinarySearchTree::LEFT_CHILD;
use constant RIGHT_CHILD => BinarySearchTree::RIGHT_CHILD;

use constant BLACK => 0;
use constant RED   => 1;

sub is_black {
    my $node = shift;
    return ((!defined($node)) || $node->{color} == BLACK);
} # is_black

sub is_red {
    my $node = shift;
    return (defined($node) && $node->{color} == RED);
} # is_red

sub rebalance_after_inserted {
    my @ret = @_;

    my $node                      = shift;
    my $inserted_before_this_time = shift;

    if ($inserted_before_this_time) {
        return @ret;
    }

    $node->{color} = RED;

    while (1) {
        if ($node->is_root()) {
            ### case 1
            $node->{color} = BLACK;
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
                $parent->{color}       = BLACK;
                $right_uncle->{color}  = BLACK;
                $grand_parent->{color} = RED;

                $node = $grand_parent;
                next;
            }

            if ($node->is_right_child()) {
                ### case 4
                ($node, $parent) = $parent->rotate_to_left();
            }

            ### case 5
            $grand_parent->rotate_to_right();
            $grand_parent->{color} = RED;
            $parent->{color}       = BLACK;

            last;
        } else {
            my $left_uncle = $grand_parent->{left};

            if (is_red($left_uncle)) {
                ### case 3
                $parent->{color}       = BLACK;
                $left_uncle->{color}   = BLACK;
                $grand_parent->{color} = RED;

                $node = $grand_parent;
                next;
            }

            if ($node->is_left_child()) {
                ### case 4
                ($node, $parent) = $parent->rotate_to_right();
            }

            ### case 5
            $grand_parent->rotate_to_left();
            $grand_parent->{color} = RED;
            $parent->{color}       = BLACK;

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
            $child->{color} = BLACK;
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
                $parent->{color}      = RED;
                $right_uncle->{color} = BLACK;
                $parent->rotate_to_left();

                $right_uncle = $parent->{right};
            }

            ### case 3
            if (is_black($parent) && is_black($right_uncle)) {
                if (is_black($right_uncle->{left}) && is_black($right_uncle->{right})) {
                    $right_uncle->{color} = RED;

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
                    $right_uncle->{color} = RED;
                    $parent->{color}      = BLACK;
                    last;
                }
            }

            ### case 5
            if (is_black($right_uncle)) {
                if (is_red($right_uncle->{left}) && is_black($right_uncle->{right})) {
                    $right_uncle->{color}       = RED;
                    $right_uncle->{left}{color} = BLACK;
                    $right_uncle->rotate_to_right();

                    $right_uncle = $parent->{right};
                }
            }

            ### case 6
            $right_uncle->{color} = $parent->{color};
            $parent->{color}      = BLACK;
            $right_uncle->{right}{color} = BLACK;

            $parent->rotate_to_left();
            last;
        } else {
            my $left_uncle = $parent->{left};

            ### case 2
            if (is_red($left_uncle)) {
                $parent->{color}     = RED;
                $left_uncle->{color} = BLACK;
                $parent->rotate_to_right();

                $left_uncle = $parent->{left};
            }

            ### case 3
            if (is_black($parent) && is_black($left_uncle)) {
                if (is_black($left_uncle->{right}) && is_black($left_uncle->{left})) {
                    $left_uncle->{color} = RED;

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
                    $left_uncle->{color} = RED;
                    $parent->{color}     = BLACK;
                    last;
                }
            }

            ### case 5
            if (is_black($left_uncle)) {
                if (is_red($left_uncle->{right}) && is_black($left_uncle->{left})) {
                    $left_uncle->{color}       = RED;
                    $left_uncle->{right}{color} = BLACK;
                    $left_uncle->rotate_to_left();

                    $left_uncle = $parent->{left};
                }
            }

            ### case 6
            $left_uncle->{color}       = $parent->{color};
            $parent->{color}           = BLACK;
            $left_uncle->{left}{color} = BLACK;

            $parent->rotate_to_right();
            last;
        }
    } # while
    return @ret;
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

=begin
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
=cut

1;

__END__
