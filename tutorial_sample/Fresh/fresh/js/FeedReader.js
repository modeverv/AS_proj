/*
 * Copyright 2007-2008. Adobe Systems Incorporated.
 * All rights reserved.
 */


var Fresh; if (!Fresh) Fresh = {};

Fresh.FeedReader = function() {
    Fresh.FeedReader.superclass.constructor.call(this, null, ['title', 'link', 'description', 'date', 'id', 'author']);
    Fresh.FeedReader.MetaInfo = {
       rss_2_0: {
            channelMetaInfo: ['title', 'description', 'link', 'language'],
            channelDescriptor: {
                title: 'channel/title',
                description: 'channel/description',
                link: 'channel/link',
                language: 'channel/language'
            },
            itemSelector: 'channel/item',
            itemMetaInfo: ['title', 'link', 'description', 'date', 'id', 'author'],
            itemDescriptor: {
                title: 'title',
                link: 'link',
                description: 'encoded,description',
                date: {selector: 'pubDate,date', func: Fresh.Utils.parseFeedDate},
                id: 'guid',
                author: 'author,creator'
            }
       },
       rss_1_0: {
            channelMetaInfo: ['title', 'description', 'link', 'language'],
            channelDescriptor: {
                title: 'channel/title',
                description: 'channel/description',
                link: 'channel/link',
                language: 'channel/language'
            },
            itemSelector: 'item',
            itemMetaInfo: ['title', 'link', 'description', 'date', 'id', 'author'],
            itemDescriptor: {
                title: 'title',
                link: 'link',
                description: 'encoded,description',
                date: {selector: 'pubDate,date', func: Fresh.Utils.parseFeedDate},
                id: 'guid',
                author: 'author,creator'
            }          
       },
       rss_1_1: {
            channelMetaInfo: ['title', 'description', 'link', 'language'],
            channelDescriptor: {
                title: 'Channel/title',
                description: 'Channel/description',
                link: 'Channel/link',
                language: 'Channel/language'
            },
            itemSelector: 'hannel/items/item',
            itemMetaInfo: ['title', 'link', 'description', 'date', 'id', 'author'],
            itemDescriptor: {
                title: 'title',
                link: 'link',
                description: 'encoded,description',
                date: {selector: 'pubDate,date', func: Fresh.Utils.parseFeedDate},
                id: 'guid',
                author: 'creator'
            }          
       },
       rss_0_90: 'rss_2_0',
       rss_0_91: 'rss_2_0',
       rss_0_92: 'rss_2_0',
       rss_0_93: 'rss_2_0',
       atom_1_0: {
            channelMetaInfo: ['title', 'description', 'link', 'language'],
            channelDescriptor: {
                title: 'title',
                description: 'subtitle',
                link: {selector: 'link', attribute: 'href'},
                language: {selector: null, attribute: 'lang'}
            },
            itemSelector: 'entry',
            itemMetaInfo: ['title', 'link', 'description', 'date', 'id', 'author'],
            itemDescriptor: {
                title: 'title',
                link: {selector: 'link', attribute: 'href'},
                description: 'content,summary',
                date: {selector: 'issued,published', func: Fresh.Utils.parseFeedDate},
                id: 'id',
                author: 'author/name'
            }
       },
       atom_0_3: {
            channelMetaInfo: ['title', 'description', 'link', 'language'],
            channelDescriptor: {
                title: 'title',
                description: 'tagline',
                link: {selector: 'link', attribute: 'href'},
                language: {selector: null, attribute: 'lang'}
            },
            itemSelector: 'entry',
            itemMetaInfo: ['title', 'link', 'description', 'date', 'id', 'author'],
            itemDescriptor: {
                title: 'title',
                link: {selector: 'link', attribute: 'href'},
                description: 'content,summary',
                date: {selector: 'issued,published', func: Fresh.Utils.parseFeedDate},
                id: 'id',
                author: 'author/name'
            }
       }
    };     
};



