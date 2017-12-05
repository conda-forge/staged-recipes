#!/usr/bin/env perl
#
use Net::SSLeay qw(get_https);

get_https("www.google.com", 443, "/");

