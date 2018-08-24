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

    {
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
    }

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

    my $s = $r->under('/s/:s_id' => sub {
	my $c = shift;
	my $s_id = $c->stash('s_id');

	if (exists $c->state->{$s_id}) {
	    $c->stash(session => $c->state->{$s_id});
	    return 1;
	}
	$c->reply->not_found;
	return undef;
    });

    $s->get('/players');

    # purely for debugging
    $s->get('/json' => sub {
	my $c = shift;
	$c->render( json => $c->stash('session')->dump );
    });

    $s->post('/' => sub {
	my $c = shift;

	my ($s_id, $session) = map { $c->stash($_) } qw(s_id session);
	my $p_id = (split '/', $c->param('ic-current-url'))[-1];

	unless ($session->player($p_id) && $session->is_active_player($p_id)) {
	    $c->reply->not_found;
	    return;
	}

	my ($r, $n) = split /,/, $c->param('ic-trigger-id');
	my $i = $c->param("hand");

	$c->state->{$s_id} = $session->play($i)->($r, $n);

	$c->stash( session => $c->state->{$s_id}, p_id => $p_id );
	$c->render( template => 'map' );
    });

    # load and save endpoints are for debugging, remove later
    $s->get('/save' => sub {
	my $c = shift;
	mkdir 'var' unless (-d 'var');
	store $c->stash('session'), "var/".$c->stash('s_id');
	$c->redirect_to('players');
    });

    # remove later
    $s->get('/load' => sub {
	my $c = shift;
	my $s_id = $c->stash('s_id');
	eval {
	    my $session = retrieve( "var/".$s_id );
	    $c->state->{$s_id} = $session;
	};
	$c->redirect_to('players');
    });

    my $p = $s->under('/p/:p_id' => sub {
	my $c = shift;
	my $p_id = $c->stash('p_id');

	return 1 if $c->stash('session')->player($p_id);

	$c->reply->not_found;
	return undef;
    });

    $p->get('/' => {template => 'screen', layout => 'main'} );

    $p->get('/hand');

    $p->get('/log' => {template => 'player_log'});

    $p->get('/undo' => sub {
	my $c = shift;
	my ($s_id, $p_id, $session) = map { $c->stash($_) } qw(s_id p_id session);
	$c->state->{$s_id} = $session->previous if $session->previous->is_active_player($p_id);

	$c->redirect_to('pp_id');
    });

    $p->get('/refresh' => sub {
	my $c = shift;
	$c->param('session-status-id') ne $c->stash('session')->md5 ?
	    $c->render( template => 'screen' ) :
	    $c->render( text => ' ' );
    });
}

1;
