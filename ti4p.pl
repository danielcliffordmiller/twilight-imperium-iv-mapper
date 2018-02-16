#!/usr/bin/perl

use strict;
use warnings;

use v5.18;

use lib 'lib';

use Mojolicious::Lite;
use YAML ();

use Storable;

use Tiles;
use Utils;

srand(6); # delete this to get actually random deck draws

my $tile_data = YAML::LoadFile('./data/tiles.yml')->{tiles};

my $deck = [ @$tile_data ];

#my @tiles = partition( \&Tiles::standard, \&Tiles::anomaly, \&Tiles::home, @$tile_data );
#my ($t, $r) = Tiles::draw($tiles[1]);
#my ($h, $ts) = Tiles::draw_tiles(2, $tiles[1]);

(my $mecatol, $deck) = Tiles::draw_tile( "MecatolRex", $tile_data );

(undef, $deck, undef) = partition( \&Tiles::home, sub {
	my $t = Tiles::template( shift );
	my @a = qw(gravityRift singlePlanet doublePlanet nebula asteroids supernova space);
	return $t ~~ @a;
    }, @$deck );

#(my $hand, $deck) = Tiles::draw_tiles(5, $deck);
my $hand = [ @$deck ];

my $map_data = [];

push @$map_data, [ 0, 0, $mecatol ];

#push @$map_data, [ 0, 0, grep { $_->{name} eq 'MecatolRex' } @$tile_data ];
#push @$map_data, [ 1, 0, grep { $_->{name} eq 'Vefut' } @$tile_data ];
#push @$map_data, [ 1, 1, grep { $_->{name} eq 'Gravity Rift' } @$tile_data ];
##push @$map_data, [ 1, 1, grep { $_->{name} eq 'Saudor' } @$tile_data ];
#push @$map_data, [ 1, 3, grep { $_->{name} eq 'Tarmann' } @$tile_data ];
#push @$map_data, [ 1, 5, grep { $_->{name} eq 'QuecennRarron' } @$tile_data ];

get '/' => sub {
    my $c = shift;
    $c->stash( map => $map_data, hand => $hand );
    $c->render(template => 'map', layout => 'main');
};

post '/' => sub {
    my $c = shift;
    my $tile = splice( @$hand, $c->param("hand") =~ s/hand//r, 1, (undef) );
    my ($r, $n) = split /,/, $c->param('ic-trigger-id');
    push @$map_data, [ $r, $n, $tile ];
    $c->stash( map => $map_data, hand => $hand );
    $c->render( template => 'map' );
};

# load and save endpoints are for debugging, remove later
get '/save/#file' => sub {
    my $c = shift;
    my $file = $c->stash('file');
    mkdir 'var' unless (-d 'var');
    store { map => $map_data, hand => $hand }, "var/".$file;
    $c->redirect_to('/');
};

# remove later
get '/load/#file' => sub {
    my $c = shift;
    my $file = $c->stash('file');
    eval {
	my $d = retrieve( "var/".$file );
	($map_data, $hand) = @$d{'map','hand'};
    };
    $c->redirect_to('/');
};

# remove later
get '/reset' => sub {
    my $c = shift;
    $map_data = [ [0, 0, $mecatol] ];
    $hand = [ @$deck ];
    $c->redirect_to('/');
};

app->start();
