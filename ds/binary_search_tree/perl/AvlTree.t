#!/usr/bin/env perl

use AvlTree;

use Data::Dump qw(dump);

my $in = [100, 50, 75, 60, 65, 25, 150, 175, 12, 200, 1, 2, 3, 4, 5, 6, 7, 8, 9];
my $tree = AvlTree->new(sub { $_[0] <=> $_[1] });

for my $i (@$in) {
    print STDERR "$i\n";
    $tree->insert($i);
    dump($tree->{root});
    print STDERR "-" x 80, "\n";
} # for

print STDERR "=" x 80, "\n";

for my $i (@$in) {
    print STDERR "$i\n";
    $tree->delete($i);
    dump($tree->{root});
    print STDERR "-" x 80, "\n";
} # for
