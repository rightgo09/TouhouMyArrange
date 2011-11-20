CREATE TABLE IF NOT EXISTS `list` (
  `video_id` varchar(15) COLLATE utf8_unicode_ci NOT NULL,
  `pubdate` datetime NOT NULL,
  `created_at` datetime NOT NULL,
  `video_id` varchar(15) COLLATE utf8_unicode_ci NOT NULL,
  `title` varchar(150) COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `thumbnail_url` varchar(150) COLLATE utf8_unicode_ci DEFAULT NULL,
  `length` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  `movie_type` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  `size` bigint(20) DEFAULT NULL,
  `view_counter` int(11) DEFAULT NULL,
  `comment_num` int(11) DEFAULT NULL,
  `mylist_counter` int(11) DEFAULT NULL,
  `last_res_body` text COLLATE utf8_unicode_ci,
  `watch_url` varchar(150) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`video_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `tag` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `video_id` varchar(15) COLLATE utf8_unicode_ci NOT NULL,
  `tag` varchar(30) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


