/*
 * Copyright 2007-2008. Adobe Systems Incorporated.
 * All rights reserved.
 */

 
var Fresh; if (!Fresh) Fresh = {};

Fresh.OpmlFile = function() {
	this.addEvents(
		"opmlimported"
	);
	Fresh.OpmlFile.superclass.constructor.call(this);
};

Ext.extend(Fresh.OpmlFile, Ext.util.Observable, {
	importOPML : function(feedDB, opmlHandler) {
		var opmlOpenFile = new air.File();
   		var opmlFilter = new runtime.Array(new air.FileFilter(_T( 'fresh', 'lblOpmlFiles',null), "*.opml"), new air.FileFilter(_T( 'fresh', 'lblAllFiles', null), "*.*"));
   		var _self = this;
		//			
    	opmlOpenFile.addEventListener(air.Event.SELECT, function(event) {
			air.trace("onImportOPML Selected")
	    	var sourceFile = event.target;
			var sourceStream = new air.FileStream();
			var content = false;
			try {
				sourceStream.open(sourceFile, air.FileMode.READ);
				content = sourceStream.readUTFBytes(sourceStream.bytesAvailable);
				sourceStream.close();
			} catch (e) {}
			delete sourceStream;
			if (content) {
				var records = opmlHandler.readOpml(content);
				if (feedDB.addOpmlFeeds(records.records)) {
					_self.fireEvent("opmlimported");
				}
				
			}					            	
		});
		try {
			opmlOpenFile.browseForOpen(_T( 'fresh', 'lblLoadOpml',null), opmlFilter);
		}catch(e) {}
	},
        
	exportOPML : function(feedDB, opmlHandler) {
		var opmlSaveFile = new air.File();
    	opmlSaveFile.addEventListener(air.Event.SELECT, function(event) {
			var destinationFile = event.target;
			//air.trace(destinationFile.nativePath);
			try {
				var xml = opmlHandler.exportOpml(feedDB);
				var destinationStream = new air.FileStream();
				destinationStream.open(destinationFile, air.FileMode.WRITE);
				destinationStream.writeUTFBytes(xml);
				destinationStream.close();
			} catch(e) {
				alert(_T( 'fresh', 'lblErrorOpmlExport',null) + e);
				return;
			}	
			Fresh.Utils.openInBrowser("file:///" + destinationFile.nativePath, this.win);
		});			
		try {
			opmlSaveFile.browseForSave(_T( 'fresh', 'lblSaveOpml',null));        		
		}catch(e) {	}
	}	
});



