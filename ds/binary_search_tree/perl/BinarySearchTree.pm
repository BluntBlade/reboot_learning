#!/usr/bin/env perl

package BinarySearchTree;

use strict;
use warnings;

use constant ROOT        => 0;
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
    return defined($node->{parent}{root}) && ($node->{parent}{root} == $node);
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

sub in_order {
    my $root = shift;
    my $proc = shift;

    my $node = $root;
    while (defined($node)) {
        if (has_left_child($node)) {
            $node = $node->{left};
            next;
        }

        $proc->($node->{data}, $node);

        if (has_right_child($node)) {
            $node = $node->{right};
            next;
        }
        
        while (1) {
            if ($node == $root) {
                return undef;
            }

            if (is_right_child($node)) {
                $node = $node->{parent};
                next;
            }

            $node = $node->{parent};
            $proc->($node->{data}, $node);

            if (has_right_child($node)) {
                $node = $node->{right};
                last;
            }
        } # while
    } # while
    return undef;
} # in_order

sub pre_order {
    my $root = shift;
    my $proc = shift;

    my $node = $root;
    while (defined($node)) {
        $proc->($node->{data}, $node);

        if (has_left_child($node)) {
            $node = $node->{left};
            next;
        }

        if (has_right_child($node)) {
            $node = $node->{right};
            next;
        }
        
        while (1) {
            if ($node == $root) {
                return undef;
            }

            if (is_right_child($node)) {
                $node = $node->{parent};
                next;
            }

            $node = $node->{parent}{right};
            last;
        } # while
    } # while
    return undef;
} # pre_order

sub post_order {
    my $root = shift;
    my $proc = shift;

    my $node = $root;
    while (defined($node)) {
        if (has_left_child($node)) {
            $node = $node->{left};
            next;
        }

        if (has_right_child($node)) {
            $node = $node->{right};
            next;
        }
        
        # reach a leaf node
        $proc->($node->{data}, $node);

        # trace back
        while (1) {
            if ($node == $root) {
                return undef;
            }

            if (is_right_child($node) or not has_right_child($node->{parent})) {
                $node = $node->{parent};
                $proc->($node->{data}, $node);
                next;
            }

            $node = $node->{parent}{right};
            last;
        } # while
    } # while
    return undef;
} # post_order

sub left_rotate {
    my $node = shift;

    if (not has_right_child($node)) {
        return $node, undef;
    }

    my $right_child = $node->{right};

    if (is_root($node)) {
        $node->{parent}{root} = $right_child;
    } else {
        if (is_left_child($node)) {
            $node->{parent}{left} = $right_child;
        } else {
            $node->{parent}{right} = $right_child;
        }
    }

    $right_child->{parent} = $node->{parent};
    $node->{parent}        = $right_child;
    $node->{right}         = $right_child->{left};
    $right_child->{left}   = $node;

    if (defined($node->{right})) {
        $node->{right}{parent} = $node;
    }

    return $node, $right_child;
} # left_rotate

sub right_rotate {
    my $node = shift;

    if (not has_left_child($node)) {
        return $node, undef;
    }

    my $left_child = $node->{left};

    if (is_root($node)) {
        $node->{parent}{root} = $left_child;
    } else {
        if (is_right_child($node)) {
            $node->{parent}{right} = $left_child;
        } else {
            $node->{parent}{left} = $left_child;
        }
    }

    $left_child->{parent} = $node->{parent};
    $node->{parent}       = $left_child;
    $node->{left}         = $left_child->{right};
    $left_child->{right}  = $node;

    if (defined($node->{left})) {
        $node->{left}{parent} = $node;
    }

    return $node, $left_child;
} # right_rotate

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

            my $deleting_pos = $is_left_child ? LEFT_CHILD : RIGHT_CHILD;

            if (not $is_leaf) {
                $child = $predecessor->{left};
                $child->{parent} = $predecessor->{parent};
            }

            if ($is_left_child) {
                $predecessor->{parent}->{left} = $child;
            } else {
                $predecessor->{parent}->{right} = $child;
            }

            $self->{size} -= 1;
            return $node, $predecessor, $deleting_pos;
        }
    } # if has_left_child($node)

    if (has_right_child($node)) {
        my $successor = successor($node);
        if (defined($successor)) {
            $node->{data} = $successor->{data};

            my $is_leaf       = is_leaf($successor);
            my $is_left_child = is_left_child($successor);
            my $child         = undef;

            my $deleting_pos = $is_left_child ? LEFT_CHILD : RIGHT_CHILD;

            if (not $is_leaf) {
                $child = $successor->{right};
                $child->{parent} = $successor->{parent};
            }

            if ($is_left_child) {
                $successor->{parent}->{left} = $child;
            } else {
                $successor->{parent}->{right} = $child;
            }


            $self->{size} -= 1;
            return $node, $successor, $deleting_pos;
        }
    } # if has_right_child($node)

    if (is_root($node)) {
        $node->{parent} = undef;
        $self->{root} = undef;
        $self->{size} -= 1;
        return $node, undef, ROOT;
    }

    # the node to be deleted is a leaf
    my $deleting_pos = undef;
    if (is_left_child($node)) {
        $deleting_pos = LEFT_CHILD;
        $node->{parent}->{left} = undef;
    } else {
        $deleting_pos = RIGHT_CHILD;
        $node->{parent}->{right} = undef;
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

sub insert {
    my $self = shift;
    my $data = shift;

    my $new_node = {
        parent => undef,
        data   => $data,
        left   => undef,
        right  => undef,
    };

    return $self->insert_node($new_node);
} # insert

sub clone {
    my $self = shift;

    my $new_tree = BinarySearchTree->new($self->{cmp});
    pre_order($self->{root}, sub {
        my $data = shift;
        $new_tree->insert($data);
    });

    return $new_tree;
} # clone

1;

__END__