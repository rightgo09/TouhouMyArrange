package TouhouMyArrange::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::Lite;

any '/' => sub {
	my ($c) = @_;
	$c->render('index.tt');
};

1;
