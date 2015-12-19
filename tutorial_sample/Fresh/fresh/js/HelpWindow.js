/*
 * Copyright 2007-2008. Adobe Systems Incorporated.
 * All rights reserved.
 */

var Fresh; if (!Fresh) Fresh = {};


Fresh.HelpWindow = function() {
	var panel = new Ext.Panel({
		html: _F("help_win_content.html").toString(),
		autoScroll: true
	});	
	Fresh.HelpWindow.superclass.constructor.call(this, {
		title: _T( 'fresh', 'lblKeyNavigationDialogTitle'),
		autoHeight: true,
		plain: true,
		modal: true,
		hidden: false,
		closeAction: 'hide',
		buttons: [{
			text:  _T( 'fresh', 'btnOk' ) ,
			handler: this.hide.createDelegate(this, [])	
		}],
		items:[panel]
	});
}

Ext.extend(Fresh.HelpWindow, Ext.Window, {
	show: function() {
		Fresh.HelpWindow.superclass.show.apply(this, arguments); 
		this.items.itemAt(0).body.update(_F("help_win_content.html").toString());
		Fresh.HelpWindow.superclass.syncSize.call(this);
		Fresh.Reader.enableKeyMap(false);		
	},
	
	hide: function() {
		Fresh.PreferencesWindow.superclass.hide.apply(this, arguments);
		Fresh.Reader.enableKeyMap(true);		
	}
});
