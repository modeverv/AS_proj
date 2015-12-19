/*
 * Copyright 2007-2008. Adobe Systems Incorporated.
 * All rights reserved.
 */


var Fresh; if (!Fresh) Fresh = {};

var langTpl = new Ext.XTemplate('<tpl for="."><div class="x-combo-list-item">{text}</div></tpl>');
              
Fresh.PreferencesWindow = function (preferences) {
	this.preferences = preferences;
	this.runInBackground = new Ext.form.Checkbox({
		fieldLabel: _T( 'fresh', 'lblRefreshInBackground' ),
		checked: preferences.getPreference('runInBackground')
	});
	this.defaultLanguage = new Ext.form.ComboBox({
		fieldLabel: _T( 'fresh', 'lblLanguage' ),
		width: 270,	   
		allowBlank: false,
		forceSelection: true,
        triggerAction: 'all',
		mode: 'local',
		displayField: 'text',
		valueField: 'value',
		tpl: langTpl,
		store: new Ext.data.SimpleStore(
			{	
				fields: ['value', 'text'],		
				data: [
				]
			}
		),
//		value: this.preferences.getPreference('defaultLanguage')
	});
	this.refreshTimeout = new Ext.form.TextField({
		fieldLabel: _T( 'fresh', 'lblRefreshTimeout' ),
		width: 50,
		value: preferences.getPreference('refreshTimeout')/60000,
		validationEvent: false,
		validateOnBlur: false,
		msgTarget: 'under',		
		listeners:{
			valid: this.syncShadow,
			invalid: this.syncShadow,
			scope: this
		}, 
	});
	this.startAtLogin = new Ext.form.Checkbox({
		fieldLabel: _T( 'fresh', 'lblStartAtLogin' ),
		checked: preferences.getPreference('startAtLogin')
	});
	this.startMinimized = new Ext.form.Checkbox({
		fieldLabel: _T( 'fresh', 'lblStartMinimized' ),
		checked: preferences.getPreference('startMinimized')
	});
	
	this.minimizeToTray = new Ext.form.Checkbox({
		fieldLabel: _T( 'fresh', 'lblMinimizeToTray' ),
		checked: preferences.getPreference('minimizeToTray')
	});
	this.showNotifications = new Ext.form.Checkbox({
		fieldLabel: _T( 'fresh', 'lblShowNotifications' ),
		checked: preferences.getPreference('showNotifications')
	});
	
	this.form = new Ext.FormPanel({
		labelWidth: 130,
		items: [this.runInBackground, this.refreshTimeout, this.startAtLogin, this.startMinimized, this.minimizeToTray, this.showNotifications, this.defaultLanguage],
		border: false,
		bodyStyle: 'background: transparent;padding: 10px;'
	});
	Fresh.PreferencesWindow.superclass.constructor.call(this, {
		title: _T( 'fresh', 'lblPreferences' ),
		autoHeight: true,
		plain: true,
		modal: true,
		hidden: false,
		closeAction: 'hide',
		buttons: [{
			text: _T( 'fresh', 'btnSave' ),
			handler: this.onSave,
			scope: this
		}, {
			text: _T( 'fresh', 'btnCancel' ),
			handler: this.hide.createDelegate(this, [])	
		}],
		items: this.form
	});
}

Ext.extend(Fresh.PreferencesWindow, Ext.Window, {
	show: function() {                    
		this.defaultLanguage.store.loadData([
			[ 'default', _T( 'fresh', 'lblSystemDefaultLanguage' , null ) ],
			[ 'en', _T( 'fresh', 'lblEnglish' , null ) ],
			[ 'ro', _T( 'fresh', 'lblRomanian' , null ) ],
			[ 'de', _T( 'fresh', 'lblGerman' , null ) ],
			[ 'es', _T( 'fresh', 'lblSpanish' , null ) ],
			[ 'fr', _T( 'fresh', 'lblFrench' , null ) ],
			[ 'it', _T( 'fresh', 'lblItalian' , null ) ],
			[ 'ja', _T( 'fresh', 'lblJapanese' , null ) ],
			[ 'ko', _T( 'fresh', 'lblKorean' , null ) ],
			[ 'pt', _T( 'fresh', 'lblPortuguese' , null ) ],
			[ 'ru', _T( 'fresh', 'lblRussian' , null ) ],
			[ 'zh_Hans', _T( 'fresh', 'lblSimplified_Chinese' , null ) ],
			[ 'zh_Hant', _T( 'fresh', 'lblTraditional_Chinese' , null ) ],
			[ 'cs', _T( 'fresh', 'lblCzech' , null ) ],
			[ 'pl', _T( 'fresh', 'lblPolish' , null ) ],
			[ 'tr', _T( 'fresh', 'lblTurkish' , null ) ],
			[ 'sv', _T( 'fresh', 'lblSwedish' , null ) ],
			[ 'nl', _T( 'fresh', 'lblDutch' , null ) ]
		]);
		this.runInBackground.setValue(this.preferences.getPreference('runInBackground'));
		this.showNotifications.setValue(this.preferences.getPreference('showNotifications'));
		this.startAtLogin.setValue(this.preferences.getPreference('startAtLogin'));
		this.startMinimized.setValue(this.preferences.getPreference('startMinimized'));
		this.minimizeToTray.setValue(this.preferences.getPreference('minimizeToTray'));
		this.refreshTimeout.setValue(this.preferences.getPreference('refreshTimeout')/60000);
		this.defaultLanguage.setValue(this.preferences.getPreference('defaultLanguage'));		
		Fresh.PreferencesWindow.superclass.show.apply(this, arguments);
		Fresh.Reader.enableKeyMap(false);
	},
	
	hide: function() {
		Fresh.PreferencesWindow.superclass.hide.apply(this, arguments);
		Fresh.Reader.enableKeyMap(true);		
	},
	
	onSave: function() {
		var timeout = parseFloat(this.refreshTimeout.getValue());
		if (isNaN(timeout)) {
			this.markInvalid();
			return;
		}
		this.hide();  
		return this.fireEvent('prefsave', {
				runInBackground: this.runInBackground.getValue(),
				refreshTimeout: timeout	* 60000,
				startAtLogin: this.startAtLogin.getValue(),
				startMinimized: this.startMinimized.getValue(),
				minimizeToTray: this.minimizeToTray.getValue(),
				showNotifications: this.showNotifications.getValue(),
				defaultLanguage: this.defaultLanguage.getValue()
			});
	},
	
	markInvalid: function() {
		this.refreshTimeout.markInvalid(_T( 'fresh', 'The specified timeout must be a number >= 0' ));
		this.el.unmask();	
	}
});