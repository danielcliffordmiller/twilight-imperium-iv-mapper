#!/usr/bin/perl

use strict;
use warnings;

use v5.18;

use lib 'lib';

use Mojolicious::Lite;
use Mojo::ByteStream 'b';

use Session;
use SessionBuilder qw(create_session);

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

my $s = create_session(@players);

my %state = ( $s->id(), $s );

say "http://localhost:3000/s/".$s->id()."/players";

helper 'outline' => sub {
    my $c = shift;
    my %attrs = ( @_,
	d	=> "M -25 -43 l 50 0 25 43 -25 43 -50 0 -25 -43 z",
	fill	=> 'black',
	'fill-opacity'	=> '0.0',
	'stroke-width'	=> '2',
	stroke	=> 'black'
    );
    return b( "<path ".(join ' ', map { $_.'="'.$attrs{$_}.'"' } keys %attrs)." />" );
};

get '/s/:s_id/players' => sub {
    my $c = shift;

    $c->stash( session => $state{$c->stash('s_id')} );
} => 'players';

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

# purely for debugging
get '/s/:s_id/json' => sub {
    my $c = shift;

    $c->render( json => $state{$c->stash('s_id')}->dump );
};

get '/s/:s_id/p/:p_id/hand' => sub {
    my $c = shift;
    my ($s_id, $p_id) = map { $c->stash($_) } qw(s_id p_id);

    $c->stash( session => $state{$s_id} );
    $c->render( template => 'hand' );
};

get '/s/:s_id/p/:p_id/undo' => sub {
    my $c = shift;
    my ($s_id, $p_id) = map { $c->stash($_) } qw(s_id p_id);

    my $s = $state{$s_id};

    $state{$s_id} = $s = $s->previous if $s->previous->is_active_player($p_id);

    $c->stash( session => $s );
    $c->redirect_to('ss_idpp_id');
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

    $state{$s_id} = $s = $s->play($i)->($r, $n);

    $c->stash( session => $s, p_id => $p_id );
    $c->render( template => 'map' );
};

# load and save endpoints are for debugging, remove later
get '/s/:s_id/save' => sub {
    my $c = shift;
    my $s = $state{ $c->stash('s_id') };
    unless ($s) {
	$c->render( status => 404 );
	return;
    }
    mkdir 'var' unless (-d 'var');
    store $s, "var/".$c->stash('s_id');
    #$c->redirect_to('/');
};

# remove later
get '/s/:s_id/load' => sub {
    my $c = shift;
    my $s_id = $c->stash('s_id');
    eval {
	my $s = retrieve( "var/".$s_id );
	$state{$s_id} = $s;
    };
    #$c->redirect_to('/');
};

## remove later
#get '/reset' => sub {
#    my $c = shift;
#    $map_data = [ [0, 0, $mecatol] ];
#    $hand = [ @$deck ];
#    $c->redirect_to('/');
#};

app->start();
