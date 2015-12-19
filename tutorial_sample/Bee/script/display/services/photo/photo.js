/*
ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.
 
NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the 
terms of the Adobe license agreement accompanying it.  If you have received this file from a 
source other than Adobe, then your use, modification, or distribution of it requires the prior 
written permission of Adobe.

*/

// ================================================================================
// PHOTO DISPLAY
// ================================================================================
Bee.Display.Photo.Main = function(title, src,  mask ){
	Bee.Display.Window.prototype.constructor.call(this, title, src,  mask);
	 
	var _this = this;
	 
	Bee.Core.Dispatcher.addEventListener(Bee.Events.FR_LOGOUT, function( args ){
	 	_this.onLogout( args );
	 });
	Bee.Core.Dispatcher.addEventListener(Bee.Events.FR_SERVICE_INIT, function( args ){
		_this.onServiceInit( args );
	});
	Bee.Core.Dispatcher.addEventListener(Bee.Events.FR_LOAD_PHOTOSETS, function( args ){
	 	_this.onLoadPhotosets( args );
	}); 
	Bee.Core.Dispatcher.addEventListener(Bee.Events.FR_LOAD_PHOTOS, function( args ){
		_this.onLoadPhotos( args );
	});
	Bee.Core.Dispatcher.addEventListener(Bee.Events.FR_LOAD_INFO, function( args ){
		_this.onLoadPhotoInfo( args );
	});
	Bee.Core.Dispatcher.addEventListener(Bee.Events.FR_LOAD_SIZES, function( args ){
		_this.onLoadPhotoSizes( args );
	});
	Bee.Core.Dispatcher.addEventListener(Bee.Events.FR_SEARCH, function( args){
		_this.onSearch( args);
	});
	Bee.Core.Dispatcher.addEventListener(Bee.Events.FR_REFRESH_PHOTOS, function( args){
		_this.onRefresh( args);
	});
	Bee.Core.Dispatcher.addEventListener(Bee.Events.FR_DELETE_DONE, function( args){
		_this.onDeleteDone( args);
	});
	Bee.Core.Dispatcher.addEventListener(Bee.Events.FR_LOGIN_FAILED, function( args){
		_this.onLoginFailed( args);
	});
	Bee.Core.Dispatcher.addEventListener(Bee.Events.FR_INVALID_API_KEY, function( args){
		_this.onInvalidApiKey( args);
	});
	Bee.Core.Dispatcher.addEventListener(Bee.Events.FR_SERVICE_UNAVAILABLE, function( args){
		_this.onServiceUnavailableForLogin( args);
	});
}

Bee.Display.Photo.Main.prototype = new Bee.Display.Window();

// view - browse for account, search for search results
Bee.Display.Photo.Main.prototype.VIEW_SEARCH = 0;
Bee.Display.Photo.Main.prototype.VIEW_BROWSE = 1;

Bee.Display.Photo.Main.prototype.lastUser = null;
// current view
Bee.Display.Photo.Main.prototype.currentView = this.VIEW_BROWSE;

// current photoset
Bee.Display.Photo.Main.prototype.currentPhotoset = {
	id : null,
	pages : -1,
	total : null,
	currentPage : null,
};

// current search results
Bee.Display.Photo.Main.prototype.currentSearch = {
	myTotal : null,
	myPages : null,
	myFullPages : null,
	publicTotal : null,
	totalPages : null,
};

// photos per page
Bee.Display.Photo.Main.prototype.photosPerPage = 30;

// id of the current photo
Bee.Display.Photo.Main.prototype.currentPhotoId = null;
Bee.Display.Photo.Main.prototype.currentPhotoInfoShown = false;
Bee.Display.Photo.Main.prototype.currentPhotoImgShown = false;

// used for encoding links in title or description of photos in preview
// so as not to follow them when clicking on them
Bee.Display.Photo.Main.prototype.encodeHrefs = function(str){
	if(!str)return "";
	var re = /<((.|[^<])*?)href((.|[^>])*?)>/gi;
	return str.replace(re,"<$1href=\"void(0)\" xref$3>");
}

