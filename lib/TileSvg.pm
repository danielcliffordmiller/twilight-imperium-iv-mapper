package TileSvg;

use strict;
use warnings;

use v5.18;

my %ring_colors = (
    home	=> [ qw( r_home	    forestgreen ) ],
    standard	=> [ qw( r_standard royalblue	) ],
    anomaly	=> [ qw( r_anomaly  red		) ]
);

sub ring_colors { \%ring_colors }

sub ring_id {
    my $tile = shift;
    return $ring_colors{$tile->{type}}[0];
}

1;
