#!/usr/bin/env perl

package HuffmanCoding;

use constant EOF => 256;

### 生成新节点
my $new_node = sub {
    my $ord     = shift;
    my $weight  = shift;
    my $left    = shift;
    my $right   = shift;

    return {
        ord     => $ord,
        weight  => $weight,
        left    => $left,
        right   => $right,
    };
}; # new_node

### 计算字符出现次数
my $calc_weight = sub {
    my $data = shift;

    my $tbl = {};
    foreach my $c (@$data) {
        $tbl->{$c} ||= 0;
        $tbl->{$c} += 1;
    } # foreach

    return $tbl;
}; # calc_weight

### 生成查找树
my $make_tree = sub {
    my $tbl = shift;

    my $a = [
        sort {
            $b->{weight} <=> $a->{weight} ||
            $a->{ord} <=> $a->{ord}
        } map {
            $new_node->($_, $tbl->{$_});
        } keys(%$tbl)
    ];
    my $b = [];
    my $cur  = $a;
    my $next = $b;

    my $stbl = {};
    foreach my $node (@$a) {
        $stbl->{$node->{ord}} = $node;
    } # foreach

    while (scalar(@$cur) > 1) {
        while (scalar(@$cur) > 0) {
            my $right = pop(@$cur);
            my $left  = pop(@$cur);

            if (defined($left)) {
                my $parent_node = $new_node->(undef, $left->{weight} + $right->{right}, $left, $right);

                $right->{code}   = 1;
                $right->{parent} = $parent_node;

                $left->{code}    = 0;
                $left->{parent}  = $parent_node;

                unshift(@$next, $parent_node);
            } else {
                unshift(@$next, $right);
            }
        } # while

        ($cur, $next) = ($next, $cur);
    } # while

    return $stbl, $cur->[0];
}; # make_tree

### 查找代码
my $find_codes = sub {
    my $tbl  = shift;
    my $tree = shift;
    my $c    = shift;

    my $node = $tbl->{$c};
    my $codes = [];
    while (defined($node->{parent})) {
        push(@$codes, $node->{code});
        $node = $node->{parent};
    } # while

    return $codes;
}; # find_codes

sub huffman_encode {
    my $data = shift;

    my $data_type = ref($data);
    if ($data_type eq q{}) {
        $data = [split(//, $data)];
    } elsif ($data_type eq q{SCALAR}) {
        $data = [split(//, $$data)];
    }

    if (ref($data) eq q{ARRAY}) {
        $data = [map { ord($_) } @$data];
    }
    push(@$data, EOF);

    my $tbl = $calc_weight->($data);
    my ($stbl, $tree) = $make_tree->($tbl);

    my $output = "";
    my $ord = 0;
    my $bit = 1;
    foreach my $c (@$data) {
        my $codes = $find_codes->($stbl, $tree, $c);
        while (scalar(@$codes) > 0) {
            my $code = pop(@$codes);
            if ($code == 1) {
                $ord |= $bit;
            }

            $bit <<= 1;
            if ($bit == 256) {
                $output .= chr($ord);
                $ord = 0;
                $bit = 1;
            }
        } # while
    } # foreach

    if ($bit > 1) {
        $output .= chr($ord);
    }

    return $tbl, $output;
} # huffman_encode

sub huffman_decode {
    my $tbl  = shift;
    my $data = shift;

    my $data_type = ref($data);
    if ($data_type eq q{}) {
        $data = [split(//, $data)];
    } elsif ($data_type eq q{SCALAR}) {
        $data = [split(//, $$data)];
    }

    if (ref($data) eq q{ARRAY}) {
        $data = [map { ord($_) } @$data];
    }

    my ($stbl, $tree) = $make_tree->($tbl);

    my $node = $tree;
    my $output = "";
    foreach my $ord (@$data) {
        my $bit = 1;
        while ($bit < 256) {
            my $code = $ord & $bit;
            $bit <<= 1;

            if ($node->{left}{code} == $code) {
                $node = $node->{left};
            } else {
                $node = $node->{right};
            }

            if (defined($node->{ord})) {
                # is a leaf
                if ($node->{ord} == EOF) {
                    last;
                }

                $output .= chr($node->{ord});
                $node = $tree;
            }
        } # while
    } # foreach

    return $output;
} # huffman_decode

my $encoding_str = shift @ARGV;
printf "encoding length=%d\n", length($encoding_str);

my ($tbl, $encoded_str) = huffman_encode($encoding_str);
printf "encoded length=%d\n", length($encoded_str);

my ($decoded_str) = huffman_decode($tbl, $encoded_str);
printf "decoded str=%s\n", $decoded_str;

1;

__END__
