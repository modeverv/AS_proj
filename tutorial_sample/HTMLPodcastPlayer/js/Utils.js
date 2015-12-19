// Copyright (c) 2007. Adobe Systems Incorporated.
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
//   * Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//   * Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//   * Neither the name of Adobe Systems Incorporated nor the names of its
//     contributors may be used to endorse or promote products derived from this
//     software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

var Podcast; if (!Podcast) Podcast = {};
if (!Podcast.Utils) Podcast.Utils = {};
 
Podcast.Utils.parseConfig = function(data) {
	var doc = null;
	try {
		doc = (new DOMParser()).parseFromString(data, "text/xml");
		if (!doc || doc.documentElement.nodeName == "parsererror") {
			doc = null;
			air.trace("Error parsing config");
		}
	}catch(e) {
		air.trace("Error parsing config");
	}
	var feedArray = [];	
	if (!doc) return feedArray;
	// get feeds
	var feedNodes = doc.getElementsByTagName("feed");

	for (var i = 0; i < feedNodes.length; i ++) {
		var feedObj = {url: "", feedLabel: ""};
		var feed = feedNodes[i].childNodes;
		for (var j = 0; j < feed.length; j ++) {
			var node = feed[j];
			if (node.nodeType == 3) continue;
			if (node.nodeName == "label") {
				feedObj.feedLabel = node.firstChild.nodeValue;
			} else if (node.nodeName == "url") {
				feedObj.url = node.firstChild.nodeValue;
			} else {
				air.trace("Invalid node: " + node.nodeName);
			}
		}
		feedArray.push(feedObj);
	}
	return feedArray;
}

Podcast.Utils.getHTML = function(feedArray) {
	var html = "<table><thead><tr><td>Label</td><td>URL</td></thead><tbody>"
	for (var i = 0; i < feedArray.length; i ++) {
		html += "<tr><td>" + feedArray[i].feedLabel	+ "</td><td>" + feedArray[i].url + "</td></tr>";
	}
	html += "</tbody></table>";
	return html;
}

Podcast.Utils.addPodcasts = function(feedArray, elm, delegate) {
	///elm.options.length = 0;
	elm.innerHTML = '';
	for (var i = 0; i < feedArray.length; i ++) {
//		elm.options[i] = new Option(feedArray[i].feedLabel, feedArray[i].url);
		var item = document.createElement('li');
		item.innerHTML = feedArray[i].feedLabel;
		item.onclick =  delegate.createCallback(null, [feedArray[i].url]);
		elm.appendChild(item);
	}
}

Podcast.Utils.getTextContent = function(oNode) 
{
    var text = ""; 
    if (oNode) 
    {   
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
                      text = Podcast.Utils.getTextContent(o) + text; 
            }
        }
    }
    return text;
}

Podcast.Utils.parseFeed = function(data) {
	var doc = null;
	try {
		doc = (new DOMParser()).parseFromString(data, "text/xml");
		if (!doc || doc.documentElement.nodeName == "parsererror") {
			doc = null;
			air.trace("Error parsing config");
		}
	}catch(e) {
		air.trace("Error parsing config");
	}
	var feed = {};	
	if (!doc) return feed;
	// get channels
	var channels = doc.getElementsByTagName("channel");
	// no channel in feed
	if (channels.length == 0) return feed;
	var channel = channels[0];
	// get channel props
	for (var i = 0; i < channel.childNodes.length; i ++) {
		var node = channel.childNodes[i];
		if (node.nodeType != 1) continue;
		switch (node.nodeName) {
			case "title":
				feed.title = Podcast.Utils.getTextContent(node);
				break;
			case "description":
				feed.description = Podcast.Utils.getTextContent(node);
				break;
			case "itunes:image":
				feed.imageUrl = node.getAttribute("href");
				break;
			case "itunes:subtitle":
				feed.subtitle = Podcast.Utils.getTextContent(node);
				break;
			case "itunes:summary":
				feed.subtitle = Podcast.Utils.getTextContent(node);
				break;
			case "link":
				feed.link = Podcast.Utils.getTextContent(node);
				break;
			
		}
	}
//	air.trace("Feed: " + feed.title + " description: " + feed.description + " image: " + feed.imageUrl);
	// parse items
	var items = doc.getElementsByTagName("item");
	var itemArray = [];
	for (var i = 0; i < items.length; i ++) {
		var itemObj = {};
		var item = items[i];
		for (var j = 0; j < item.childNodes.length; j ++) {
			var node = item.childNodes[j];
			if (node.nodeType != 1) continue;
			switch (node.nodeName) {
				case "title": 
					itemObj.title = Podcast.Utils.getTextContent(node);
					break;
				case "enclosure":
					itemObj.soundUrl = node.getAttribute("url");
					break;
				case "itunes:subtitle":
					itemObj.subtitle = Podcast.Utils.getTextContent(node);
					break;
				case "itunes:summary":
					itemObj.summary = Podcast.Utils.getTextContent(node);
					break;
				case "pubDate":
					itemObj.pubDate = Podcast.Utils.getTextContent(node);
					break;
			}
		}
		itemArray.push(itemObj);
	}
	feed.itemArray = itemArray;
	return feed;
}

Podcast.Utils.getDescriptionHTML = function(feed) {
	var html = "";

    if (feed.subtitle != null)
    {
        html += "<p><b>" + feed.subtitle + "</b></p>";
    }
    
    if (feed.description != null)
	{
		html += "<p>" + feed.description + "</p>";
	}
	else if (feed.summary != null)
	{
		html += "<p>" + feed.summary + "</p>";
	}
		    
	if (feed.link != null)
	{
		html += "<p><font color='#0000cc'><a href='" + feed.link + "' target='_blank'>[link]</a></font></p>";
	}
		    
	return html;	
}

Podcast.Utils.addArticles = function(itemArray, elm, delegate) {
//	elm.options.length = 0;
	elm.innerHTML = '';
	for (var i = 0; i < itemArray.length; i ++) {
//		elm.options[i] = new Option(itemArray[i].title, itemArray[i].soundUrl);
		var item = document.createElement('li');
		item.innerHTML = itemArray[i].title;
		item.onclick =  delegate.createCallback(null, [itemArray[i].title, itemArray[i].soundUrl]);		
		elm.appendChild(item);
	}
}
