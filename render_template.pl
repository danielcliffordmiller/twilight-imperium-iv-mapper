#!/usr/bin/perl

use strict;
use warnings;

use v5.12;

use Mojolicious::Lite;

my $tiles = [ {
    name => "ArinamMeer",
    type => "Standard",
    planets => [ {
        name => "Arinam",
        resources => 1,
        influence => 2,
        trait	    => "Industrial"
    }, {
        name => "Meer",
        resources => 0,
        influence => 4,
        trait => "Hazardous",
        tech => "Red"
    } ]
}, {
    name => "ArnorLor",
    type => "Standard",
    planets => [ {
        name => "Arnor",
        resources => 2,
        influence => 1,
        trait	    => "Industrial"
    }, {
        name => "Lor",
        resources => 1,
        influence => 2,
        trait => "Industrial"
    } ]
}];

helper res => sub {
    my ($c, $planet) = @_;
    return $planet->{resources};
};

helper inf => sub {
    my ($c, $planet) = @_;
    return $planet->{influence};
};

get '/' => sub {
    my $c = shift;
    $c->stash( { tile => $tiles->[0] } );
    $c->render( template => "tiles/doublePlanet" );
};

app->start();
