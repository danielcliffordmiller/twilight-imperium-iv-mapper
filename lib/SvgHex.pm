package SvgHex;

require Exporter;
use strict;

use feature qw(say);

use constant RINGS => 3;

use constant LENGTH => 50;

our @ISA= qw(Exporter);

our @EXPORT = qw(hex_num_tiles hex_coords);

sub hex_num_tiles {
    my ($ring) = @_;
    return $ring == 0 ? 1 : $ring * 6;
}

sub hex_direction {
    my $direction = shift;
    return (
	cos( 0.5236 + 1.0472 * $direction * -1 ) * 1.732 * LENGTH, 
	- sin( 0.5236 + 1.0472 * $direction * -1 ) * 1.732 * LENGTH 
    );
}

sub hex_path {
    my ($r, $n) = @_;
    
    return () if $r == 0 && $n == 0;

    my @path = ( 0 );

    push @path, 5 foreach (0..($r-2));

    push @path, 1 foreach (0..($n % $r - 1));

    { use integer;
	return map { ( $_ + $n / $r ) % 6 } @path;
    }
}

sub hex_coords {
    my @path = hex_path(@_);

    my ($x, $y) = (0, 0);
    my ($dx, $dy);

    # $d is for direction
    for my $d (@path) {
	($dx, $dy) = hex_direction( $d );
	$x += $dx; $y += $dy;
    }

    return map { sprintf "%.1f", $_ } ($x, $y);
}

1;
