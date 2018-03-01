package SVG;

use strict;
use warnings;

use v5.18;

require Exporter;

our @ISA = qw(Exporter);

our @EXPORT_OK = qw(active_players);

use HTML::Element;
use Mojo::ByteStream qw(b);

sub active_players {
    my $s = shift;
    my ($players, $active) = ($s->players(), $s->active_player);

    return b(HTML::Element->new_from_lol( [ 'ul', map {
		[ 'li', $_ == $active ? { class => 'active' } : (), $_->[1] ]
	    } @$players ] )->as_HTML());
}

1;
