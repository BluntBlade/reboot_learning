#!/usr/bin/env perl

use strict;
use warnings;

package SplayTree;

use BinarySearchTree;

use constant ROOT        => BinarySearchTree::ROOT;

sub splay {
    my $node = shift;
    
    while (!$node->is_root()) {
        my $parent = $node->{parent};

        if ($parent->is_root()) {
            if ($node->is_left_child()) {
                $parent->rotate_to_right();
            } else {
                $parent->rotate_to_left();
            }
            next;
        }

        my $grand_parent = $parent->{parent};

        if ($parent->is_left_child()) {
            if ($node->is_left_child()) {
                $grand_parent->rotate_to_right();
                $parent->rotate_to_right();
            } else {
                $parent->rotate_to_left();
                $grand_parent->rotate_to_right();
            }
        } else {
            if ($node->is_right_child()) {
                $grand_parent->rotate_to_left();
                $parent->rotate_to_left();
            } else {
                $parent->rotate_to_right();
                $grand_parent->rotate_to_left();
            }
        } # if
    } # while

    return $node;
} # splay

sub rebalance_after_inserted {
    my @ret = @_;

    my $node                      = shift;
    my $inserted_before_this_time = shift;

    if ($inserted_before_this_time) {
        return @ret;
    }

    splay($node);

    return @ret;
} # rebalance_after_inserted

sub rebalance_after_deleted {
    my @ret = @_;

    my $deleting_node = shift;
    my $deleted_node  = shift;
    my $deleted_pos   = shift;

    if ($deleted_pos == ROOT) {
        ### the deleted node was the old root
        return;
    }

    splay($deleted_node->{parent});

    return @ret;
} # rebalance_after_deleted

our @ISA = qw(BinarySearchTree);

sub search {
    my $self = shift;
    my $data = shift;

    my ($node, undef, undef) = $self->BinarySearchTree::search_node($data);
    if (not defined($node)) {
        return undef;
    }

    splay($node);
    return $node->{data};
} # search

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
