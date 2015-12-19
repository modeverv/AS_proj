/*
 * Copyright 2007-2008. Adobe Systems Incorporated.
 * All rights reserved.
 */


 
var Fresh; if (!Fresh) Fresh = {};
if (!Fresh.Utils) Fresh.Utils = {};

Fresh.Settings = 
{
	LOCAL_OPML : "fresh.opml",
	INSTALL_OPML : "data/fresh.opml",
	PROPERTY_FILE : "app.properties",
	FEEDS_FILE : "fresh.feeds",
	FEEDS_DATABASE : "feeds.db"
};

Fresh.Utils.SHA1 = function(content) 
{
	return hex_sha1(content);
}

Fresh.Utils.getTextContent = function(oNode) 
{
	var text = ""; 
	if (oNode) {   
		// W3C DOM Level 3 
        if (typeof oNode.textContent != "undefined")
        {
            text = oNode.textContent; 
        }
        // W3C DOM Level 2 
        else
        {
            if (oNode.childNodes && oNode.childNodes.length)
            for (var i = oNode.childNodes.length; i--; i>0) 
            { 
                  var o = oNode.childNodes[i]; 
                  if (o.nodeType == 3 /* Node.TEXT_NODE */) 
                      text = o.nodeValue + text; 
                  else 
                      text = Fresh.Utils.getTextContent(o) + text; 
            }
        }
    }
    return text;
}

Fresh.Utils.parseFeedDate = function(feedDate)
{
    if (!feedDate) return null;
    var d = Date.parse(feedDate);
    
    if (!d) {
          // parse 2007-02-12T01:59:06.123-05:00
          feedDate = feedDate.replace(/([+-])(\d\d):(\d\d)/, '$1$2$3').replace(/\.\d+/, '').replace(/Z$/, '');
          d = Date.parseDate(feedDate, 'Y-m-d\\TH:i:sO');
          if (!d) d = Date.parseDate(feedDate, 'Y-m-d\\TH:i:s');
          if (!d) d = Date.parseDate(feedDate, 'Y-m-d');
    }
    if (!d) return null;
    return (new Date(d)).toString();
}

/**
     * Applies the passed C#/DomHelper style format (e.g. "The variable {0} is equal to {1}") 
     * @param {Mixed} arg1
     * @param {Mixed} arg2
     * @param {Mixed} etc
     * @method tracef
*/
Fresh.Utils.tracef = function(format, arg1, arg2, etc){
	air.trace(String.format.apply(String, arguments));
}

Fresh.Utils.openInBrowser = function(url) {
	air.navigateToURL(new air.URLRequest(url));
}

Fresh.Utils.ellipse = function(value, maxLength){
    var ret = value;
    if(ret.length > maxLength){
        ret = ret.substr(0, maxLength-3);
        for (var i = maxLength-3; i < value.length; i++) {
            var c = value.charAt(i);
            if  (c == ' ') return ret + '...';
            else ret = ret + c;
        }
    }
    return ret;
};

Fresh.Utils.feedStatus = function(state) {
	return " (" + state.unread + "/" + state.total + ")";
};

Fresh.Utils.isFeedValid = function(url) {
	return url.match("^http([s]*):\/\/");
}


Fresh.Utils.readDefaultOpml = function() {
	var file = air.File.applicationDirectory.resolvePath(Fresh.Settings.INSTALL_OPML);
	if (file == null) {
		return false;
	}
	if (!file.exists)
		return false;
	var sourceStream = new air.FileStream();
	var content = false;
	try {
		sourceStream.open(file, air.FileMode.READ);
		content = sourceStream.readUTFBytes(sourceStream.bytesAvailable);
		sourceStream.close();
	} catch (e) {}
	delete sourceStream;
	return content;		
}

Fresh.Utils.existLocalOpml = function() {
	var file = air.File.applicationStorageDirectory.resolvePath(Fresh.Settings.LOCAL_OPML);
	return file.exists;
}

Fresh.Utils.readLocalOpml = function() {
	var file = air.File.applicationStorageDirectory.resolvePath(Fresh.Settings.LOCAL_OPML);
	if (file == null) {
		return false;
	}
	if (!file.exists)
		return false;
	var sourceStream = new air.FileStream();
	var content = false;
	try {
		sourceStream.open(file, air.FileMode.READ);
		content = sourceStream.readUTFBytes(sourceStream.bytesAvailable);
		sourceStream.close();
	} catch (e) {}
	delete sourceStream;
	return content;		
}

rhu = function(o) {
	if(typeof o == 'string' || typeof o == 'number' || typeof o == 'undefined' || o instanceof Date){
		runtime.trace(o);
	}else if(!o){
		runtime.trace("null");
	}else if(typeof o != "object"){
		runtime.trace('Unknown return type');
	}else if(o instanceof Array){
            runtime.trace('['+o.join(',')+']');
	}else{
		var b = ["{\n"];
		for(var key in o){
			var to = typeof o[key];
				if(to != "function" && to != "object"){
					b.push(String.format("  {0}: {1},\n", key, o[key]));
				}
		}
		var s = b.join("");
		if(s.length > 3){
			s = s.substr(0, s.length-2);
		}
		runtime.trace(s + "\n}");
	}
}	
