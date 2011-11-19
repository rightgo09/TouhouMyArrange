#!/home/rightgo09/perl5/perlbrew/perls/perl-5.14.2/bin/perl
use strict;
use warnings;
use Plack::Loader;

my $app = Plack::Util::load_psgi('./app.psgi');
Plack::Loader->auto->run($app);

