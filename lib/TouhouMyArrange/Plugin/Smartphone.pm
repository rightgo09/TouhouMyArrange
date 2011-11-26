package TouhouMyArrange::Plugin::Smartphone;
use strict;
use warnings;
use utf8;

sub init {
	my ($class, $c, $conf) = @_;
	no strict 'refs';
	*{"$c\::is_smartphone"} = \&_is_smartphone;
}

sub _is_smartphone {
	my ($self) = @_;
	my $ua = $self->req->user_agent;
	if ($ua =~ /iphone|android|mobi/i) {
		return 1;
	}
	return;
}

1;

