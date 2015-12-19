/*
 * Copyright 2007-2008. Adobe Systems Incorporated.
 * All rights reserved.
 */


var Fresh = Fresh || {};

Fresh.Preferences = function(database) {
	this.preferences = {
		runInBackground: {value: false, bool: true},
		refreshTimeout: {value: 180000, bool: false, defaultValue: 180000},
		startAtLogin: {value: false, bool: true},
		startMinimized: {value: false, bool: true},
		minimizeToTray: {value: false, bool: true},
		showNotifications: {value: true, bool: true},
		defaultLanguage: {value: "default", bool: false}		
	};
	this.feedDB = database;
	
	// load preferences
	var prefs = database.loadPreferences();
	var _self = this; 
	prefs.forEach(function(pref) {
		air.trace("Initial preference: " + pref.preference_name + " = " + pref.preference_value);
		var p = _self.preferences[pref.preference_name];
		if (p) {
			p.value = pref.preference_value;
			p.preference_id = pref.preference_id;
		}	
	});
	this.addEvents(
        "prefupdated"
    );
	Fresh.Preferences.superclass.constructor.call(this);
}

Ext.extend(Fresh.Preferences, Ext.util.Observable, {
	getPreference: function(preference) {
		var pref = this.preferences[preference];
		if (!pref) {
			return false;
		}
		if (pref.bool) {
			return pref.value != 0 ? true : false;
		}
		return pref.value;
	},
	
	setPreference: function(preference, value) {
		var pref = this.preferences[preference];
		if (!pref) {
			return;
		}
		if (pref.bool) {
			pref.value = (value && value != 0) ? true : false;	
		} else {
			if (pref.defaultValue) {
 				pref.value = value >= 0 ? value : pref.defaultValue;
			} else {
				pref.value = value;
			}
		}
	},
	
	savePreferences: function(prefs) {
		for (var i in prefs) {
			this.setPreference(i, prefs[i]); 		
		}
		this.save();
	},
	
	save: function() {
		for (var pref in this.preferences) {
			var id = null;
			if (this.preferences[pref].preference_id) {
				id = this.feedDB.savePreference(pref, this.preferences[pref].value, this.preferences[pref].preference_id);
			} else {
				id = this.feedDB.savePreference(pref, this.preferences[pref].value);
			}
			if (id !== false) {
				this.preferences[pref].preference_id = id;
			}
		}
		this.fireEvent('prefupdated', this);
	},
	
	//
	getAll: function() {
		return this.preferences;	
	}
});