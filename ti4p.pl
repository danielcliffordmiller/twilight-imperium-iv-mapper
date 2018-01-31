#!/usr/bin/perl -w
#
use strict;
use POSIX;

use Storable;

use feature qw(say);

use constant H_WIDTH => 8;
use constant D_LENGTH => 3;

sub H_BLANK() { return ' 'x(H_WIDTH) }
sub H_LINE() { return '_'x(H_WIDTH) }
sub D_BLANK() { return ' 'x(D_LENGTH) }

use constant LEFT   => '/  ';
use constant RIGHT  => '  \\';

sub surround {
    my ($str, $width) = @_;
    return ' 'x$width unless $str;
    my $pad = $width - length($str);
    return $pad > 0 ?
	sprintf '%'.($width).'s', $str.(' 'x(ceil($pad/2))) :
	substr($str, 0, $width);
}

my $print_data = [ 0, [ 1, {} ], [ 2, {} ] ];

sub print_hex {
    my ($txt) = @_;
    say surround( '_'x 8, 14 );
    say '  /'.(' 'x8).'\  ';
    say ' / '.(' 'x8).' \ ';
    say '/  '.(surround($txt, 8)).'  \\';
    say '\  '.(' 'x8).'  /';
    say ' \ '.(' 'x8).' / ';
    say '  \\'.('_'x8).'/  ';
}

sub max {
    my $v = shift;
    return $v unless scalar @_;
    return  $v > $_[0] ? max( $v, @_[1..$#_] ) : max(@_);
}

sub horizontals {
    my ($opening, $open, $closing, $even) = @_;
    my @hmaps = map {
	my $ret = [];
	for my $val (@$_) { $ret->[$val] = 1 }
	$ret;
    } ($opening, $open, $closing);

    my $until = max( map { scalar @$_ } @hmaps );

    my $ws = D_BLANK . H_BLANK;
    #my $ws = ' 'x(D_LENGTH);
#    my $ws = $even ?
#	' ' x (D_LENGTH*2) . ' ' x H_WIDTH :
#	' ' x (D_LENGTH);
    my $ret = "";
    for (my $i=0; $i <= $until; $i++) {
	$ret .= $hmaps[1][$i] || $i > 0 && $hmaps[2][$i-1] ? LEFT : D_BLANK;
	$ret .= H_BLANK;
	if ( $hmaps[1][$i] || $hmaps[2][$i] ) {
	    $ret .= RIGHT;
	} else {
	    $ret .= D_BLANK;
	}
	$ret .= $hmaps[0][$i] || $hmaps[2][$i] ? H_LINE : H_BLANK;
	#$ret .= ' 'x(H_WIDTH);
	#$ret .= LEFT;
    }
    say '"'.$ret.'"';
    return $ws.join $ws x 2, map {
	$_ ? H_LINE : H_BLANK
    } @{$hmaps[0]};
}

#say horizontals([0], [], [], 0);
say horizontals([0], [1], [1], 1);

sub print_map {
    my ($data) = @_;

    for (my $i=0; $i < scalar @$data; $i++) {
    }
}
#$print_map($print_data);

print_hex("MC 1/6");
