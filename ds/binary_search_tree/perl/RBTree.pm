#!/usr/bin/env perl

package RBTree;

use strict;
use warnings;

use BinarySearchTree qw(:BST);

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
        if (is_root($node)) {
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
        if (is_left_child($parent)) {
            my $right_uncle = $grand_parent->{right};

            if (is_red($right_uncle)) {
                ### case 3
                $parent->{color}       = BLACK;
                $right_uncle->{color}  = BLACK;
                $grand_parent->{color} = RED;

                $node = $grand_parent;
                next;
            }

            if (is_right_child($node)) {
                ### case 4
                ($node, $parent) = rotate_to_left($parent);
            }

            ### case 5
            rotate_to_right($grand_parent);
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

            if (is_left_child($node)) {
                ### case 4
                ($node, $parent) = rotate_to_right($parent);
            }

            ### case 5
            rotate_to_left($grand_parent);
            $grand_parent->{color} = RED;
            $parent->{color}       = BLACK;

            last;
        } # if
    } # while

    return @ret;
} # rebalance_after_inserted

our @ISA = qw(BinarySearchTree);

sub insert {
    my $self = shift;
    my $data = shift;

    my @ret  = $self->BinarySearchTree::insert($data);
    return rebalance_after_inserted(@ret);
} # insert

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

1;

__END__
