package Player;

use v5.18;

use Mouse;

has name    => (is => 'ro', isa => 'Str' );
has id	    => (is => 'ro', isa => 'Str' );
has hand    => (is => 'ro', isa => 'ArrayRef' );

around 'hand' => sub {
    my ($orig, $self, $n) = @_;
    return defined $n ? $self->$orig()->[$n] : $self->$orig();
};

sub play {
    my ($self, $n) = @_;

    return splice @{ $self->hand }, $n, 1, undef;
}

sub dump {
    my $self = shift;
    return {
	name => $self->name,
	id  => $self->id,
	hand	=> $self->hand
    };
}

1;