Bee.Display.Photo.Main.prototype.decodeHrefs = function(str){
	if(!str)return "";
	var re = /<((.|[^<])*?)href=\"void\(0\)\" xref((.|[^>])*?)>/gi;
	return str.replace(re, "<$1href$3>");    
}

//------------------------------------ handlers -------------------------------
// init page when flickr service is initialized
Bee.Display.Photo.Main.prototype.onServiceInit = function(){
	
	this.cleanPage();
	this.refreshSwitch();
	this.currentView = this.VIEW_BROWSE;
	
	if (Bee.Services.Photo.Flickr.currentUser){
		Bee.Window.$('fp_noAccount').style.display = "none";
		Bee.Window.$('fp_account').style.display = "";
		
		Bee.Window.$('fp_searchPhotos').style.display = "none";
		Bee.Window.$('fp_accountPhotos').style.display = "";
		Bee.Window.$('fp_photosetsTitle').style.display = "";
		Bee.Window.$('fp_photosets').style.display = "";
		
		Bee.Services.Photo.Flickr.loadAccount();
	}
	else{
		Bee.Window.$('fp_noAccount').style.display = "";
		Bee.Window.$('fp_serviceUnavailable').style.display = "none";
		Bee.Window.$('fp_invalidApiKey').style.display = "none";
		this.hideAccountSpecificObjects();
	}
}

Bee.Display.Photo.Main.prototype.onLoginFailed = function ( obj ){
	
	//failed to login user... remove from accounts - user has revoked authorization for bee
	Bee.Storage.Db.remove("accounts_acc", "title_acc", this.lastUser);
	
	var acc = this.getLastFlickrAccount();
	if (acc == null){
		this.lastUser = null;
		Bee.Services.Photo.Flickr.initService(null, Bee.Services.Photo.Flickr.NO_USER);
	}
	else{
		var token = getSecureStore('flickrToken_' + acc.title);
		this.lastUser = acc.title;
		Bee.Services.Photo.Flickr.initUser(token, Bee.Services.Photo.Flickr.EXISTING_USER);
	}
}

Bee.Display.Photo.Main.prototype.onInvalidApiKey = function (){
	this.hideAccountSpecificObjects();
	Bee.Window.$('fp_noAccount').style.display = "none";
	Bee.Window.$('fp_serviceUnavailable').style.display = "none";
	Bee.Window.$('fp_invalidApiKey').style.display = "block";
}

Bee.Display.Photo.Main.prototype.onServiceUnavailableForLogin = function (){
	this.hideAccountSpecificObjects();
	Bee.Window.$('fp_noAccount').style.display = "none";
	Bee.Window.$('fp_invalidApiKey').style.display = "none";
	Bee.Window.$('fp_serviceUnavailable').style.display = "block";
}

// send refresh commands to service
Bee.Display.Photo.Main.prototype.onRefresh = function (){
	var _this = Bee.Application.navigWindows['photo'];
	
	if ( _this.currentPhotoset.id )
		Bee.Services.Photo.Flickr.loadPhotos(_this.currentPhotoset.id);
	else{
		_this.currentPhotoset.id = "0";
		_this.currentPhotoset.pages = -1;
		Bee.Services.Photo.Flickr.loadPhotos(_this.currentPhotoset.id);
	}
}

// sets datasets for photosets
Bee.Display.Photo.Main.prototype.onLoadPhotosets = function ( obj ) {
	
	if ( !obj || !obj.args || !obj.args.success){
		Bee.Window.$('fp_photosetsTitle').innerHTML = lang.FR_PHOTOSETS_LOADING_FAILED;
		return false;
	}
	Bee.Window.$('fp_photosetsTitle').innerHTML = lang.BEE_PHOTOSETS;
	Bee.Window.pgFlickrPhotosets.setDataFromArray( obj.args.photosets );
	if (Bee.Window.pgFlickrPhotosets.getPageCount() <= 1){
		Bee.Window.$('fp_photosetsPages').hide();
	}
	else{
		Bee.Window.$('fp_photosetsPages').show();
	}
}

