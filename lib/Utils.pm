package Utils;

use strict;

use v5.12;

require Exporter;

our @ISA = qw(Exporter);

our @EXPORT_OK = qw(partition get_tag draw shuffle random_shift);

sub partition {
    my @subs;

    push @subs, shift until ref $_[0] ne 'CODE';

    my @res = ( map { [] } @subs, [] );

    item: foreach my $item (@_) {
	for my $i (0 .. $#subs) {
	    if ( $subs[$i]($item) ) {
	        push @{ $res[$i] }, $item;
	        next item;
	    }
	    #push @{ $res[$i] }, $item and next item if $subs[$i]($item);
	    # ^^ does the same thing but is less clear
	}
	push @{ $res[-1] }, $item;
    }

    return @res;
}

sub cache {
    my $fn = shift;
    my %data;
    my $m = shift || sub { join '.' => @_ };
    return sub { $data{ $m->(@_) } ||= $fn->(@_) };
}

sub characters { 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'; }

sub get_tag {
    my $n = shift || 8;
    my $c = characters;
    return join '', map { substr $c, int rand length $c, 1 } (0 .. $n-1);
}

sub draw {
    my $items = shift;
    my $item = $items->[int(rand(@$items))];
    return $item, [ grep { $_ != $item } @$items ];
}

sub shuffle {
    my $items = [ @_ ];
    my (@res, $i);
    while (@$items) {
	($i, $items) = draw( $items );
	push @res, $i;
    }
    return @res;
}

sub random_shift {
    my @items = @_;

    my @res = splice @items, int(rand(@items));
    
    return ( @res, @items );
}

sub to_string {
    return '('.(join ',' => map { to_string($_) } @_).')' if scalar @_ > 1;
    my $var = shift;
    #return '['.(join ',' => map { to_string($_) } @$var).']' if ref $var eq 'ARRAY';
    #return '{'.(join ',' => map { $_.'=>'.to_string($var->{$_}) } keys %$var).'}' if ref $var eq 'HASH';
    return "[$var]" if ref $var eq 'ARRAY';
    return "{$var}" if ref $var eq 'HASH';
    return $var;
}

1;
