#!/usr/bin/env perl

use strict;
use warnings;

require "binary_search_tree.pm";

sub make_tree {
    my $arr = shift;

    my $tree = BinarySearchTree->new(sub { $_[0] <=> $_[1]; });
    foreach my $i (@{$arr}) {
        $tree->insert($i);
    } # foreach

    return $tree;
} # make_tree

sub list_in_order {
    my $tree = shift;

    my $arr = [];
    BinarySearchTree::in_order($tree->root(), sub { push(@{$arr}, $_[0]) });
    return $arr;
} # list_in_order

my %trees = (
    '01_only_root' => {
        'in' => [100],
    },
    '02_only_left_child' => {
        'in' => [100, 50],
    },
    '03_only_right_child' => {
        'in' => [100, 150],
    },
    '04_min_full_tree' => {
        'in' => [100, 50, 150],
    },
    '05_left_left_child' => {
        'in' => [100, 50, 25],
    },
    '06_left_right_child' => {
        'in' => [100, 50, 75],
    },
    '07_right_left_child' => {
        'in' => [100, 150, 125],
    },
    '08_right_right_child' => {
        'in' => [100, 150, 175],
    },
    '09_mid_full_tree' => {
        'in' => [100, 50, 25, 75, 150, 125, 175],
    },
    '10_big_full_tree' => {
        'in' => [100, 50, 25, 12, 27, 75, 60, 90, 150, 125, 112, 127, 175, 160, 190],
    },
);

my @trees = sort(keys(%trees));

foreach my $id (@trees) {
    $trees{$id}{tree} = make_tree($trees{$id}{in});
    $trees{$id}{sorted} = [sort { $a <=> $b } @{$trees{$id}{in}}];
    $trees{$id}{in_order} = list_in_order($trees{$id}{tree});
} # foreach

sub test_in_order {
    print "test_in_order ... \n";

    my $cnt   = 0;
    my $total = 0;
    foreach my $id (@trees) {
        $total += 1;

        print "test_in_order - $id ... ";

        my $in_str = "@{$trees{$id}{in_order}}";

        my $expect     = $trees{$id}{sorted};
        my $expect_str = "@{$expect}";

        if ($in_str eq $expect_str) {
            print "OK\n";
            $cnt += 1;
        } else {
            print "NG\n";
            print "[${in_str}]\n";
            print "[${expect_str}]\n";
        }
    } # foreach

    print "test_in_order ... ${cnt}/${total}\n";
    return $cnt == $total;
} # test_in_order

sub test_pre_order {
    print "test_pre_order ... \n";

    my $cnt   = 0;
    my $total = 0;
    foreach my $id (@trees) {
        $total += 1;

        print "test_pre_order - $id ... ";

        my $pre = [];
        BinarySearchTree::pre_order($trees{$id}{tree}->root(), sub { push(@{$pre}, $_[0]) });
        my $pre_str = "@{$pre}";

        my $expect     = $trees{$id}{in};
        my $expect_str = "@{$expect}";

        if ($pre_str eq $expect_str) {
            print "OK\n";
            $cnt += 1;
        } else {
            print "NG\n";
            print "[${pre_str}]\n";
            print "[${expect_str}]\n";
        }
    } # foreach

    print "test_pre_order ... ${cnt}/${total}\n";
    return $cnt == $total;
} # test_pre_order

sub test_predecessor {
    print "test_predecessor ... \n";

    my $cnt   = 0;
    my $total = 0;
    foreach my $id (@trees) {
        $total += 1;

        print "test_predecessor - $id ... ";

        my $sorted  = $trees{$id}{sorted};
        my $tree    = $trees{$id}{tree};
        my $val_cnt = 0;
        foreach my $i (1..scalar(@{$sorted}) - 1) {
            my $node = $tree->search_node($sorted->[$i]);
            if (not defined($node)) {
                last;
            }
            my $predecessor = BinarySearchTree::predecessor($node);
            if (not defined($predecessor)) {
                last;
            }
            if ($predecessor->{data} != $sorted->[$i - 1]) {
                last;
            }
            $val_cnt += 1;
        } # foreach

        if ($val_cnt eq (scalar(@{$sorted}) - 1)) {
            print "OK\n";
            $cnt += 1;
        } else {
            print "NG\n";
        }
    } # foreach

    print "test_predecessor ... ${cnt}/${total}\n";
    return $cnt == $total;
} # test_predecessor

sub test_successor {
    print "test_successor ... \n";

    my $cnt   = 0;
    my $total = 0;
    foreach my $id (@trees) {
        $total += 1;

        print "test_successor - $id ... ";

        my $sorted  = $trees{$id}{sorted};
        my $tree    = $trees{$id}{tree};
        my $val_cnt = 0;
        foreach my $i (0..scalar(@{$sorted}) - 2) {
            my $node = $tree->search_node($sorted->[$i]);
            if (not defined($node)) {
                last;
            }
            my $successor = BinarySearchTree::successor($node);
            if (not defined($successor)) {
                last;
            }
            if ($successor->{data} != $sorted->[$i + 1]) {
                last;
            }
            $val_cnt += 1;
        } # foreach

        if ($val_cnt eq (scalar(@{$sorted}) - 1)) {
            print "OK\n";
            $cnt += 1;
        } else {
            print "NG\n";
        }
    } # foreach

    print "test_successor ... ${cnt}/${total}\n";
    return $cnt == $total;
} # test_successor

sub test_size {
    print "test_size ... \n";

    my $cnt   = 0;
    my $total = 0;
    foreach my $id (@trees) {
        $total += 1;

        print "test_size - $id ... ";

        my $sorted  = $trees{$id}{sorted};
        my $tree    = $trees{$id}{tree};

        if ($tree->size() == (scalar(@{$sorted}))) {
            print "OK\n";
            $cnt += 1;
        } else {
            print "NG\n";
        }
    } # foreach

    print "test_size ... ${cnt}/${total}\n";
    return $cnt == $total;
} # test_size

test_in_order();
test_pre_order();
test_size();
test_predecessor();
test_successor();