// shows photos and page numbers on account page
Bee.Display.Photo.Main.prototype.onLoadPhotos = function ( obj ){
	
	this.cleanPreview();
	
	if ( !obj || !obj.args || !obj.args.success){
		this.currentPhotoset.id = null;
		Bee.Window.$('fp_accountPhotosTitle').innerHTML = lang.FR_PHOTO_LOADING_FAILED;
		return false;
	}
	Bee.Window.$('fp_accountPhotosTitle').innerHTML = lang.BEE_PHOTOS;
	if (this.currentView == this.VIEW_SEARCH){
		this.currentView = this.VIEW_BROWSE;
		Bee.Window.$('fp_searchPhotos').style.display = "none";
		Bee.Window.$('fp_searchPages').hide();
		Bee.Window.$('fp_accountPageNumbers').show();
		Bee.Window.$('fp_accountPhotos').style.display = "";
	}
	
	if (this.currentPhotoset.pages < 0){
		this.currentPhotoset.pages = obj.args.pages;
	}
	this.currentPhotoset.total = obj.args.total;
	this.currentPhotoset.currentPage = obj.args.currentPage;
	this.displayAccountPageNumbers( obj.args.id, obj.args.currentPage );
	
	Bee.Window.dsFlickrPhotos.setDataFromArray( obj.args.photos );
	
	if (Bee.Window.hourglassOn){
		Bee.Application.hideHourglass();
	}
}

// shows search results and search results pages
Bee.Display.Photo.Main.prototype.onSearch = function ( obj ){
	
	this.cleanPreview();
	
	if (this.currentView == this.VIEW_BROWSE){
		this.currentView = this.VIEW_SEARCH;
		
		if ( !Bee.Services.Photo.Flickr.currentUser ){
			Bee.Window.$('fp_noAccount').style.display = "none";
			Bee.Window.$('fp_account').style.display = "";
		}
		
		Bee.Window.$('fp_searchPhotos').style.display = "";
		Bee.Window.$('fp_accountPhotos').style.display = "none";
		Bee.Window.$('fp_searchPages').show();
		Bee.Window.$('fp_accountPageNumbers').hide();
	}
	
	if ( !obj || !obj.args){
		return this.searchEmpty( "Search operation failed.");
	}
	
	if ( !obj.args.photos.length){
		return this.searchEmpty( "There are no search results.");
	}
	
	this.currentSearch.myTotal = obj.args.myTotal;
	this.currentSearch.myFullPages = parseInt(obj.args.myTotal / this.photosPerPage);
	this.currentSearch.myPages = obj.args.myPages;
	this.currentSearch.publicTotal = obj.args.publicTotal;
	this.currentSearch.totalPages = parseInt( ( obj.args.myTotal + obj.args.publicTotal) / this.photosPerPage) + 
		(( obj.args.myTotal + obj.args.publicTotal) % this.photosPerPage > 0);
	
	Bee.Window.dsFlickrSearchPhotos.setDataFromArray( obj.args.photos );
	
	if (this.currentSearch.totalPages > 0){
		this.displaySearchPages( obj.args.currentPage);
		Bee.Window.$('fp_searchPages').show();
	}
	else{
		Bee.Window.$('fp_searchPages').hide();
	}
	
	if (Bee.Window.hourglassOn){
		Bee.Application.hideHourglass();
	}
}

Bee.Display.Photo.Main.prototype.onDeleteDone = function(){
	//if current photoset only has one photo, it was deleted, reload photosets and go to all photos
	if (Bee.Application.navigWindows['photo'].currentPhotoset.total <= 1){
		Bee.Application.navigWindows['photo'].currentPhotoset.id = null;
		Bee.Services.Photo.Flickr.loadAccount();
	}
	else{
		Bee.Application.navigWindows['photo'].onRefresh();
	}
}

Bee.Display.Photo.Main.prototype.searchEmpty = function( message ){
	Bee.Window.$('fp_searchPhotosTitle').innerHTML = message;
	Bee.Window.dsFlickrSearchPhotos.setDataFromArray( [] );
	Bee.Window.$('fp_searchPages').hide();
	if (Bee.Window.hourglassOn){
		Bee.Application.hideHourglass();
	}
	return false;
}

