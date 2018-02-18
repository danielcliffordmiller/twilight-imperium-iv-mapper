package Utils;

use strict;

use v5.12;

require Exporter;

our @ISA = qw(Exporter);

our @EXPORT = qw(partition);

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

sub to_string {
    return '('.(join ',' => map { to_string($_) } @_).')' if scalar @_ > 1;
    my $var = shift;
    given(ref $var) {
	when('ARRAY') {
	    return '['.(join ',' => map { to_string($_) } @$var).']';
	}
	when('HASH') {
	    return '{'.(join ',' => map { $_.'=>"'.$var->{$_}.'"' } keys %$var).'}';
	}
    }
    return $var;
}

1;
