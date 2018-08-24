package TwilightImperiumMapper::Model::PlayerRole;

use v5.18;

use Mouse::Role;

requires 'play';
requires 'name';
requires 'id';
requires 'view';

has hand => (is => 'ro', isa => 'ArrayRef[Maybe[TwilightImperiumMapper::Model::Tile]]', required => 1 );

around 'hand' => sub {
    my ($orig, $self, $n) = @_;
    return defined $n ? $self->$orig()->[$n] : $self->$orig();
};

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