// loads selected account
Bee.Display.Photo.Main.prototype.onSelectSwitch = function(){
	
	var select = Bee.Window.$('fp_photoAccountSelector');
	if ( !select )
		return;
	
	var acc = Bee.Storage.Db.Accounts.getAccountByTitle(select.options[select.selectedIndex].value);
	
	if ( !acc )
		return;
	
	var token = getSecureStore('flickrToken_' + acc.title);
	
	Bee.Application.showHourglass();
	this.lastUser = acc.title;
	Bee.Services.Photo.Flickr.initUser(token,  Bee.Services.Photo.Flickr.EXISTING_USER);
}

// called when removing accounts from settings
Bee.Display.Photo.Main.prototype.onLogout = function ( obj ){
	
	if (obj && obj.args ){
		
		if ( Bee.Services.Photo.Flickr.currentUser  && 
				Bee.Services.Photo.Flickr.currentUser.username == obj.args){
			//logout user is current user => clean up, reinit flickr service
			this.cleanPage();
			
			var acc = this.getLastFlickrAccount();
		 	if (acc == null){
		 		this.lastUser = null;
		 		Bee.Services.Photo.Flickr.initService(null, Bee.Services.Photo.Flickr.NO_USER);
		 	}
		 	else{
		 		var token = getSecureStore('flickrToken_' + acc.title);
		 		this.lastUser = acc.title;
		 		Bee.Services.Photo.Flickr.initUser(token,  Bee.Services.Photo.Flickr.EXISTING_USER);
		 	}
		}
		else{
			// remove option from switch
			this.refreshSwitch();
		}
	}
}

//------------------------------------ page cleaning -------------------------------
//cleans preview area
Bee.Display.Photo.Main.prototype.cleanPreview = function(){
	
	Bee.Window.$('fp_previewActions').hide(); //style.display = "none";
	div = Bee.Window.$('fp_previewImage');
	while(div.hasChildNodes())
		div.removeChild(div.childNodes[0]);
	
	div = Bee.Window.$('fp_previewTitle');
	while(div.hasChildNodes())
		div.removeChild(div.childNodes[0]);
	
	div = Bee.Window.$('fp_previewDescription');
	while(div.hasChildNodes())
		div.removeChild(div.childNodes[0]);
}

//cleans whole page
Bee.Display.Photo.Main.prototype.cleanPage = function(){

	this.currentPhotoId = null;
	this.currentPhotoSize = null;
	this.currentPhotosetId = "0";
	
	Bee.Window.dsFlickrPhotosets.setDataFromArray([]);
	Bee.Window.dsFlickrPhotos.setDataFromArray([]);
	Bee.Window.dsFlickrSearchPhotos.setDataFromArray([]);
	
	this.cleanPreview();
}

Bee.Display.Photo.Main.prototype.hideAccountSpecificObjects = function(){
	
	Bee.Window.$('fp_account').style.display = "none";
	Bee.Window.$('fp_photosetsTitle').style.display = "none";
	Bee.Window.$('fp_photosetsPages').hide();
	Bee.Window.$('fp_photosets').style.display = "none";
}

//------------------------------------ page number functions -------------------------------
//creates a page number as an anchor element 
Bee.Display.Photo.Main.prototype.createPageElement = function( idPrefix, page, currentPage ){
	var el = Bee.Window.document.createElement("a");
	el.setAttribute("id", idPrefix + page);
	el.setAttribute("href", "#");
	if (page == currentPage){
		el.setAttribute("class", "currentPageNumber");
	}
	else{
		el.setAttribute("class", "pageNumber");
	}
	el.innerHTML = page;
	return el;
}

