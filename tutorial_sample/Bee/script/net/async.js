/*
ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.
 
NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the 
terms of the Adobe license agreement accompanying it.  If you have received this file from a 
source other than Adobe, then your use, modification, or distribution of it requires the prior 
written permission of Adobe.

*/

 //async problems come up when you wait multiple events
 //so this object waits every event to finish and fires a handler

//------------------------------------------------------------
//USAGE
 
 /*
  
 var atom = new Bee.Net.AsyncAtom();
 
 atom.onfinish=function(){
  	//fired when all events are finished
 
 }
 
 atom.addHandler('fileDownload', function(obj){
 	
 	alert('file downloaded');	
	
 });
 
 atom.addHandler('fileUpload', function(obj){
 	
 	alert('file uploaded');	
	
 });
 * 
 loader.addEventListener("complete", atom.getHandler('fileDownload', loader) );
 uploader.addEventListener("complete", atom.getHandler('fileUpload', uploader) ); 
 
 atom.finish();
 
 */
 //------------------------------------------------------------
 
 function AsyncAtom (){
 	this.opStack = {};
	this.handlers = {};
	this.id=0;
	this.finished  =false;
	this.stack = [];
 }
 
 AsyncAtom.prototype.addHandler =function(type, fn){
 	this.handlers[type]=fn;
	
 }
 
 AsyncAtom.prototype.getHandler = function (type, obj){
 	var that = this;
	var id = ++this.id;
	this.opStack[id]=obj;
 	var ret = function(){
		
		var args = [];
			
		for(var i=0;i<arguments.length;i++) args [i+1] =arguments[i];
			
		args[0]=obj;
		
		if(that.finished){
			if(type&&that.handlers[type])
				that.handlers[type].apply(that, args);
		}else{
			that.stack.push({type:type, args:args});
		}
			delete that.opStack[id];
			if(that.finished){
				for(var i in that.opStack){ return; }
				if(that.onfinish) that.onfinish();
			}

	}
	return ret;
 }
 
 AsyncAtom.prototype.finish =function(){
 		for(var i=0;i<this.stack.length;i++){
			var args = this.stack[i].args;
			var type = this.stack[i].type;
			
			if(type&&this.handlers[type])
					this.handlers[type].apply(this, args);
		}
 		this.finished = true;
		for(var i in this.opStack){ return; }
		if(this.onfinish) this.onfinish();
 }
 
 
 Bee.Net.AsyncAtom = AsyncAtom;
 
 
