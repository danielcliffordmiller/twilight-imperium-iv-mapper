#!/usr/bin/perl -w
#
use strict;

use feature qw(say);

use Mojolicious::Lite;

get '/' => sub {
    my $c = shift;
    $c->render(template => 'test');
};

app->start();
__DATA__

@@ test.html.ep

% use SvgHex;
%
% my $hex = begin
% my ($x, $y) = @_;
<use xlink:href="#svg_hex" transform="translate(<%= $x %>,<%= $y %>)"/>
% end
%
<!DOCTYPE html>
<html>
<head>
<title>Twilight Imperium IV Mapper</title>
<style>
.tile:hover { fill: blue; fill-opacity: 1.0; }
</style>
</head>
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="1600" height="1600">
<defs>
<path id="svg_hex" class="tile" d="M 500 350 l 50 0 25 43 -25 43 -50 0 -25 -43 z" fill="black" fill-opacity="0.0" stroke-width="2" stroke="black"/>
</defs>
% for my $ring (0..3) {
%     for my $n (0..(hex_num_tiles($ring)-1)) {
<%= $hex->(@{hex_coords($ring, $n)}) %>
%     }
% }
</svg>
<!--<img class="tile" src="graphics/hex.svg" />-->
</html>
