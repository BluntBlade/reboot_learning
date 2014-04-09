#!/usr/bin/env perl

use strict;
use warnings;

package HuffmanCoding::ByteStringPump;

use constant BYTE_EOF => 256;

sub new {
    my $class = shift || __PACKAGE__;
    my $str = shift;
    my $self = {
        pos => 0,
        str => $str,
        len => length($str),
    };
    return bless $self, $class;
} # new

sub eof_sym {
   return BYTE_EOF;
} # eof_sym

sub eof {
    my $self = shift;
    return $self->{pos} == $self->{len};
} # eof

sub reset {
    my $self = shift;
    $self->{pos} = 0;
    return $self;
} # reset

sub get {
    my $self = shift;
    if ($self->eof()) {
        return BYTE_EOF;
    }

    my $chr = substr($self->{str}, $self->{pos}, 1);
    $self->{pos} += 1;
    return ord($chr);
} # get 

package HuffmanCoding::SymbolModel::Tracer;

sub new {
    my $class = shift || __PACKAGE__;
    my $model = shift;
    my $self  = {
        root  => $model->{root},
        node  => $model->{root},
    };
    return bless $self, $class;
} # new

sub trace {
    my $self = shift;
    my $bit  = shift;

    if ($self->{node}{left}{bit} == $bit) {
        $self->{node} = $self->{node}{left};
    } else {
        $self->{node} = $self->{node}{right};
    }

    return $self->{node}{sym};
} # trace

sub reset {
    my $self = shift;
    $self->{node} = $self->{root};
    return $self;
} # reset

package HuffmanCoding::SymbolModel;

### 生成新节点
my $new_node = sub {
    my $sym     = shift;
    my $weight  = shift;
    my $left    = shift;
    my $right   = shift;

    return {
        sym     => $sym,
        weight  => $weight,
        left    => $left,
        right   => $right,
    };
}; # new_node

sub new {
    my $class = shift || __PACKAGE__;
    my $eof = shift;
    my $self = {
        tbl => {},
        eof => $eof,
    };
    return bless $self, $class;
} # new

sub new_tracer {
    my $self = shift;
    return HuffmanCoding::SymbolModel::Tracer->new($self);
} # new_tracer

sub eof_sym {
    my $self = shift;
    return $self->{eof};
} # eof_sym

sub count {
    my $self = shift;
    my $sym  = shift;

    if (not exists($self->{tbl}{$sym})) {
        $self->{tbl}{$sym} = $new_node->($sym, 1);
        ### TODO: add the new node into the chain
    } else {
        $self->{tbl}{$sym}{weight} += 1;
        ### TODO: reduce counts proportionally
    }
    ### TODO: update tree
} # count

sub travel_code_bits {
    my $self = shift;
    my $sym  = shift;
    my $proc = shift;

    my $node = $self->{tbl}{$sym};
    if (not defined($node)) {
        return;
    }

    ### 编码的最后一位首先处理
    ### 编码的第一位最后处理
    while (defined($node->{parent})) {
        $proc->($node->{bit});
        $node = $node->{parent};
    } # while

    return;
} # travel_code_bits

### class method
sub make_static_model {
    my $sym_pump = shift;

    my $model = HuffmanCoding::SymbolModel->new($sym_pump->eof_sym());

    ### 计算符号出现次数
    while ((my $sym = $sym_pump->get()) != $model->{eof}) {
        if (not exists($model->{tbl}{$sym})) {
            $model->{tbl}{$sym} = $new_node->($sym, 1);
        } else {
            $model->{tbl}{$sym}{weight} += 1;
        }
    } # while
    $model->{tbl}{$model->{eof}} = $new_node->($model->{eof}, 1);

    ### 生成查找树
    my $cur = [
        sort {
            $b->{weight} <=> $a->{weight} ||
            $a->{sym}    <=> $b->{sym}
        } values(%{$model->{tbl}})
    ];
    my $next = [];

    while (scalar(@$cur) > 1) {
        while (scalar(@$cur) > 0) {
            my $right = pop(@$cur);
            my $left  = pop(@$cur);

            if (defined($left)) {
                my $parent_node = $new_node->(undef, $left->{weight} + $right->{weight}, $left, $right);

                $right->{bit}    = 1;
                $right->{parent} = $parent_node;

                $left->{bit}     = 0;
                $left->{parent}  = $parent_node;

                unshift(@$next, $parent_node);
            } else {
                unshift(@$next, $right);
            }
        } # while

        ($cur, $next) = ($next, $cur);
    } # while

    $model->{root} = $cur->[0];
    return $model;
} # make_static_model

package HuffmanCoding;

sub huffman_encode {
    my $data = shift;

    my $sym_pump = HuffmanCoding::ByteStringPump->new($data);
    my $model    = HuffmanCoding::SymbolModel::make_static_model($sym_pump);
    $sym_pump->reset();

    my $output = "";
    my $byte = 0;
    my $mask = 1;
    while (1) {
        my $sym = $sym_pump->get();

        my @bits = ();
        $model->travel_code_bits($sym, sub {
            my $bit = shift;
            push(@bits, $bit);
        });

        while (scalar(@bits) > 0) {
            my $bit = pop(@bits);
            if ($bit == 1) {
                $byte |= $mask;
            }

            $mask <<= 1;
            if ($mask == 256) {
                $output .= chr($byte);
                $byte = 0;
                $mask = 1;
            }
        } # while

        if ($sym == $sym_pump->eof_sym()) {
            last;
        }
    } # foreach

    if ($mask > 1) {
        $output .= chr($byte);
    }

    return $model, $output;
} # huffman_encode

sub huffman_decode {
    my $model = shift;
    my $data  = shift;

    my $sym_pump = HuffmanCoding::ByteStringPump->new($data);

    my $tracer = $model->new_tracer();
    my $output = "";
    while (!$sym_pump->eof()) {
        my $byte = $sym_pump->get();
        my $mask = 1;
        while ($mask < 256) {
            my $bit = $byte & $mask;
            $mask <<= 1;

            my $sym = $tracer->trace($bit);
            if (not defined($sym)) {
                next;
            }

            if ($sym == $model->eof_sym()) {
                last;
            }

            $output .= chr($sym);
            $tracer->reset();
        } # while
    } # foreach

    return $output;
} # huffman_decode

my $encoding_str = shift @ARGV || '';
printf "encoding length=%d\n", length($encoding_str);

my ($model, $encoded_str) = huffman_encode($encoding_str);
printf "encoded length=%d\n", length($encoded_str);

my ($decoded_str) = huffman_decode($model, $encoded_str);
printf "decoded str=%s\n", $decoded_str;

printf "equality=%d\n", $encoding_str eq $decoded_str;

1;

__END__
