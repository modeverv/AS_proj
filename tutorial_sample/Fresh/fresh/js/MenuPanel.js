/*
 * Copyright 2007-2008. Adobe Systems Incorporated.
 * All rights reserved.
 */


var Fresh; if (!Fresh) Fresh = {};
          
Fresh.MenuPanel = function(preferences) {
	this.currentTheme = 'aero';
	Fresh.MenuPanel.superclass.constructor.call(this, {
		region: 'north',
		margins: '0 0 0 0',
		tbar: [{
			text: 'Fresh', //_T( 'fresh', 'mnuMain' ),
			menu: {
				id: 'mainMenu',
				items: [
	        	{
	        		text: _T( 'fresh', 'mnuRefreshAllFeeds' ),
					handler: Fresh.Reader.onRefreshAll,
					scope: Fresh.Reader
	        	},	            
	        	{
	        		text: _T( 'fresh', 'mnuMarkAllFeedsRead' ),
					handler: Fresh.Reader.onMarkAllRead,
					scope: Fresh.Reader
	        	},'-',
				{
		        	text: _T( 'fresh', 'mnuImportOpml' ),
					handler: Fresh.Reader.onImportOpml,
					scope: Fresh.Reader
	        	},
	        	{
	        		text: _T( 'fresh', 'mnuExportOpml' ),
					handler: Fresh.Reader.onExportOpml,
					scope: Fresh.Reader
	        	},'-',
	        	{
	        		text: _T( 'fresh', 'mnuEmptyCache' ),
					handler: Fresh.Reader.emptyCache,
					scope: Fresh.Reader
	        	}, {
	        		text: _T( 'fresh', 'mnuResetWindowState' ),
					handler: Fresh.Reader.resetState,
					scope: Fresh.Reader
	        	}]
			}
		},'-',{
			text: _T( 'fresh', 'mnuPreferences' ),
			tooltip : {title: _T( 'fresh', 'lblPreferencesDialogTitle' ), text: _T( 'fresh', 'mnuPreferencesTooltip' )},
			handler: this.onPreferencesClick,
			scope: this
		},'-',{
			text:_T( 'fresh', 'mnuHelp' ),
			menu: {
				id: 'helpMenu',
				items: [{
		        		text: _T( 'fresh', 'mnuKeyNavigation' ),
						handler:  this.onHelpClick,
						scope: this
		        	},'-', {
		        		text: _T( 'fresh', 'mnuViewSources' ),
						handler:  this.onViewSource,
						scope: this
		        	},
		        	{
		        		text: _T( 'fresh', 'mnuAbout' ),
						handler: this.onAboutClick,
						scope: this
		        }]
			}
		}]
	});
	// preferences
	this.preferences = preferences;
	this.prefWin = new Fresh.PreferencesWindow(preferences);
	this.prefWin.on('prefsave', this.savePreferences, this);
	// about
	this.aboutWin = new Fresh.AboutWindow();
	// help
	this.helpWin = new Fresh.HelpWindow();
}

Ext.extend(Fresh.MenuPanel, Ext.Panel, {
	onThemeClick: function(item, checked) {
		runtime.trace("Theme Click: " + item.id);
	},
	
	onPreferencesClick: function() {
		this.prefWin.show();
	},
	
	savePreferences: function(prefs) {
		
		this.preferences.savePreferences(prefs);

		setLocaleChain(this.preferences.getPreference('defaultLanguage'));

		
	},
	
	onHelpClick: function() {
		this.helpWin.show();
	},
	
	onViewSource: function() {
		air.SourceViewer.getDefault().viewSource();
	},
	
	onAboutClick: function() {
		this.aboutWin.show();
	}
});