//display page numbers for account photos
Bee.Display.Photo.Main.prototype.displayAccountPageNumbers = function( id, currentPage ){
	
	var div = Bee.Window.$('fp_accountPageNumbers');
	while(div.hasChildNodes())
		div.removeChild(div.childNodes[0]);
	
	/*
	var span = Bee.Window.document.createElement("span");
	span.setAttribute("class", "pageNumber");
	span.innerHtml = "Photos in pages: ";
	div.appendChild(span);
	*/
	
	//display previous marks ( < )
	var el = Bee.Window.document.createElement("a");
	el.setAttribute("id", "fp_accountPageNumberPrev");
	el.setAttribute("href", "#");
	if (currentPage > 1){
		el.setAttribute("class", "pageNumber");
		el.onclick = function(e){
			Bee.Application.navigWindows['photo'].sendCommand("loadPhotoset", {id: id, pageNo: currentPage - 1});
		};
	}
	else{
		el.setAttribute("class", "disabledPageNumber");
	}
	el.innerHTML = "&lt;";
	div.appendChild(el);	
	
	//display 7 page numbers before current page
	for (var i = (currentPage > 8)?(currentPage - 8) : 1; i < currentPage; i++){
		
		var el = Bee.Application.navigWindows['photo'].createPageElement( 
			"fp_accountPageNumber", i, currentPage);
		el.onclick = function(e){
			var pageNo = this.id.substr( "fp_accountPageNumber".length );
			Bee.Application.navigWindows['photo'].sendCommand("loadPhotoset", {id: id, pageNo: pageNo});
		};
		div.appendChild(el);
	}
	
	//display current page and 7 page numbers after current page
	for (var i = currentPage; (i <= this.currentPhotoset.pages)&&(i < currentPage + 8); i++){
		
		var el = Bee.Application.navigWindows['photo'].createPageElement( 
			"fp_accountPageNumber", i, currentPage);
		el.onclick = function(e){
			var pageNo = this.id.substr( "fp_accountPageNumber".length );
			Bee.Application.navigWindows['photo'].sendCommand("loadPhotoset", {id: id, pageNo: pageNo});
		};
		div.appendChild(el);
	}
	
	//display next marks ( > )
	el = Bee.Window.document.createElement("a");
	el.setAttribute("id", "fp_accountPageNumberNext");
	el.setAttribute("href", "#");
	if (currentPage < this.currentPhotoset.pages){
		el.setAttribute("class", "pageNumber");
		el.onclick = function(e){
			Bee.Application.navigWindows['photo'].sendCommand("loadPhotoset", {id: id, pageNo: currentPage + 1});
		};
	}
	else{
		el.setAttribute("class", "disabledPageNumber");
	}
	el.innerHTML = "&gt;";
	div.appendChild(el);
}

// display page numbers for search photos
Bee.Display.Photo.Main.prototype.displaySearchPages = function( currentPage){
	
	var div = Bee.Window.$('fp_searchPages');
	while(div.hasChildNodes())
		div.removeChild(div.childNodes[0]);
	
	var total = this.currentSearch.totalPages + this.currentSearch.myFullPages;
	
	//display previous marks ( < )
	var el = Bee.Window.document.createElement("a");
	el.setAttribute("id", "fp_searchPageNumberPrev");
	el.setAttribute("href", "#");
	if (currentPage > 1){
		el.setAttribute("class", "pageNumber");
		el.onclick = function(e){
			Bee.Application.navigWindows['photo'].sendCommand("search", { pageNo: currentPage-1});
		};
	}
	else{
		el.setAttribute("class", "disabledPageNumber");
	}
	el.innerHTML = "&lt;";
	div.appendChild(el);
	
	for (var i = (currentPage > 8)?(currentPage - 8) : 1; i < currentPage; i++){
		var el = Bee.Application.navigWindows['photo'].createPageElement( "fp_searchPageNumber", i, currentPage);
		el.onclick = function(e){
			var pageNo = this.id.substr( "fp_searchPageNumber".length );
			Bee.Application.navigWindows['photo'].sendCommand("search", { pageNo: pageNo});
		};
		div.appendChild(el);
	}
	for (var i = currentPage; (i <= total)&&(i < currentPage + 8); i++){
		var el = Bee.Application.navigWindows['photo'].createPageElement( "fp_searchPageNumber", i, currentPage);
		el.onclick = function(e){
			var pageNo = this.id.substr( "fp_searchPageNumber".length );
			Bee.Application.navigWindows['photo'].sendCommand("search", { pageNo: pageNo});
		};
		div.appendChild(el);
	}
	
	//display next marks ( > )
	var el = Bee.Window.document.createElement("a");
	el.setAttribute("id", "fp_searchPageNumberPrev");
	el.setAttribute("href", "#");
	if (currentPage < total){
		el.setAttribute("class", "pageNumber");
		el.onclick = function(e){
			Bee.Application.navigWindows['photo'].sendCommand("search", { pageNo: currentPage+1});
		};
	}
	else{
		el.setAttribute("class", "disabledPageNumber");
	}
	el.innerHTML = "&gt;";
	div.appendChild(el);
}

