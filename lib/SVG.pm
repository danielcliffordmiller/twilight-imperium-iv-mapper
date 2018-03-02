package SVG;

use strict;
use warnings;

use v5.18;

require Exporter;

our @ISA = qw(Exporter);

our @EXPORT_OK = qw(render_active_players);

use HTML::Element;
use Mojo::ByteStream qw(b);

sub render_active_players {
    my $s = shift;
    my ($players, $active) = ($s->players(), $s->active_player);

    return html([ 'ul', map {
	[ 'li', $_ == $active ? { class => 'active' } : (), [ 'a', {href => "/".(join '/', 's', $s->id(), $_->[0])}, $_->[1] ] ]
    } @$players ]);
}

sub html {
    return b(HTML::Element->new_from_lol( @_ )->as_HTML());
}

1;
