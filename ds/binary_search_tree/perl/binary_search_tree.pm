#!/usr/bin/env perl

package BinarySearchTree;

use strict;
use warnings;

use constant LEFT_CHILD  => 1;
use constant RIGHT_CHILD => 2;

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

sub is_root {
    my $node = shift;
    return !defined($node->{parent});
} # is_root

sub is_leaf {
    my $node = shift;
    return (!defined($node->{left}) && !defined($node->{right}));
} # is_leaf

sub is_left_child {
    my $node = shift;
    return (defined($node->{parent}) && defined($node->{parent}{left}) && $node->{parent}{left} == $node);
} # is_left_child

sub is_right_child {
    my $node = shift;
    return (defined($node->{parent}) && defined($node->{parent}{right}) && $node->{parent}{right} == $node);
} # is_right_child

sub has_left_child {
    my $node = shift;
    return defined($node->{left});
} # has_left_child

sub has_right_child {
    my $node = shift;
    return defined($node->{right});
} # has_right_child

sub predecessor {
    my $node = shift;

    if (not defined($node)) {
        return undef;
    }

    if (has_left_child($node)) {
        $node = $node->{left};
        while (has_right_child($node)) {
            $node = $node->{right};
        } # while
        return $node;
    }

    while (is_left_child($node)) {
        $node = $node->{parent};
    }
    return $node->{parent};
} # predecessor

sub successor {
    my $node = shift;

    if (not defined($node)) {
        return undef;
    }

    if (has_right_child($node)) {
        $node = $node->{right};
        while (defined($node->{left})) {
            $node = $node->{left};
        } # while
        return $node;
    }

    while (is_right_child($node)) {
        $node = $node->{parent};
    } # while
    return $node->{parent};
} # successor

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

sub search {
    my $self = shift;
    my $data = shift;

    my ($node) = $self->search_node($data);
    if (defined($node)) {
        return $data;
    }
    return undef;
} # search

sub is_empty {
    my $self = shift;
    return defined($self->{root});
} # is_empty

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

sub delete_node {
    my $self = shift;
    my $node = shift;

    if (has_left_child($node)) {
        my $predecessor = predecessor($node);
        if (defined($predecessor)) {
            $node->{data} = $predecessor->{data};

            my $is_leaf       = is_leaf($predecessor);
            my $is_left_child = is_left_child($predecessor);
            my $child         = undef;

            if (not $is_leaf) {
                $child = $predecessor->{left};
                $child->{parent} = $predecessor->{parent};
            }

            if (not $is_left_child) {
                $predecessor->{parent}->{left} = $child;
            } else {
                $predecessor->{parent}->{right} = $child;
            }

            $self->{size} -= 1;
            return $node, $predecessor;
        }
    } # if has_left_child($node)

    if (has_right_child($node)) {
        my $successor = successor($node);
        if (defined($successor)) {
            $node->{data} = $successor->{data};

            my $is_leaf       = is_leaf($successor);
            my $is_left_child = is_left_child($successor);
            my $child         = undef;

            if (not $is_leaf) {
                $child = $successor->{right};
                $child->{parent} = $successor->{parent};
            }

            if (not $is_left_child) {
                $successor->{parent}->{left} = $child;
            } else {
                $successor->{parent}->{right} = $child;
            }

            $self->{size} -= 1;
            return $node, $successor;
        }
    } # if has_right_child($node)

    if (is_root($node)) {
        $self->{root} = undef;
        $self->{size} -= 1;
        return $node, undef;
    }

    # the node to be deleted is a leaf
    if (is_left_child($node)) {
        $node->{parent}->{left} = undef;
    } else {
        $node->{parent}->{right} = undef;
    }

    $self->{size} -= 1;
    return $node, undef;
} # delete_node

sub delete {
    my $self = shift;
    my $data = shift;

    my $node = $self->search_node($data);
    if (not defined($node)) {
        return undef, undef;
    }

    return $self->delete_node($node);
} # delete

sub insert_node {
    my $self        = shift;
    my $new_node    = shift;
    my $root_node   = shift;

    if (not defined($self->{root})) {
        $self->{root} = $new_node;
        $self->{size} += 1;
        return $new_node, undef;
    }

    my ($node, $parent, $pos) = $self->search_node(
        $new_node->{data},
        $root_node,
    );

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

    return $self->insert_node($new_node, $root_node);
} # insert

1;

__END__
