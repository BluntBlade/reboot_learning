#!/usr/bin/env perl

use strict;
use warnings;

package HuffmanCoding::CodeSink;

sub new {
    my $class = shift || __PACKAGE__;
    my $self = {
        byte    => 0,
        mask    => 1,
        bits    => [],
        output  => "",
        bitcnt  => 0,
    };

    return bless $self, $class;
} # new

sub push_bit {
    my $self = shift;
    my $bit  = shift;
    push(@{$self->{bits}}, $bit);
    $self->{bitcnt} += 1;
    return $self;
} # push_bit

sub pack {
    my $self = shift;

    while (scalar(@{$self->{bits}}) > 0) {
        my $bit = pop(@{$self->{bits}});
        if ($bit == 1) {
            $self->{byte} |= $self->{mask};
        }

        $self->{mask} <<= 1;
        if ($self->{mask} == 256) {
            $self->{output} .= chr($self->{byte});
            $self->{byte} = 0;
            $self->{mask} = 1;
        }
    } # while

    return $self;
} # pack

sub finish {
    my $self = shift;
    if ($self->{mask} > 1) {
        $self->{output} .= chr($self->{byte});
    }
    return $self;
} # finish

sub output {
    my $self = shift;
    return $self->{output};
} # output

package HuffmanCoding::ByteStringPump;

use constant BYTE_EOF => 256;
use constant BYTE_ESC => 257;

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

sub esc_sym {
   return BYTE_ESC;
} # esc_sym

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
        model => $model,
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
    $self->{node} = $self->{model}{root};
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

        parent  => undef,
        left    => $left,
        right   => $right,

        next    => undef,
        prev    => undef,
    };
}; # new_node

