package SessionConfig;

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

sub _check_coord {
    my $c = shift;
    my @v = split ',' => $c;
    return scalar @v == 2
	&& looks_like_number( $v[0] )
	&& looks_like_number( $v[1] );
}

has 'class_name' => (is => 'ro', isa => 'Str', required => 1);
has ['red_tiles', 'blue_tiles'] => (is => 'ro', isa => 'Int', required => 1);
has 'players' => (is => 'ro', isa => 'ArrayRef[Coord]', required => 1);
has 'non_map' => (is => 'ro', isa => 'ArrayRef[Coord]', default => sub { [] } );

around 'non_map' => sub {
    my $orig = shift;
    my $self = shift;

    return map { [ split ',' => $_ ] } @{ $self->$orig() };
};

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