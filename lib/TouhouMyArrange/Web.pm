package TouhouMyArrange::Web;
use strict;
use warnings;
use utf8;
use parent qw/TouhouMyArrange Amon2::Web/;
use File::Spec;

__PACKAGE__->load_plugins('+TouhouMyArrange::Plugin::Smartphone');

# dispatcher
use TouhouMyArrange::Web::Dispatcher;
sub dispatch {
    return TouhouMyArrange::Web::Dispatcher->dispatch($_[0]) or die "response is not generated";
}

# setup view class
use Text::Xslate qw/ html_builder html_escape /;
use URI::Find;
{
    my $view_conf = __PACKAGE__->config->{'Text::Xslate'} || +{};
    unless (exists $view_conf->{path}) {
        $view_conf->{path} = [ File::Spec->catdir(__PACKAGE__->base_dir(), 'tmpl') ];
    }
    my $view = Text::Xslate->new(+{
        'syntax'   => 'TTerse',
        'module'   => [ 'Text::Xslate::Bridge::Star' ],
        'function' => {
            c => sub { Amon2->context() },
            uri_with => sub { Amon2->context()->req->uri_with(@_) },
            uri_for  => sub { Amon2->context()->uri_for(@_) },
            static_file => do {
                my %static_file_cache;
                sub {
                    my $fname = shift;
                    my $c = Amon2->context;
                    if (not exists $static_file_cache{$fname}) {
                        my $fullpath = File::Spec->catfile($c->base_dir(), $fname);
                        $static_file_cache{$fname} = (stat $fullpath)[9];
                    }
                    return $c->uri_for($fname, { 't' => $static_file_cache{$fname} || 0 });
                }
            },
            clickable => html_builder {
                my $word = shift;
                URI::Find->new(\&_autourl)->find(\$word, \&html_escape);
                $word = _autourl_mylist($word);
                $word = _autourl_video_id($word);
                return $word;
            },
        },
        %$view_conf
    });
    sub create_view { $view }
}

sub _autourl {
    my ($url, $org) = @_;
    my $org_esc = html_escape($org);
    return qq'<a href="$org_esc" target="_blank">$org_esc</a>';
}
sub _autourl_mylist {
    my $word = shift;
    $word =~ s{(mylist/\d+)}{<a href="http://www.nicovideo.jp/$1" target="_blank">$1</a>}gs;
    return $word;
}
sub _autourl_video_id {
    my $word = shift;
    $word =~ s{((sm|nm)\d+)}{<a href="http://www.nicovideo.jp/watch/$1" target="_blank">$1</a>}gs;
    return $word;
}


# for your security
__PACKAGE__->add_trigger(
    AFTER_DISPATCH => sub {
        my ( $c, $res ) = @_;
        $res->header( 'X-Content-Type-Options' => 'nosniff' );
        $res->header( 'X-Frame-Options' => 'DENY' );
    },
);

1;
