/*
ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.
 
NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the 
terms of the Adobe license agreement accompanying it.  If you have received this file from a 
source other than Adobe, then your use, modification, or distribution of it requires the prior 
written permission of Adobe.

*/

/*
 * Retrieves a page and referenced images and CSS files from url and save it to local
 * Does not support < !--[if lte IE 6]>-like tags, not needed in Safari / WebKit
 */
function modSaveWebPage(url, local, HTMLDocument, callback)
{
	this.webUrl = url.charAt(url.length - 1) != "/" ? url + "/" : url;
	this.localUrl = local;
	this.pageAssets = new Object();
	this.pageAssetsCnt = 0;
	this.remainingFiles = 0;
			
	var tempHTMLData = "";
	var currentDir = "";
	
	var patternCSSImports = /@import\s+url\s*\([\s]*["']?(.*?)["']?[\s]*\)/gi;
	var patternCSSImportURL = /@import\s+url\s*\([\s]*["']?(.*?)["']?[\s]*\)/i;
	var patternBackgroundImages = /background(?:\-image)?\s*\:.*url\s*\(['"]?(.*?)['"]?\)/gi;
	var patternBackgroundImageUrl = /background(?:\-image)?\s*\:.*url\s*\(['"]?(.*?)['"]?\)/i;
	
	// Pattern to detect characters not allowed in file names and replace them with replaceChar
	var patternDetectForbiddenChars = /[\\:*"<>|]/;
	var replaceChar = "_";
	
	// e.g.: //dir1/dir2/index.html returns //
	var patternDetectFirstPathSlash = /^\s*(\/+).*?/gi;
	
	var patternBaseURL = /(?:http|https|ftp)\:\/\/(?:www.)?(?:[\w-]+\.)*[\w-]+\.[\w]{2,6}/gi;
	
	var patternDetectRelativePath = /\/?((\.{1,2}|[\w.%-]+)\/)+/gi;
	
	// Escapes '/', '%', '.', '_', '-'
	this.escapeURL = function(string)
	{
		string = string.replace(/\//g, "\\/");
		string = string.replace(/\%/g, "\\%");
		string = string.replace(/\./g, "\\.");
		string = string.replace(/\_/g, "\\_");
		string = string.replace(/\-/g, "\\-");
		string = string.replace(/\:/g, "\\:");
		
		return string;
	}

	var patternDetectURLPath = /(?:http|https|ftp)\:\/\/(?:(?:www.)?(?:[\w-]+\.)*[\w-]+\.[\w]{2,6}|(?:[\w-]+))(?:\:\d{1,5})?\/?(?:(?:(?:\.{1,2}|[\w.%-]+)\/)+)?/gi;
	
	var patternDetectSiteURLPath = new RegExp(this.escapeURL( this.webUrl ) + "(?:[\\w.%-]+\\/)*", "gi");

	// Class to describe a single page asset
	this.pageAsset = function(fileName, fileFormat, fileContent)
	{
		this.fileName = fileName;
		this.fileFormat = fileFormat;
		this.fileContent = fileContent;
	}
	
	// Files included with the @import url command, from the index.html file or other CSS files
	this.getCSSImports = function(string, includerPath)
	{
		var elems = string.match(patternCSSImports);

		if(elems != null)
		{
			for(var i=0; i<elems.length; i++)
			{
				var fileName = this.sanitizeFileName(elems[i].match(patternCSSImportURL)[1]);
				var resolvedFileName = this.resolveCSSPath(fileName, includerPath);

				if(! this.isCached(resolvedFileName))
				{
					this.pageAssets[ this.pageAssetsCnt ] = new this.pageAsset(resolvedFileName, air.URLLoaderDataFormat.TEXT, null);
					this.remainingFiles++;
					this.copyContentToAssets( this.pageAssetsCnt );
					this.pageAssetsCnt++;
				}

				string = string.replace(fileName, this.stripPathsToLocalRoot(resolvedFileName));
			}
		}
		
		return string;
	}
	
	// Searches a string (CSS file usually) for background-image properties and retrieves the URLs
	this.getBackgroundImages = function(string, includerPath)
	{
		var elems = string.match(patternBackgroundImages);

		if(elems != null)
		{
			for(var i=0; i<elems.length; i++)
			{
				var fileName = this.sanitizeFileName(elems[i].match(patternBackgroundImageUrl)[1]);
				var resolvedFileName = this.resolveCSSPath(fileName, includerPath);
				
				if(! this.isCached(resolvedFileName))
				{
					this.pageAssets[ this.pageAssetsCnt ] = new this.pageAsset(resolvedFileName, air.URLLoaderDataFormat.BINARY, null);
					this.remainingFiles++;
					this.copyContentToAssets( this.pageAssetsCnt );
					this.pageAssetsCnt++;
				}
						
				string = string.replace(fileName, this.stripPathsToLocalRoot(resolvedFileName));
			}
		}
		
		return string;
	}
	
	// Retrieve all references to CSS files from index.html
	this.getCSS = function()
	{
		// Files included with the link tag
		var elems = HTMLDocument.getElementsByTagName("link");

		for(var i=0; i<elems.length; i++)
		{
			if(elems[i].hasAttribute("rel") && elems[i].hasAttribute("type") && elems[i].hasAttribute("href"))
			{
				if(elems[i].getAttribute("rel") == "stylesheet" && elems[i].getAttribute("type") == "text/css")
				{
					var fileName = this.sanitizeFileName(elems[i].getAttribute("href"));
					var resolvedFileName = this.resolveRelativePath(fileName);
					
					if(fileName != null && fileName != "")
					{
						if(! this.isCached(resolvedFileName))
						{
							this.pageAssets[ this.pageAssetsCnt ] = new this.pageAsset(resolvedFileName, air.URLLoaderDataFormat.TEXT, null);
							this.remainingFiles++;
							this.copyContentToAssets( this.pageAssetsCnt );
							this.pageAssetsCnt++;
						}
						
						tempHTMLData.fileContent = tempHTMLData.fileContent.replace(fileName, this.stripPathsToLocalRoot(resolvedFileName));
					}
				}
			}
		}

		// Follow any CSS @imports, once a file is downloaded it recursively follows other @imports (behavior alleged by this.copyContentToAssets)
		tempHTMLData.fileContent = this.getCSSImports(tempHTMLData.fileContent, this.webUrl);
	}

	// Strip all absolute http paths from a given file leaving the file names intact
	this.stripPathsToLocalRoot = function(string)
	{
		return string.replace(patternDetectURLPath, "");
	}

	// Strip all relative-like paths from a given file leaving the file names intact
	this.stripRelativePathsToLocalRoot = function(string)
	{
		return string.replace(patternDetectRelativePath, "");
	}
	
	// Finds non-allowable characters in file name and replaces them
	this.sanitizeFileName = function(fileName)
	{
		return fileName.replace(patternDetectForbiddenChars, replaceChar);
	}
	
	// Translates relative paths to absolute URL paths
	this.resolveRelativePath = function(includePath)
	{
		// If it's not an absolute URL path
		if(includePath.indexOf("http://") != 0)
		{
			// If it's something like dir1/dir2/file.f or ../../dir/file.f
			if(includePath.charAt(0) != "/" || includePath.indexOf("../") == 0)
				includePath = this.webUrl + includePath;
			// If it's something that translates to the relative root of the site
			else
				includePath = this.webUrl.match(patternBaseURL)[0] + includePath;
		}

		return includePath;
	}
	
	// Resolve paths in CSS files to absolute URL paths
	this.resolveCSSPath = function(includePath, includerPath)
	{
		if(includePath.indexOf("http://") != 0)
		{
			return includerPath.match(patternDetectURLPath)[0] + includePath.replace(patternDetectFirstPathSlash, "");
		}
		return includePath;
	}
	
	// Retrieve all references to images
	this.getImages = function()
	{
		var elems;
		
		// Files included with the img tag
		elems = HTMLDocument.getElementsByTagName("img");
		for(var i=0; i<elems.length; i++)
		{
			if(elems[i].hasAttribute("src"))
			{
				var fileName = this.sanitizeFileName(elems[i].getAttribute("src"));
				var resolvedFileName = this.resolveRelativePath(fileName);
				
				if(fileName != null && fileName != "")
				{
					if(! this.isCached(resolvedFileName))
					{
						this.pageAssets[ this.pageAssetsCnt ] = new this.pageAsset(resolvedFileName, air.URLLoaderDataFormat.BINARY, null);
						this.remainingFiles++;
						this.copyContentToAssets( this.pageAssetsCnt );
						this.pageAssetsCnt++;
					}
					
					tempHTMLData.fileContent = tempHTMLData.fileContent.replace(fileName, this.stripPathsToLocalRoot(resolvedFileName));
				}
			}
		}
		
		// Scan index.html for inline background or background-image references
		tempHTMLData.fileContent = this.getBackgroundImages(tempHTMLData.fileContent, this.webUrl);
	}
	
	// Download file contents from URL and store it wherever the caller function wants
	this.downloadFile = function(downloadUrl, downloadDataFormat, callback)
	{
		var urlRequest = new air.URLRequest(downloadUrl);
		var urlLoader = new air.URLLoader();

		urlLoader.dataFormat = downloadDataFormat;
		urlLoader.addEventListener(air.Event.COMPLETE, 
						function() {
							callback(urlLoader.data);
						});
		
		urlLoader.addEventListener(air.IOErrorEvent.IO_ERROR,
						function() {
							callback(null);
						});
		
		urlLoader.addEventListener(air.SecurityErrorEvent.SECURITY_ERROR,
						function() {
							callback(null);
						});

		urlLoader.load(urlRequest);
	}
	
	// Invokes this.downloadFile for one asset and copy the response to the assets library
	this.copyContentToAssets = function(i)
	{
		var that = this;
		this.downloadFile(this.pageAssets[i].fileName, this.pageAssets[i].fileFormat, 
						function(response) {
						
							// fileContent gets null when a file couldn't be retrieved (or the attempt failed)
							that.pageAssets[i].fileContent = response;

							if(that.pageAssets[i].fileContent != null)
							{
								// If it's a text file (most probably a CSS file)...
								if(that.pageAssets[i].fileFormat == air.URLLoaderDataFormat.TEXT)
								{
									// ... parse it for more references to CSS and image files, send the includeURL, then get the returned resolved-to-local content
									that.pageAssets[i].fileContent = that.getCSSImports(that.pageAssets[i].fileContent, that.pageAssets[i].fileName);
									that.pageAssets[i].fileContent = that.getBackgroundImages(that.pageAssets[i].fileContent, that.pageAssets[i].fileName);
								}
							}
																	
							that.fileDownloadComplete();
						});
	}

	// Invokes writeFile to write assets to the disk when they are completely downloaded
	this.fileDownloadComplete = function()
	{
		this.remainingFiles--; 
	
		if(! this.remainingFiles){
	
			// Writes to the disk assets with content that isn't null
			for(var i=0; i<this.pageAssetsCnt; i++)
			{
			 	if(this.pageAssets[i].fileContent != null)
				{
					this.writeFile(this.pageAssets[i].fileName, this.pageAssets[i].fileFormat, this.pageAssets[i].fileContent);
				}
			}
			callback();
		}
	 }
	
	// Checks whether an asset already exists in the library
	this.isCached = function(fileName)
	{
		for(var i=0; i<this.pageAssetsCnt; i++)
			if(fileName == this.pageAssets[i].fileName)
				return true;
			
		return false;
	}
	
	// Writes a file to the disk
	this.writeFile = function(fileName, fileFormat, fileContent)
	{
		//var localFile = air.File.applicationStorageDirectory.resolvePath(this.localUrl + (new air.File(fileName)).name);

		var shortName = fileName;
		var i = shortName.lastIndexOf('/');
		if(i != -1) shortName= shortName.substr(i + 1);
		i = shortName.lastIndexOf('?');
		if(i != -1) shortName= shortName.substr(0, i);
			
		if(shortName.length == 0) return;
		var localFile = local.resolvePath(shortName);
		
		var fs = new air.FileStream();
		fs.open(localFile, air.FileMode.WRITE);
		
		if(fileFormat == air.URLLoaderDataFormat.TEXT)
		{
			fs.writeUTFBytes(fileContent);
		}
		else if(fileFormat == air.URLLoaderDataFormat.BINARY)
		{
			fs.writeBytes(fileContent, 0, fileContent.length);
		}
		
		fs.close();
	}
	
	tempHTMLData = new this.pageAsset(this.webUrl + "index.html", air.URLLoaderDataFormat.TEXT, HTMLDocument.outerHTML);

	this.getCSS();
	this.getImages();
	
	this.pageAssets[ this.pageAssetsCnt++ ] = tempHTMLData;
	this.remainingFiles++;

	/*
	 *  Writes file to the disk when all files are completely downloaded
	 *  Call fileDownloadComplete() here to download one more file (the index.html file)
	 */
	this.fileDownloadComplete();
	
}