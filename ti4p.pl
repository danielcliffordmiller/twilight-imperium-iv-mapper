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

(my $mecatol, $deck) = Tiles::draw_tile( "mecatolrex", $tile_data );

(undef, $deck, undef) = partition( sub { $_[0]{type} eq 'home' }, sub {
	my $t = shift;
	my @a = qw(gravityRift singlePlanet doublePlanet nebula asteroids supernova space wormholePlanet);
	return $t->{template} ~~ @a;
    }, @$deck );

#(my $hand, $deck) = Tiles::draw_tiles(5, $deck);
my $hand = [ @$deck ];

my $map_data = [];

push @$map_data, [ 0, 0, $mecatol ];

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
