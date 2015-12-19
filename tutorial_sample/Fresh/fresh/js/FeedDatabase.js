/*
 * Copyright 2007-2008. Adobe Systems Incorporated.
 * All rights reserved.
 */


var Fresh; if (!Fresh) Fresh = {};

Fresh.FeedDatabase = function() {
	var sqlConn;
	
	var dbFile = air.File.applicationStorageDirectory.resolvePath(Fresh.Settings.FEEDS_DATABASE);
	
	function createDatabase() {
		try {
			sqlConn.begin();
			var stmt = new air.SQLStatement();
			stmt.sqlConnection = sqlConn;
			// create FOLDERS table
			stmt.text = 'CREATE TABLE IF NOT EXISTS folders (' +
				"folder_id INTEGER PRIMARY KEY AUTOINCREMENT," + 
				"folder_name TEXT" + 
				");";
			stmt.execute();
			runtime.trace("Execute: " + stmt.text);
			// create FEEDS table
			stmt.text = 'CREATE TABLE IF NOT EXISTS feeds (' +
					'feed_id INTEGER PRIMARY KEY AUTOINCREMENT,' +
					'folder_id INTEGER,' +
					'feed_title TEXT NOT NULL,' +
					'feed_text TEXT NOT NULL,' +
					'feed_xmlUrl TEXT NOT NULL,' +
					'feed_htmlUrl TEXT NOT NULL' +
					');';
			runtime.trace("Execute: " + stmt.text);
			stmt.execute();
			// create ARTICLES table
			stmt.text = 'CREATE TABLE IF NOT EXISTS articles (' +
					'article_id INTEGER PRIMARY KEY AUTOINCREMENT,' +
					'feed_id INTEGER NOT NULL,' +
					'article_guid TEXT,' +
					'article_title TEXT NOT NULL DEFAULT "",'+
					'article_link TEXT NOT NULL DEFAULT "",' +
					'article_description TEXT,' +
					'article_date INTEGER DEFAULT 0,' +
					'article_author TEXT DEFAULT "",' +
					'article_read INTEGER DEFAULT 0' +
					');';
			runtime.trace("Execute: " + stmt.text);
			stmt.execute();
			// create TAGS table
			stmt.text = 'CREATE TABLE IF NOT EXISTS tags (' +
					'tag_id INTEGER PRIMARY KEY AUTOINCREMENT,' + 
					'tag_name TEXT NOT NULL' +
					');';
			runtime.trace("Execute: " + stmt.text);
			stmt.execute();
			stmt.text = 'CREATE TABLE IF NOT EXISTS articles_tags (' +
					'article_id INTEGER NOT NULL,' +
					'tag_id INTEGER NOT NULL' +
					');';
			runtime.trace("Execute: " + stmt.text);
			stmt.execute();
			//
			stmt.text = 'CREATE TABLE IF NOT EXISTS preferences (' +
					'preference_id INTEGER PRIMARY KEY AUTOINCREMENT,' +
					'preference_name TEXT NOT NULL,' +
					'preference_value TEXT NOT NULL' +
					');';
			runtime.trace("Execute: " + stmt.text);
			stmt.execute();
			//
			stmt.text = 'CREATE TABLE IF NOT EXISTS states (' +
					'state_id INTEGER PRIMARY KEY AUTOINCREMENT,' +
					'state_name TEXT NOT NULL,' +
					'state_value TEXT NOT NULL' +
					');';
			runtime.trace("Execute: " + stmt.text);
			stmt.execute();			
			if (sqlConn.inTransaction) sqlConn.commit();
		}catch(e) {
			if (sqlConn.inTransaction) sqlConn.rollback();
			runtime.trace("ERROR creating table: " + e);
			return false;
		}
		return true;
	}
	
	function openDatabase() {
		//if (dbFile.exists) dbFile.deleteFile();
		var create = !dbFile.exists;
		var createMode = dbFile.exists ? air.SQLMode.UPDATE : air.SQLMode.CREATE; 
		sqlConn = new air.SQLConnection();
		sqlConn.open(dbFile, createMode);
		createDatabase();
		return create; 
	}
	
	function getArticlesCount(data) {
		if (!data) {
			return {total: 0, unread: 0};
		}
		var total = 0;
		var unread = 0;
		data.forEach(function(el){
			total += el.total;
			if (!el.read) unread += el.total;
		}); 
		return {total: total, unread: unread};
	}
	
	
	function showFolders() {
		try
		{	
			air.trace("FOLDERS:");
			var stmt = new air.SQLStatement();
			stmt.sqlConnection = sqlConn;
			stmt.text = "SELECT * FROM folders";
			stmt.execute();
			var folders = stmt.getResult();
			if (folders.data) 
			{  
				for (var i = 0; i < folders.data.length; i ++) {
					var folder = folders.data[i];
					air.trace(folder.folder_name);
					var s2 = new air.SQLStatement();
					s2.sqlConnection = sqlConn;
					s2.text = "SELECT * from feeds where folder_id = :folder";
					s2.parameters[':folder'] = folder.folder_id;
					s2.execute();
					var feeds = s2.getResult();
					if (feeds.data) 
					{
						for (var j = 0; j < feeds.data.length; j ++) {
							var feed = feeds.data[j];
							air.trace("\t" + feed.feed_title);
							var s3 = new air.SQLStatement();
							s3.sqlConnection = sqlConn;
							s3.text = "SELECT * FROM articles where feed_id=:feed";
							s3.parameters[':feed'] = feed.feed_id;
							s3.execute();
							var articles = s3.getResult();
							if (articles.data) 
							{		
								for (var k = 0; k < articles.data.length; k ++) {
									var article = articles.data[k];
									var s4 = new air.SQLStatement();
									s4.sqlConnection = sqlConn;
									s4.text = "select tag_name from tags t join articles_tags A on t.tag_id = a.tag_id where a.article_id = :article";
									s4.parameters[':article'] = article.article_id;
									s4.execute();
									var tags = s4.getResult().data;
									var tg = "{";
									if (tags) {
										for (var ii = 0; ii < tags.length; ii ++) {
											tg += tags[ii].tag_name + ",";
										}
									}
									tg += "}";
									air.trace("\t\t" + article.article_title + " " + tg);
								}
							}
						}
					}
				}
			}
			air.trace("STANDALONE FEEDS:");
			var s2 = new air.SQLStatement();
			s2.sqlConnection = sqlConn;
			s2.text = "SELECT * from feeds where folder_id is null";
			s2.execute();
			var feeds = s2.getResult();
			if (feeds.data) 
			{
				for (var j = 0; j < feeds.data.length; j ++) {
					var feed = feeds.data[j];
					air.trace(feed.feed_title);
					var s3 = new air.SQLStatement();
					s3.sqlConnection = sqlConn;
					s3.text = "SELECT * FROM articles where feed_id=:feed";
					s3.parameters[':feed'] = feed.feed_id;
					s3.execute();
					var articles = s3.getResult();
					if (articles.data) 
					{		
						for (var k = 0; k < articles.data.length; k ++) {
							var article = articles.data[k];
							var s4 = new air.SQLStatement();
							s4.sqlConnection = sqlConn;
							s4.text = "select tag_name from tags t join articles_tags A on t.tag_id = a.tag_id where a.article_id = :article";
							s4.parameters[':article'] = article.article_id;
							s4.execute();
							var tags = s4.getResult().data;
							var tg = "{";
							if (tags) {
								for (var ii = 0; ii < tags.length; ii ++) {
									tg += tags[ii].tag_name + ",";
								}
							}
							tg += "}";
							air.trace("\t" + article.article_title + " " + tg);
						}
					}
				}
			}
		}catch(e) {
			air.trace("ERROR: showFeeds: " + e);
		}
		return false;
		
	}
	
	// run 
	var created = openDatabase();
	
	// load 
	return {
		isCreated: function() {
			return created;
		},
		
		addArticle: function(feedId, title, link, author, date, description, guid) {
			air.trace("Article: " + feedId + "[" + title + "]")
			var d = new Date(date).valueOf();
			try
			{
				var stmt = new air.SQLStatement();
				stmt.sqlConnection = sqlConn;
				stmt.text = "INSERT INTO articles(feed_id, article_title, article_link, article_author, article_date, article_description, article_guid) " +
							" VALUES(:feed, :title, :link, :author, :date, :description, :guid);"; 
				stmt.parameters[':feed'] = feedId;
				stmt.parameters[':title'] = title;
				stmt.parameters[':link'] = link;
				stmt.parameters[':author'] = author;
				stmt.parameters[':date'] = d;
				stmt.parameters[':description'] = description;
				stmt.parameters[':guid'] = guid;
				stmt.execute();
				var res = stmt.getResult();
				return res.lastInsertRowID;
			}catch(e) {
				air.trace("ERROR: AddArticle: " + e);
			}
			return false;
		},
		
		addFeed: function(folderId, title, text, xmlUrl, htmlUrl) {
			try
			{
				air.trace("Add feed: " + folderId + "[" + title + "]");
				var stmt = new air.SQLStatement();
				stmt.sqlConnection = sqlConn;
				stmt.text = "INSERT INTO feeds(folder_id, feed_title, feed_text, feed_xmlUrl, feed_htmlUrl) VALUES(:folder, :title, :text, :xmlUrl, :htmlUrl);"; 
				stmt.parameters[':folder'] = folderId;
				stmt.parameters[':title'] = title;
				stmt.parameters[':text'] = text;
				stmt.parameters[':xmlUrl'] = xmlUrl;
				stmt.parameters[':htmlUrl'] = htmlUrl;
				stmt.execute();
				var res = stmt.getResult();
				return res.lastInsertRowID;
			}catch(e) {
				air.trace("ERROR: AddFeed: " + e);
			}
			return false;
		},
		
		addTag: function(name) {
			try {
				sqlConn.begin();
				var stmt = new air.SQLStatement();
				stmt.sqlConnection = sqlConn;
				stmt.text = "INSERT INTO tags(tag_name) VALUES(:tag);";
				stmt.parameters[':tag'] =name;
				stmt.execute();
				if (sqlConn.inTransaction) sqlConn.commit();
				var res = stmt.getResult();
				return res.lastInsertRowID;
			}catch(e) {
				if (sqlConn.inTransaction) sqlConn.rollback();
				air.trace("ERROR: AddTag: " + e);
			}
			return false;
		},		
		
		addArticleTag: function(articleId, tagId) {
			try {
				sqlConn.begin();
				var stmt = new air.SQLStatement();
				stmt.sqlConnection = sqlConn;
				stmt.text = "INSERT INTO articles_tags(article_id, tag_id) VALUES(:article, :tag);";
				stmt.parameters[':article'] = articleId;
				stmt.parameters[':tag'] =tagId;
				stmt.execute();
				if (sqlConn.inTransaction) sqlConn.commit();
				var res = stmt.getResult();
				return res.lastInsertRowID;
			}catch(e) {
				if (sqlConn.inTransaction) sqlConn.rollback();
				air.trace("ERROR: AddArticleTag: " + e);
			}
			return false;
		},		
		
		getFolders : function() {
			try 
			{
				var stmt = new air.SQLStatement();
				stmt.sqlConnection = sqlConn;
				stmt.text = "SELECT * FROM folders ORDER BY folder_name";
				stmt.execute();
				var folders = stmt.getResult().data;
				if (!folders) {
					return [];
				}
				return folders;
			}catch(e) {
				air.trace("ERROR: getFolders:" + e);
			}
			return [];
		},
		
		getFoldersCount : function() {
			try {
				var stmt = new air.SQLStatement();
				stmt.sqlConnection = sqlConn;
				stmt.text = "select d.folder_id as folderId, article_read as read, count(article_read) as total from articles a join feeds f on a.feed_id = f.feed_id join folders d on f.folder_id = d.folder_id group by d.folder_id, article_read order by d.folder_id";
				stmt.execute();
				var folders = stmt.getResult().data;
				if (!folders) {
					return [];
				}
				return folders;
			}catch(e) {
				air.trace("ERROR: getFoldersCount:" + e);
			}
			return [];
		},
		
		getFeeds : function(folderId) {
			try 
			{
				var stmt = new air.SQLStatement();
				stmt.sqlConnection = sqlConn;
				if (folderId) {
					stmt.text = "SELECT * FROM feeds WHERE folder_id=:folder ORDER BY feed_title";
					stmt.parameters[':folder'] = folderId;
				} else {
					stmt.text = "SELECT * FROM feeds WHERE folder_id IS NULL ORDER BY feed_title";
				}
				stmt.execute();
				var feeds = stmt.getResult().data;
				if (!feeds) {
					return [];
				}
				return feeds;
			}catch(e) {
				air.trace("ERROR: getFeeds:" + e);
			}
			return [];
		},
		
		getFeedsForRefresh: function() {
			try 
			{
				var stmt = new air.SQLStatement();
				stmt.sqlConnection = sqlConn;
				stmt.text = "SELECT feed_id AS id, feed_xmlUrl AS url, feed_title as title FROM feeds";
				stmt.execute();
				var feeds = stmt.getResult().data;
				if (!feeds) {
					return [];
				}
				return feeds;
			}catch(e) {
				air.trace("ERROR: getFeedsForRefresh:" + e);
			}
			return [];			
		},
		
		getFeedsCount : function() {
			try {
				var stmt = new air.SQLStatement();
				stmt.sqlConnection = sqlConn;
				stmt.text = "select f.feed_id as feedId, article_read as read, count(article_read) as total from articles a join feeds f on a.feed_id = f.feed_id group by f.feed_id, article_read order by f.feed_id";
				stmt.execute();
				var feeds = stmt.getResult().data;
				if (!feeds) {
					return [];
				}
				return feeds;
			}catch(e) {
				air.trace("ERROR: getFeedsCount:" + e);
			}
			return [];
		},
		
		
		getTags : function() {
			try 
			{
				var stmt = new air.SQLStatement();
				stmt.sqlConnection = sqlConn;
				stmt.text = "SELECT * FROM tags ORDER BY tag_name";
				stmt.execute();
				var tags = stmt.getResult().data;
				if (!tags) {
					return [];
				}
				return tags;
			}catch(e) {
				air.trace("ERROR: getTags:" + e);
			}
			return [];			
		},
		
		getArticles: function(feedId, callback, args, scope) {
			air.trace("getArticles: " + feedId);
			var sql = new air.SQLConnection();
			sql.addEventListener(air.SQLEvent.OPEN, function() {
				var stmt = new air.SQLStatement();
				stmt.sqlConnection = sql;
				stmt.text = "SELECT * FROM articles WHERE feed_id=:feed";
				stmt.parameters[':feed'] = feedId;
				stmt.addEventListener(air.SQLEvent.RESULT, function(event) {
					sql.close();
					var articles = stmt.getResult().data;
					if (!articles) {
						articles = [];
					}
					air.trace("Found: " + articles.length);
					callback.apply(scope, [articles, event, args]);
				});
				stmt.addEventListener(air.SQLErrorEvent.ERROR, function(event) {
					air.trace("error: " + scope);
					sql.close();
					callback.apply(scope, [false, event, args]);
				});
				stmt.execute();
			});
			sql.openAsync(dbFile);
		},
		
		getLastArticleForFeed: function(feedId) {
			try 
			{
				var stmt = new air.SQLStatement();
				stmt.sqlConnection = sqlConn;
				stmt.text = "SELECT * FROM articles WHERE feed_id=:feed ORDER BY article_id DESC;";
				stmt.parameters[':feed'] = feedId;
				stmt.execute();
				var tags = stmt.getResult().data;
				if (!tags) {
					return null;
				}
				return tags[0];
			}catch(e) {
				air.trace("ERROR: getTags:" + e);
			}
			return null;					
		},
		
		getArticlesByFolder:  function(folderId, callback, args, scope) {
			air.trace("getArticlesByFolder: " + folderId);
			var sql = new air.SQLConnection();
			sql.addEventListener(air.SQLEvent.OPEN, function() {
				var stmt = new air.SQLStatement();
				stmt.sqlConnection = sql;
				stmt.text = "SELECT * FROM articles JOIN feeds ON articles.feed_id = feeds.feed_id WHERE feeds.folder_id=:folder";
				stmt.parameters[':folder'] = folderId;
				stmt.addEventListener(air.SQLEvent.RESULT, function(event) {
					sql.close();
					var articles = stmt.getResult().data;
					if (!articles) {
						articles = [];
					}
					air.trace("Found: " + articles.length);
					callback.apply(scope, [articles, event, args]);
				});
				stmt.addEventListener(air.SQLErrorEvent.ERROR, function(event) {
					air.trace("error: " + scope);
					sql.close();
					callback.apply(scope, [false, event, args]);
				});
				stmt.execute();
			});
			sql.openAsync(dbFile);			
		},
		
		getArticlesByDate: function(dateId, callback, args, scope) {
			air.trace("getArticlesByDate: " + dateId);
			var sql = new air.SQLConnection();
			sql.addEventListener(air.SQLEvent.OPEN, function() {
				var stmt = new air.SQLStatement();
				stmt.sqlConnection = sql;
				var dateSql = '';
				switch (dateId) {
					case 1: // all
						dateSql = '';
						break;
					case 2: // today
						dateSql = ' WHERE strftime("%s", article_date/1000,"unixepoch", "localtime") >= strftime("%s", "now", "start of day");'
						break;
					case 3: // last week
						var week = new Date();
						var dt = new Date(week.getFullYear(), week.getMonth(), week.getDate() - week.getDay());
						var month = dt.getMonth() + 1;
						if (month < 10) month = '0' + month;
						stmt.parameters[':day'] = dt.getFullYear() + '-' + month + '-' + ((dt.getDate() < 10) ? '0' + dt.getDate() : dt.getDate());
						dateSql = ' WHERE strftime("%s", article_date/1000,"unixepoch", "localtime") >= strftime("%s", :day, "start of day");'
						break;
					case 4: // last month
						dateSql = ' WHERE strftime("%s", article_date/1000,"unixepoch", "localtime") >= strftime("%s", "now", "start of month");'
						break;
					case 5: // older
						dateSql = ' WHERE strftime("%s", article_date/1000,"unixepoch", "localtime") < strftime("%s", "now", "start of month");'
						break;
				}
				stmt.text = "SELECT * FROM articles " + dateSql;
				stmt.addEventListener(air.SQLEvent.RESULT, function(event) {
					sql.close();
					var articles = stmt.getResult().data;
					if (!articles) {
						articles = [];
					}
					air.trace("Found: " + articles.length);
					callback.apply(scope, [articles, event, args]);
				});
				stmt.addEventListener(air.SQLErrorEvent.ERROR, function(event) {
					air.trace("error: " + scope);
					sql.close();
					callback.apply(scope, [false, event, args]);
				});
				stmt.execute();
			});
			sql.openAsync(dbFile);			
		},
		
		getArticlesCountByDate: function() {
			try {
				var stmt = new air.SQLStatement();
				stmt.sqlConnection = sqlConn;
				stmt.text = "SELECT article_read as read, count(article_read) as total FROM articles GROUP BY article_read ORDER BY article_read;";
				stmt.execute();
				var allArt = stmt.getResult().data;
				stmt.text = 'SELECT article_read as read, count(article_read) as total FROM articles WHERE strftime("%s", article_date/1000,"unixepoch", "localtime") >= strftime("%s", "now", "start of day") GROUP BY article_read ORDER BY article_read;';
				stmt.execute();
				var todayArt = stmt.getResult().data;
				stmt.text = 'SELECT article_read as read, count(article_read) as total FROM articles WHERE strftime("%s", article_date/1000,"unixepoch", "localtime") >= strftime("%s", :day, "start of day") GROUP BY article_read ORDER BY article_read;';
				var week = new Date();
				var dt = new Date(week.getFullYear(), week.getMonth(), week.getDate() - week.getDay());
				var month = dt.getMonth() + 1;
				if (month < 10) month = '0' + month; 
				stmt.parameters[':day'] = dt.getFullYear() + '-' + month + '-' + ((dt.getDate() < 10) ? '0' + dt.getDate() : dt.getDate());	
				air.trace("DAY: "+ stmt.parameters[':day']);			
				stmt.execute();
				stmt.clearParameters();
				var weekArt = stmt.getResult().data;
				stmt.text = 'SELECT article_read as read, count(article_read) as total FROM articles  WHERE strftime("%s", article_date/1000,"unixepoch", "localtime") >= strftime("%s", "now", "start of month") GROUP BY article_read ORDER BY article_read;';
				stmt.execute();
				var monthArt = stmt.getResult().data;
				stmt.text = 'SELECT article_read as read, count(article_read) as total FROM articles WHERE strftime("%s", article_date/1000,"unixepoch", "localtime") < strftime("%s", "now", "start of month") GROUP BY article_read ORDER BY article_read;';
				stmt.execute();
				var olderArt = stmt.getResult().data;
				return articles = {1: getArticlesCount(allArt), 2: getArticlesCount(todayArt), 3: getArticlesCount(weekArt), 4:getArticlesCount(monthArt),
					5: getArticlesCount(olderArt)};
			}catch(e) {
				air.trace("ERROR: getArticlesCountByDate:" + e);
			}
			return {1: {total: 0, unread: 0}, 2: {total: 0, unread: 0}, 3: {total: 0, unread: 0}, 4: {total: 0, unread: 0}, 5: {total: 0, unread: 0}};			
		},
		
		saveFeed: function(url, parsed, folderId) {
			air.trace("SaveFeed: " + url);
			try {
				sqlConn.begin();
				var feedId = this.addFeed(folderId ? folderId : null, parsed.feed.title, parsed.feed.title, url, parsed.feed.link);
				if (!feedId) {
					sqlConn.rollback();
					return false;
				}

				var records = [];
				for(var i = parsed.records.length - 1; i >=0; i --) {
					records.push(parsed.records[i]);
				}
				records.forEach(function(article) {
					var articleId = this.addArticle(feedId, article.get('title'), article.get('link'), article.get('author'), article.get('date'), article.get('description'), article.get('id'));
					if (!articleId) {
						sqlConn.rollback();
						return false;
					}
				}, this);
				if (sqlConn.inTransaction) {
					sqlConn.commit();
				}
				return feedId;
			}catch(e) {
				air.trace("Save feed: " + e);
			}
			return false;
		}, 
		
		addNewArticles: function(feedId, newArticles) {
			air.trace("AddNewArticles: " + feedId + " " + newArticles.length)
			sqlConn.begin();
			air.trace("AddNewArticle1: inTransaction: " + sqlConn.inTransaction);
			newArticles.forEach(function(article) {
				var articleId = this.addArticle(feedId, article.get('title'), article.get('link'), article.get('author'), article.get('date'), article.get('description'), article.get('id'));
				air.trace("AddNewArticleXX: inTransaction: " + sqlConn.inTransaction);
				if (!articleId) {
					sqlConn.rollback();
					return false;
				}
			}, this);
			if (sqlConn.inTransaction) {
				sqlConn.commit();
			}
			return true;
		},
		
		markFolderRead: function(folderId, read) {
			air.trace("markFolderRead: " + folderId);
			var sql = new air.SQLConnection();
			try {
				var stmt = new air.SQLStatement();
				stmt.sqlConnection = sqlConn;
				stmt.text = "UPDATE articles SET article_read=:read WHERE article_id IN (SELECT article_id FROM articles JOIN feeds ON articles.feed_id = feeds.feed_id WHERE feeds.folder_id=:folder)";
				stmt.parameters[':read'] = read;
				stmt.parameters[':folder'] = folderId;
				stmt.execute();
				return true;
			}catch(e) {air.trace("Error: markFolderRead: " + e);}
			return false;
		},
		
		markReadByDate: function(dateId, read) {
			air.trace("markReadByDate: " + dateId);
			try {
				var stmt = new air.SQLStatement();
				stmt.sqlConnection = sqlConn;
				var dateSql = '';
				switch (dateId) {
					case 1: // all
						dateSql = '';
						break;
					case 2: // today
						dateSql = ' WHERE strftime("%s", article_date/1000,"unixepoch", "localtime") >= strftime("%s", "now", "start of day");'
						break;
					case 3: // last week
						var week = new Date();
						stmt.parameters[':day'] = week.getFullYear() + '-' + week.getMonth() + '-' + (week.getDate() - week.getDay());
						dateSql = ' WHERE strftime("%s", article_date/1000,"unixepoch", "localtime") >= strftime("%s", :day, "start of day");'
						break;
					case 4: // last month
						dateSql = ' WHERE strftime("%s", article_date/1000,"unixepoch", "localtime") >= strftime("%s", "now", "start of month");'
						break;
					case 5: // older
						dateSql = ' WHERE strftime("%s", article_date/1000,"unixepoch", "localtime") < strftime("%s", "now", "start of month");'
						break;
				}
				stmt.text = "UPDATE articles SET article_read=:read " + dateSql;
				stmt.parameters[':read'] = read;
				stmt.execute();
				return true;
			} catch(e) {air.trace("Error: markReadByDate " + e)};
			return false
		},
		
		markFeedRead: function(feedId, read) {
			air.trace("Feed: " + feedId + " mark read: " + read);
			try {
				var stmt = new air.SQLStatement();
				stmt.sqlConnection = sqlConn;
				stmt.text = "UPDATE articles SET article_read=:read WHERE feed_id =:feed;";
				stmt.parameters[':read'] = read ? 1 : 0;
				stmt.parameters[':feed'] = feedId;
				stmt.execute();
				return true;
			}catch(e) {
				air.trace("ERROR: markFeedRead: " + e);
			}
			return false;			
		},
		
		markArticleRead:function(articleId, read) {
			air.trace("Article: " + articleId + " mark read: " + read);
			try {
				var stmt = new air.SQLStatement();
				stmt.sqlConnection = sqlConn;
				stmt.text = "UPDATE articles SET article_read=:read WHERE article_id =:article;";
				stmt.parameters[':read'] = read ? 1 : 0;
				stmt.parameters[':article'] = articleId;
				stmt.execute();
				return true;
			}catch(e) {
				air.trace("ERROR: markArticleRead: " + e);
			}
			return false;
		},
		
		addFolder: function(name) {
			air.trace("Add folder: " + name);
			try {
				var stmt = new air.SQLStatement();
				stmt.sqlConnection = sqlConn;
				stmt.text = "INSERT INTO folders(folder_name) VALUES(:folder);";
				stmt.parameters[':folder'] =name;
				stmt.execute();
				var res = stmt.getResult();
				return res.lastInsertRowID;
			}catch(e) {
				air.trace("ERROR: AddFolder: " + e);
			}
			return false;
		},
		
		renameFolder: function(folderId, name) {
			air.trace("Rename: " + folderId + "/" + name);
			try {
				var stmt = new air.SQLStatement();
				stmt.sqlConnection = sqlConn;
				stmt.text = "UPDATE folders SET folder_name=:name WHERE folder_id =:id;";
				stmt.parameters[':id'] = folderId;
				stmt.parameters[':name'] = name;
				stmt.execute();
				return true;
			}catch(e) {
				air.trace("ERROR: RenameFolder: " + e);
			}
			return false;	
		},
		
		moveFeed: function(feedId, folderId) {
			air.trace("Feed: " + feedId + " moved to: " + folderId);
			try {
				var stmt = new air.SQLStatement();
				stmt.sqlConnection = sqlConn;
				if (folderId) {
					stmt.text = "UPDATE feeds SET folder_id=:folder WHERE feed_id=:feed";
					stmt.parameters[':feed'] = feedId;
					stmt.parameters[':folder'] = folderId;	
				} else {
					stmt.text = "UPDATE feeds SET folder_id=NULL WHERE feed_id=:feed";
					stmt.parameters[':feed'] = feedId;
				}
				stmt.execute();
				return true;
			}catch(e) {
				air.trace("ERROR: MoveFeed: " + e);
			}
			return false;
		},
		
		loadPreferences: function() {
			air.trace("Load preferences");
			try {
				var stmt = new air.SQLStatement();
				stmt.sqlConnection = sqlConn;
				stmt.text = "SELECT * FROM preferences;";
				stmt.execute();
				var preferences = stmt.getResult().data;
				if (!preferences) {
					return [];
				}
				return preferences;
			}catch(e) {
				air.trace("ERROR: LoadPreferences: " + e);
			}
			return [];
		},
		
		savePreference: function(prefName, prefValue, prefId) {
			air.trace("Save preference: " + prefName + " = " + prefValue + " id: " + (prefId ? prefId : "-"));
			try {
				var stmt = new air.SQLStatement();
				stmt.sqlConnection = sqlConn;
				if (!prefId) {
					stmt.text = "INSERT INTO preferences(preference_name, preference_value) VALUES(:preference,:value);";
				} else {
					stmt.text = "UPDATE preferences SET preference_value=:value WHERE preference_name=:preference;";
				}
				stmt.parameters[':preference'] = prefName;
				stmt.parameters[':value'] = prefValue;
				stmt.execute();
				if (!prefId) {
					var res = stmt.getResult();
					return res.lastInsertRowID;
				}
				return prefId;
			}catch(e) {
				air.trace("ERROR: Add/SavePreferences: " + e);
			}
			return false;			
		},
		
		loadStates: function() {
			air.trace("Load states");
			try {
				var stmt = new air.SQLStatement();
				stmt.sqlConnection = sqlConn;
				stmt.text = "SELECT * FROM states;";
				stmt.execute();
				var preferences = stmt.getResult().data;
				if (!preferences) {
					return [];
				}
				return preferences;
			}catch(e) {
				air.trace("ERROR: LoadStates: " + e);
			}
			return [];
		},		
		
		deleteState: function(stateName) {
			air.trace("Delete state: " + stateName);
			try {
				var stmt = new air.SQLStatement();
				stmt.sqlConnection = sqlConn;
				stmt.text = "DELETE FROM states WHERE state_name = :state;";
				stmt.parameters[':state'] = stateName;
				stmt.execute();
				return true;
			}catch(e) {
				air.trace("ERROR: deletePreference: " + e);
			}
			return false;			
		},
		
		saveState: function(stateName, stateValue, stateId) {
			air.trace("Save state: " + stateName + " = " + stateValue + " id: " + (stateId ? stateId : "-"));
			try {
				var stmt = new air.SQLStatement();
				stmt.sqlConnection = sqlConn;
				if (!stateId) {
					stmt.text = "INSERT INTO states(state_name, state_value) VALUES(:state,:value);";
				} else {
					stmt.text = "UPDATE states SET state_value=:value WHERE state_name=:state;";
				}
				stmt.parameters[':state'] = stateName;
				stmt.parameters[':value'] = stateValue;
				stmt.execute();
				if (!stateId) {
					var res = stmt.getResult();
					return res.lastInsertRowID;
				}
				return stateId;
			}catch(e) {
				air.trace("ERROR: Add/SaveState: " + e);
			}
			return false;			
		},	
		
		deleteAllStates: function() {
			air.trace("Delete all states");
			try {
				var stmt = new air.SQLStatement();
				stmt.sqlConnection = sqlConn;
				stmt.text = "DELETE FROM states";
				stmt.execute();
				return true;
			}catch(e) {
				air.trace("ERROR: deleteAllStates: " + e);
			}
			return false;			
		},
		
		existsFeed: function(url) {
			try 
			{
				var stmt = new air.SQLStatement();
				stmt.sqlConnection = sqlConn;
				stmt.text = "SELECT count(*) as cnt FROM feeds WHERE feed_xmlUrl=:feed;";
				stmt.parameters[':feed'] = url;
				stmt.execute();
				var count = stmt.getResult().data;
				if (!count) {
					return false;
				}
				return (count[0].cnt == 1 ? true : false);
			}catch(e) {
				air.trace("ERROR: existsFolder:" + e);
			}
			return false;				
		},
		
		existsFolder: function(folderName) {
			try 
			{
				var stmt = new air.SQLStatement();
				stmt.sqlConnection = sqlConn;
				stmt.text = "SELECT folder_id FROM folders WHERE folder_name=:folder;";
				stmt.parameters[':folder'] = folderName;
				stmt.execute();
				var folder = stmt.getResult().data;
				if (!folder) {
					return false;
				}
				return folder[0].folder_id;
			}catch(e) {
				air.trace("ERROR: existsFolder:" + e);
			}
			return false;			
		},
		
		deleteFeed: function(feedId) {
			try {
				sqlConn.begin();				
				var stmt = new air.SQLStatement();
				stmt.sqlConnection = sqlConn;
				stmt.text = "DELETE FROM articles WHERE feed_id=:feed";
				stmt.parameters[':feed'] = feedId;
				stmt.execute();
				stmt.text = "DELETE FROM feeds WHERE feed_id=:feed;";
				stmt.execute();
				if (sqlConn.inTransaction) sqlConn.commit();
				return true;				
			}catch(e) {
				if (sqlConn.inTransaction) sqlConn.rollback();
				air.trace("ERROR: deleteFeed :" + e);
			}
			return false;
		},
		
		deleteFolder: function(folderId) {
			try {
				sqlConn.begin();				
				var stmt = new air.SQLStatement();
				stmt.sqlConnection = sqlConn;
				stmt.text = "DELETE FROM articles WHERE feed_id IN (SELECT feed_id FROM feeds WHERE folder_id=:folder);";
				stmt.parameters[':folder'] = folderId;
				stmt.execute();
				stmt.text = "DELETE FROM feeds WHERE folder_id=:folder;";
				stmt.execute();
				stmt.text = "DELETE FROM folders WHERE folder_id=:folder;";
				stmt.execute();
				if (sqlConn.inTransaction) sqlConn.commit();
				return true;				
			}catch(e) {
				if (sqlConn.inTransaction) sqlConn.rollback();
				air.trace("ERROR: deleteFolder :" + e);
			}
			return false;
		},
		
		deleteAllArticles: function() {
			try {
				var stmt = new air.SQLStatement();
				stmt.sqlConnection = sqlConn;
				stmt.text = "DELETE FROM articles;";
				stmt.execute();
				return true;				
			}catch(e) {
				air.trace("ERROR: deleteAllArticles :" + e);
			}
			return false;
		},
		
		addOpmlFeeds: function(records) {
			var folderId;
			var exists = true;
			try {
				records.childs.forEach(function(child) {
					if (child.xmlUrl) {
						exists = this.existsFeed(child.xmlUrl);					
						if (!exists) {
							if (!this.addFeed(null, child.title, child.text, child.xmlUrl, child.htmlUrl)) {
								sqlConn.rollback();
								return false;
							}
						}					
					} else {
						folderId = this.existsFolder(child.text);
						air.trace("FOUND folder: " + child.text + ' -- '+ folderId);
						if (!folderId) {
							folderId = this.addFolder(child.text);
							if (!folderId) {
								sqlConn.rollback();
								return false;						
							}
						}
						child.childs.forEach(function(c) {
							if (c.xmlUrl) {
								exists = this.existsFeed(c.xmlUrl);
								air.trace("FOUND child: " + c.xmlUrl + " -- " + exists);
								if (!exists) {
									if (!this.addFeed(folderId, c.title, c.text, c.xmlUrl, c.htmlUrl)) {
										sqlConn.rollback();
										return false;
									}
								}
							}						
						}, this);
					}
				}, this);
			}catch(e) {
				air.trace("Error: addOpmlFeeds" + e);
			}
			return true;
		}
		 
	}
};
