package Tiles;

use v5.12;
use strict;
use warnings;

use Utils;

no warnings "experimental::smartmatch";

my @anomaly_tiles = ("Gravity Rift", "Asteroid Field", "Supernova", "Nebula");

my @standard_tiles = qw(
    AbyzFria	    ArinamMeer		ArnorLor	BeregLirta
    CentauriGral    CoorneeqResculon	DalBoothaXXehan	LazarSakulag
    LodorAlpha	    MeharXull		MellonZohbat	NewAlbionStarpoint
    QuannBeta	    QuecennRarron	Saudor		Tarmann
    TequranTorkan   Thibah		Vefut		Wellon
    MecatolRex	    Space		Alpha		Beta
);

my @home_tiles = qw(
    Arborec Creuss	Hacan	JolNar
    L1Z1X   Letnev	Mentak	Muaat
    Naalu   NekroVirus	Saar	SardakkNorr
    Sol	    Winnu	Xxcha	Yin
    Yssaril
);

sub anomaly {
    return $_[0]->{name} ~~ @anomaly_tiles;
}

sub standard {
    return $_[0]->{name} ~~ @standard_tiles;
}

sub home {
    return $_[0]->{name} ~~ @home_tiles;
}

sub type {
    my $tile = shift;
    my $type = standard($tile) ? "standard" :
		anomaly($tile) ? "anomaly"  :
		   home($tile) ? "home"     : "unknown";
    warn qq(tile "$tile->{name}" is of unknown type!) if $type eq "unknown";
    return $type;
}

sub draw {
    my $tiles = shift;
    my $tile = $tiles->[int(rand(@$tiles))];
    return $tile, [ grep { $_ != $tile } @$tiles ];
}

sub draw_tiles {
    my ($n, $tiles) = @_;
    my $hand = [];

    my $t;

    for my $i (0 .. $n-1) {
	($t, $tiles) = draw($tiles);
	push @$hand, $t;
    }
    return $hand, $tiles;
}

sub draw_tile {
    my ($name, $tiles) = @_;

    my @tiles = partition( sub { $_[0]{name} eq $name }, @$tiles );
    return ($tiles[0][0], $tiles[1]);
}

my %template_rules = (
    asteroids	    => sub { $_[0]{name} eq "Asteroid Field" },
    gravityRift	    => sub { $_[0]{name} eq "Gravity Rift" },
    nebula	    => sub { $_[0]{name} eq "Nebula" },
    space	    => sub { $_[0]{name} eq "Space" },
    supernova	    => sub { $_[0]{name} eq "Supernova" },
    singlePlanet    => sub { $_[0]{planets} && scalar @{$_[0]{planets}} == 1 },
    doublePlanet    => sub { $_[0]{planets} && scalar @{$_[0]{planets}} == 2 },
);

sub template {
    my $tile = shift;
    return (grep { $template_rules{$_}($tile) } keys %template_rules)[0];
}

1;
