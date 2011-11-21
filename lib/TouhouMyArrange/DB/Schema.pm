package TouhouMyArrange::DB::Schema;
use Teng::Schema::Declare;
use Time::Piece::MySQL;
table {
    name 'list';
    pk 'video_id';
    columns (
        {name => 'view_counter', type => 4},
        {name => 'last_res_body', type => 12},
        {name => 'mylist_counter', type => 4},
        {name => 'pubdate', type => 11},
        {name => 'movie_type', type => 12},
        {name => 'thumbnail_url', type => 12},
        {name => 'description', type => 12},
        {name => 'size', type => 4},
        {name => 'created_at', type => 11},
        {name => 'length', type => 12},
        {name => 'video_id', type => 12},
        {name => 'watch_url', type => 12},
        {name => 'title', type => 12},
        {name => 'comment_num', type => 4},
    );
		inflate 'created_at' => sub {
			Time::Piece->from_mysql_datetime(+shift);
		};
		deflate 'created_at' => sub {
			my $t = shift;
			$t->mysql_datetime;
		};
};

table {
    name 'tag';
    pk 'id';
    columns (
        {name => 'video_id', type => 12},
        {name => 'tag', type => 12},
        {name => 'id', type => 4},
    );
};

1;
