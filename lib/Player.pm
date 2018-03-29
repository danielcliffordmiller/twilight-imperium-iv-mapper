package Player;

use v5.18;

use Mouse;

has name    => (is => 'ro', isa => 'Str', required => 1 );
has id	    => (is => 'ro', isa => 'Str', required => 1 );
has hand    => (is => 'ro', isa => 'ArrayRef', required => 1 );
has view    => (is => 'ro', isa => 'Int', required => 1 );

around 'hand' => sub {
    my ($orig, $self, $n) = @_;
    return defined $n ? $self->$orig()->[$n] : $self->$orig();
};

sub play {
    my ($self, $n) = @_;

    my $t = $self->hand($n);

    return (
	$t,
	Player->new(
	    name    => $self->name,
	    id	    => $self->id,
	    view    => $self->view,
	    hand    => [ map { $_ == $t ? undef : $_ } @{$self->hand} ]
	)
    );
}

sub dump {
    my $self = shift;
    return {
	name	=> $self->name,
	id	=> $self->id,
	hand	=> $self->hand,
	view	=> $self->view
    };
}

1;
