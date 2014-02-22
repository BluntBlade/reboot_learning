#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dump qw(dump);

use BinarySearchTree;

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
        'input' => [100],
        'post'  => [100],
    },
    '02_only_left_child' => {
        'input' => [100, 50],
        'post'  => [50, 100],
    },
    '03_only_right_child' => {
        'input' => [100, 150],
        'post'  => [150, 100],
    },
    '04_min_full_tree' => {
        'input' => [100, 50, 150],
        'post'  => [50, 150, 100],
    },
    '05_left_left_child' => {
        'input' => [100, 50, 25],
        'post'  => [25, 50, 100],
    },
    '06_left_right_child' => {
        'input' => [100, 50, 75],
        'post'  => [75, 50, 100],
    },
    '07_right_left_child' => {
        'input' => [100, 150, 125],
        'post'  => [125, 150, 100],
    },
    '08_right_right_child' => {
        'input' => [100, 150, 175],
        'post'  => [175, 150, 100],
    },
    '09_mid_full_tree' => {
        'input' => [100, 50, 25, 75, 150, 125, 175],
        'post'  => [25, 75, 50, 125, 175, 150, 100],
    },
    '10_big_full_tree' => {
        'input' => [100, 50, 25, 12, 27, 75, 60, 90, 150, 125, 112, 127, 175, 160, 190],
        'post'  => [12, 27, 25, 60, 90, 75, 50, 112, 127, 125, 160, 190, 175, 150, 100],
    },
);

my @trees = sort(keys(%trees));

foreach my $id (@trees) {
    $trees{$id}{tree} = make_tree($trees{$id}{input});
    $trees{$id}{sorted} = [sort { $a <=> $b } @{$trees{$id}{input}}];
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

        my $expect     = $trees{$id}{input};
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

sub test_post_order {
    print "test_post_order ... \n";

    my $cnt   = 0;
    my $total = 0;
    foreach my $id (@trees) {
        $total += 1;

        print "test_post_order - $id ... ";

        my $post = [];
        BinarySearchTree::post_order($trees{$id}{tree}->root(), sub { push(@{$post}, $_[0]) });
        my $post_str = "@{$post}";

        my $expect     = $trees{$id}{post};
        my $expect_str = "@{$expect}";

        if ($post_str eq $expect_str) {
            print "OK\n";
            $cnt += 1;
        } else {
            print "NG\n";
            print "[${post_str}]\n";
            print "[${expect_str}]\n";
        }
    } # foreach

    print "test_post_order ... ${cnt}/${total}\n";
    return $cnt == $total;
} # test_post_order

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

sub test_clone {
    print "test_clone ... \n";

    my $cnt   = 0;
    my $total = 0;
    foreach my $id (@trees) {
        $total += 1;

        print "test_clone - $id ... ";

        my $cloned_one = $trees{$id}{tree}->clone();
        my $input = [];
        
        BinarySearchTree::in_order(
            $cloned_one->root(),
            sub { push(@{$input}, $_[0]); },
        );

        my $in_str = "@{$input}";

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

    print "test_clone ... ${cnt}/${total}\n";
    return $cnt == $total;
} # test_clone

sub test_delete {
    print "test_delete ... \n";

    my $cnt   = 0;
    my $total = 0;
    foreach my $id (@trees) {
        $total += 1;

        print "test_delete - $id ... ";

        my $tree = $trees{$id}{tree}->clone();
        my $input = [@{$trees{$id}{input}}];

        my $data_cnt = 0;

        #dump($tree);
        #print STDERR "-" x 80, "\n";

        while (scalar(@{$input}) > 0) {
            my $data = shift @{$input};
            $tree->delete($data);

            my $in2 = [];
            BinarySearchTree::in_order(
                $tree->root(),
                sub { push(@{$in2}, $_[0]); },
            );

            my $in2_str = "@{$in2}";

            my $expect = [sort { $a <=> $b } @{$input}];
            my $expect_str = "@{$expect}";

            if ($in2_str eq $expect_str) {
                $data_cnt += 1;
            }

            #dump($tree);
            #print STDERR "-" x 80, "\n";
        } # while

        #print STDERR "=" x 80, "\n";

        if ($data_cnt eq scalar(@{$trees{$id}{input}})) {
            print "OK\n";
            $cnt += 1;
        } else {
            print "NG\n";
        }
    } # foreach

    print "test_delete ... ${cnt}/${total}\n";
    return $cnt == $total;
} # test_delete

sub test_left_rotate {
    print "test_left_rotate ... \n";

    my $cnt   = 0;
    my $total = 0;
    foreach my $id (@trees) {
        $total += 1;

        print "test_left_rotate - $id ... ";

        my $tree = $trees{$id}{tree}->clone();
        my $input = [@{$trees{$id}{input}}];

        my $data_cnt = 0;

        #dump($tree);
        #print STDERR "-" x 80, "\n";

        for my $data (@{$input}) {
            #printf STDERR "data=$data\n";
            my ($node) = $tree->search_node($data);
            BinarySearchTree::left_rotate($node);

            my $in2 = [];
            BinarySearchTree::in_order(
                $tree->root(),
                sub { push(@{$in2}, $_[0]); },
            );

            my $in2_str = "@{$in2}";
            my $expect_str = "@{$trees{$id}{sorted}}";

            if ($in2_str eq $expect_str) {
                $data_cnt += 1;
            } else {
                print STDERR "$in2_str\n";
                print STDERR "$expect_str\n";
            }

            #dump($tree);
            #print STDERR "-" x 80, "\n";
        } # while

        #print STDERR "=" x 80, "\n";

        if ($data_cnt eq scalar(@{$trees{$id}{input}})) {
            print "OK\n";
            $cnt += 1;
        } else {
            print "NG\n";
        }
    } # foreach

    print "test_left_rotate ... ${cnt}/${total}\n";
    return $cnt == $total;
} # test_left_rotate

sub test_right_rotate {
    print "test_right_rotate ... \n";

    my $cnt   = 0;
    my $total = 0;
    foreach my $id (@trees) {
        $total += 1;

        print "test_right_rotate - $id ... ";

        my $tree = $trees{$id}{tree}->clone();
        my $input = [@{$trees{$id}{input}}];

        my $data_cnt = 0;

        #dump($tree);
        #print STDERR "-" x 80, "\n";

        for my $data (@{$input}) {
            #printf STDERR "data=$data\n";
            my ($node) = $tree->search_node($data);
            BinarySearchTree::right_rotate($node);

            my $in2 = [];
            BinarySearchTree::in_order(
                $tree->root(),
                sub { push(@{$in2}, $_[0]); },
            );

            my $in2_str = "@{$in2}";
            my $expect_str = "@{$trees{$id}{sorted}}";

            if ($in2_str eq $expect_str) {
                $data_cnt += 1;
            } else {
                print STDERR "$in2_str\n";
                print STDERR "$expect_str\n";
            }

            #dump($tree);
            #print STDERR "-" x 80, "\n";
        } # while

        #print STDERR "=" x 80, "\n";

        if ($data_cnt eq scalar(@{$trees{$id}{input}})) {
            print "OK\n";
            $cnt += 1;
        } else {
            print "NG\n";
        }
    } # foreach

    print "test_right_rotate ... ${cnt}/${total}\n";
    return $cnt == $total;
} # test_right_rotate

test_in_order();
test_pre_order();
test_post_order();
test_size();
test_predecessor();
test_successor();
test_clone();
test_delete();
test_left_rotate();
test_right_rotate();

1;
