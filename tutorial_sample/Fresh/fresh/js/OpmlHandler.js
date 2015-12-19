/*
 * Copyright 2007-2008. Adobe Systems Incorporated.
 * All rights reserved.
 */


 
var Fresh; if (!Fresh) Fresh = {};

Fresh.OpmlHandler = function(meta, recordType){
	Fresh.OpmlHandler.superclass.constructor.call(this, meta, recordType);
}

Ext.extend(Fresh.OpmlHandler, Ext.data.DataReader, {
	
    readOpml : function(content){
      	// error reading file
       	if (!content)
        	return {records: {'childs':[]}};
    	var doc = null;
	   	try {
	       	doc = (new DOMParser()).parseFromString(content, "text/xml"); 	
	       	if (!doc || doc.documentElement.nodeName == "parsererror") {
	       		air.trace("Error parsing");
	            throw {message: "OpmlReader.read: OPML not available"};
        	}
       	}catch(e) {
     		air.trace("exception");
       		throw {message: "OpmlReader.read: OPML not available"};
       	}
    	return this.readRecords(doc);
    },
    
    addNodes : function(nodes, records, fields) {
    	var q = Ext.DomQuery;
    	 for(var i = 0, len = nodes.length; i < len; i++) {
    	 	var child = {};
			var n = nodes[i];
			var text = n.getAttribute('text');
			child['text'] = text;
			// category
			if (!n.getAttribute('xmlUrl')) {
				child['childs'] = [];
				/**@TODO check for imbricated categories */
				var children = q.select('outline', n);
				this.addNodes(children, child, fields);
			} else {
		        for(var j = 0, jlen = fields.length; j < jlen; j++){
	                var f = fields.items[j];
    		  		var v = n.getAttribute(f.name);
   	              	child[f.name] = v;
	        	}
			}
			records['childs'][records['childs'].length] = child;
    	 }
    },
    
    readRecords : function(doc){
        this.xmlData = doc;
        var root = doc.documentElement || doc;
        var fields = this.recordType.prototype.fields;
    	var q = Ext.DomQuery;
    	var totalRecords = 0;
    	var records = {'childs':[]};
    	var ns = q.select('body > outline', root);
    	this.addNodes(ns, records, fields);
	    return {
	        records : records
	    };
    }, 
    
    /* 
     * Save an object of type {childs:[{text: name, desc: description, url:url}, {text: text, childs:[{...}, {...}]}] } 
     * as an OPML file
     */
    exportOpml : function(feedDB) {
    	var enc = Ext.util.Format.htmlEncode;
       	var xml = '<?xml version="1.0" encoding="utf-8"?>\n' + '' +
       			  '<opml version="1.1">\n' + '' +
       			  '<head>\n' + 
       			  '\t<title>Fresh RSS Reader Subscriptions</title>\n' + 
       			  '\t<dateCreated>' + new Date().dateFormat('D M j, Y, g:i a') + '</dateCreated>\n' + '' +
       			  '\t<ownerName></ownerName>\n' + 
       			  '</head>\n' + 
       			  '<body>\n';
       	var folders = feedDB.getFolders();
		folders.forEach(function(folder) {
			xml += '\t<outline  text="' + enc(folder.folder_name) + '">\n';
			var feeds = feedDB.getFeeds(folder.folder_id);
			feeds.forEach(function(feed) {
				xml += '\t\t<outline title="' + enc(feed.feed_title) + '" text="' + enc(feed.feed_text) + 
        		'" htmlUrl="' + enc(feed.feed_htmlUrl) + '" type="rss" xmlUrl="' + enc(feed.feed_xmlUrl) + '" />\n';
			});
			xml += '\t</outline>\n';
		});
		var feeds = feedDB.getFeeds();
		feeds.forEach(function(feed) {
			xml += '\t<outline title="' + enc(feed.feed_title) + '" text="' + enc(feed.feed_text) + 
       		'" htmlUrl="' + enc(feed.feed_htmlUrl) + '" type="rss" xmlUrl="' + enc(feed.feed_xmlUrl) + '" />\n';
		});
       	xml += '</body>\n' + 
       			'</opml>';
       	//trace("xml:" + xml);
       	return xml;
    }
});