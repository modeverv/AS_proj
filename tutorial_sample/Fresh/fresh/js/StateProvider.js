/*
 * Copyright 2007-2008. Adobe Systems Incorporated.
 * All rights reserved.
 */


var Fresh; if (!Fresh) Fresh = {};

Fresh.StateProvider = function(config) {
	Fresh.StateProvider.superclass.constructor.call(this);
	Ext.apply(this, config);
	this.state = {};
	this.stateIds = {};
	var dbStates = this.database.loadStates();
	dbStates.forEach(function(state) {
		air.trace("Initial state: " + state.state_name + " = " + state.state_value);
		this.state[state.state_name] =  this.decodeValue(state.state_value);
		this.stateIds[state.state_name] = state.state_id;
	}, this);	
}

Ext.extend(Fresh.StateProvider, Ext.state.Provider, {
	set: function(name, value) {
		if(typeof value == "undefined" || value === null){
			this.clear(name);
			return;
		}
		this.database.saveState(name, this.encodeValue(value), this.stateIds[name]);
		Fresh.StateProvider.superclass.set.call(this, name, value);
	},

	clear: function(name) {
		this.database.clearState(name);
		Fresh.StateProvider.superclass.clear.call(this, name);
	},
	
	resetState: function() {
		this.database.deleteAllStates();
	}
});