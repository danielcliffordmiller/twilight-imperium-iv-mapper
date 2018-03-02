#!/usr/bin/perl

use strict;
use warnings;

use v5.18;

use lib 'lib';

use Mojolicious::Lite;

use Session;

use Storable;

use Utils qw(get_tag);

srand(6); # delete this to get actually random deck draws

my @players = qw(
    David
    Dan
    Randy
    Rob
    Aaron
    Alex
);

my $s = Session->new(@players);

my %state = ( $s->id(), $s );

say "http://localhost:3000/s/".$s->id()."/".$s->players->[0][0];

get '/s/:s_id/:p_id' => sub {
    my $c = shift;
    my ($s_id, $p_id) = map { $c->stash($_) } qw(s_id p_id);

    unless (exists $state{$s_id} && $state{$s_id}->player($p_id)) {
	$c->render( status => 404 );
	return;
    }

    my $s = $state{$s_id};

    $c->stash( session => $s );
    $c->render(template => 'map', layout => 'main');
};

post '/' => sub {
    my $c = shift;
    my ($s_id, $p_id);
    (undef, undef, $s_id, $p_id) = split '/', $c->param('ic-current-url');

    unless (exists $state{$s_id} && $state{$s_id}->player($p_id)) {
	$c->render( status => 404 );
	return;
    }

    my $s = $state{$s_id};

    my $tile = splice( @{ $s->hand($p_id) }, $c->param("hand") =~ s/hand//r, 1, (undef) );
    my ($r, $n) = split /,/, $c->param('ic-trigger-id');

    push @{ $s->map_data }, [ $r, $n, $tile ];
    $c->stash( session => $s, p_id => $p_id );
    $c->render( template => 'map' );
};

## load and save endpoints are for debugging, remove later
#get '/save/#file' => sub {
#    my $c = shift;
#    my $file = $c->stash('file');
#    mkdir 'var' unless (-d 'var');
#    store { map => $map_data, hand => $hand }, "var/".$file;
#    $c->redirect_to('/');
#};
#
## remove later
#get '/load/#file' => sub {
#    my $c = shift;
#    my $file = $c->stash('file');
#    eval {
#	my $d = retrieve( "var/".$file );
#	($map_data, $hand) = @$d{'map','hand'};
#    };
#    $c->redirect_to('/');
#};
#
## remove later
#get '/reset' => sub {
#    my $c = shift;
#    $map_data = [ [0, 0, $mecatol] ];
#    $hand = [ @$deck ];
#    $c->redirect_to('/');
#};

app->start();
