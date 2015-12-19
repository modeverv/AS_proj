/*
 * Copyright 2007-2008. Adobe Systems Incorporated.
 * All rights reserved.
 */

var Fresh; if (!Fresh) Fresh = {};

Fresh.AboutWindow = function() {
	var panel = new Ext.Panel({
		html: _F("about_win_content.html" ).toString()
	});
	Fresh.AboutWindow.superclass.constructor.call(this, {
		title:  _T( 'fresh', 'lblAboutDialogTitle' ) ,
		autoHeight: true,
		plain: true,
		modal: true,
		hidden: false,
		closeAction: 'hide',
		listeners: Fresh.Reader.LinkInterceptor,
		buttons: [{
			text:  _T( 'fresh', 'btnOk' ) ,
			handler: this.hide.createDelegate(this, [])	
		}],
		items: [panel]
	});
}

Ext.extend(Fresh.AboutWindow, Ext.Window, {
	show: function() {
		Fresh.AboutWindow.superclass.show.apply(this, arguments);
		this.items.itemAt(0).body.update(_F("about_win_content.html").toString());
		Fresh.AboutWindow.superclass.syncSize.call(this);
		Fresh.Reader.enableKeyMap(false);		
	},
	
	hide: function() {
		Fresh.AboutWindow.superclass.hide.apply(this, arguments);
		Fresh.Reader.enableKeyMap(true);		
	}
});