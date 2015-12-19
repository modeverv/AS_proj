/*
 * Copyright 2007-2008. Adobe Systems Incorporated.
 * All rights reserved.
 */

 
var Fresh; if (!Fresh) Fresh = {};
Fresh.FileUtils = {};

Fresh.FileUtils.copy = function(source, destination, overwrite)
{
	var sourceFile = air.File.applicationResourceDirectory.resolvePath(source);
	var destinationFile  = air.File.applicationResourceDirectory.resolvePath(destination);
	var clobber = (overwrite && overwrite.toString() == "true")? true: false;
  
	try {
		sourceFile.copyTo(destinationFile, clobber);
	}
	catch (e) { return false; }
	return true;
};


Fresh.FileUtils.copyAsync = function(source, destination, callback, overwrite) 
{
	var sourceFile = air.File.applicationResourceDirectory.resolvePath(source);
	var destinationFile  = air.File.applicationResourceDirectory.resolvePath(destination);
	var clobber = (overwrite && overwrite.toString() == "true")? true: false;

	sourceFile.addEventListener(air.Event.COMPLETE, function(ev) { 
		if (callback) callback.apply(this, [true, ev]);
	});
	sourceFile.addEventListener(air.IOErrorEvent.IO_ERROR, function(ev) {  
		if (callback) callback.apply(this, [false, ev]);
	});
	sourceFile.copyToAsync(destinationFile, clobber);
};



Fresh.FileUtils.readContent = function(source) 
{
	var sourceFile = air.File.applicationResourceDirectory.resolvePath(source);
	var sourceStream = new air.FileStream();
  
	var content = false;
	try {
		sourceStream.open(sourceFile, air.FileMode.READ);
		content = sourceStream.readUTFBytes(sourceStream.bytesAvailable);
		sourceStream.close();
	} catch (e) {}
  
	delete sourceStream;
	return content;
};



Fresh.FileUtils.readContentAsync = function(source, callback) 
{
  var sourceFile = air.File.applicationResourceDirectory.resolvePath(source);
  var sourceStream = new air.FileStream();
  
  sourceStream.addEventListener(air.Event.COMPLETE, function(ev) {
        var content = sourceStream.readUTFBytes(sourceStream.bytesAvailable); 
        sourceStream.close();
        if (callback) callback.apply(this, [content, ev]);
  });
  sourceStream.addEventListener(air.IOErrorEvent.IO_ERROR, function(ev) { 
      sourceStream.close();
      if (callback) callback.apply(this, [false, ev]);
   });
  sourceStream.openAsync(sourceFile, air.FileMode.READ);
};



Fresh.FileUtils.writeContent = function(destination, content, overwrite) 
{
  var destinationFile = air.File.applicationResourceDirectory.resolvePath(destination);
  var clobber = (overwrite && overwrite.toString() == "true")? true: false; 
  
  if (destinationFile.exists && !clobber) 
     return false;
  
  var destinationStream = new air.FileStream();
  try {
    destinationStream.open(destinationFile, air.FileMode.WRITE);
    destinationStream.writeUTFBytes(content);
    destinationStream.close();
  } catch (e) {return false;}
  
  return true;
};


Fresh.FileUtils.writeContentAsync = function(destination, content, callback, overwrite) 
{
  var destinationFile = air.File.applicationResourceDirectory.resolvePath(destination);
  var clobber = (overwrite && overwrite.toString() == "true")? true: false; 
  
  if (destinationFile.exists && !clobber) 
  {
     if (callback) callback.apply(this, [false]);
     return;
  }
         
  var destinationStream = new air.FileStream();
  destinationStream.addEventListener(air.IOErrorEvent.IO_ERROR, function(ev) { 
      if (callback) callback.apply(this, [false, ev]);
   });
  destinationStream.addEventListener(air.Event.CLOSE, function(ev) { 
        destinationStream.close();
        if (callback) callback.apply(this, [true, ev]);
   });
   
  destinationStream.openAsync(destinationFile, air.FileMode.WRITE);
  destinationStream.writeUTFBytes(content);
  destinationStream.close();
};



