#!/usr/bin/env perl

use strict;
use warnings;

use v5.18;

use lib 'lib';

use Mojolicious::Commands;

srand(6); # delete this to get actually random deck draws

Mojolicious::Commands->start_app("TwilightImperiumMapper");
