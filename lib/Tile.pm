package Tile;

use strict;
use warnings;

use v5.18;

use Mouse;

use Mouse::Util::TypeConstraints;

subtype 'Template',
    as 'Str',
    where { _check_template($_) },
    message { "template '$_' not found in templates/tiles/" };

no Mouse::Util::TypeConstraints;

my @valid_templates = map { s|templates/tiles/(\w+)\..*$|$1|r } glob "templates/tiles/*";

has ['name', 'type'] => (is => 'ro', isa => 'Str', required => 1);

has 'template' => (is => 'ro', isa => 'Template');
#has 'template' => (is => 'ro', isa => 'Template', required => 1, trigger => \&_check_template);

has 'planets' => (is => 'ro', isa => 'ArrayRef[Tile::Planet]');
has 'wormhole' => (is => 'ro', isa => 'Str');
has 'text' => (is => 'ro', isa => 'Str');

sub _check_template {
    grep { $_[0] eq $_ } @valid_templates;
}

around 'BUILDARGS' => sub {
    my $orig = shift;
    my $self = shift;

    my %params = @_;

    $params{planets} = [ map { Tile::Planet->new(%$_) } @{$params{planets}} ] if exists $params{planets};

    return $self->$orig(%params);
};

package Tile::Planet;

use Mouse;

has [qw(text resources influence)] => (is => 'ro', isa => 'Str', required => 1);
has 'trait' => (is => 'ro', isa => 'Str', predicate => 'has_trait');
has 'tech' => (is => 'ro', isa => 'Str', predicate => 'has_tech');

1;
