package SvgHex;

require Exporter;
use strict;

use feature qw(say switch);

use constant RINGS => 3;

use constant LENGTH => 50;

our @ISA= qw(Exporter);

our @EXPORT = qw(hex_move hex_num_tiles hex_coords);

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

sub hex_move {
    my ($x, $y, $direction) = @_;
    
    my ($dx, $dy) = hex_direction( $direction );
    return ( $x + $dx, $y + $dy );
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
	#( $dx, $dy ) = @{ hex_move( $dx, $dy, $d ) };
    }

    return map { sprintf "%.1f", $_ } ($x, $y);
    #return sprintf "%.1f, %.1f", $x, $y;
}

#my ($r, $n) = (1, 5);
#say "($r, $n): [".( join ', ', @{ hex_path( $r, $n ) } )."]";
#say "($r, $n): ".hex_coords( $r, $n );
#
#for my $ring (0..3) {
#    for my $n (0..(hex_num_tiles($ring)-1)) {
#	say "($ring, $n): [".( join ', ', @{ hex_path( $ring, $n ) } )."]";
#    }
#}

1;
