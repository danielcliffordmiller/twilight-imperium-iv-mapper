package PlayerLog;

use v5.18;

use Mouse;

has entries => (is => 'ro', isa => 'ArrayRef', default => sub {[]}, reader => '_entries');

sub iterator {
    my $self = shift;
    my $v = shift;
    my @a = map {
	my ($p,$t,$r,$n) = @$_;
	PlayerLog::Entry->new(
	    player  => $p,
	    tile    => $t,
	    r => $r, n => $n,
	    view    => $v,
	)
    } @{ $self->_entries };
    return sub { shift @a };
}

sub place {
    my $self = shift;
    my ($p, $t, $r, $n) = @_;

    return PlayerLog->new( entries => [ @{ $self->_entries }, [ @_ ] ] );
}

sub dump {
    my $self = shift;
    return { entries => [ map {
	{
	    player => $_->[0]->name,
	    coord	=> [ $_->[2], $_->[3] ],
	}
    } @{$self->_entries} ] };
}

package PlayerLog::Entry;

use v5.18;

use Mouse;

use Player;
use Tile;

has player  => (is => 'ro', required => 1, isa => 'Player');
has tile    => (is => 'ro', required => 1, isa => 'Tile');
has view    => (is => 'ro', required => 1, isa => 'Int');

with 'ViewPointRole';

1;
