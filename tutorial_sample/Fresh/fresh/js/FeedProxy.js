/*
 * Copyright 2007-2008. Adobe Systems Incorporated.
 * All rights reserved.
 */


var Fresh; if (!Fresh) Fresh = {};

Fresh.FeedProxy = function(conn){
    Fresh.FeedProxy.superclass.constructor.call(this);
    // is conn a conn config or a real conn?
    this.conn = conn.events ? conn : new Ext.data.Connection(conn);
};

Ext.extend(Fresh.FeedProxy, Ext.data.DataProxy, {
    getConnection : function(){
        return this.conn;
    },
    
    load : function(params, reader, callback, scope, arg){
        if( this.fireEvent("beforeload", this, params) !== false){
        	var opt = {
	                params : params || {}, 
	                request: {
	                    callback : callback,
	                    scope : scope,
	                    arg : arg
	                },
	                reader: reader,
	                callback : this.loadResponse,
	                scope: this,
	                url: arg.url
	           	};
        	// if forced or not in cache
        	runtime.trace("Database: " +  arg.database + " feed_id: " + (arg.feed_id ? arg.feed_id : '-') + 'folder_id: ' + (arg.folder_id ? arg.folder_id : '-') + " URL: " + arg.url);
       		if (arg.forced || !arg.database) {
        		air.trace("CacheMiss / Forced: " + arg.url);        		
	            this.conn.request(opt);
       		} else {
        		air.trace("CacheHit: " + arg.url);
       			if (arg.feed_id) {
        			Fresh.Reader.feedDB.getArticles(arg.feed_id, this.loadCacheResponse, opt, this);
       			} else if(arg.folder_id) {
        			Fresh.Reader.feedDB.getArticlesByFolder(arg.folder_id, this.loadCacheResponse, opt, this);
       			} else if (arg.special_id) {
        			Fresh.Reader.feedDB.getArticlesByDate(arg.special_id, this.loadCacheResponse, opt, this);
       			}
       		}
        }else{
            callback.call(scope||this, null, arg, false);
        }
    },
    
    loadCacheResponse : function(content, ev, o) {
    	air.trace("loadCacheResponse: " + content);
    	if (content === false) {
    		o.scope.fireEvent("loadexception", o.scope, o, {message:'Error loading cached file'});
            o.request.callback.call(o.request.scope, null, o.request.arg, false);
            return;
    	}
        var result;
        try {
            result = o.reader.read({responseDatabase: content});
        }catch(e){
        	air.trace("Error: " + e.message);
            o.scope.fireEvent("loadexception", o.scope, o, content, e);
            o.request.callback.call(o.request.scope, null, o.request.arg, false);
            return;
        }
        o.request.callback.call(o.request.scope, result, o.request.arg, true);
    },
    
    loadResponse : function(o, success, response){
    	air.trace("Load response: " + success + " " + o.url);
        if(!success){
            this.fireEvent("loadexception", this, o, response, {message:'Could not load '+ o.url});
            o.request.callback.call(o.request.scope, null, o.request.arg, false);
            return;
        }
        var result = response;
        if (o.reader) {
	        try {
	            result = o.reader.read(response);
	            if (o.request.arg.feed_id) {
            		var newArticles = this.updateFeed(o.request.arg.feed_id, o.url, result.records);
            		o.request.arg.newArticlesCount = newArticles;
            		// read again from database
            		Fresh.Reader.feedDB.getArticles(o.request.arg.feed_id, this.loadCacheResponse, o, this);
            		return;
	            } else {
	            	Fresh.Reader.feedDB.saveFeed(o.url, result);
	            }
	        }catch(e){
	        	air.trace("loadResponse: " + e);
	            this.fireEvent("loadexception", this, o, response, e);
	            o.request.callback.call(o.request.scope, null, o.request.arg, false);
	            return;
	        }
        }
        o.request.callback.call(o.request.scope, result, o.request.arg, true);
    },
    
    updateFeed: function(feedId, url, records) {
		air.trace("Proxy: update feed: " + feedId + " " + url);
		var lastArt = Fresh.Reader.feedDB.getLastArticleForFeed(feedId);
		var newArticles = [];
		var found = false;
		if (!lastArt) {
			found = true;
		}
		for (var i = records.length - 1; i >= 0; i --) {
			var art = records[i];
			if (found) {
				newArticles.push(art);
			} else {
				art.data.read = true;
				if (art.get('link') == lastArt.article_link) {
					found = true;
				}		
			}
		}
		// if !found then all articles are new
		if (newArticles.length > 0) {
			if (Fresh.Reader.feedDB.addNewArticles(feedId, newArticles)) {
				return newArticles.length;
			}
		} else {
			if (!found) {
				for (var i = records.length - 1; i >= 0; i --) {
					newArticles.push(records[i]);
				}
				if (Fresh.Reader.feedDB.addNewArticles(feedId, newArticles)) {
					return records.length;
				}	
			}
		}
		return 0;
    },
    
    update : function(dataSet){
        
    },
    
    updateResponse : function(dataSet){
        
    }
});