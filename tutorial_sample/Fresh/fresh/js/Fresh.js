/*
 * Copyright 2007-2008. Adobe Systems Incorporated.
 * All rights reserved.
 */


Ext.BLANK_IMAGE_URL = 'extjs/images/default/s.gif';

var Fresh; if (!Fresh) Fresh = {};

Fresh.Reader = function(){
	// private functions 
	
	// public functions
	return {
		init: function(){
			var that = this;
		   
			air.Localizer.localizer.setBundlesDirectory('app:/locales/');
		   
			this.opmlHandler = new Fresh.OpmlHandler({record: 'outline'}, ['title', 'text', 'xmlUrl', 'htmlUrl', 'type']);
			this.opmlFile = new Fresh.OpmlFile();
				 
			this.feedDB = new Fresh.FeedDatabase();
			if (this.feedDB.isCreated()) {
				var content = false;
				if (Fresh.Utils.existLocalOpml()) {
					content = Fresh.Utils.readLocalOpml();
				} else {
					content = Fresh.Utils.readDefaultOpml();
				}
				var records = this.opmlHandler.readOpml(content);
				this.feedDB.addOpmlFeeds(records.records);
			}             
			
		   	this.preferences = new Fresh.Preferences(this.feedDB);
			this.preferences.on('prefupdated', this.preferencesUpdated, this);
			              
			setLocaleChain(this.preferences.getPreference('defaultLanguage'));

		   	this.init2();
		},              
		
		initMessageBoxButtons: function(){
			 Ext.MessageBox.buttonText.yes = _T( 'fresh', 'btnYes' );
   			 Ext.MessageBox.buttonText.no = _T( 'fresh', 'btnNo' ); 
   			 Ext.MessageBox.buttonText.ok = _T( 'fresh', 'btnOk' ); 
   			 Ext.MessageBox.buttonText.cancel = _T( 'fresh', 'btnCancel' );
		},               		
		
		init2: function() {
			//runtime.trace("Fresh started");
			Ext.QuickTips.init();
			//
			window.precompileDateFormating();
			
			this.initMessageBoxButtons();
			
			
			// get preview template
			var tpl = Ext.Template.from('preview-tpl', {
				compiled:true,
				getBody : function(v, all){
					return v || all.description;
					//return Ext.util.Format.stripScripts(v || all.description);
				}
			});
			Fresh.Reader.getTemplate = function(){
				return tpl;
			}
			var _self = this;
		   
			
			this.stateProvider = new Fresh.StateProvider({state: Ext.appState, database: this.feedDB});
			var defaultPosition = true;
			// get native position
			if (this.stateProvider.get('native-window-height', null) != null) {
				nativeWindow.height = this.stateProvider.get('native-window-height', null);
				defaultPosition = false;
			}
			if (this.stateProvider.get('native-window-width', null) != null) {
				nativeWindow.width = this.stateProvider.get('native-window-width', null);
				defaultPosition = false;
			}
			if (this.stateProvider.get('native-window-x', null) != null) {
				nativeWindow.x = this.stateProvider.get('native-window-x', null);
				defaultPosition = false;
			}
			if (this.stateProvider.get('native-window-y', null) != null) {
				nativeWindow.y = this.stateProvider.get('native-window-y', null);
				defaultPosition = false;
			}
			if (defaultPosition) {
				nativeWindow.x = (screen.width - nativeWindow.width)/2;
				nativeWindow.y = (screen.height - nativeWindow.height)/2;
			}
			
			// preferences 
			if (!this.preferences.getPreference('startMinimized')) {
				nativeWindow.visible = true;
			}

			Ext.state.Manager.setProvider(this.stateProvider);
			//
			this.tray = new Fresh.Tray(this.preferences);
			// init icon and tray menu
			this.tray.init();
			// add handlers
			nativeWindow.addEventListener(air.Event.CLOSING, function() {
				_self.saveWindowPositionAndSize();
				_self.tray.closing();
			});
			nativeWindow.addEventListener(air.NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING, function(ev) {
					_self.tray.minimizeToTray(ev);
			});
			air.NativeApplication.nativeApplication.addEventListener(air.InvokeEvent.INVOKE, this.onInvoke.createDelegate(this));
			//
			this.refreshThread = new Fresh.RefreshThread(this.feedDB, this.preferences);			
			//
			this.feedPanel = new Fresh.FeedPanel(this.feedDB);
			this.feedPanel.init();
			this.mainPanel = new Fresh.MainPanel();
			this.menuPanel = new Fresh.MenuPanel(this.preferences);
			
			//
			this.feedPanel.on('feedselect', function(feed){
				_self.mainPanel.loadFeed(feed);
			});
			
			this.feedPanel.on('selectgrid', function() {
				_self.mainPanel.focusGrid();
			});
			this.feedPanel.on('feedread', function(){
				_self.mainPanel.refreshGrid();
			});
			this.feedPanel.on('emptycache', function() {
				_self.mainPanel.loadFeed();
			});
			this.mainPanel.on('articleread', function(articleId, feedId) {
				_self.feedPanel.markArticleRead(articleId, feedId);
			});
			this.mainPanel.on('selectpanel', function() {
				air.trace(_self.feedPanel.getTreeEl());
				var node = _self.feedPanel.getSelectionModel().getSelectedNode();
				if (node) {
					node.ensureVisible();
					node.getUI().focus();
				}	
			});
			this.mainPanel.on('newarticles', function(feedId, newArticlesCount, refresh){
				air.trace("New articles for " + feedId + " count:" + newArticlesCount);
				_self.feedPanel.feedUpdated(feedId, newArticlesCount, (refresh ? refresh : false));
			});
			this.mainPanel.on('refreshfeed', function() {
				air.trace("Refresh current feed");
				_self.feedPanel.refreshCurrentFeed();
			});
			this.mainPanel.on('feedread', function() {
				air.trace("Mark feed read");
				_self.feedPanel.markCurrentFeedRead();
			});
			
			// refresh thread
			this.refreshThread.on('newarticles', function(feedId, newArticlesCount, title){
				air.trace("New articles for " + title + " count:" + newArticlesCount);
				_self.feedPanel.feedUpdated(feedId, newArticlesCount, true);
				_self.tray.addNotification(_T( 'fresh', 'lblNewArticlesAvailable'), _T( 'fresh', 'lblNewArticles', [newArticlesCount]));
			});
			// opmlFile
			this.opmlFile.on('opmlimported', function() {
				air.trace("Opml imported");
				_self.feedPanel.refreshFeeds(true);
			});
			// create layout
			var viewport = new Ext.Viewport({
				layout: 'border',
				items: [
					this.menuPanel,
					this.feedPanel,
					this.mainPanel
				]
			});
			air.Localizer.localizer.addEventListener( air.Localizer.LOCALE_CHANGE, function(){ 
				_self.initMessageBoxButtons(); 
				air.Localizer.localizer.update();				
				//hack to make the reading pane button resize
				var readingButton = _self.mainPanel.grid.getTopToolbar().items.get('reading');
				readingButton.setText( readingButton.getText() );
			});
			// create key nav
			this.keyMap = new Ext.KeyMap("fresh", [
				{
					key: "a",
					fn: this.onMarkAllRead,
					scope: this
				},
				{
					key: "m",
					fn: this.onMarkArticlesRead,
					scope: this
				},
				{
					key: "r",
					fn: this.onRefreshAll,
					scope: this
				},
				{
					key: "w",
					fn: this.onCloseTab,
					scope: this
				}
			])
			
			// finished loading
			Ext.get('loading').hide();
			// start the refresh thread
			this.refreshThread.init(this.preferences);
		},
		
		preferencesUpdated: function(prefs) {
			// set start at login flag
			try {
				air.NativeApplication.nativeApplication.startAtLogin = prefs.getPreference('startAtLogin');
			}catch(e) {air.trace("Error: Cannot set startAtLogin: running in ADL or another application is already registered");}
		},
		
		// from MenuPanel		
		onRefreshAll: function() {
			air.trace("Refresh all");
			this.refreshThread.runCheck();
		},
		
		onMarkArticlesRead: function() {
			runtime.trace("Mark Articles read");
			this.feedPanel.markArticlesRead();
		},
		
		onMarkAllRead:function() {
			this.feedDB.markReadByDate(1, true);
			this.feedPanel.refreshFeeds();
		},
		
		onImportOpml: function() {
			this.opmlFile.importOPML(this.feedDB, this.opmlHandler);
		},
		
		onExportOpml: function() {
			this.opmlFile.exportOPML(this.feedDB, this.opmlHandler);
		},
		
		emptyCache: function() {
			this.feedPanel.emptyCache();
		},
		
		onCloseTab: function() {
			air.trace("Close tab");
			this.mainPanel.closeTab();
		},
		
		enableKeyMap: function(enabled) {
			enabled ? this.keyMap.enable() : this.keyMap.disable();	
		},
		
		saveWindowPositionAndSize: function(event) {
			if (!this.windowStateReset) {
				this.stateProvider.set('native-window-height', nativeWindow.height);
				this.stateProvider.set('native-window-width', nativeWindow.width);
				this.stateProvider.set('native-window-x', nativeWindow.x);
				this.stateProvider.set('native-window-y', nativeWindow.y);
			}
		},
		
		resetState: function() {
			var _self = this;
			Ext.MessageBox.show({
				title: _T( 'fresh', 'lblResetStateTitle'),
				msg: _T( 'fresh', 'lblResetStateMsg' )
					 + "<p style='padding-top:5px;font-size: 10px; font-weight: bold'>" + _T( 'fresh', 'lblChangesOnNextStart' ) + "<p>",
				buttons: Ext.Msg.YESNO,
				icon: Ext.MessageBox.WARNING,
				fn: function(btn) {
					if (btn == 'yes') {
						_self.windowStateReset = true;
						_self.stateProvider.resetState();
					}
				}
			});			
		},
		
		onInvoke: function(event) {
			// ignore first invoke
			if (!this.invoke) {
				this.invoke = true;
				return;
			}
			this.tray.showApplication();
        	for (var i = 0, len = event.arguments.length; i < len; i ++) {
        		var a = event.arguments[i];
        		if (a.toLowerCase().indexOf("http://") == 0 || 
        			a.toLowerCase().indexOf("feed://") == 0)  {
        			if (a.toLowerCase().indexOf("feed://") == 0) {
        				a = "http://" + a.substr(7);
        			}
	        		this.feedPanel.showWindow(null, a);
	        		return;
        		}
        	}
		}
	}
}();

Fresh.Reader.LinkInterceptor = {
    render: function(p){
        p.body.on({
            'mousedown': function(e, t){ // try to intercept the easy way
            },
            'click': function(e, t){ // if they tab + enter a link, need to do it old fashioned way
                if(String(t.target).toLowerCase() != '_blank'){
                    e.stopEvent();
                    Fresh.Utils.openInBrowser(t.href);
                }
            },
            delegate:'a'
        });
    }
};


Ext.onReady(Fresh.Reader.init, Fresh.Reader);