Ext.extend(Fresh.FeedReader, Ext.data.DataReader, {
    read : function(response){
        var doc = response.responseXML;
        if(!doc) {
        	try {
        		if (response.responseDatabase) {
        			return this.readDatabase(response.responseDatabase);
        		}
	        	doc = (new DOMParser()).parseFromString(response.responseText, "text/xml");
	        	if (!doc || doc.documentElement.nodeName == "parsererror") {
		            throw { message: "FeedReader.read: Parse error." };
    	    	}
        	}catch(e) {
        		air.trace("Err:" + e);
        		throw { message: "FeedReader.read: Error loading feed." };
        	}
        }
        return this.readRecords(doc);
    },
    
    readDatabase: function(articles) {
		var FeedRecord = Ext.data.Record.create(Fresh.FeedReader.MetaInfo['rss_2_0'].itemMetaInfo);
		records = [];
		for (var i = 0, len = articles.length; i < len; i ++) {
			var f = articles[i];
			var values = {title: f.article_title, link: f.article_link, description: f.article_description, date: new Date(f.article_date), id: f.article_id, author: f.article_author, feedid: f.feed_id, read: f.article_read};
			var record = new FeedRecord(values);
			record.feed = f;
			records[records.length] = record;
		}
		return {
			records: records,
			totalRecords : records.length,
		}
    },
    
    readJsonRecords: function(feed) {
		var FeedRecord = Ext.data.Record.create(Fresh.FeedReader.MetaInfo['rss_2_0'].itemMetaInfo);
		records = [];
		for (var i = 0, len = feed.items.length; i < len; i ++) {
			var f = feed.items[i];
			var values = {title: f.title, link: f.link, description: f.description, date: f.date, id: f.id, author: f.author, feedid: f.feedid, read: f.read};
			var record = new FeedRecord(values);
			record.feed = f;
			records[records.length] = record;
		}
		return {
			records: records,
			totalRecords : records.length,
	        json: feed
		}
    },
    
    readRecords : function(doc){
        this.xmlData = doc;
        var root = doc.documentElement || doc;
        
        var tv = this.getTypeAndVersion(root);
        if (!tv)
            throw { message: "FeedReader.readRecords: Error getting type and version" };
        
        air.trace(tv.type + '_' + tv.version);
        var metainfo = Fresh.FeedReader.MetaInfo[tv.type + '_' + tv.version];
        if (typeof metainfo == 'string') 
            metainfo = Fresh.FeedReader.MetaInfo[metainfo];
        
        var parsed = this.parseFeed(root, metainfo);
	    return {
	        records : parsed.records,
	        totalRecords : parsed.records.length,
	        feed: parsed
	    };
    },
    
    /*
     * Parses a Feed (RSS, Atom) and extracts channel-related and item-related values
     * 
     * */
    parseFeed: function(root, metainfo){
        var q = Ext.DomQuery;
        
        var parsed = {};
        var cm = metainfo.channelMetaInfo;
        var cd = metainfo.channelDescriptor;
        for (var i=0; i < cm.length; i++)
        {
            var nodeName = cm[i];
            var nodeValue = null;
            
            var selector = cd[nodeName];
            if (typeof selector == 'object')
            {
                var node = root;
                if (selector.selector) {
                    node = q.selectNode(selector.selector, root);
                }
                if (selector.attribute)
                    nodeValue = node.getAttribute(selector.attribute);
                else
                    nodeValue = Fresh.Utils.getTextContent(node);
            }
            else 
            {
                nodeValue = Fresh.Utils.getTextContent(q.selectNode(selector, root));
            }
            parsed[nodeName] = nodeValue;
        }
        var im = metainfo.itemMetaInfo;
        var id = metainfo.itemDescriptor;
        
        var FeedRecord = Ext.data.Record.create(im);
        var records = [];
      	var ns = q.select(metainfo.itemSelector, root);
        for(var j = 0, len = ns.length; j < len; j++) {
	        var n = ns[j];
	        var values = {};
            for (var i = 0; i < im.length; i++)
            {
            	
                var nodeName = im[i];
                var nodeValue = null;
                
                var selector = id[nodeName];
                if (typeof selector == 'object')
                {
                    var node = q.selectNode(selector.selector, n);
                    if (selector.attribute)
                        nodeValue = node.getAttribute(selector.attribute);
                    else {
                        nodeValue = Fresh.Utils.getTextContent(node);
                    }
                   if (selector.func) 
                        nodeValue = selector.func(nodeValue);
                }
                else 
                {
                    nodeValue = Fresh.Utils.getTextContent(q.selectNode(selector, n));
                }
                //nodeValue = Ext.util.Format.stripTags(nodeValue);
                values[nodeName] = nodeValue;
            }
	        values['feedid'] =  Ext.id();
	        values['read'] = false;
	        var record = new FeedRecord(values);
	        record.node = n;
	        records[records.length] = record;
        }
        parsed.records = records;
        return parsed;
    },
    
    getTypeAndVersion: function(root) {
        var type = ''
        var version = '';
        var namespace = root.namespaceURI;
        switch(namespace) 
        {
            case 'http://purl.org/atom/ns#':
                type = 'atom';
                version = '0_3';
                break;
            case 'http://www.w3.org/2005/Atom':
                type = 'atom';
                version = '1_0';
                break;
			case 'http://purl.org/net/rss1.1#':
				type = 'rss';
				version = '1_1';
				break;
			case 'http://www.w3.org/1999/02/22-rdf-syntax-ns#':
				type = 'rss';
				var tmp_nodeList = root.getElementsByTagNameNS('http://purl.org/rss/1.0/', '*');
				if (tmp_nodeList && tmp_nodeList.length > 0)
				    version = '1_0';
				else {
				    tmp_nodeList = root.getElementsByTagNameNS('http://my.netscape.com/rdf/simple/0.9/', '*');  
    				if (tmp_nodeList && tmp_nodeList.length > 0)
    				    version = '0_90';
				}
				break;
			default: 
				var nodeName = root.nodeName.toLowerCase();
				if (nodeName == 'rss') {
					type = 'rss';
					var versionAttr = root.getAttribute('version');
					switch (versionAttr) {
						case '0.91':
							version = '0_91';
							break;
						case '0.92':
							version = '0_92';
							break;
						case '0.93':
							version = '0_93';
							break;
						case '2.0':
							version = '2_0';
							break;
					}
				}				
        }
        
		if (type != '' && version != '') {
			return {'type': type, 'version': version};
		} else {
			return false;
		}
    }
    
    
});