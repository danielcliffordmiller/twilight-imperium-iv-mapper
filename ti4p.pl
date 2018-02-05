#!/usr/bin/perl -w
#
use strict;

use lib 'lib';
use feature qw(say);

use Mojolicious::Lite;

get '/' => sub {
    my $c = shift;
    $c->render(template => 'main');
};

app->start();
