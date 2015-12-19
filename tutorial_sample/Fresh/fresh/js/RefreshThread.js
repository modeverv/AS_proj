/*
 * Copyright 2007-2008. Adobe Systems Incorporated.
 * All rights reserved.
 */


var Fresh; if (!Fresh) Fresh = {};

Fresh.RefreshThread = function (feedDB, preferences) {
	this.feedDB = feedDB;
	this.feeds = [];
	this.reader = new Fresh.FeedReader();
	this.proxy = new Fresh.FeedProxy({});
	this.runOnce = false;
	this.resetCurrent = false;
	this.preferences = preferences;
	this.preferences.on('prefupdated', this.prefererencesUpdated, this);
	this.addEvents(
        "newarticles"
    );
	Fresh.RefreshThread.superclass.constructor.call(this);
}

Ext.extend(Fresh.RefreshThread, Ext.util.Observable, {
	init: function() {
		this.runInBackground = this.preferences.getPreference('runInBackground');
		this.refreshTimeout = this.preferences.getPreference('refreshTimeout');			
		if (this.runInBackground) {
			this.start(true);
		} 
	},
	
	prefererencesUpdated: function() {
		// save the new refreshTimeout
		// will be picked up at next check
		this.refreshTimeout = this.preferences.getPreference('refreshTimeout');
		var newRunInBackground = this.preferences.getPreference('runInBackground');
		// check if we must start the thread
		// otherwise it will stop at next check
		if (newRunInBackground != this.runInBackground) {
			this.runInBackground = newRunInBackground;
			if (newRunInBackground) {
				this.start(true);
			} 
		}
	},
	
	start: function(reload) {
		air.trace("Thread started: " + this.runInBackground);
		if (!this.runInBackground && !this.runOnce) {
			return;
		}
		if (reload) {
			this.resetCurrent = false;
			this.currentFeed = 0;
			this.feeds = this.feedDB.getFeedsForRefresh();
		}
		// no feeds, restart
		if (this.feeds.length == 0) {
			this.start.defer(this.refreshTimeout, this, [true]);
			return;
		}
		if (this.currentFeed < this.feeds.length) {
			var feed = this.feeds[this.currentFeed];
			this.proxy.load({}, null, this.feedLoaded, this, {forced:true, url: feed.url, feed_id: feed.id})
		}
	},
	
	runCheck: function() {
		this.runOnce = true;
		// no background process
		if (!this.runInBackground) {
			this.start(true);
		} else {
			this.resetCurrent = true;
		}
	},
	
	feedLoaded: function(result, options, success) {
		if (this.currentFeed < this.feeds.length) {
			air.trace("FeedLoaded: " + this.feeds[this.currentFeed].title);
			if (success) {
				try {
	       			var r = this.reader.read(result);
	       			this.updateFeed(options, r, this.feeds[this.currentFeed].title);
       			}catch(e) {air.trace("Error parsing feed: " + e)}
			}
		}
		// if resetCurrent = true (from runOnce) then restart the checking from the beginning
		if (this.resetCurrent) {
			this.start.defer(this.refreshTimeout, this, [true]);
			return;
		}
		this.currentFeed ++;
		var reload = false;
		var timeout = 50;
		if (this.currentFeed >= this.feeds.length) {
			this.runOnce = false;
			reload = true;
			timeout = this.refreshTimeout;
		}
		this.start.defer(timeout, this, [reload]);
	},
	
	updateFeed: function(options, parsed, title) {
		air.trace("Should update feed: " + options.feed_id + " " + options.url);
		var lastArt = this.feedDB.getLastArticleForFeed(options.feed_id);
		var newArticles = [];
		var found = false;
		if (!lastArt) {
			found = true;
		}
		for (var i = parsed.records.length - 1; i >= 0; i --) {
			var art = parsed.records[i];
			if (found) {
				newArticles.push(art);
			} else {
				if (art.get('link') == lastArt.article_link) {
					found = true;
				}		
			}
		}
		if (newArticles.length > 0) {
			if (this.feedDB.addNewArticles(options.feed_id, newArticles)) {
				this.fireEvent("newarticles", options.feed_id, newArticles.length, title);
			}
		}  else {
			if (!found) {
				for (var i = parsed.records.length - 1; i >= 0; i --) {
					newArticles.push(parsed.records[i]);
				}
				if (this.feedDB.addNewArticles(options.feed_id, newArticles)) {
					this.fireEvent("newarticles", options.feed_id, newArticles.length, title);
				}	
			}
		}
	}	
});