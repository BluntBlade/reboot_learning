#!/usr/bin/env perl

use strict;
use warnings;

sub max {
    my $lhs = shift;
    my $rhs = shift;
    if ($lhs > $rhs) {
        return $lhs;
    }
    return $rhs;
} # max

sub dynamic_package {
    my $volumn = shift;
    my $items  = shift;

    my $states = [];
    for (my $i = 0; $i <= scalar(@$items); $i += 1) {
        push(@$states, [ 0, (0) x $volumn ]);
    } # for

    for (my $i = 1; $i <= scalar(@$items); $i += 1) {
        for (my $j = 1; $j <= $volumn; $j += 1) {
            if ($j >= $items->[$i - 1]{weight}) {
                $states->[$i][$j] = max($states->[$i - 1][$j], $states->[$i - 1][$j - $items->[$i - 1]{weight}] + $items->[$i - 1]{value});
            } else {
                $states->[$i][$j] = $states->[$i - 1][$j];
            }
        } # for
    } # for

    local $" = "\t";
    for (my $i = 0; $i <= scalar(@$items); $i += 1) {
        print "@{$states->[$i]}\n";
    } # for
} # dynamic_package

dynamic_package(20, [
    { weight => 6, value  => 8, },
    { weight => 4, value  => 10, },
    { weight => 2, value  => 14, },
    { weight => 1, value  => 5, },
    { weight => 3, value  => 5, },
]);
