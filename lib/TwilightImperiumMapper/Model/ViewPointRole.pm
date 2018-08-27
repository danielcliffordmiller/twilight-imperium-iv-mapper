package TwilightImperiumMapper::Model::ViewPointRole;

use v5.18;

use Mouse::Role;

use constant LENGTH => 50;

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

sub view_xy {
    my $self = shift;
    return _xy_coords( $self->view_rn );
}

sub _xy_direction {
    my $direction = shift;
    return (
	cos( 0.5236 - 1.0472 * $direction ) * 1.732 * LENGTH,
	- sin( 0.5236 - 1.0472 * $direction ) * 1.732 * LENGTH
    );
}

sub _xy_path {
    my ($r, $n) = @_;

    return () if $r == 0 && $n == 0;

    my @path = ( 0 );

    push @path, 5 foreach (0..($r-2));

    push @path, 1 foreach (0..($n % $r - 1));

    { use integer;
	return map { ( $_ + $n / $r ) % 6 } @path;
    }
}

sub _xy_coords {
    my @path = _xy_path(@_);

    my ($x, $y) = (0, 0);
    my ($dx, $dy);

    # $d is for direction
    for my $d (@path) {
	($dx, $dy) = _xy_direction( $d );
	$x += $dx; $y += $dy;
    }

    return map { sprintf "%.1f", $_ } ($x, $y);
}

1;
