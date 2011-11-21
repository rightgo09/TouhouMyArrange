#!/home/rightgo09/perl5/perlbrew/perls/perl-5.14.2/bin/perl
use strict;
use warnings;
use Furl;
use XML::Simple;
use Encode qw/ encode_utf8 /;
use Time::Piece::MySQL;

my $LIST_RSS_URL = 'http://www.nicovideo.jp/tag/%E6%9D%B1%E6%96%B9%E8%87%AA%E4%BD%9C%E3%82%A2%E3%83%AC%E3%83%B3%E3%82%B8?sort=f&rss=2.0';
my $VIDEO_RSS_URL = 'http://ext.nicovideo.jp/api/getthumbinfo/';


use FindBin;
use File::Spec;
use lib File::Spec->catdir($FindBin::Bin, '..', 'lib');
use lib File::Spec->catdir($FindBin::Bin, '..', 'extlib', 'lib', 'perl5');
use TouhouMyArrange;

my $c = TouhouMyArrange->bootstrap;
my $furl = Furl->new(timeout => 60);

sub get_xml {
	my ($url) = @_;
	my $res = $furl->get($url);
	return XML::Simple->new->XMLin($res->content);
}
sub month {
	my %month = (
		Jan => 1, Feb => 2, Mar => 3, Apr =>  4, May =>  5, Jun =>  6,
		Jul => 7, Aug => 8, Sep => 9, Oct => 10, Nov => 11, Dec => 12,
	);
	return $month{$_[0]};
}

my $list_xml = get_xml($LIST_RSS_URL);
for my $item (@{ $list_xml->{channel}->{item} }) {

	my ($video_id) = $item->{link} =~ m|/([^/]+)$|;
	my $title = encode_utf8($item->{title});

	# ex."Sat, 12 Nov 2011 08:56:23"
	my ($week, $d, $m, $y, $time)
		= $item->{pubDate} =~ m|^(\w+),\s(\d+)\s(\w+)\s(\d+)\s(\d+:\d+:\d+)|;
	$m = month($m);
	my $pubdate = "$y-$m-$d $time";

	print $video_id."\n", $title."\n", $pubdate."\n";

	my $video_xml = get_xml($VIDEO_RSS_URL.$video_id);
	my %video = parse_video_xml($video_xml);

	my $row = $c->db->single('list' => { video_id => $video_id });
	if (!$row) { # INSERT, LIST and VIDEO info.
		$row = $c->db->insert('list' => {
			video_id       => $video_id,
			pubdate        => $pubdate,
			created_at     => scalar(localtime),
			title          => $video{title},
			description    => $video{description},
			thumbnail_url  => $video{thumbnail_url},
			length         => $video{length},
			movie_type     => $video{movie_type},
			size           => $video{size},
			view_counter   => $video{view_counter},
			comment_num    => $video{comment_num},
			mylist_counter => $video{mylist_counter},
			last_res_body  => $video{last_res_body},
			watch_url      => $video{watch_url},
		});
		print "    insert.\n";
	}
	else { # UPDATE
		$row->update({
			title          => $video{title},
			description    => $video{description},
			thumbnail_url  => $video{thumbnail_url},
			length         => $video{length},
			movie_type     => $video{movie_type},
			size           => $video{size},
			view_counter   => $video{view_counter},
			comment_num    => $video{comment_num},
			mylist_counter => $video{mylist_counter},
			last_res_body  => $video{last_res_body},
			watch_url      => $video{watch_url},
		});
		print "    update.\n";
	}
	# INSERT, Tag.
	for my $tag_name (@{ $video{tags} }) {
		my $tag = $c->db->single('tag' => {
			video_id => $video_id,
			tag      => $tag_name,
		});
		if (!$tag) {
			$tag = $c->db->insert('tag' => {
				video_id => $video_id,
				tag      => $tag_name,
			});
			print "                tag insert [$tag_name].\n";
		}
	}

	print "----------------\n";
	sleep 5;
}

sub parse_video_xml {
	my ($xml) = @_;

	my $thumb = $xml->{thumb};
	my %video = (
		video_id       => $thumb->{video_id},
		title          => encode_utf8($thumb->{title}),
		description    => encode_utf8($thumb->{description}),
		thumbnail_url  => $thumb->{thumbnail_url},
		length         => $thumb->{length},
		movie_type     => $thumb->{movie_type},
		size           => $thumb->{size_high},
		view_counter   => $thumb->{view_counter},
		comment_num    => $thumb->{comment_num},
		mylist_counter => $thumb->{mylist_counter},
		last_res_body  => $thumb->{comment_num} ? encode_utf8($thumb->{last_res_body}) : '',
		watch_url      => $thumb->{watch_url},
	);

	if (ref($thumb->{tags}) eq 'ARRAY') {
		for my $tag (@{ $thumb->{tags} }) {
			if ($tag->{domain} eq 'jp') {
				$video{tags} = $tag->{tag};
				last;
			}
		}
	}
	else {
		$video{tags} = $thumb->{tags}->{tag};
	}
	if (ref($video{tags}) eq 'ARRAY') {
		my @tags;
		for my $tag (@{ $video{tags} }) {
			if (ref($tag) eq 'HASH') {
				push @tags, $tag->{content};
			}
			else {
				push @tags, $tag;
			}
		}
		$video{tags} = \@tags;
	}
	elsif (ref($video{tags}) eq 'HASH') {
		$video{tags} = [ $video{tags}->{content} ];
	}
	else {
		$video{tags} = [ $video{tags} ];
	}

	$_ = encode_utf8($_) for @{ $video{tags} };

	return %video;
}



