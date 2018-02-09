#!/usr/bin/perl -w
#
use strict;

use lib 'lib';
use feature qw(say);

use Mojolicious::Lite;
use YAML ();

my $tile_data = YAML::LoadFile('./data/tiles.yml')->{tiles};
my $map_data = [];

push @$map_data, [ 0, 0, grep { $_->{name} eq 'MecatolRex' } @$tile_data ];
push @$map_data, [ 1, 0, grep { $_->{name} eq 'Vefut' } @$tile_data ];
push @$map_data, [ 0, 0, grep { $_->{name} eq 'Saudor' } @$tile_data ];
push @$map_data, [ 0, 0, grep { $_->{name} eq 'Tarmann' } @$tile_data ];
push @$map_data, [ 0, 0, grep { $_->{name} eq 'QuecennRarron' } @$tile_data ];

for (@$map_data) {
    say $_->[2]{name};
}

get '/' => sub {
    my $c = shift;
    #$c->stash( # <- this is how we'll pass the map to the 'main' template
    $c->render(template => 'map', layout => 'main');
};

post '/' => sub {
    my $c = shift;
    say $c->param("hand")." wants to be placed at ".$c->param('ic-trigger-id');
    $c->render( text => '' ); # <- empty response stops ics from rerendering the page
};

app->start();
