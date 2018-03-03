#!/usr/bin/perl

use strict;
use warnings;

use v5.18;

use lib 'lib';

use Mojolicious::Lite;

use Session;

use Storable;

use SVG qw(render_active_players);

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

say "http://localhost:3000/s/".$s->id()."/players";

get '/s/:s_id/players' => sub {
    my $c = shift;

    my $s_id = $c->stash('s_id');

    $c->render( text => render_active_players($state{$s_id}), format => 'html' );
};

get '/s/:s_id/p/:p_id' => sub {
    my $c = shift;
    my ($s_id, $p_id) = map { $c->stash($_) } qw(s_id p_id);

    unless (exists $state{$s_id} && $state{$s_id}->player($p_id)) {
	$c->render( status => 404 );
	return;
    }

    my $s = $state{$s_id};

    $c->stash( session => $s );
    $c->render( template => 'screen', layout => 'main' );
};

get '/s/:s_id/p/:p_id/hand' => sub {
    my $c = shift;
    my ($s_id, $p_id) = map { $c->stash($_) } qw(s_id p_id);

    $c->stash( session => $state{$s_id} );
    $c->render( template => 'hand' );
};

post '/s/:s_id' => sub {
    my $c = shift;
    my $s_id = $c->stash("s_id");
    my $p_id = (split '/', $c->param('ic-current-url'))[-1];

    my $s = $state{$s_id};

    unless ($s && $s->player($p_id) && $s->is_active_player($p_id)) {
	$c->render( status => 404 );
	return;
    }

    my ($r, $n) = split /,/, $c->param('ic-trigger-id');
    my $i = $c->param("hand") =~ s/hand//r;

    $s->play($i)->($r, $n);

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
