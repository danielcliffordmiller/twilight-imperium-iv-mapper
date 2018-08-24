package TwilightImperiumMapper::Model::SessionConfig;

use strict;
use warnings;

use v5.18;

use Mouse;

use Mouse::Util::TypeConstraints;

use Scalar::Util qw(looks_like_number);

subtype 'Coord',
    as 'Str',
    where { _check_coord($_) },
    message { "coord must be two numbers joined by a comma" };

subtype 'ShadowPlayer',
    as 'HashRef',
    where { _check_shadow_players($_) },
    message { "shadow order sequence must match dealt shadow tiles" };

sub _check_coord {
    my $c = shift;
    my @v = split ',' => $c;
    return scalar @v == 2
	&& looks_like_number( $v[0] )
	&& looks_like_number( $v[1] );
}

sub _check_shadow_players {
    my $s = shift;
    my $t = 0;
    foreach my $p (@{$s->{players}}) {
	$t += ($p->{red_tiles} // 0) + ($p->{blue_tiles} // 0);
    }
    return scalar @{$s->{order}} == $t;
}

#has 'adjacent' => (is => 'ro', isa => 'HashRef', default => sub { {} });
has 'adjacent' => (is => 'ro', isa => 'HashRef[ArrayRef[Coord]]', default => sub { {} });
has ['red_tiles', 'blue_tiles'] => (is => 'ro', isa => 'Int', required => 1);
has 'players' => (is => 'ro', isa => 'ArrayRef[Coord]', required => 1);
has 'non_map' => (is => 'ro', isa => 'ArrayRef[Coord]', default => sub { [] } );
has 'shadow'  => (is => 'ro', isa => 'ShadowPlayer');

around 'non_map' => sub {
    my $orig = shift;
    my $self = shift;

    return map { [ split ',' => $_ ] } @{ $self->$orig() };
};

around 'adjacent' => sub {
    my $orig = shift;
    my $self = shift;
    my %r = %{$self->$orig()};
    return {
	map {
	    my $k = $_;
	    ( $_, [ map { [split ','] } @{$r{$_}} ] );
	} keys %r
    };
};

sub num_shadow_tiles {
    my $self = shift;
    return $self->shadow ? scalar @{$self->shadow->{order}} : 0;
}

sub view {
    my $self = shift;
    my $n = shift;

    my $c = $self->players($n);

    die "no coord found for player $n" unless $c;

    return 5 - ( ( int( ( ($c->[1]-1) % 18 ) / 3 ) ) + 3 ) % 6;
}

around 'players' => sub {
    my ($orig, $self, $n) = @_;
    return defined $n ?
	[ split ',' => $self->$orig()->[$n] ] :
	map { [ split ',' => $_ ] } @{$self->$orig()};
};

1;