sub new {
    my $class = shift || __PACKAGE__;
    my $eof_sym = shift;
    my $esc_sym = shift || -1;
    my $self = {
        tbl => {},
        eof => $eof_sym,
        esc => $esc_sym,
    };

    my $eof_node = $new_node->($eof_sym, 1);
    my $esc_node = $new_node->($esc_sym, 1);
    my $root = $new_node->(undef, 2, $eof_node, $esc_node);

    $eof_node->{bit}        = 0;
    $eof_node->{parent}     = $root;
    $esc_node->{bit}        = 1;
    $esc_node->{parent}     = $root;

    $eof_node->{next}       = $esc_node;
    $esc_node->{next}       = $root;

    $root->{prev}           = $esc_node;
    $esc_node->{prev}       = $eof_node;

    $self->{head}           = $eof_node;
    $self->{root}           = $root;

    $self->{tbl}{$eof_sym}  = $eof_node;
    $self->{tbl}{$esc_sym}  = $esc_node;

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

sub esc_sym {
    my $self = shift;
    return $self->{esc};
} # esc_sym

my $swap_node = sub {
    my $a = shift;
    my $b = shift;

    ### exchange the position in the binary tree
    if (defined($a->{parent})) {
        if ($a->{parent}{left} == $a) {
            $a->{parent}{left} = $b;
        } else {
            $a->{parent}{right} = $b;
        }
    }
    if (defined($b->{parent})) {
        if ($b->{parent}{left} == $b) {
            $b->{parent}{left} = $a;
        } else {
            $b->{parent}{right} = $a;
        }
    }

    ($a->{parent}, $b->{parent}) = ($b->{parent}, $a->{parent});

    ### exchange the position in the sibling chain
    ($a->{bit}, $b->{bit}) = ($b->{bit}, $a->{bit});
}; # swap_node

sub count {
    my $self = shift;
    my $sym  = shift;

    my $node = $self->{tbl}{$sym};
    if (not defined($node)) {
        $node = $self->{tbl}{$sym} = $new_node->($sym, 0);

        ### add the new node into the chain
        my $head_node = $self->{head};
        my $new_parent = $new_node->(
            undef,
            $node->{weight} + $head_node->{weight},
            $node,
            $head_node
        );
        $new_parent->{bit}     = $head_node->{bit};
        $new_parent->{parent}  = $head_node->{parent};

        if ($head_node->{parent}{left} == $head_node) {
            $head_node->{parent}{left} = $new_parent;
        } else {
            $head_node->{parent}{right} = $new_parent;
        }

        $node->{bit}            = 0;
        $node->{parent}         = $new_parent;
        $head_node->{bit}       = 1;
        $head_node->{parent}    = $new_parent;

        $head_node->{next}{prev} = $new_parent;
        $new_parent->{prev}     = $head_node;
        $head_node->{prev}      = $node;

        $new_parent->{next}     = $head_node->{next};
        $head_node->{next}      = $new_parent;
        $node->{next}           = $head_node;

        $self->{head} = $node;
    } # if

    while (defined($node)) {
        $node->{weight} += 1;

        ### TODO: update tree
        my $cur = $node->{next};
        my $pos = undef;
        while (defined($cur) && $cur->{weight} < $node->{weight}) {
            $pos = $cur;
            $cur = $cur->{next};
        } # while

        if (defined($pos)) {
            $swap_node->($pos, $node);

            my $tmp = $pos->{prev};
            $pos->{prev} = $node->{prev};
            if (defined($pos->{prev})) {
                $pos->{prev}{next} = $pos;
            }
            $node->{prev} = $tmp;
            if (defined($node->{prev})) {
                $node->{prev}{next} = $node;
            }

            $tmp = $pos->{next};
            $pos->{next} = $node->{next};
            if (defined($pos->{next})) {
                $pos->{next}{prev} = $pos;
            }
            $node->{next} = $tmp;
            if (defined($node->{next})) {
                $node->{next}{prev} = $node;
            }
        }

        $node = $node->{parent};
    } # while

    ### TODO: reduce counts proportionally
} # count

sub travel_code_bits {
    my $self = shift;
    my $sym  = shift;
    my $proc = shift;

    my $node = $self->{tbl}{$sym};
    if (not defined($node)) {
        return undef;
    }

    ### 编码的最后一位首先处理
    ### 编码的第一位最后处理
    while (defined($node->{parent})) {
        $proc->($node->{bit});
        $node = $node->{parent};
    } # while

    return 1;
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
    # 按权重排序
    my @sorted = sort {
        $b->{weight} <=> $a->{weight} ||
        $a->{sym}    <=> $b->{sym}
    } values(%{$model->{tbl}});

    # 生成排序链表
    for (my $i = 1; $i < scalar(@sorted); $i += 1) {
        $sorted[$i]->{next} = $sorted[$i - 1];
    } # for

    my $tail = $sorted[-1];
    while (defined($tail->{next})) {
        my $right = $tail;
        my $left  = $tail->{next};

        $tail = $left->{next};

        my $parent_node = $new_node->(undef, $left->{weight} + $right->{weight}, $left, $right);

        $right->{bit}    = 1;
        $right->{parent} = $parent_node;

        $left->{bit}     = 0;
        $left->{parent}  = $parent_node;

        my $next = $tail;
        my $prev = undef;
        while (defined($next) && $next->{weight} < $parent_node->{weight}) {
            $prev = $next;
            $next = $next->{next};
        } # while

        $parent_node->{next} = $next;
        if (defined($prev)) {
            $prev->{next} = $parent_node;
        } else {
            $tail = $parent_node;
        }
    } # while

    $model->{root} = $tail;
    return $model;
} # make_static_model

package HuffmanCoding;

sub huffman_encode {
    my $data = shift;

    my $sym_pump = HuffmanCoding::ByteStringPump->new($data);
    my $model    = HuffmanCoding::SymbolModel::make_static_model($sym_pump);
    $sym_pump->reset();

    my $code_sink = HuffmanCoding::CodeSink->new();
    my $sym = undef;
    do {
        $sym = $sym_pump->get();

        $model->travel_code_bits($sym, sub {
            $code_sink->push_bit(shift);
        });
        $code_sink->pack();
    } while($sym != $sym_pump->eof_sym()); 

    $code_sink->finish();
    return $model, $code_sink->output();
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
            my $bit = ($byte & $mask) ? 1 : 0;
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

sub huffman_adaptive_encode {
    my $data = shift;

    my $sym_pump = HuffmanCoding::ByteStringPump->new($data);
    my $model    = HuffmanCoding::SymbolModel->new($sym_pump->eof_sym(), $sym_pump->esc_sym());

    my $code_sink = HuffmanCoding::CodeSink->new();
    while (1) {
        my $sym = $sym_pump->get();
        if (not defined($sym)) {
            last;
        }

        ### 输出编码
        my $found = $model->travel_code_bits($sym, sub {
            $code_sink->push_bit(shift);
        });
        if ($found) {
            $code_sink->pack();
            if ($sym == $model->eof_sym()) { 
                $code_sink->finish();
                last;
            }

            ### 对符号计数
            $model->count($sym);
            next;
        }

        ### 输出转义符
        my $esc_sym = $model->esc_sym();
        $model->travel_code_bits($esc_sym, sub {
            $code_sink->push_bit(shift);
        });
        $code_sink->pack();

        ### 输出符号
        foreach my $bit (split(//, unpack("B*", chr($sym)))) {
            $code_sink->push_bit($bit);
        } # foreach
        $code_sink->pack();

        ### 对符号计数
        $model->count($sym);
    } # while

    return $code_sink->output();
} # huffman_adaptive_encode

use constant TRACING => 0;
use constant OUTPUTTING => 1;

sub huffman_adaptive_decode {
    my $data = shift;

    my $sym_pump = HuffmanCoding::ByteStringPump->new($data);
    my $model    = HuffmanCoding::SymbolModel->new($sym_pump->eof_sym(), $sym_pump->esc_sym());

    my $tracer = $model->new_tracer();
    my $output = "";
    my $real_sym  = 0;
    my $real_mask = 1;
    my $state  = TRACING;
    while (!$sym_pump->eof()) {
        my $byte = $sym_pump->get();
        my $mask = 1;
        while ($mask < 256) {
            my $bit = ($byte & $mask) ? 1 : 0;
            $mask <<= 1;

            if ($state == TRACING) {
                my $sym = $tracer->trace($bit);
                if (not defined($sym)) {
                    next;
                }

                if ($sym == $model->esc_sym()) {
                    $state = OUTPUTTING;
                    next;
                }

                if ($sym == $model->eof_sym()) {
                    return $output;
                }

                $output .= chr($sym);
                $model->count($sym);
                $tracer->reset();
            } else {
                $real_sym |= ($bit > 0) ? $real_mask : 0;
                $real_mask <<= 1;

                ### output the origin code
                if ($real_mask == 256) {
                    $output .= chr($real_sym);
                    $model->count($real_sym);
                    $tracer->reset();

                    $real_sym  = 0;
                    $real_mask = 1;

                    $state = TRACING;
                }
            } # if
        } # while
    } # while

    return $output;
} # huffman_adaptive_decode

my $encoding_str = shift @ARGV || '';
printf "encoding length=%d\n", length($encoding_str);

my ($model, $encoded_str) = huffman_encode($encoding_str);
printf "encoded length=%d\n", length($encoded_str);

my ($decoded_str) = huffman_decode($model, $encoded_str);
printf "decoded str=%s\n", $decoded_str;

printf "equality=%d\n", $encoding_str eq $decoded_str;

my ($encoded_str2) = huffman_adaptive_encode($encoding_str);
printf "encoded length=%d\n", length($encoded_str2);

my ($decoded_str2) = huffman_adaptive_decode($encoded_str2);
printf "decoded str=%s\n", $decoded_str2;

printf "equality=%d\n", $encoding_str eq $decoded_str2;

1;

__END__