//-------------------------------- Display commands and functions --------------------------------

Bee.Display.Photo.Main.prototype.onLoadPhotoInfo = function( obj){

	if ( !obj || !obj.args || !obj.args.success){
		Bee.Application.navigWindows['photo'].currentPhotoId = null;
		return false;
	}
	
	if (!Bee.Services.Photo.Flickr.currentPhoto.photo
		|| Bee.Application.navigWindows['photo'].currentPhotoId != Bee.Services.Photo.Flickr.currentPhoto.photo.id
		|| Bee.Application.navigWindows['photo'].currentPhotoInfoShown){
		return false;
	}
	
	Bee.Application.navigWindows['photo'].currentPhotoInfoShown = true;
	
	var _this = Bee.Application.navigWindows['photo'];
	var photo = Bee.Services.Photo.Flickr.currentPhoto.photo;
	
	var divTitle = Bee.Window.$("fp_previewTitle");
	var divDescription = Bee.Window.$("fp_previewDescription");
	
	var pElement = Bee.Window.document.createElement("p");
	
	var str = _this.encodeHrefs(photo.title);
	if (str.length > 40){
		pElement.innerHTML = str.substr(0, 40) + "...";
	}
	else{
		pElement.innerHTML = str;
	}
	divTitle.appendChild(pElement);
	
	pElement = Bee.Window.document.createElement("p");
	
	str = _this.encodeHrefs( photo.description);
	if (str.length > 80){
		pElement.innerHTML = str.substr(0, 80) + "...";
	}
	else{
		pElement.innerHTML = str;
	}
	divDescription.appendChild(pElement);
	
	if (!Bee.Services.Photo.Flickr.currentUser || 
			Bee.Services.Photo.Flickr.currentUser.nsid != photo.ownerId){
		Bee.Window.$('fp_deletePicture').hide();
	}
	else{
		Bee.Window.$('fp_deletePicture').show();
	}
	Bee.Window.$('fp_previewActions').show();
}

Bee.Display.Photo.Main.prototype.onLoadPhotoSizes = function( obj){
	
	if ( !obj || !obj.args || !obj.args.success){
		Bee.Application.navigWindows['photo'].currentPhotoId = null;
		return false;
	}
	
	if (!Bee.Services.Photo.Flickr.currentPhoto.photo
		|| Bee.Application.navigWindows['photo'].currentPhotoId != Bee.Services.Photo.Flickr.currentPhoto.photo.id
		|| Bee.Application.navigWindows['photo'].currentPhotoImgShown){
		return false;
	}
	
	Bee.Application.navigWindows['photo'].currentPhotoImgShown = true;
	
	var _this = Bee.Application.navigWindows['photo'];
	var photo = Bee.Services.Photo.Flickr.currentPhoto.photo;
	var size = Bee.Services.Photo.Flickr.currentPhoto.size;
	
	var divImg = Bee.Window.$("fp_previewImage");
	
	var imgElement = Bee.Window.document.createElement("img");
	imgElement.setAttribute("photoId", photo.id);
	imgElement.setAttribute("alt", photo.title);
	imgElement.setAttribute("src", size.source);
	imgElement.setAttribute("width", size.width);
	imgElement.setAttribute("height", size.height);
	
	divImg.appendChild(imgElement);
}

