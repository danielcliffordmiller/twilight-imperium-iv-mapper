package Session;

use v5.18;

use Tiles;
use Utils;

use Mouse;

has map_data => (is => 'ro', isa => 'ArrayRef');

has players => (is => 'ro', isa => 'HashRef');

state $tile_data = YAML::LoadFile('./data/tiles.yml')->{tiles};

around 'BUILDARGS' => sub {
    my $orig = shift;
    my $self = shift;
    my @names = @_;

    my ($mecatol, $deck) = Tiles::draw_tile( "mecatolrex", $tile_data );

    my @map_data;

    push @map_data, [ 0, 0, $mecatol ];

    my ($home, $red, $blue) = partition(
	sub { $_[0]{type} eq 'home' },
	\&Tiles::red_backed,
	@$deck
    );

    my %players;

    foreach my $n (0 .. $#names) {
	my ($hand, $t);

	($t, $red) = Tiles::draw_tiles(2, $red);
	push @$hand, @$t;
	($t, $blue) = Tiles::draw_tiles(3, $blue);
	push @$hand, @$t;

	$players{ Utils::get_tag } = {
	    name => $names[$n],
	    hand => $hand
	};

	push @map_data, [ 3, ($n*3-1)%(3*6), {
	    name	=> 'player_tile',
	    type	=> 'home',
	    text	=> $names[$n],
	    template	=> 'singleText'
	} ];
    }

    return $self->$orig( map_data => \@map_data, players => \%players );
};

sub player_exists {
    my $self = shift;
    return exists $self->players->{$_[0]};
}

sub hand {
    my $self = shift;
    return undef unless $self->players->{$_[0]};
    return $self->players->{$_[0]}->{hand};
}

sub say_players {
    my $self = shift;

    my $players = $self->players;
    foreach ( keys %{ $players } ) {
	say $_." -> ".$players->{$_}{name};
    }
}

1;