Fresh.FileUtils.listDir = function(dir) 
{
  var dir = air.File.applicationResourceDirectory.resolvePath(dir);
  try {
    var list = dir.listDirectory();
  } catch(e){}
  
  if (!list) return false;
  
  // format the result
  var result = new Array();
  for (var file in list) 
  {
    var currentFile = list[file];
    var resultFile = {};
    resultFile.relPath = air.File.applicationResourceDirectory.relativize(currentFile, true);
    resultFile.fullPath = currentFile.nativePath;
    resultFile.isDirectory = currentFile.isDirectory;
    result.push(resultFile);    
  }
  return result;
};


Fresh.FileUtils.listDirAsync = function(dir, callback) 
{
  var dir = air.File.applicationResourceDirectory.resolvePath(dir);

  dir.addEventListener(air.FileListEvent.DIRECTORY_LISTING, function(ev) {
      var result = new Array();
      for (var file in ev.files) 
      {
        var currentFile = ev.files[file];
        var resultFile = {};
        resultFile.relPath = air.File.applicationResourceDirectory.relativize(currentFile, true);
        resultFile.fullPath = currentFile.nativePath;
        resultFile.isDirectory = currentFile.isDirectory;
        result.push(resultFile);    
      }
      if (callback) callback.apply(this, [result, ev]);
  });
  dir.addEventListener(air.ErrorEvent.ERROR, function(ev) {  
      if (callback) callback.apply(this, [false, ev]);
  });
  dir.addEventListener(air.IOErrorEvent.IO_ERROR, function(ev) {  
      if (callback) callback.apply(this, [false, ev]);
  });  
  dir.listDirectoryAsync(); 
};



Fresh.FileUtils.move = function(source, destination, overwrite)
{
  var sourceFile = air.File.applicationResourceDirectory.resolvePath(source);
  var destinationFile  = air.File.applicationResourceDirectory.resolvePath(destination);
  var clobber = (overwrite && overwrite.toString() == "true")? true: false;
  
  try {
    sourceFile.moveTo(destinationFile, clobber);
  }  catch (e) { return false; }
  return true;
};



Fresh.FileUtils.moveAsync = function(source, destination, callback, overwrite) 
{
  var sourceFile = air.File.applicationResourceDirectory.resolvePath(source);
  var destinationFile  = air.File.applicationResourceDirectory.resolvePath(destination);
  var clobber = (overwrite && overwrite.toString() == "true")? true: false;

  sourceFile.addEventListener(air.Event.COMPLETE, function(ev) { 
      if (callback) callback.apply(this, [true, ev]);
  });
  sourceFile.addEventListener(air.IOErrorEvent.IO_ERROR, function(ev) {  
      if (callback) callback.apply(this, [false, ev]);
  });
  sourceFile.moveToAsync(destinationFile, clobber);
};


Fresh.FileUtils.deleteFile = function(source)
{
  var sourceFile = air.File.applicationResourceDirectory.resolvePath(source);
  try {
    sourceFile.deleteFile();
  }
  catch (e) { return false; }
  return true;
};


Fresh.FileUtils.deleteFileAsync = function(source, callback)
{
  var sourceFile = air.File.applicationResourceDirectory.resolvePath(source);
  sourceFile.addEventListener(air.Event.COMPLETE, function(ev) { 
      if (callback) callback.apply(this, [true, ev]);
  });
  sourceFile.addEventListener(air.IOErrorEvent.IO_ERROR, function(ev) {  
      if (callback) callback.apply(this, [false, ev]);
  });
  sourceFile.deleteFileAsync();
};


Fresh.FileUtils.deleteDir = function(source, deleteDirContents)
{
  var sourceDir = air.File.applicationResourceDirectory.resolvePath(source);
  var delContents = (deleteDirContents && deleteDirContents.toString() == "true")? true: false;
  try {
    sourceDir.deleteDirectory(delContents);
  }
  catch (e) { return false; }
  return true;
};


Fresh.FileUtils.deleteDirAsync = function(source, deleteDirContents, callback)
{
  var sourceDir = air.File.applicationResourceDirectory.resolvePath(source);
  var delContents = (deleteDirContents && deleteDirContents.toString() == "true")? true: false;

  sourceDir.addEventListener(air.Event.COMPLETE, function(ev) { 
      if (callback) callback.apply(this, [true, ev]);
  });
  sourceDir.addEventListener(air.IOErrorEvent.IO_ERROR, function(ev) {  
      if (callback) callback.apply(this, [false, ev]);
  });
  sourceDir.deleteDirectoryAsync(delContents);
};

