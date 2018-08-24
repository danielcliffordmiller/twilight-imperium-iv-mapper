package TwilightImperiumMapper;

use v5.18;

use Mojo::Base 'Mojolicious';
use Mojo::ByteStream 'b';

use Session;
use SessionBuilder qw(create_session);

use Storable;

use Utils qw(get_tag);

sub startup {
    my $self = shift;

    my @players = qw(
	Dan
	Randy
	Rob
	Scott
	Frank
	Ben
    );

    my $s = create_session(@players);

    say "http://localhost:3000/s/".$s->id()."/players";

    $self->helper('state' => sub { state $state = { $s->id(), $s } });

    $self->helper('outline' => sub {
	my $c = shift;
	my %attrs = ( @_,
	    d	=> "M -25 -43 l 50 0 25 43 -25 43 -50 0 -25 -43 z",
	    fill	=> 'black',
	    'fill-opacity'	=> '0.0',
	    'stroke-width'	=> '2',
	    'stroke-linejoin' => 'round',
	    stroke	=> 'black'
	);
	return b( "<path ".(join ' ', map { $_.'="'.$attrs{$_}.'"' } keys %attrs)." />" );
    });

    my $r = $self->routes;

    $r->get('/s/:s_id/players' => sub {
	my $c = shift;

	$c->stash( session => $c->state->{$c->stash('s_id')} );
    } => 'players');

    $r->get('/s/:s_id/p/:p_id' => sub {
	my $c = shift;
	my ($s_id, $p_id) = map { $c->stash($_) } qw(s_id p_id);

	unless (exists $c->state->{$s_id} && $c->state->{$s_id}->player($p_id)) {
	    $c->render( status => 404 );
	    return;
	}

	my $s = $c->state->{$s_id};

	$c->stash( session => $s );
	$c->render( template => 'screen', layout => 'main' );
    });

    # purely for debugging
    $r->get('/s/:s_id/json' => sub {
	my $c = shift;

	$c->render( json => $c->state->{$c->stash('s_id')}->dump );
    });

    $r->get('/s/:s_id/p/:p_id/hand' => sub {
	my $c = shift;
	my ($s_id, $p_id) = map { $c->stash($_) } qw(s_id p_id);

	$c->stash( session => $c->state->{$s_id} );
	$c->render( template => 'hand' );
    });

    $r->get('/s/:s_id/p/:p_id/log' => sub {
	my $c = shift;
	my $s_id = $c->stash('s_id');
	
	$c->stash( session => $c->state->{$s_id} );
	$c->render( template => 'player_log' );
    });

    $r->get('/s/:s_id/p/:p_id/undo' => sub {
	my $c = shift;
	my ($s_id, $p_id) = map { $c->stash($_) } qw(s_id p_id);

	my $s = $c->state->{$s_id};

	$c->state->{$s_id} = $s = $s->previous if $s->previous->is_active_player($p_id);

	$c->stash( session => $s );
	$c->redirect_to('ss_idpp_id');
    });

    $r->get('/s/:s_id/p/:p_id/refresh' => sub {
	my $c = shift;
	my $s_id = $c->stash("s_id");
	my $p_id = $c->stash("p_id");

	my $s = $c->state->{$s_id};

	if ($c->param('session-status-id') ne $s->md5) {
	    $c->stash(session => $s, p_id => $p_id);
	    $c->render( template => 'screen' );
	} else {
	    #$c->res->headers->header("X-IC-CancelPolling" => 'true');
	    $c->render(text => ' ');
	}
    });

    $r->post('/s/:s_id' => sub {
	my $c = shift;
	my $s_id = $c->stash("s_id");
	my $p_id = (split '/', $c->param('ic-current-url'))[-1];

	my $s = $c->state->{$s_id};

	unless ($s && $s->player($p_id) && $s->is_active_player($p_id)) {
	    $c->render( status => 404 );
	    return;
	}

	my ($r, $n) = split /,/, $c->param('ic-trigger-id');
	my $i = $c->param("hand");

	$c->state->{$s_id} = $s = $s->play($i)->($r, $n);

	$c->stash( session => $s, p_id => $p_id );
	$c->render( template => 'map' );
    });

    # load and save endpoints are for debugging, remove later
    $r->get('/s/:s_id/save' => sub {
	my $c = shift;
	my $s = $c->state->{ $c->stash('s_id') };
	unless ($s) {
	    $c->render( status => 404 );
	    return;
	}
	mkdir 'var' unless (-d 'var');
	store $s, "var/".$c->stash('s_id');
	$c->redirect_to('players');
    });

    # remove later
    $r->get('/s/:s_id/load' => sub {
	my $c = shift;
	my $s_id = $c->stash('s_id');
	eval {
	    my $s = retrieve( "var/".$s_id );
	    $c->state->{$s_id} = $s;
	};
	$c->redirect_to('players');
    });
}

1;
