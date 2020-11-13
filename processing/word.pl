#!/usr/bin/perl -l

use strict qw/refs/;
use utf8;
use warnings FATAL => 'all';
use Text::Extract::Word;

binmode STDOUT, ':encoding(UTF-8)';

my $file = '/var/www/2013/doc.doc';
my $extractor = Text::Extract::Word->new($file);
my $string = $extractor->get_body(':raw');
# print "$string";
open (OUT, ">2013.txt");
binmode(OUT, ":utf8");
print OUT $string;
close OUT;

close STDOUT;