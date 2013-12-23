CREATE TABLE `hids` (
  `id` tinyint(4) NOT NULL AUTO_INCREMENT,
  `hid` int(9) NOT NULL,
  `banned` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
