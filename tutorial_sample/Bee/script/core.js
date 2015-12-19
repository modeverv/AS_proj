/*
ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.
 
NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the 
terms of the Adobe license agreement accompanying it.  If you have received this file from a 
source other than Adobe, then your use, modification, or distribution of it requires the prior 
written permission of Adobe.

*/
//Bee.Core
//handling events in Bee
 
 Bee.Core.Event = function(target, event_args){
 	
 	this.target = target;
 	
 	this.args = event_args;
 	
 }
 
 Bee.Core.Handler = function (event, func){
 	this.event = event;
 	this.func = func;
 }
 
 //Bee.Core.Handler.prototype.constructor = Bee.Core.Handler;
 
 Bee.Core.Handler.prototype.fire = function(target, event_args){
 	
 		//var e = {target : target, args: event_args };
 		this.func(new Bee.Core.Event(target, event_args));
 	
 }
 
 Bee.Core.Dispatcher = {
 	handlers:{},
 	
 	addEventListener: function (event, func){
 		var e = new Bee.Core.Handler(event, func);
 		
 		if(this.handlers[event]== undefined)
	 		this.handlers[event]=[e];
	 	else
	 		this.handlers[event].push(e);
	 		
	 		
 	},
 	
 	dispatch : function (event, target, event_args){
		var that = this;
 		setTimeout(function(){
 		
 		if(that.handlers[event]==undefined) return;
 		
 		var handlers_event = that.handlers[event];
 		
 		for(var i=0;i<handlers_event.length;i++)
 		{
 			var handler = handlers_event[i];
 			
 			
 			handler.fire(target, event_args);
 		}
		},0);
 	}
 	
 };