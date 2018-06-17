package ViewPointRole;

use v5.18;

use Mouse::Role;

has ['r', 'n']	    => (is => 'ro', isa => 'Int', required => 1);

requires 'view';

sub rn {
    my $self = shift;
    return ($self->r, $self->n);
}

sub view_rn {
    my $self = shift;
    my ($r, $n, $v) = ($self->r, $self->n, $self->view);
    return $r == 0 ?
	($r, $n) :
	($r, ($n + ($r * $v)) % (6 * $r));
}

1;
