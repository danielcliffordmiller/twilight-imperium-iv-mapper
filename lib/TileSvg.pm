package TileSvg;

use strict;
use warnings;

use v5.18;

my %ring_colors = (
    home	=> [ qw( r_home	    forestgreen ) ],
    standard	=> [ qw( r_standard royalblue	) ],
    alpha	=> [ qw( r_standard royalblue	) ],
    beta	=> [ qw( r_standard royalblue	) ],
    anomaly	=> [ qw( r_anomaly  red		) ]
);

my %trait_colors = (
    industrial	=> "forestgreen",
    hazardous	=> "red",
    cultural	=> "royalblue"
);

my %tech_colors = (
    biotic	=> "forestgreen",
    warfare 	=> "red",
    propulsion	=> "royalblue",
    cybernetic	=> "gold"
);

sub ring_colors { \%ring_colors }

sub ring_id {
    my $tile = shift;
    return $ring_colors{$tile->{type}}[0];
}

sub trait_color {
    return $trait_colors{$_[0]};
}

sub tech_color {
    return $tech_colors{$_[0]};
}

1;
