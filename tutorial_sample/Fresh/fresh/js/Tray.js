/*
 * Copyright 2007-2008. Adobe Systems Incorporated.
 * All rights reserved.
 */


var Fresh = Fresh || {};
               
Fresh.Tray = function(preferences) {
	this.addEvents(
        "click"
    );
    this.preferences = preferences;
    this.lastNotificationWindow = null;
   	Fresh.Tray.superclass.constructor.call(this);
}

Ext.extend(Fresh.Tray, Ext.util.Observable, {
	init: function() {
		var loader = new air.Loader();
		var _self = this;
	    loader.contentLoaderInfo.addEventListener(air.Event.COMPLETE, function(event){
	    	var bitmap = event.target.loader.content;
	    	air.NativeApplication.nativeApplication.icon.bitmaps = [bitmap.bitmapData];
	    	if (air.NativeApplication.supportsSystemTrayIcon)
			{
				air.NativeApplication.nativeApplication.icon.tooltip = "Fresh - RSS Reader";
			}
    		// set menu
			var menu = new air.NativeMenu();
			var item_show = new air.NativeMenuItem(_T( 'fresh', 'mnuShow',null ));
			item_show.addEventListener( air.Event.SELECT , _self.showApplication);
			menu.addItem(item_show);
			//
			var item_hide = new air.NativeMenuItem(_T( 'fresh', 'mnuHide',null ));
			item_hide.addEventListener( air.Event.SELECT , function(ev) {nativeWindow.visible = false});
			menu.addItem(item_hide);
			//
			var item_sel = new air.NativeMenuItem("", true);
			menu.addItem(item_sel);
			//
			var item_exit = new air.NativeMenuItem(_T( 'fresh', 'mnuExit',null ));
			item_exit.addEventListener( air.Event.SELECT , function(ev) {nativeWindow.close()});
			menu.addItem(item_exit);
			air.NativeApplication.nativeApplication.icon.menu = menu;
			air.NativeApplication.nativeApplication.icon.addEventListener('click', _self.showApplication);
			
			
			air.Localizer.localizer.addEventListener(air.Localizer.LOCALE_CHANGE, function(){
				item_show.label =  _T( 'fresh', 'mnuShow',null );
				item_hide.label =  _T( 'fresh', 'mnuHide',null );
				item_exit.label =  _T( 'fresh', 'mnuExit',null );				
			});
    	});
		var request;
		if(air.NativeApplication.supportsDockIcon){
			request = new air.URLRequest("fresh/icons/Fresh_128.png");
		}
		else {
			request = new air.URLRequest("fresh/icons/Fresh_16.png");
		}
		loader.load(request);    
	},
	
	minimizeToTray: function(e) {
		if(e.afterDisplayState=='minimized' && this.preferences.getPreference('minimizeToTray')){
			e.preventDefault();
			nativeWindow.visible = false;
		}
	},
	
	showApplication: function() {
		if(nativeWindow.displayState == air.NativeWindowDisplayState.MINIMIZED){
			nativeWindow.restore();
		}			
		nativeWindow.visible = true;
		nativeWindow.activate();
	},
	
	closing: function() {
		if (this.lastNotificationWindow) {
			this.lastNotificationWindow.window.nativeWindow.close();
		}
	},
	
	addNotification: function(title, message) {
		if (!this.preferences.getPreference('showNotifications')) {
			return;
		}
		var _self = this;
		var text = "";
		air.trace("Notification: " + this.lastNotificationWindow);
		if (this.lastNotificationWindow) {
			return;
		}
		var options = new air.NativeWindowInitOptions();
		options.maximizable = false;
		options.minimizable = false;
		options.resizable = false;
		options.systemChrome = 'none';	
		options.transparent = true;
		options.type = air.NativeWindowType.UTILITY;
		var htmlLoader =  air.HTMLLoader.createRootWindow (false, options, false);
		try{
			//since AIR1.5 the htmlLoader will not allow string load in app sandbox
			//surrownded with try/catch in case we are running in older runtime
			//don't need to switch this back to false, because the htmlLoader will die after this call
			htmlLoader.placeLoadStringContentInApplicationSandbox = true;
		}catch(e){}
		var closeFunc = function() {
			htmlLoader.window.nativeWindow.close();
		}
		nativeWindow.addEventListener(air.Event.CLOSING, closeFunc);
		this.lastNotificationWindow = htmlLoader;
		htmlLoader.addEventListener(air.Event.HTML_DOM_INITIALIZE , function(){
			htmlLoader.removeEventListener(air.Event.HTML_DOM_INITIALIZE, arguments.callee);
			htmlLoader.window.nativeWindow.alwaysInFront  = true;
			htmlLoader.window.nativeWindow.addEventListener(air.Event.CLOSE, function() {
				nativeWindow.removeEventListener(air.Event.CLOSING, closeFunc);
				_self.lastNotificationWindow = null;
		
			});
			htmlLoader.window.doClick = function(){
				htmlLoader.window.nativeWindow.close();
				_self.lastNotificationWindow = null;
				nativeWindow.visible = true;
				nativeWindow.activate();
			}
		});
		htmlLoader.loadString ('<html>\n'+
				'<head>\n'+
					'<meta http-equiv="Content-Type" '+
						'content="text/html;charset=UTF-8" />\n'+
					'<script type="text/javascript" '+
						'src="fresh/js/AIRAliases.js">\n '+
					'</script>\n '+						
					'<script type="text/javascript" '+
						'src="fresh/js/notification.js">\n '+
					'</script>\n '+
					'<link '+ 
						'href="fresh/css/notifications.css" type="text/css" '+ 
						'rel="stylesheet" />\n'+
				'</head>\n'+
				'<body onload="doLoad()" onunload="doUnload()">\n'+
					'<div id="bg">\n' +
					'<table width="100%" height="100%" onclick="doClick()">\n'+
						'<tr>\n'+
							'<td valign="middle" align="center">\n'+
								'<span id="notificationText">\n'+
									'<a href="#">\n' +title+ '</a>\n'+
								'</span>\n'+
							'</td>\n'+
						'</tr>\n'+
					'</table>\n'+
					'</div>' +
				'</body>\n'+
			'</html>'
		);			
	}
	
});