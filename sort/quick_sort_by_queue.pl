#!/usr/bin/env perl

sub swap {
    my $arr = shift;
    my $a   = shift;
    my $b   = shift;

    ($arr->[$a], $arr->[$b]) = ($arr->[$b], $arr->[$a]);
} # swap

sub quick_sort {
    my $arr     = shift;
    my $left    = shift;
    my $right   = shift;

    my @queue   = ([$left, $right]);

    while (scalar(@queue) > 0) {
        my $left    = $queue[0][0];
        my $right   = $queue[0][1];

        shift(@queue);

        my $len = $right - $left + 1;
        my $pivot = $left + int(rand($len));
        my $pivot_val = $arr->[$pivot];

        swap($arr, $pivot, $right);

        my $next_big = $left;
        my $next_small = $right - 1;

        while (1) {

            while ($next_big < $right && $arr->[$next_big] <= $pivot_val) {
                $next_big += 1;
            } # while
            while ($next_small >= $next_big && $pivot_val <= $arr->[$next_small]) {
                $next_small -= 1;
            } # while

            if ($next_big < $next_small) {
                swap($arr, $next_big, $next_small);
                $next_big += 1;
                $next_small -= 1;
            } else {
                last;
            }

        } # while

        swap($arr, $next_big, $right);
        if ($left < $next_small) {
            push(@queue, [$left, $next_small]);
        }
        if ($next_big + 1 < $right) {
            push(@queue, [$next_big + 1, $right]);
        }
    } # while
} # quick_sort

my $arr = [ 10, 12, 6, 45, 0, 7, 19, 2, 16, 19, 3, 5, 98, 28, 34, 20, 1 ];
quick_sort($arr, 0, scalar(@$arr) - 1);
print "@$arr\n";

$arr = [ 19, 10, 12, 6, 45, 0, 7, 19, 2, 16, 19, 3, 5, 98, 28, 34, 20, 1 ];
quick_sort($arr, 0, scalar(@$arr) - 1);
print "@$arr\n";
