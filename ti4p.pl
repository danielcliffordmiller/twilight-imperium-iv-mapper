#!/usr/bin/perl -w
#
use strict;

use lib 'lib';
use feature qw(say);

use Mojolicious::Lite;
use YAML ();

use Tiles;
use Utils;

my $tile_data = YAML::LoadFile('./data/tiles.yml')->{tiles};

my @tiles = partition( \&Tiles::standard, \&Tiles::anomaly, \&Tiles::home, @$tile_data );

my ($t, $r) = Tiles::draw($tiles[1]);

my ($h, $ts) = Tiles::draw_tiles(2, $tiles[1]);

my $map_data = [];

push @$map_data, [ 0, 0, grep { $_->{name} eq 'MecatolRex' } @$tile_data ];
push @$map_data, [ 1, 0, grep { $_->{name} eq 'Vefut' } @$tile_data ];
push @$map_data, [ 1, 1, grep { $_->{name} eq 'Gravity Rift' } @$tile_data ];
#push @$map_data, [ 1, 1, grep { $_->{name} eq 'Saudor' } @$tile_data ];
push @$map_data, [ 1, 3, grep { $_->{name} eq 'Tarmann' } @$tile_data ];
push @$map_data, [ 1, 5, grep { $_->{name} eq 'QuecennRarron' } @$tile_data ];

get '/' => sub {
    my $c = shift;
    $c->stash( map => $map_data );
    $c->render(template => 'map', layout => 'main');
};

post '/' => sub {
    my $c = shift;
    say $c->param("hand")." wants to be placed at ".$c->param('ic-trigger-id');
    $c->render( text => '' ); # <- empty response stops ics from rerendering the page
};

app->start();