Fresh.FileUtils.createDir = function(dir)
{
  var sourceDir = air.File.applicationResourceDirectory.resolvePath(dir);
  try {
    sourceDir.createDirectory();
  }
  catch (e) { return false; }
  return true;
};

Fresh.FileUtils.inResource= function(name) {
	var sourceFile = air.File.applicationResourceDirectory.resolvePath(name);
	return sourceFile.exists;
};



/******************************************************************/
Fresh.FilePrefs = {cached:[]};

Fresh.FilePrefs.storePut = function(name, content, overwrite) {
 	var destinationFile = air.File.applicationStorageDirectory.resolvePath(name);
  	var clobber = (overwrite && overwrite.toString() == "true")? true: false; 
  
	if (destinationFile.exists && !clobber) return false;
  
	var destinationStream = new air.FileStream();
	try {
		destinationStream.open(destinationFile, air.FileMode.WRITE);
		destinationStream.writeUTFBytes(content);
		destinationStream.close();
	} catch (e) {air.trace(e); return false;}
	return true;	
};

Fresh.FilePrefs.storeGet = function(name) {
	var sourceFile = air.File.applicationStorageDirectory.resolvePath(name);
	var sourceStream = new air.FileStream();
  
	var content = false;
	try {
		sourceStream.open(sourceFile, air.FileMode.READ);
		content = sourceStream.readUTFBytes(sourceStream.bytesAvailable);
		sourceStream.close();
	} catch (e) {}
  
	delete sourceStream;
	return content;	
};

Fresh.FilePrefs.storeDel = function(name) {
	var sourceFile = air.File.applicationStorageDirectory.resolvePath(name);	
	try {
		sourceFile.deleteFile();
	}
	catch (e) { return false; }
	return true;	
};

Fresh.FilePrefs.storeGetAsync = function(name, callback, args) {
	var sourceFile = air.File.applicationStorageDirectory.resolvePath(name);
 	var sourceStream = new air.FileStream();
  
	sourceStream.addEventListener(air.Event.COMPLETE, function(ev) {
		var content = [];
		content['responseText'] = sourceStream.readUTFBytes(sourceStream.bytesAvailable);
        sourceStream.close();
        if (callback) callback.apply(this, [content, ev, args]);
	});
	sourceStream.addEventListener(air.IOErrorEvent.IO_ERROR, function(ev) { 
		sourceStream.close();
		if (callback) callback.apply(this, [false, ev, args]);
	});
	sourceStream.openAsync(sourceFile, air.FileMode.READ);	
};

Fresh.FilePrefs.inStore = function(name) {
	var sourceFile = air.File.applicationStorageDirectory.resolvePath(name);
	return sourceFile.exists;
};

Fresh.FilePrefs.propGet = function(key, propertyFile) {
	var propFile = air.File.applicationStorageDirectory.resolvePath(propertyFile);
	if (!Fresh.FilePrefs.cached[propertyFile]) {
		if(Fresh.FilePrefs.inStore(propertyFile)) {
			Fresh.FilePrefs.cached[propertyFile] = Ext.decode(Fresh.FilePrefs.storeGet(propertyFile));
		}
		else {
			Fresh.FilePrefs.cached[propertyFile] = {};	
		}
	}
	return Fresh.FilePrefs.cached[propertyFile][key];
};

Fresh.FilePrefs.propPut = function(key, value, propertyFile) {
	var propFile = air.File.applicationStorageDirectory.resolvePath(propertyFile);
	if (!Fresh.FilePrefs.cached[propertyFile]) {
		if(Fresh.FilePrefs.inStore(propertyFile)) {
			Fresh.FilePrefs.cached[propertyFile] = Ext.decode(Fresh.FilePrefs.storeGet(propertyFile));
		}
		else {
			Fresh.FilePrefs.cached[propertyFile] = {};	
		}
	} 
	Fresh.FilePrefs.cached[propertyFile][key] = value;
	var encode = Ext.encode(Fresh.FilePrefs.cached[propertyFile]);
	if (Fresh.FilePrefs.storePut(propertyFile, encode, true) === false) {
		air.trace("Error saving property file");
	}
};

Fresh.FilePrefs.storeDelDir = function(source, deleteDirContents)
{
	var sourceDir = air.File.applicationStorageDirectory.resolvePath(source);
	var delContents = (deleteDirContents && deleteDirContents.toString() == "true")? true: false;
	try {
		sourceDir.deleteDirectory(delContents);
	}
	catch (e) { return false; }
	return true;
};
