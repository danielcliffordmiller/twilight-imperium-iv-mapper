#!/usr/bin/perl -w
#
use strict;

use feature qw(say);

use Mojolicious::Lite;

get '/' => sub {
    my $c = shift;
    $c->render(template => 'main');
};

app->start();
