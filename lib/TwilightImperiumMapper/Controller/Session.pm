package TwilightImperiumMapper::Controller::Session;

use v5.18;

use Mojo::Base 'Mojolicious::Controller';

use TwilightImperiumMapper::Model::SessionBuilder;

use List::Util qw(shuffle);
use Data::Dumper;

sub create {
    my $self = shift;
    my $params = $self->req->params->to_hash;
    my @p = map {
	/^\s*$/ ? undef : $_
    } map {
	exists $params->{$_} ? $params->{$_} : undef
    } map { 'p' . $_ } (1..6);

    my ($speaker, $players) = exists $params->{'cb-speaker'} ?
	_get_speaker( $params->{'r-speaker'} =~ s/r//r, \@p ) :
	(undef, \@p);

    $players = [ grep { $_ } @$players ];

    $players = [ shuffle @$players ] if exists $params->{'cb-random'};

    my $session = TwilightImperiumMapper::Model::SessionBuilder::create_session
	( $speaker ? ($speaker, @$players) : @$players );

    my $s_id = $session->id;

    $self->state->{$s_id} = $session;

    $self->stash('session', $session);
    $self->render;
}

sub _get_speaker {
    my ($n, $players) = @_;
    return ($n >= 1 && $n <= 6) ?
	($players->[$n-1], [ @$players[$n..6-1], @$players[0..$n-2] ]) :
	(undef, $players);
}

1;