//shows preview for current photo
Bee.Display.Photo.Main.prototype.showPreview = function( obj ){
	
	if ( !obj || !obj.success){
		Bee.Application.navigWindows['photo'].currentPhotoId = null;
		return false;
	}
	
	if (Bee.Application.navigWindows['photo'].currentPhotoId 
			!= Bee.Services.Photo.Flickr.currentPhoto.photo.id){
		return false;
	}
	
	var _this = Bee.Application.navigWindows['photo'];
	var photo = Bee.Services.Photo.Flickr.currentPhoto.photo;
	var size = Bee.Services.Photo.Flickr.currentPhoto.size;
	
	var divImg = Bee.Window.$("fp_previewImage");
	var divTitle = Bee.Window.$("fp_previewTitle");
	var divDescription = Bee.Window.$("fp_previewDescription");
		
	var imgElement = Bee.Window.document.createElement("img");
	imgElement.setAttribute("photoId", photo.id);
	imgElement.setAttribute("alt", photo.title);
	imgElement.setAttribute("src", size.source);
	imgElement.setAttribute("width", size.width);
	imgElement.setAttribute("height", size.height);
	
	divImg.appendChild(imgElement);
	
	var pElement = Bee.Window.document.createElement("p");
	
	var str = _this.encodeHrefs(photo.title);
	if (str.length > 40){
		pElement.innerHTML = str.substr(0, 40) + "...";
	}
	else{
		pElement.innerHTML = str;
	}
	divTitle.appendChild(pElement);
	
	pElement = Bee.Window.document.createElement("p");
	
	str = _this.encodeHrefs( photo.description);
	if (str.length > 80){
		pElement.innerHTML = str.substr(0, 80) + "...";
	}
	else{
		pElement.innerHTML = str;
	}
	divDescription.appendChild(pElement);
	
	if (!Bee.Services.Photo.Flickr.currentUser || 
			Bee.Services.Photo.Flickr.currentUser.nsid != photo.ownerId){
		Bee.Window.$('fp_deletePicture').hide();
	}
	else{
		Bee.Window.$('fp_deletePicture').show();
	}
	Bee.Window.$('fp_previewActions').show();
}

// gets last used flickr account, if any, or last flickr account in database
Bee.Display.Photo.Main.prototype.getLastFlickrAccount = function (){
	
	var accounts = Bee.Storage.Db.Accounts.getAccountsByService( Bee.Constants.FR_SERVICE );
	
	if (accounts == null || accounts.length == 0)
		return null;
	
	if (config['lastFlickrUser']){	
		var username = config['lastFlickrUser'];	
		for(var i = 0; i < accounts.length; i++){
			if (accounts[i].title == username)
				return accounts[i];
		} 
	}
	return accounts[accounts.length-1];
}

// fires an "insert picture" event (picture wil be inserted in a post) 
Bee.Display.Photo.Main.prototype.insertPicture = function( obj ){
	
	if ( !obj || !obj.success ){
		if (Bee.Window.hourglassOn){
			Bee.Application.hideHourglass();
		}
		Bee.Core.Dispatcher.dispatch(Bee.Events.INSERT_PICTURE, null, null);
		return false;
	}
	var embed = Bee.Services.Photo.Flickr.buildPhotoElement();
	
	if (Bee.Window.hourglassOn){
		Bee.Application.hideHourglass();
	}
	Bee.Core.Dispatcher.dispatch(Bee.Events.INSERT_PICTURE, null, embed);
}

// refreshes switch, to show currently loaded account, or not to show switch at all, if no accounts
Bee.Display.Photo.Main.prototype.refreshSwitch = function(){
	
	var select = Bee.Window.$('fp_photoAccountSelector');
	
	while( select && select.hasChildNodes() )
		select.removeChild(select.childNodes[0]);
	select.selectedIndex = -1;
	
	if ( !Bee.Services.Photo.Flickr.currentUser ){
		Bee.Window.$('fp_selector').style.display = "none";
		return;
	}
	
	var flickrAccounts = Bee.Storage.Db.Accounts.getAccountsByService( Bee.Constants.FR_SERVICE );
	
	if ( flickrAccounts && flickrAccounts.length > 0 ){
		
		var sel;
		for (var i = 0; i < flickrAccounts.length; i++){
			var opt = Bee.Window.document.createElement("option");
			opt.innerHTML = flickrAccounts[i].title;
			opt.value = flickrAccounts[i].title;
			opt.selected = false;
			
			if (flickrAccounts[i].title == Bee.Services.Photo.Flickr.currentUser.username){
				opt.selected = true;
				sel = i;
			}
			select.options.add(opt);
		}
		select.selectedIndex = sel;
		
		Bee.Window.$('fp_selector').style.display = "block";
	}
	else{
		Bee.Window.$('fp_selector').style.display = "none";
	}
}

