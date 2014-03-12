#!/usr/bin/env perl

use strict;
use warnings;

package BinarySearchTree::Node;

use BinaryTree;

our @ISA = qw(BinaryTree::Node);

sub predecessor {
    my $self = shift;

    if (not defined($self)) {
        return undef;
    }

    my $node = $self;
    if ($node->has_left_child()) {
        $node = $node->{left};

        while ($node->has_right_child()) {
            $node = $node->{right};
        } # while

        return $node;
    } # if

    while ($node->is_left_child()) {
        $node = $node->{parent};
    } # while
    return $node->{parent};
} # predecessor

sub successor {
    my $self = shift;

    if (not defined($self)) {
        return undef;
    }

    my $node = $self;
    if ($node->has_right_child()) {
        $node = $node->{right};

        while ($node->has_left_child()) {
            $node = $node->{left};
        } # while

        return $node;
    } # if

    while ($node->is_right_child()) {
        $node = $node->{parent};
    } # while
    return $node->{parent};
} # successor

package BinarySearchTree;

use constant ROOT        => BinaryTree::ROOT;
use constant LEFT_CHILD  => BinaryTree::LEFT_CHILD;
use constant RIGHT_CHILD => BinaryTree::RIGHT_CHILD;

sub new {
    my $class = shift || __PACKAGE__;
    my $cmp = shift;
    my $self = {
        root => undef,
        cmp  => $cmp,
        size => 0,
    };
    return bless $self, $class;
} # new

sub root {
    my $self = shift;
    return $self->{root};
} # root

sub size {
    my $self = shift;
    return $self->{size};
} # size

sub search_starting_at_root {
    my $self = shift;
    my $data = shift;

    my $node = $self->{root};
    if (not defined($node)) {
        return undef;
    }

    while (1) {
        my $cmp_ret = $self->{cmp}->($data, $node->{data});

        if ($cmp_ret < 0) {
            if (defined($node->{left})) {
                $node = $node->{left};
                next;
            }
                
            return undef, $node, LEFT_CHILD;
        } elsif ($cmp_ret > 0) {
            if (defined($node->{right})) {
                $node = $node->{right};
                next;
            }
                
            return undef, $node, RIGHT_CHILD;
        } else {
            return $node;
        }
    } # while
} # search_starting_at_root

use constant STARTING_SEARCH       => 0;
use constant SEARCHING_PREDECESSOR => 1;
use constant SEARCHING_SUCCESSOR   => 2;
use constant ENDING_SEARCH         => 3;

sub search_starting_at_given_node {
    my $self = shift;
    my $data = shift;
    my $node = shift;

    $node ||= $self->{root};
    if (not defined($node)) {
        return undef;
    }

    my $direction = STARTING_SEARCH;
    while (1) {
        my $cmp_ret = $self->{cmp}->($data, $node->{data});

        if ($cmp_ret < 0) {
            $direction |= SEARCHING_PREDECESSOR;
            if ($direction == ENDING_SEARCH) {
                return undef, $node, LEFT_CHILD;
            }

            my $predecessor = predecessor($node);
            if (defined($predecessor)) {
                $node = $predecessor;
                next;
            }

            return undef, $node, LEFT_CHILD;
        } elsif ($cmp_ret > 0) {
            $direction |= SEARCHING_SUCCESSOR;
            if ($direction == ENDING_SEARCH) {
                return undef, $node, RIGHT_CHILD;
            }

            my $successor = successor($node);
            if (defined($successor)) {
                $node = $successor;
                next;
            }

            return undef, $node, RIGHT_CHILD;
        }

        return $node;
    } # while
} # search_starting_at_given_node

sub search_node {
    my $self = shift;
    my $data = shift;
    my $start_node = shift;

    if (defined($start_node) && ($start_node != $self->{root})) {
        return $self->search_starting_at_given_node(
            $data,
            $start_node,
        );
    }

    return $self->search_starting_at_root($data);
} # search_node

