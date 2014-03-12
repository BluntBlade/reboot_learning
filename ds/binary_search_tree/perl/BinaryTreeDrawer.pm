#!/usr/bin/env perl

use strict;
use warnings;

use BinaryTree;

package BinaryTreeDrawer;

sub draw_text {
    my $root = shift;

    my @nodes = ();
    my $callback = sub {
        my $data = shift;
        my $node = shift;
        my $level = shift;
        my $id = shift;

        push @nodes, {
            id    => $id,
            level => $level,
            data  => $data,
            node  => $node,
        };
    };

    my $width = 5;
    my $format = sub {
        my $data = shift;
        my $node = shift;
        if (not defined($data)) {
            return " " x $width;
        }

        my $c = $node->{color};
        if (not defined($c)) {
            $c = $node->{factor};
        }
        my $str = sprintf("%3d $c", $data);
        my $len = $width - length($str);
        my $leading  = " " x ($len / 2 + ($len & 0x1));
        my $trailing = " " x ($len / 2);
        return $leading . $str . $trailing;
    };

    BinaryTree::travel_by_breadth_first_search(
        $root,
        $callback,
        1,
    );

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

        $rect = $format->($node->{data}, $node->{node}) . $rect;
    } # while

    if ($level > 0) {
        unshift @rects, $rect;
        $rect = "";
        $width *= 2;
    }

    for my $rect (@rects) {
        print "$rect\n";
    } # for
} # draw_text

use AvlTree;
use RBTree;

my $in = [100, 50, 75, 60, 65, 25, 150, 175, 12, 200, 1, 2, 3, 4, 5, 6, 7, 8, 9];

=begin
my $tree = AvlTree->new(sub { $_[0] <=> $_[1] });

for my $i (@$in) {
    $tree->insert($i);
    draw_text($tree->{root});
    print "-" x 80, "\n";
} # for

print "=" x 80, "\n";
=cut

my $tree2 = RBTree->new(sub { $_[0] <=> $_[1] });

for my $i (@$in) {
    $tree2->insert($i);
    draw_text($tree2->{root});
    print "-" x 80, "\n";
} # for

print "=" x 80, "\n";

for my $i (@$in) {
    $tree2->delete($i);
    draw_text($tree2->{root});
    print "-" x 80, "\n";
} # for

1;

__END__