// callback for the confirm function for deleting a function 
Bee.Display.Photo.Main.prototype.deletePhoto = function ( pressed ){
	if (pressed == "ok"){
		Bee.Application.showHourglass();
		Bee.Services.Photo.Flickr.deletePhoto( Bee.Application.navigWindows['photo'].currentPhotoId );
	}
}


Bee.Display.Photo.Main.prototype.sendCommand = function (command, obj){
		 	switch(command){
		 		
		 		case 'doInit':
			 		Bee.Services.Photo.Flickr.init();
		 			
		 			var acc = this.getLastFlickrAccount();
		 			if (acc == null){
		 				this.lastUser = null;
		 				Bee.Services.Photo.Flickr.initService(null,  Bee.Services.Photo.Flickr.NO_USER);
		 			}
		 			else{
		 				var token = getSecureStore('flickrToken_' + acc.title);
		 				this.lastUser = acc.title;
		 				Bee.Services.Photo.Flickr.initUser(token,  Bee.Services.Photo.Flickr.EXISTING_USER);
		 			}
		 			break;
		 			
		 		case 'switch':
		 			this.onSelectSwitch();
		 			break;
		 		
		 		case 'loadPhotoPreview':
		 			if (obj){
		 				if ( this.currentPhotoId  && this.currentPhotoId == obj.id){
		 					return;
		 				}
		 				this.currentPhotoInfoShown = false;
						this.currentPhotoImgShown = false;
		 				this.cleanPreview();
		 				this.currentPhotoId = obj.id;
		 				Bee.Services.Photo.Flickr.loadPhotoInformation(obj.id, "Small", null);
		 			}
		 			break;
		 		
		 		case 'loadPhotoset':
		 			if (obj && obj.id){
		 				var _this = Bee.Application.navigWindows['photo'];
		 				if (_this.currentView == _this.VIEW_BROWSE){
		 					if (_this.currentPhotoset.id 
		 						&& _this.currentPhotoset.id == obj.id 
		 						&& _this.currentPhotoset.currentPage == obj.pageNo){
		 						return false;
		 					}
		 				}
		 				Bee.Application.showHourglass();
		 				_this.currentPhotoset.id = obj.id;
		 				_this.currentPhotoset.pages = -1;
		 				Bee.Services.Photo.Flickr.loadPhotos(obj.id, obj.pageNo);
		 			}
		 			break;
		 		
		 		case 'search':
		 			if (obj && obj.pageNo){
		 				if (obj.pageNo <= this.currentSearch.myPages){
		 					Bee.Application.showHourglass();
		 					Bee.Services.Photo.Flickr.searchMine(obj.pageNo);
		 				}
		 				else{
		 					Bee.Application.showHourglass();
		 					Bee.Services.Photo.Flickr.searchPublic(obj.pageNo - this.currentSearch.myPages);
		 				}
		 			}
		 			else{
		 				Bee.Application.showHourglass();
		 				Bee.Services.Photo.Flickr.search(obj);
		 			}
		 			break;
		 		case 'searchFirstPublicPage':
		 			Bee.Application.navigWindows['photo'].sendCommand("search", { pageNo: this.currentSearch.myFullPages + 1});
		 			break;
		 		
		 		case 'insertPicture':
		 			//send embed html for current photo
		 			var id;
		 			if ( obj && obj.id ){
		 				id = obj.id;
		 			}
		 			else{
		 				id = this.currentPhotoId;
		 			}
		 			Bee.Application.showHourglass();
		 			Bee.Services.Photo.Flickr.loadPhotoInformation(id, "Small", this.insertPicture );
		 			break;
		 		
		 		case 'deletePicture':
		 			doConfirm("", lang.FR_DELETE_CONFIRM, 4|8, this.deletePhoto );
		 			break;
		 	}
	}