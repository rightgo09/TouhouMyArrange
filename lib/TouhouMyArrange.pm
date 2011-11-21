package TouhouMyArrange;
use strict;
use warnings;
use utf8;
use parent qw/Amon2/;
our $VERSION='0.01';
use 5.008001;

#__PACKAGE__->load_plugin(qw/DBI/);

sub load_config {
	my ($class) = @_;
	my $fname = File::Spec->catfile($class->base_dir, 'config', "db_arrange.pl");
	my $db_config = do $fname;
	return +{
		'Text::Xslate' => +{},
		'Teng' => +{
			dsn => $db_config->{dsn},
			username => $db_config->{username},
			password => $db_config->{password},
			connect_options => $db_config->{connect_options},
		},
	}
}

use DBI;
use TouhouMyArrange::DB;
sub db {
	my ($self) = @_;
	if (!defined $self->{db}) {
		my $conf = $self->config->{'Teng'} or die "missing configuration for 'Teng'";
		my $dbh = DBI->connect($conf->{dsn}, $conf->{username}, $conf->{password}, $conf->{connect_options})
			or die "Cannot connect to DB:: ".$DBI::errstr;
		$dbh->do('SET NAMES utf8');
		$self->{db} = TouhouMyArrange::DB->new({ dbh => $dbh });
	}
	return $self->{db};
}



1;
