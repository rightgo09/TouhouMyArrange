package TouhouMyArrange::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::Lite;

any '/' => sub {
	my ($c) = @_;

	my @list = $c->db->search('list'=>{},{limit=>20,offset=>0,order_by=>{pubdate=>'DESC'}});

	my @video_list;
	for my $video (@list) {
		my @tag = $c->db->search('tag'=>{video_id=>$video->video_id},{order_by=>'id'});
		push @video_list, { video => $video, tag => \@tag };
	}

	$c->render('index.tt' => { video_list => \@video_list });
};

any '/watch/:video_id' => sub {
	my ($c, $args) = @_;

	$c->render('watch.tt' => { video_id => $args->{video_id} });
};

1;
