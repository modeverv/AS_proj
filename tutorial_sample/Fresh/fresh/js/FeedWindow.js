/*
 * Copyright 2007-2008. Adobe Systems Incorporated.
 * All rights reserved.
 */


var Fresh; if (!Fresh) Fresh = {};

var wndTpl = new Ext.XTemplate(
	'<tpl for="."><div class="x-combo-list-item">',
	'<em>{url}</em><strong>{text}</strong>',
	'<div class="x-clear"></div>',
	'</div></tpl>');
            
Fresh.FeedWindow = function() {
	this.feedUrl = new Ext.form.ComboBox({
		id: 'feed-url',
		fieldLabel: _T( 'fresh', 'lblEnterURL'),
		emptyText: _T( 'fresh', 'txtEnterUrlTooltip', null ),
		text: 'http://weblogs.macromedia.com/cantrell/atom.xml',
		width: 450,
		validationEvent: false,
		validateOnBlur: false,
		msgTarget: 'under',
        triggerAction: 'all',
        displayField: 'url',
        mode: 'local',
		listeners:{
			valid: this.syncShadow,
			invalid: this.syncShadow,
			scope: this
		}, 		
		tpl: wndTpl,
        store: new Ext.data.SimpleStore({
            fields: ['url', 'text'],
            data : []
        })		
	});
	this.feedUrl.on('specialkey', function(field, e) {
		if (e.getKey() == Ext.EventObject.ENTER) {
			this.onAdd();
		}
	}, this);
	//
	this.form = new Ext.FormPanel({
		labelAlign: 'top',
		items: this.feedUrl,
		border: false,
		bodyStyle: 'background: transparent;padding: 10px;'
	});
	//
	Fresh.FeedWindow.superclass.constructor.call(this, {
		title: _T( 'fresh', 'btnAddFeed' ),
		iconCls: 'feed-icon',
		id: 'add-feed-win',
		autoHeight: true,
		width: 500,
		resizable: false,
		plain: true,
		modal: true,
		y: 100,
		autoScroll: true,
		closeAction: 'hide',
		
		buttons: [{
			text: _T( 'fresh', 'btnAddFeed' ),
			handler: this.onAdd,
			scope: this
		}, {
			text: _T( 'fresh', 'btnCancel' ),
			handler: this.hide.createDelegate(this, [])	
		}],
		items: this.form
	});
	//
	this.addEvents({add:true});
}

Ext.extend(Fresh.FeedWindow, Ext.Window, {
	show: function(feed) {
		air.trace(feed);
		this.feedUrl.clearInvalid();
		this.feedUrl.store.loadData([]);		
		this.feedUrl.setValue(feed ? feed : "");
		Fresh.FeedWindow.superclass.show.apply(this, arguments);
		Fresh.Reader.enableKeyMap(false);
	},
	
	hide: function() {
		Fresh.FeedWindow.superclass.hide.apply(this, arguments);
		Fresh.Reader.enableKeyMap(true);
	},
	
	onAdd: function() {
		this.el.mask(_T( 'fresh', 'lblValidatingFeed' ), 'x-mask-loading');
		var url = this.feedUrl.getValue().trim();
		if (url.length == 0) 
		{
			this.markInvalid();
			return;
		}
		if (url.toLowerCase().indexOf("feed://") == 0) {
        		url = "http://" + url.substr(7);
        }
        if (url.toLowerCase().indexOf("http://") != 0) {
        	url = "http://" + url;
        }        
		Ext.Ajax.request({
			url: url,
			success: this.validateFeed,
			failure: function() {this.markInvalid();},
			scope: this,
			feedUrl: url
		});
	},
	
	markInvalid: function(msg) {
		this.feedUrl.markInvalid(!msg ? _T( 'fresh', 'lblNotValid' ) : msg);
		this.el.unmask();	
	},
	
	validateFeed: function(response, options) {
		try {
			if (!this.reader) {
				this.reader = new Fresh.FeedReader();
			}
			var parsed = this.reader.read(response);
			this.el.unmask();
			this.hide();
			return this.fireEvent('validfeed', {
				url: options.feedUrl,
				parsed: parsed 
			});
		} catch(e) {
			air.trace("Error parsing feed: " + e);
		}
		// try reading feeds locations
		try {
			var doc = (new DOMParser()).parseFromString(response.responseText, "text/xml");
			var ctx = doc.ownerDocument == null ? doc.documentElement : doc.ownerDocument.documentElement;
			var nsResolver = doc.createNSResolver(ctx);
			var ns = '';
			var html = ctx.getAttribute('xmlns');
			if (html) {
				ns = 'myns:'
				nsResolver = function(prefix) {
					return html;
				}
			}
			
			var result = doc.evaluate('//' + ns + 'link[@rel="alternate"][contains(@type, "rss") or contains(@type, "atom") or contains(@type, "rdf")]', doc, nsResolver, 0, null);
			var item;
			var feeds = [];
			foundFeeds = [];
			while (item = result.iterateNext()) feeds.push(item);	
			if (feeds.length == 0) {
				this.markInvalid();
				return;
			}
			for(var i = 0; i < feeds.length; i++) {
				var str = feeds[i].getAttribute('type').toLowerCase();
				var type = str.indexOf('rss') ? 'RSS' : str.indexOf('atom') ? 'ATOM' : 'RDF';
				foundFeeds.push([feeds[i].getAttribute('href'), feeds[i].getAttribute('title') + '&nbsp;(' + type + ')']) 
			}
			this.feedUrl.store.loadData(foundFeeds);
		    this.markInvalid(_T( 'fresh', 'lblNotFound', [feeds.length] ));
			this.el.unmask();
		}catch(e) {
			air.trace("Error" + e);
			this.markInvalid();
		}
	}
	
});