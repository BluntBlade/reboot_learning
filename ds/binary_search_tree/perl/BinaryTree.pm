#!/usr/bin/env perl

package BinaryTree::Node;

sub new {
    my $class = shift || __PACKAGE__;
    my $data  = shift;

    my $self = {
        parent => undef,
        data   => $data,
        left   => undef,
        right  => undef,
    };
    return bless $self, $class;
} # new

sub left_child {
    my $self = shift;
    return $self->{left};
} # left_child

sub right_child {
    my $self = shift;
    return $self->{right};
} # right_child

sub parent {
    my $self = shift;
    return $self->{parent};
} # parent

sub data {
    my $self = shift;
    return $self->{data};
} # data

sub is_root {
    my $self = shift;
    return defined($self->{parent}{root}) && ($self->{parent}{root} == $self);
} # is_root

sub is_leaf {
    my $self = shift;
    return (!defined($self->{left}) && !defined($self->{right}));
} # is_leaf

sub is_left_child {
    my $self = shift;
    return (defined($self->{parent}) && defined($self->{parent}{left}) && $self->{parent}{left} == $self);
} # is_left_child

sub is_right_child {
    my $self = shift;
    return (defined($self->{parent}) && defined($self->{parent}{right}) && $self->{parent}{right} == $self);
} # is_right_child

sub has_left_child {
    my $self = shift;
    return defined($self->{left});
} # has_left_child

sub has_right_child {
    my $self = shift;
    return defined($self->{right});
} # has_right_child

sub rotate_to_left {
    my $self = shift;

    if (not $self->has_right_child()) {
        return $self, undef;
    }

    my $right_child = $self->{right};

    if ($self->is_root()) {
        $self->{parent}{root} = $right_child;
    } else {
        if ($self->is_left_child()) {
            $self->{parent}{left} = $right_child;
        } else {
            $self->{parent}{right} = $right_child;
        }
    }

    $right_child->{parent} = $self->{parent};
    $self->{parent}        = $right_child;
    $self->{right}         = $right_child->{left};
    $right_child->{left}   = $self;

    if ($self->has_right_child()) {
        $self->{right}{parent} = $self;
    }

    return $self, $right_child;
} # rotate_to_left

sub rotate_to_right {
    my $self = shift;

    if (not $self->has_left_child()) {
        return $self, undef;
    }

    my $left_child = $self->{left};

    if ($self->is_root()) {
        $self->{parent}{root} = $left_child;
    } else {
        if ($self->is_right_child()) {
            $self->{parent}{right} = $left_child;
        } else {
            $self->{parent}{left} = $left_child;
        }
    }

    $left_child->{parent} = $self->{parent};
    $self->{parent}       = $left_child;
    $self->{left}         = $left_child->{right};
    $left_child->{right}  = $self;

    if ($self->has_left_child()) {
        $self->{left}{parent} = $self;
    }

    return $self, $left_child;
} # rotate_to_right

package BinaryTree;

use constant ROOT        => 0;
use constant LEFT_CHILD  => 1;
use constant RIGHT_CHILD => 2;

sub travel_by_in_order {
    my $root = shift;
    my $proc = shift;

    my $node = $root;
    while (defined($node)) {
        if ($node->has_left_child()) {
            $node = $node->{left};
            next;
        }

        $proc->($node->{data}, $node);

        if ($node->has_right_child()) {
            $node = $node->{right};
            next;
        }
        
        # trace back
        while (1) {
            if ($node == $root) {
                return;
            }

            if ($node->is_right_child()) {
                $node = $node->{parent};
                next;
            }

            $node = $node->{parent};
            $proc->($node->{data}, $node);

            if ($node->has_right_child()) {
                $node = $node->{right};
                last;
            }
        } # while
    } # while
    return;
} # travel_by_in_order

sub travel_by_pre_order {
    my $root = shift;
    my $proc = shift;

    my $node = $root;
    while (defined($node)) {
        $proc->($node->{data}, $node);

        if ($node->has_left_child()) {
            $node = $node->{left};
            next;
        }

        if ($node->has_right_child()) {
            $node = $node->{right};
            next;
        }
        
        # trace back
        while (1) {
            if ($node == $root) {
                return;
            }

            if ($node->is_right_child()) {
                $node = $node->{parent};
                next;
            }

            $node = $node->{parent}{right};
            last;
        } # while
    } # while
    return;
} # travel_by_pre_order

sub travel_by_post_order {
    my $root = shift;
    my $proc = shift;

    my $node = $root;
    while (defined($node)) {
        if ($node->has_left_child()) {
            $node = $node->{left};
            next;
        }

        if ($node->has_right_child()) {
            $node = $node->{right};
            next;
        }
        
        # reach a leaf node
        $proc->($node->{data}, $node);

        # trace back
        while (1) {
            if ($node == $root) {
                return;
            }

            if ($node->is_right_child() or not $node->{parent}->has_right_child()) {
                $node = $node->{parent};
                $proc->($node->{data}, $node);
                next;
            }

            $node = $node->{parent}{right};
            last;
        } # while
    } # while
    return;
} # travel_by_post_order

sub travel_by_breadth_first_search {
    my $root       = shift;
    my $proc       = shift;
    my $check_full = shift;

    my @a_queue    = ();
    my @b_queue    = ();
    my $fake_node  = BinaryTree::Node->new(undef);

    push @a_queue, $root;

    my $id         = 0;
    my $level      = 1;
    my $real_nodes = 1;
    my $queue      = \@b_queue;
    my $next_queue = \@a_queue;

    while (scalar(@{$next_queue}) > 0 && $real_nodes > 0) {

        my $tq = $queue;
        $queue = $next_queue;
        $next_queue = $tq;

        $real_nodes = 0;

        while (scalar(@{$queue}) > 0) {
            my $node = shift @{$queue};

            if (defined($node->{data})) {

                $proc->($node->{data}, $node, $level, $id);

                if ($node->has_left_child()) {
                    push @{$next_queue}, $node->left_child();
                    $real_nodes += 1;
                } elsif ($check_full) {
                    push @{$next_queue}, $fake_node;
                }

                if ($node->has_right_child()) {
                    push @{$next_queue}, $node->right_child();
                    $real_nodes += 1;
                } elsif ($check_full) {
                    push @{$next_queue}, $fake_node;
                }

            } elsif ($check_full) {

                $proc->($node->{data}, $node, $level, $id);

                push @{$next_queue}, $fake_node;
                push @{$next_queue}, $fake_node;
            } # if

            $id += 1;
        } # while

        $level += 1;
    } # while
} # travel_by_breadth_first_search

1;

__END__