sub search {
    my $self = shift;
    my $data = shift;

    my ($node) = $self->search_starting_at_root($data);
    if (defined($node)) {
        return $data;
    }
    return undef;
} # search

sub is_empty {
    my $self = shift;
    return defined($self->{root});
} # is_empty

sub delete_node {
    my $self = shift;
    my $node = shift;

    if ($node->has_left_child()) {
        my $predecessor = $node->predecessor();
        if (defined($predecessor)) {
            $node->{data} = $predecessor->{data};

            my $is_leaf       = $predecessor->is_leaf();
            my $is_left_child = $predecessor->is_left_child();
            my $child         = undef;

            my $deleting_pos = $is_left_child ? LEFT_CHILD : RIGHT_CHILD;

            if (not $is_leaf) {
                $child = $predecessor->{left};
                $child->{parent} = $predecessor->{parent};
            }

            if ($is_left_child) {
                $predecessor->{parent}{left} = $child;
            } else {
                $predecessor->{parent}{right} = $child;
            }

            $self->{size} -= 1;
            return $node, $predecessor, $deleting_pos;
        }
    } # if has_left_child($node)

    if ($node->has_right_child()) {
        my $successor = $node->successor();
        if (defined($successor)) {
            $node->{data} = $successor->{data};

            my $is_leaf       = $successor->is_leaf();
            my $is_left_child = $successor->is_left_child();
            my $child         = undef;

            my $deleting_pos = $is_left_child ? LEFT_CHILD : RIGHT_CHILD;

            if (not $is_leaf) {
                $child = $successor->{right};
                $child->{parent} = $successor->{parent};
            }

            if ($is_left_child) {
                $successor->{parent}{left} = $child;
            } else {
                $successor->{parent}{right} = $child;
            }


            $self->{size} -= 1;
            return $node, $successor, $deleting_pos;
        }
    } # if has_right_child($node)

    if ($node->is_root()) {
        $node->{parent} = undef;
        $self->{root} = undef;
        $self->{size} -= 1;
        return $node, undef, ROOT;
    }

    # the node to be deleted is a leaf
    my $deleting_pos = undef;
    if ($node->is_left_child()) {
        $deleting_pos = LEFT_CHILD;
        $node->{parent}{left} = undef;
    } else {
        $deleting_pos = RIGHT_CHILD;
        $node->{parent}{right} = undef;
    }

    $self->{size} -= 1;
    return $node, $node, $deleting_pos;
} # delete_node

sub delete {
    my $self = shift;
    my $data = shift;

    my $node = $self->search_starting_at_root($data);
    if (not defined($node)) {
        return undef, undef;
    }

    return $self->delete_node($node);
} # delete

sub insert_node {
    my $self        = shift;
    my $new_node    = shift;
    my $start_node  = shift;

    if (not defined($self->{root})) {
        $new_node->{parent} = $self;
        $self->{root} = $new_node;
        $self->{size} += 1;
        return $new_node, undef;
    }

    my ($node, $parent, $pos) = $self->search_node($new_node->{data});

    if (defined($node)) {
        # already inserted
        return $node, 1;
    }

    $new_node->{parent} = $parent;

    if ($pos == LEFT_CHILD) {
        $parent->{left}  = $new_node;
    } else {
        $parent->{right} = $new_node;
    }

    $self->{size} += 1;
    return $new_node, undef;
} # insert_node

sub new_node {
    my $self = shift;
    my $data = shift;
    return BinarySearchTree::Node->new($data);
} # new_node

sub insert {
    my $self = shift;
    my $data = shift;
    return $self->insert_node($self->new_node($data));
} # insert

sub clone {
    my $self = shift;

    my $new_tree = BinarySearchTree->new($self->{cmp});
    BinaryTree::travel_by_pre_order($self->{root}, sub {
        my $data = shift;
        $new_tree->insert($data);
    });

    return $new_tree;
} # clone

1;

__END__
