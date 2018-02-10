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

1;
