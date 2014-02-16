#!/usr/bin/env perl

package BinarySearchTree;

use strict;
use warnings;

sub new {
    my $class = shift || __PACKAGE__;
    my $cmp = shift;
    my $self = {
        root => undef,
        cmp  => $cmp,
    };
    return bless $self, $class;
} # new

use constant LEFT_CHILD  => 1;
use constant RIGHT_CHILD => 2;

sub search {
    my $self = shift;
    my $data = shift;

    my ($node) = $self->search_node($data);
    if (defined($node)) {
        return $data;
    }
    return undef;
} # search

sub search_node {
    my $self = shift;
    my $data = shift;
    my $root_node = shift;

    my $node = $root_node || $self->{root};
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
} # search_node

sub predecessor {
    my $node = shift;

    if (not defined($node)) {
        return undef;
    }

    if (not defined($node->{left})) {
        return $node->{parent};
    }

    $node = $node->{left};
    while (defined($node->{right})) {
        $node = $node->{right};
    } # while

    return $node;
} # predecessor

sub successor {
    my $node = shift;

    if (not defined($node)) {
        return undef;
    }

    if (not defined($node->{right})) {
        return $node->{parent};
    }

    $node = $node->{right};
    while (defined($node->{left})) {
        $node = $node->{left};
    } # while

    return $node;
} # successor

sub in_order {
    my $self = shift;
    my $proc = shift;

    my @stack = ();
    my $node = $self->{root};

    while (defined($node)) {
        if (defined($node->{left})) {
            push(@stack, $node);
            $node = $node->{left};
            next;
        }

        $proc->($node->{data}, $node);

        if (defined($node->{right})) {
            push(@stack, $node);
            $node = $node->{right};
            next;
        }
        
        while (1) {
            my $parent = pop(@stack);
            if (not defined($parent)) {
                return undef;
            }

            if (defined($parent->{right}) and $parent->{right} == $node) {
                $node = $parent;
                next;
            }

            $node = $parent;
            $proc->($node->{data}, $node);

            if (defined($node->{right})) {
                push @stack, $node;
                $node = $node->{right};
                last;
            }
        } # while
    } # while
    return undef;
} # in_order

sub insert {
    my $self = shift;
    my $data = shift;
    my $root_node = shift;

    my $new_node = {
        parent => undef,
        data   => $data,
        left   => undef,
        right  => undef,
    };

    if (not defined($self->{root})) {
        $self->{root} = $new_node;
        return $new_node, undef;
    }

    my ($node, $parent, $pos) = $self->search_node($data, $root_node);
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

    return $new_node, undef;
} # insert

1;

__END__
