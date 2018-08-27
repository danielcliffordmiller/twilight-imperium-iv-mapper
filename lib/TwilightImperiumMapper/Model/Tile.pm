package TwilightImperiumMapper::Model::Tile;

use strict;
use warnings;

use v5.18;

use Mouse;

use Mouse::Util::TypeConstraints;

subtype 'Template',
    as 'Str',
    where { _check_template($_) },
    message { "template '$_' not found in templates/tiles/" };

subtype 'Type',
    as 'Str',
    where { _check_types($_) },
    message { "type '$_' is not a  valid tile type" };

no Mouse::Util::TypeConstraints;

my @valid_templates = map { s|templates/tiles/(\w+)\..*$|$1|r } glob "templates/tiles/*";

has 'name' => (is => 'ro', isa => 'Str',  required => 1);
has 'type' => (is => 'ro', isa => 'Type', required => 1);

has 'template' => (is => 'ro', isa => 'Template', required => 1);

has 'planets' => (is => 'ro', isa => 'ArrayRef[TwilightImperiumMapper::Model::Tile::Planet]');
has 'wormhole' => (is => 'ro', isa => 'Str');
has 'text' => (is => 'ro', isa => 'Str');

my %ring_ids = (
    home	=> 'r_home',
    standard	=> 'r_standard',
    alpha	=> 'r_standard',
    beta	=> 'r_standard',
    anomaly	=> 'r_anomaly',
);

sub dump {
    my $self = shift;
    return {
	name => $self->name,
	type => $self->type,
    };
}

sub ring_id {
    my $t = shift;
    return $ring_ids{$t->type};
}

sub ring_ids { return values %ring_ids }

sub _check_template {
    grep { $_[0] eq $_ } @valid_templates;
}

sub _check_types {
    grep { $_[0] eq $_ } keys %ring_ids;
}

around 'BUILDARGS' => sub {
    my $orig = shift;
    my $self = shift;

    my %params = @_;

    $params{planets} = [
	map { TwilightImperiumMapper::Model::Tile::Planet->new(%$_) } @{$params{planets}}
    ] if exists $params{planets};

    return $self->$orig(%params);
};

package TwilightImperiumMapper::Model::Tile::Planet;

use Mouse;

has [qw(text resources influence)] => (is => 'ro', isa => 'Str', required => 1);
has 'trait' => (is => 'ro', isa => 'Str', predicate => 'has_trait');
has 'tech' => (is => 'ro', isa => 'Str', predicate => 'has_tech');

1;
