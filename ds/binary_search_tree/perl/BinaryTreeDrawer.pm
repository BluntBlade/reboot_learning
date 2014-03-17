#!/usr/bin/env perl

use strict;
use warnings;

use BinaryTree;

package BinaryTreeDrawer;

sub draw_as_text {
    my $root   = shift;
    my $render = shift;
    my $width  = shift || 5;

    my @nodes = ();
    my $callback = sub {
        my $data = shift;
        my $node = shift;
        my $level = shift;

        push @nodes, {
            level => $level,
            node  => $node,
        };
    };

    BinaryTree::travel_by_breadth_first_search($root, $callback, 1);

    my $format = sub {
        my $node = shift;
        if (not defined($node->{data})) {
            return " " x $width;
        }

        my ($str, $len) = $render->($node);
        my $padding_len = $width - $len;
        my $leading  = " " x ($padding_len / 2 + ($padding_len & 0x1));
        my $trailing = " " x ($padding_len / 2);
        return $leading . $str . $trailing;
    };

    my $rect  = "";
    my @rects = ();
    my $level = 0;
    while (scalar(@nodes) > 0) {
        my $node = pop @nodes;
        if ($level != $node->{level}) {
            if ($level > 0) {
                unshift @rects, $rect;
                $rect = "";
                $width *= 2;
            }

            $level = $node->{level};
        } # if

        $rect = $format->($node->{node}) . $rect;
    } # while

    if ($level > 0) {
        unshift @rects, $rect;
        $rect = "";
        $width *= 2;
    }

    for my $rect (@rects) {
        print "$rect\n";
    } # for
} # draw_as_text

use AvlTree;
use RBTree;
use SplayTree;

my $in = [100, 50, 75, 60, 65, 25, 150, 175, 12, 200, 1, 2, 3, 4, 5, 6, 7, 8, 9];
my $in2 = [100, 50, 75, 60, 65, 25, 150];

my $avl_tree = AvlTree->new(sub { $_[0] <=> $_[1] });

my $render_avltree_node = sub {
    my $node = shift;

    my $color_tpl = "";
    if ($node->{factor} == 0) {
        $color_tpl = "\033[47;30m%s\033[40;37m";
    } elsif ($node->{factor} == +1) {
        $color_tpl = "\033[44;30m%s\033[40;37m";
    } elsif ($node->{factor} == -1) {
        $color_tpl = "\033[45;30m%s\033[40;37m";
    }

    my $str = sprintf("%03d", $node->{data});
    my $len = length($str);
    return sprintf($color_tpl, $str), $len;
}; # render_avltree_node

for my $i (@$in) {
    $avl_tree->insert($i);
    draw_as_text($avl_tree->{root}, $render_avltree_node, 5);
    print "-" x 80, "\n";
} # for

print "=" x 80, "\n";

for my $i (@$in) {
    $avl_tree->delete($i);
    draw_as_text($avl_tree->{root}, $render_avltree_node, 5);
    print "-" x 80, "\n";
} # for

print "~" x 80, "\n";

my $rb_tree = RBTree->new(sub { $_[0] <=> $_[1] });

my $render_rbtree_node = sub {
    my $node = shift;

    my $color_tpl = "";
    if ($node->{color} == 0) {
        $color_tpl = "\033[47;30m%s\033[40;37m";
    } elsif ($node->{color} == 1) {
        $color_tpl = "\033[41;30m%s\033[40;37m";
    }

    my $str = sprintf("%03d", $node->{data});
    my $len = length($str);
    return sprintf($color_tpl, $str), $len;
}; # render_rbtree_node

for my $i (@$in) {
    $rb_tree->insert($i);
    draw_as_text($rb_tree->{root}, $render_rbtree_node, 5);
    print "-" x 80, "\n";
} # for

print "=" x 80, "\n";

for my $i (@$in) {
    $rb_tree->delete($i);
    draw_as_text($rb_tree->{root}, $render_rbtree_node, 5);
    print "-" x 80, "\n";
} # for

print "~" x 80, "\n";

my $splay_tree = SplayTree->new(sub { $_[0] <=> $_[1] });

my $render_splaytree_node = sub {
    my $node = shift;

    my $str = sprintf("%03d", $node->{data});
    my $len = length($str);
    return $str, $len;
}; # render_splaytree_node

for my $i (@$in2) {
    $splay_tree->insert($i);
    draw_as_text($splay_tree->{root}, $render_splaytree_node, 5);
    print "-" x 80, "\n";
} # for

print "=" x 80, "\n";

for my $i (@$in2) {
    $splay_tree->search($i);
    draw_as_text($splay_tree->{root}, $render_splaytree_node, 5);
    print "-" x 80, "\n";
} # for
print "=" x 80, "\n";

for my $i (@$in2) {
    $splay_tree->delete($i);
    draw_as_text($splay_tree->{root}, $render_splaytree_node, 5);
    print "-" x 80, "\n";
} # for

1;

__END__
