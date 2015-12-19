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
// FLICKR SERVICE OBJECT
// ================================================================================
var FlickrApi = runtime.com.adobe.webapis.flickr;

function flickr() {} 

flickr.prototype = 
{
	flickrApi : runtime.com.adobe.webapis.flickr,
	
	// service objects
	service : null,
	tmpService : null,
	tmpFrob : null,
	
	// shows if service is logged in (uses a token for signing calls)
	loggedIn: false,
	
	// current logged in user
	currentUser : null,
	NO_USER: 0,
	EXISTING_USER: 1,
	NEW_USER: 2,
	
	// nr of photos displayed
	photosPerPage : 30,
	
	// information about current search
	currentSearch : {
		args : null,
		photos : null,
		offset : null,
		myPages : null,
		myTotal : null,
		publicTotal : null,
	},
	
	//information about current photo
	currentPhoto : {
		photo : null,
		requestedSize : null,
		size : null,
		callback : null,
	},

	// callback after uploading a file
	fileUploadCallback : null,
	// whether a url is requested for the uploaded file or not
	// if uploaded from photo page, none will be required
	fileUploadRequestingUrl : null,
	
	getApiKey : function(){
		return "f73af4f08be90abce7c6815875e119a8";
	},
	
	getSecret : function(){
		return "0dfdc8e32ca1ad44";
	},
	
	//--------------------------------  SERVICE AND USER INITIALIZATION --------------------------------
	// only inits logged in information at first
	init : function() {	
		this.loggedIn = false;
	},
	
	// initializes the service for a user with a given token
	// a temporary service is used, in case the token is bad, previous state will be preserved
	initUser : function( token ) {
		 
		this.tmpService = new FlickrApi.FlickrService(this.getApiKey());
		this.tmpService.secret = this.getSecret();
		this.tmpService.token = token;
		
		var _this = this;
		this.tmpService.addEventListener(air.IOErrorEvent.IO_ERROR , function(e){
			_this.onIOErrorEvent(e);
			Bee.Core.Dispatcher.dispatch(Bee.Events.FR_LOGIN_FAILED, null, null);
		});
		this.tmpService.addEventListener(FlickrApi.events.FlickrResultEvent.AUTH_CHECK_TOKEN, function(e){
			_this.initService(e, _this.EXISTING_USER);
		});
		
		try{
			this.tmpService.auth.checkToken( token );
		}
		catch( error ){
			//this.onErrorAlert( lang.FR_LOGIN_FAILED, error.errorId );
			//Bee.Core.Dispatcher.dispatch(Bee.Events.FR_LOGIN_FAILED, null, null);
		}
	},
	
	// initializes service object
	// if event is defined - then this is the result for token checking for a user
	// if event null then service will only make unauthenticated calls
	initService : function( event, userType ){
		
		if (event && !event.success){
			//tried to get token for a user, got error
			switch( event.data.error.errorCode ){
				case FlickrApi.FlickrError.INVALID_FROB:
					this.onErrorAlert( lang.FR_AUTHENTICATION_FAILED, event.data.error.errorCode, event.data.error.errorMessage );
				break;
				
				case FlickrApi.FlickrError.LOGIN_FAILED:
					if (userType == this.NEW_USER){
						this.onErrorAlert( lang.FR_AUTHENTICATION_FAILED, event.data.error.errorCode, event.data.error.errorMessage );
					}
					else{
						Bee.Core.Dispatcher.dispatch(Bee.Events.FR_LOGIN_FAILED, null, null);
					}
				break;
				
				case FlickrApi.FlickrError.INVALID_API_KEY:
					this.onErrorAlert( lang.FR_INVALID_API_KEY, event.data.error.errorCode, event.data.error.errorMessage );
					Bee.Core.Dispatcher.dispatch(Bee.Events.FR_INVALID_API_KEY, null, null);
				break;
				
				case FlickrApi.FlickrError.SERVICE_CURRENTLY_UNAVAILABLE:
					this.onErrorAlert( lang.FR_SERVICE_UNAVAILABLE, event.data.error.errorCode, event.data.error.errorMessage );
					Bee.Core.Dispatcher.dispatch(Bee.Events.FR_SERVICE_UNAVAILABLE, null, null);
				break;
			}
			return false;
		};
		
		this.service = new FlickrApi.FlickrService( this.getApiKey() );
		this.service.secret = this.getSecret();
		
		if ( userType == this.NO_USER ){
			this.loggedIn = false;
			this.currentUser = null;
		}
		else{
			var token = event.data["auth"].token;
			var user = event.data["auth"].user;
			var perms = event.data["auth"].perms;
			
			this.service.token = token;
			this.service.permission = perms;
			
			if ( userType == this.NEW_USER ){
				
				var found = false;
				var accounts = Bee.Storage.Db.Accounts.getAccountsByService(2);
				
				for (var i = 0; i < accounts.length; i++){
					if (accounts[i].title == user.username){
						var userAccount = {
							id: accounts[i].id, 
							idsrv : Bee.Constants.FR_SERVICE, 
							title: user.username};
						setSecureStore('flickrToken_' + user.username, token);
						found = true;
					}
				}
			
				if (!found){
					var userAccount = {
						idsrv : Bee.Constants.FR_SERVICE, 
						title: user.username};
					setSecureStore('flickrToken_' + user.username, token);
					Bee.Storage.Db.saveAccount(userAccount);
				}
				
				Bee.Core.Dispatcher.dispatch(Bee.Events.SETTINGS_REFRESH, null, null);
			}
			
			this.loggedIn = true;
			this.currentUser = user;
			config['lastFlickrUser'] = user.username;
		}

		var _this = this;
		
		this.service.addEventListener( air.IOErrorEvent.IO_ERROR, function(e){
			_this.onIOErrorEvent(e);
		});
		this.service.addEventListener( FlickrApi.events.FlickrResultEvent.PHOTOSETS_GET_LIST, function(e){
			_this.onLoadPhotosets(e);
		});
		this.service.addEventListener( FlickrApi.events.FlickrResultEvent.PHOTOSETS_GET_PHOTOS, function(e){
			_this.onLoadPhotos(e);
		} );
		this.service.addEventListener( FlickrApi.events.FlickrResultEvent.PHOTOS_GET_RECENTLY_UPLOADED, function(e){
			_this.onLoadPhotos(e);
		} );
		this.service.addEventListener( FlickrApi.events.FlickrResultEvent.PHOTOS_GET_INFO, function(e){
			_this.onLoadPhotoInfo(e);
		});
		this.service.addEventListener( FlickrApi.events.FlickrResultEvent.PHOTOS_GET_SIZES, function(e){
			_this.onLoadPhotoSizes(e);
		});
		this.service.addEventListener( FlickrApi.events.FlickrResultEvent.PHOTOS_SEARCH, function(e){
			_this.onSearchMine(e);
		});
		this.service.addEventListener( FlickrApi.events.FlickrResultEvent.PHOTOS_SEARCH_PUBLIC, function(e){
			_this.onSearchPublic(e);
		});
		this.service.addEventListener( FlickrApi.events.FlickrResultEvent.PHOTOS_DELETE, function(e){
			_this.onDeletePhoto(e);
		});
		
		Bee.Core.Dispatcher.dispatch(Bee.Events.FR_SERVICE_INIT, null, null);
	},
	
	// opens an authorization window, using a temporary service
	// used for authorizing a new user to this application
	openAuthorizeWindow : function(){
		
		this.tmpService = new FlickrApi.FlickrService(this.getApiKey());
		this.tmpService.secret = this.getSecret();
		
		var _this = this;
		
		this.tmpService.addEventListener( FlickrApi.events.FlickrResultEvent.AUTH_GET_FROB, function (e) { 
			 _this.onFrobResult(e)} );
		this.tmpService.addEventListener( FlickrApi.events.FlickrResultEvent.AUTH_GET_TOKEN, function(e){
			_this.initService(e, _this.NEW_USER)} );
			
		this.tmpService.addEventListener( air.IOErrorEvent.IO_ERROR, function(e){
			_this.onIOErrorEvent(e);
		});
		
		try{
			this.tmpService.auth.getFrob();
		}
		catch( error ){
			this.onErrorAlert( lang.FR_AUTHENTICATION_FAILED);
		}
	},
	
	// registers a user, by getting a token from flickr, which will be stored in secure store
	registerUser : function(){
		try{
			this.tmpService.auth.getToken( this.tmpFrob );
		}
		catch( error ){
			this.onErrorAlert( lang.FR_AUTHENTICATION_FAILED);
		}
	},
	
	//--------------------------------  ACCOUNT LOADING AND COMMANDS --------------------------------
	
	//loads account for user
	//photoset "0" represents all photos
	loadAccount : function(){
		
		this.loadPhotosets();
		this.loadPhotos( "0" );
	},
	
	/*
	refreshPhotos : function(){
		if (this.loggedIn != true){
			air.trace("Load account error - not logged in or during login.");
			return;
		}
		var id = this.currentPhotoset.id;
		
		this.currentPhotoset.id = null;
		this.currentPhotoset.loadedTotal = 0;
		this.currentPhotoset.total = -1;
		
		this.loadPhotos( id );
	},
	*/

	//loads photosets for the current user
	loadPhotosets : function(){
		
		if ( !this.currentUser)
		{
			this.onErrorAlert(lang.FR_NOTLOGGEDIN);
			return false;
		}
		try{
			this.service.photosets.getList( this.currentUser.nsid );
		}
		catch( error ){
			this.onErrorAlert( null );
		}
	},
	
	//loads a page of photos from a certain photoset
	loadPhotos : function( setId, pageNo ){
		if (!pageNo){
			pageNo = 1;
		}
		try{
			if (setId == "0"){
				try{
					this.service.photos.getRecentlyUploaded(this.currentUser.nsid, "last_update", this.photosPerPage, pageNo );
				}catch(error){
					this.onErrorAlert( null, error);
				}
			}
			else{
				try{
					this.service.photosets.getPhotos( setId, "last_update", this.photosPerPage, pageNo );
				}catch(error){
					this.onErrorAlert( null, error);
				}
			}
		}
		catch( error ){
			this.onErrorAlert(null, error);
		}
	},
	
	//loads information (info and sizes) for a certain photo
	loadPhotoInformation : function( id, requestedSize, callback ){
		
		if ( !id )
			return false;
			
		this.currentPhoto.photo = null;
		this.currentPhoto.requestedSize = requestedSize;
		this.currentPhoto.size = null;
		this.currentPhoto.callback = callback;
		
		try{
			this.service.photos.getInfo( id );
		}
		catch(error){
			this.onErrorAlert(null);
		}
	},
	
	//deletes a photo
	deletePhoto : function( id ){
		if (!id){
			if (Bee.Window.hourglassOn){
				Bee.Application.hideHourglass();
			}
			return false;
		}
		try{
			this.service.photos.deletePhoto( id );
		}
		catch(error){
			this.onErrorAlert(lang.FR_DELETE_FAIL);
		}
	},
	
	//searches flickr
	search :  function( args, pageNo ){
		
		this.currentSearch.args = args;
		this.currentSearch.photos = [];
		this.currentSearch.offset = 0;
		this.currentSearch.myPages = 0;
		this.currentSearch.myTotal = -1;
		this.currentSearch.publicTotal = -1;
		
		if ( this.loggedIn ){
			this.searchMine( pageNo);
		}
		else{
			this.currentSearch.myTotal = 0;
			this.searchPublic( pageNo);
		}
	},
	
	//gets search results from my results
	searchMine : function( pageNo ){
		if (!pageNo){
			pageNo = 1;
		}
		this.currentSearch.photos = [];
		try{
			this.service.photos.search(this.currentUser.nsid, "", "any", this.currentSearch.args, "", "", "", "",
				"", "", "last_update",
				this.photosPerPage, pageNo);
		}catch(error){
			this.onErrorAlert(lang.FR_IO_ERROR, error);
		}
	},
	
	//gets search results from public photos
	searchPublic : function( pageNo ){
		
		if (!pageNo){
			pageNo = 1;
		}
		else{
			this.currentSearch.photos = [];
			this.currentSearch.currentPage = null;
		}
		
		try{
			this.service.photos.search("", "", "any", this.currentSearch.args, "", "", "", "", 
				"2,3,4,6", "safe", "last_update", 
				this.photosPerPage, pageNo, 
				"interestingness-desc");
		}catch(error){
			this.onErrorAlert(lang.FR_IO_ERROR, error);
		}
	},
	
	//--------------------------------  UTILITIES --------------------------------
	
	//builds a url (75x75) for a photo
	buildSmallUrl : function( photo, isPhotoset ){
		var url = "http://farm" + photo.farm + ".static.flickr.com/" + photo.server + "/";
		if (isPhotoset){
			url += photo.primaryPhotoId;
		}
		else{
			url += photo.id;
		}
		url += "_" + photo.secret + "_s.jpg";
		return url;
	},
	
	//builds a photo element for inserting in a post
	//photo will be linked to the original page on flickr
	buildPhotoElement : function(){
	
		var photo = Bee.Services.Photo.Flickr.currentPhoto.photo;
		var size = Bee.Services.Photo.Flickr.currentPhoto.size;
		
		var photoUrl;
		for (i = 0; i < photo.urls.length; i++){
			if (photo.urls[i].type == "photopage"){
				photoUrl = photo.urls[i].url;
				break;
			}
		}
		
		if ( i == photo.urls.length){
			photoUrl = size.source;
		}
		
		var embed = "<a href='" + photoUrl + "' target='_blank'>";
		embed += "<img src='" + size.source + "' width=" + size.width + " height=" + size.height;
		embed += " alt='" + photo.title + "' border='0' ></a>";
		
		return embed;
	},
	
	//--------------------------------  PHOTO UPLOADING --------------------------------
	
	//calls upload callback for an uploaded file to send the photo element
	sendPhotoElement : function( obj ){
		
		if ( !obj || !obj.success ){
			Bee.Services.Photo.Flickr.fileUploadCallback(5);
			return false;
		}
		var embed = Bee.Services.Photo.Flickr.buildPhotoElement();
		if (embed){
			Bee.Services.Photo.Flickr.fileUploadCallback(4, embed);
		}
		else{
			Bee.Services.Photo.Flickr.fileUploadCallback(5);
		}
	},
	
	//parses an upload response to get the assigned photo id for the uploaded photo
	parseUploadResponse : function( response){
		var doc = new air.XMLDocument();
		doc.ignoreWhite = true;
		doc.parseXML( response );
		var rsp = doc.firstChild;
		if ( rsp.attributes.stat == "ok" ){
			var data = air.XML(rsp);
			return data.photoid;
		}
		return null;
	},
	
	//adds handlers for the file to be uploaded
	addFileUploadHandlers : function( file )
	{
		file.addEventListener(air.Event.COMPLETE, Bee.Services.Photo.Flickr.onFileUploadComplete);
		file.addEventListener(air.ProgressEvent.PROGRESS, Bee.Services.Photo.Flickr.onFileUploadProgress);
		file.addEventListener(air.DataEvent.UPLOAD_COMPLETE_DATA, Bee.Services.Photo.Flickr.onFileUploadCompleteData);
		file.addEventListener(air.IOErrorEvent.IO_ERROR, Bee.Services.Photo.Flickr.onFileUploadIOError);
	},
	
	//removes hanlders for the file that was uploaded
	removeFileUploadHandlers : function( file ){
		file.removeEventListener(air.Event.COMPLETE, Bee.Services.Photo.Flickr.onFileUploadComplete);
		file.removeEventListener(air.ProgressEvent.PROGRESS, Bee.Services.Photo.Flickr.onFileUploadProgress);
		file.removeEventListener(air.DataEvent.UPLOAD_COMPLETE_DATA, Bee.Services.Photo.Flickr.onFileUploadCompleteData);
		file.removeEventListener(air.IOErrorEvent.IO_ERROR, Bee.Services.Photo.Flickr.onFileUploadIOError);
	},
	
	//uploads a file to flickr
	uploadFile : function( file, requestSize, callback){
		
		this.fileUpload = file.file;
		this.fileUploadCallback = callback;
		this.fileUploadRequestingUrl = requestSize;
		
		var fileUploadRequest = this.service.photos.upload.buildUploadRequest(file.file, file.title, file.description, "",
			(config['uploadIsPublic'] != undefined && config['uploadIsPublic'] != null)?config['uploadIsPublic']:"1",
			(config['uploadIsFriend'] != undefined && config['uploadIsFriend'] != null)?config['uploadIsFriend']:"0",
			(config['uploadIsFamily'] != undefined && config['uploadIsFamily'] != null)?config['uploadIsFamily']:"0");
		this.addFileUploadHandlers( file.file );
		
		//this is the upload call
		file.file.upload(fileUploadRequest, "photo");
	},
	
	//handler for complete event
	onFileUploadComplete : function(event){
	},
	
	//handler for progress event
	onFileUploadProgress : function( event ){
		Bee.Services.Photo.Flickr.fileUploadCallback(2, {"bytesLoaded" : event.bytesLoaded, "bytesTotal" : event.bytesTotal});
	},
	
	//handler for upload complete data event 
	onFileUploadCompleteData : function( event ){
		
		Bee.Services.Photo.Flickr.removeFileUploadHandlers(Bee.Services.Photo.Flickr.fileUpload);
		
		if (Bee.Services.Photo.Flickr.fileUploadRequestingUrl){
			var id = Bee.Services.Photo.Flickr.parseUploadResponse(event["data"]);
			
			if ( !id ){
					if (Bee.Services.Photo.Flickr.fileUploadCallback)
					Bee.Services.Photo.Flickr.fileUploadCallback(1);
			}
			else{
				Bee.Services.Photo.Flickr.loadPhotoInformation(id, "Small", Bee.Services.Photo.Flickr.sendPhotoElement );
			}
		}
		else{
			if (Bee.Services.Photo.Flickr.fileUploadCallback)
				Bee.Services.Photo.Flickr.fileUploadCallback(3);
		}
	},
	
	//handler for io error event
	onFileUploadIOError :function( event){
		air.trace("IOError: " + event)
		Bee.Services.Photo.Flickr.removeFileUploadHandlers(Bee.Services.Photo.Flickr.fileUpload);
		if (Bee.Services.Photo.Flickr.fileUploadCallback)
			Bee.Services.Photo.Flickr.fileUploadCallback(1);
	},
	
	//--------------------------------  HANDLERS --------------------------------
	
	// gets the frob needed to start the authorization process and build the authorization url
	onFrobResult : function(event){
		
		if (event.success){
			
			this.tmpFrob = new String(event.data.frob);
			var authUrl = this.tmpService.getLoginURL( this.tmpFrob, FlickrApi.AuthPerm.DELETE );
			
			try{
				air.navigateToURL( new air.URLRequest( authUrl ), "_blank" );
			}catch( error ){
				this.onErrorAlert( lang.FR_AUTHENTICATION_FAILED );
			}
		}
		else{
			var error = event.data.error;
			switch(error.errorCode){
				case FlickrApi.FlickrError.INVALID_API_KEY:
					this.onErrorAlert( lang.FR_INVALID_API_KEY, event.data.error.errorCode, event.data.error.errorMessage );
					Bee.Core.Dispatcher.dispatch(Bee.Events.FR_INVALID_API_KEY, null, null);
				break;
				
				case FlickrApi.FlickrError.SERVICE_CURRENTLY_UNAVAILABLE:
					this.onErrorAlert( lang.FR_SERVICE_UNAVAILABLE, event.data.error.errorCode, event.data.error.errorMessage );
					Bee.Core.Dispatcher.dispatch(Bee.Events.FR_SERVICE_UNAVAILABLE, null, null);
				break;
				
				default:
					this.onErrorAlert( lang.FR_AUTHENTICATION_FAILED, error.errorCode, error.errorMessage);
				break;
			}
		}
	},
	
	//loads photosets, and builds javascript array for the spry dataset
	//data in event is an action script array, must be transformed
	onLoadPhotosets : function(event){
		
		if (event.success){
			
			var photosetList = event.data["photoSets"];
			
			//build js array for spry dataset
			var photosets = [];
			photosets.push( {id: "0", primarySmallUrl: null, title: "All photos"});
			
			for (var i = 0; i < photosetList.length; i++){
				var ps = photosetList[i];
				photosets.push({ 
					id: ps.id, 
					primarySmallUrl: this.buildSmallUrl(ps, true), 
					title: ps.title });
			}
		}
		else{
			var error = event.data.error;
			switch(error.errorCode){
				case FlickrApi.FlickrError.INVALID_API_KEY:
					this.onErrorAlert( lang.FR_INVALID_API_KEY, event.data.error.errorCode, event.data.error.errorMessage );
					Bee.Core.Dispatcher.dispatch(Bee.Events.FR_INVALID_API_KEY, null, null);
					return false;
				break;
				case FlickrApi.FlickrError.SERVICE_CURRENTLY_UNAVAILABLE:
					this.onErrorAlert( lang.FR_SERVICE_UNAVAILABLE, event.data.error.errorCode, event.data.error.errorMessage );
					return false;
				break;
				case FlickrApi.FlickrError.LOGIN_FAILED:
					this.onErrorAlert( lang.FR_LOGIN_FAILED, event.data.error.errorCode, event.data.error.errorMessage );
					return false;
				break;
				default:
					this.onErrorAlert( null, error.errorCode, error.errorMessage);		
			}
		}
		//fire event for display
		Bee.Core.Dispatcher.dispatch(Bee.Events.FR_LOAD_PHOTOSETS, null, {success : event.success, photosets: photosets});
	},
	
	//loads photos, builds the array for the spry dataset
	onLoadPhotos : function( event ){
		
		if (event.success){
			
			var photoList = ( event.data["photos"] ) ? event.data["photos"] : event.data["photoSet"];
			
			var id = (photoList.id)? photoList.id : "0";
			
			var photos = [];
			
			for (var i = 0; i < photoList.photos.length; i++){
				var ph = photoList.photos[i];
				photos.push({ 
					id: ph.id,
					smallUrl: this.buildSmallUrl(ph, false),
					title: ph.title });
			}
				
			//fire event for display
			Bee.Core.Dispatcher.dispatch(Bee.Events.FR_LOAD_PHOTOS, null, {
					success: event.success, 
					id: id,
					total: photoList.total,
					currentPage: photoList.page,
					pages: photoList.pages,
					photos: photos });
		}
		else{
			var error = event.data.error;
			
			switch(error.errorCode){
				case FlickrApi.FlickrError.INVALID_API_KEY:
					this.onErrorAlert( lang.FR_INVALID_API_KEY, event.data.error.errorCode, event.data.error.errorMessage );
					Bee.Core.Dispatcher.dispatch(Bee.Events.FR_INVALID_API_KEY, null, null);
					return false;
				break;
				case FlickrApi.FlickrError.SERVICE_CURRENTLY_UNAVAILABLE:
					this.onErrorAlert( lang.FR_SERVICE_UNAVAILABLE, event.data.error.errorCode, event.data.error.errorMessage );
					return false;
				break;
				case FlickrApi.FlickrError.LOGIN_FAILED:
					this.onErrorAlert( lang.FR_LOGIN_FAILED, event.data.error.errorCode, event.data.error.errorMessage );
					return false;
				break;
			}
			
			this.onErrorAlert( null, error.errorCode, error.errorMessage);
			
			//fire event for display
			Bee.Core.Dispatcher.dispatch(Bee.Events.FR_LOAD_PHOTOS, null, {success : event.success});
		}
	},
	
	//loads sizes for a photo
	onLoadPhotoSizes : function( event ){
		
		if (event.success){
			
			var pszList = event.data["photoSizes"];
			
			if ( !this.currentPhoto.photo || 
					pszList[0].url.indexOf(this.currentPhoto.photo.id) < 0){
				return false;
			}
			var i;
			for (i = 0; i < pszList.length; i++ ){
				if (pszList[i].label == this.currentPhoto.requestedSize ){
					break;
				}
			}
	
			//if no such size found, just take first
			if (i == pszList.length)
				i = 0;
			
			this.currentPhoto.size = pszList[i];
		}
		else{
			var error = event.data.error;
			switch(error.errorCode){
				case FlickrApi.FlickrError.INVALID_API_KEY:
					this.onErrorAlert( lang.FR_INVALID_API_KEY, event.data.error.errorCode, event.data.error.errorMessage );
					Bee.Core.Dispatcher.dispatch(Bee.Events.FR_INVALID_API_KEY, null, null);
					return false;
				break;
				case FlickrApi.FlickrError.SERVICE_CURRENTLY_UNAVAILABLE:
					this.onErrorAlert( lang.FR_SERVICE_UNAVAILABLE, event.data.error.errorCode, event.data.error.errorMessage );
					return false;
				break;
				case FlickrApi.FlickrError.LOGIN_FAILED:
					this.onErrorAlert( lang.FR_LOGIN_FAILED, event.data.error.errorCode, event.data.error.errorMessage );
					return false;
				break;
			}
			this.onErrorAlert( null, error.errorCode, error.errorMessage);
		}
		
		if (event && this.currentPhoto.callback)
			this.currentPhoto.callback( { "success" : event.success} );
		
		Bee.Core.Dispatcher.dispatch(Bee.Events.FR_LOAD_SIZES, null, { "success" : event.success});
	},
	
	//loads information for a photo
	onLoadPhotoInfo : function( event ){
		
		if (event.success){
			this.currentPhoto.photo = event.data["photo"];
			
			try{
				this.service.photos.getSizes( event.data["photo"].id );
			}catch( error ){
				this.onErrorAlert( null, error.errorCode, error.errorMessage);
			}
		}
		else{
			var error = event.data.error;
			switch(error.errorCode){
				case FlickrApi.FlickrError.INVALID_API_KEY:
					this.onErrorAlert( lang.FR_INVALID_API_KEY, event.data.error.errorCode, event.data.error.errorMessage );
					Bee.Core.Dispatcher.dispatch(Bee.Events.FR_INVALID_API_KEY, null, null);
					return false;
				break;
				case FlickrApi.FlickrError.SERVICE_CURRENTLY_UNAVAILABLE:
					this.onErrorAlert( lang.FR_SERVICE_UNAVAILABLE, event.data.error.errorCode, event.data.error.errorMessage );
					return false;
				break;
				case FlickrApi.FlickrError.LOGIN_FAILED:
					this.onErrorAlert( lang.FR_LOGIN_FAILED, event.data.error.errorCode, event.data.error.errorMessage );
					return false;
				break;
			}
			this.onErrorAlert( null, error.errorCode, error.errorMessage);
			
			if (this.currentPhoto.callback)
				this.currentPhoto.callback( { "success" : event.success} );
		}
		
		Bee.Core.Dispatcher.dispatch(Bee.Events.FR_LOAD_INFO, null, { "success" : event.success});
	},
	
	// loads search results from the users photos
	// first time, a second search call in public photos will be made, to get the number of pages
	// after that, a second call will be made only if not enough photos are returned to fill 
	// the current page (we have a combined page of user's and public photos) 
	// search calls ask for same nr of photos per call as there will be per our page
	onSearchMine : function( event ){
		
		if (event.success){
			var photoList = event.data["photos"];
			
			this.currentSearch.currentPage = photoList.page;
			this.currentSearch.myPages = photoList.pages;
			
			var className = "fp_s_photo_mine";
			for (var i = 0; i < photoList.photos.length; i++){
				var photo = photoList.photos[i];
				this.currentSearch.photos.push({ 
					"id": photo.id, 
					"smallUrl": this.buildSmallUrl(photo, false), 
					"title": photo.title,
					"divClass" : className });
			}
			
			this.currentSearch.offset = (this.photosPerPage - photoList.total % this.photosPerPage);
			if (this.currentSearch.offset == this.photosPerPage)
				this.currentSearch.offset = 0;
			if ( this.currentSearch.myTotal < 0 )
			{
				//first search call
				this.currentSearch.myTotal = photoList.total;
				this.searchPublic( );
			}
			else{
				this.currentSearch.myTotal = photoList.total;
				if ( photoList.photos.length < this.photosPerPage){
					this.searchPublic( );
				}
				else{
					Bee.Core.Dispatcher.dispatch(Bee.Events.FR_SEARCH, null, {
						success : event.success,
						photos : this.currentSearch.photos,
						currentPage : this.currentSearch.currentPage,
						myPages : this.currentSearch.myPages,
						myTotal : this.currentSearch.myTotal,
						publicTotal : this.currentSearch.publicTotal});
				}
			}
		}
		else{
			var error = event.data.error;
			switch(error.errorCode){
				case FlickrApi.FlickrError.INVALID_API_KEY:
					this.onErrorAlert( lang.FR_INVALID_API_KEY, event.data.error.errorCode, event.data.error.errorMessage );
					Bee.Core.Dispatcher.dispatch(Bee.Events.FR_INVALID_API_KEY, null, null);
					return false;
				break;
				case FlickrApi.FlickrError.SERVICE_CURRENTLY_UNAVAILABLE:
					this.onErrorAlert( lang.FR_SERVICE_UNAVAILABLE, event.data.error.errorCode, event.data.error.errorMessage );
					return false;
				break;
				case FlickrApi.FlickrError.LOGIN_FAILED:
					this.onErrorAlert( lang.FR_LOGIN_FAILED, event.data.error.errorCode, event.data.error.errorMessage );
					return false;
				break;
			}
			this.onErrorAlert( null, error.errorCode, error.errorMessage);
			Bee.Core.Dispatcher.dispatch(Bee.Events.FR_SEARCH, null, {success : event.success});
		}
	},
	
	// gets search results from public photos
	// a second call may be necessary to fill the page, given the initial offset of the first page
	// of public photos (tha page might contain results from my photos)
	// search calls ask for same nr of photos per call as there will be per our page
	onSearchPublic : function( event){
		if (event.success){
			var photoList = event.data["photos"];
			
			this.currentSearch.publicTotal = photoList.total;
			
			if ( this.currentSearch.photos.length < this.photosPerPage){
				
				var offset;
				if (this.currentSearch.photos.length > 0){
					offset = 0;
				}
				else{
					offset = this.currentSearch.offset;
					this.currentSearch.currentPage = photoList.page + this.currentSearch.myPages;
				}
				
				var className = "fp_s_photo_public";
				
				for (var i = offset; i < photoList.photos.length; i++){
					var ph = photoList.photos[i];
					
					this.currentSearch.photos.push({ 
						"id": ph.id, 
						"smallUrl": this.buildSmallUrl(ph, false), 
						"title": ph.title,
						"divClass" : className });
					if (this.currentSearch.photos.length == this.photosPerPage)
						break;
				}
			}
			
			if ((this.currentSearch.photos.length < this.photosPerPage) 
				&& (photoList.page < photoList.pages)){
				try{
					this.service.photos.search("", "", "any", this.currentSearch.args, "", "", "", "", 
						"2,3,4,6", "safe", "last_update", 
						this.photosPerPage, photoList.page + 1, 
						"interestingness-desc");
				}catch(error){
					this.onErrorAlert(null, error);
				}
			}
			else{
				Bee.Core.Dispatcher.dispatch(Bee.Events.FR_SEARCH, null, {
					success : event.success,
					photos : this.currentSearch.photos,
					currentPage : this.currentSearch.currentPage,
					myPages : this.currentSearch.myPages,
					myTotal : this.currentSearch.myTotal,
					publicTotal : this.currentSearch.publicTotal});
			}
		}
		else{
			var error = event.data.error;
			switch(error.errorCode){
				case FlickrApi.FlickrError.INVALID_API_KEY:
					this.onErrorAlert( lang.FR_INVALID_API_KEY, event.data.error.errorCode, event.data.error.errorMessage );
					Bee.Core.Dispatcher.dispatch(Bee.Events.FR_INVALID_API_KEY, null, null);
					return false;
				break;
				case FlickrApi.FlickrError.SERVICE_CURRENTLY_UNAVAILABLE:
					this.onErrorAlert( lang.FR_SERVICE_UNAVAILABLE, event.data.error.errorCode, event.data.error.errorMessage );
					return false;
				break;
				case FlickrApi.FlickrError.LOGIN_FAILED:
					this.onErrorAlert( lang.FR_LOGIN_FAILED, event.data.error.errorCode, event.data.error.errorMessage );
					return false;
				break;
			}
			this.onErrorAlert( null, error.errorCode, error.errorMessage);
			Bee.Core.Dispatcher.dispatch(Bee.Events.FR_SEARCH, null, {success : event.success});
		}
	},
	
	// gets result for delete command, refreshes if successful
	onDeletePhoto : function( event){
		if (event.success){
			Bee.Core.Dispatcher.dispatch(Bee.Events.FR_DELETE_DONE, null, null);
		}
		else{
			var error = event.data.error;
			this.onErrorAlert( lang.FR_DELETE_FAIL, error.errorCode, error.errorMessage);
		}
	},
	
	onIOErrorEvent : function( event){
		this.onErrorAlert( lang.FR_IO_ERROR, null, event.toString());
	},
	
	// called on errors
	onErrorAlert : function( message, errorCode, errorMessage ){
		air.trace("Error: " + message + " Code[" + errorCode + "] - " + errorMessage); 
		if (Bee.Window.hourglassOn){
			Bee.Application.hideHourglass();
		}
		if (message){
			doConfirm("", message, 8, null );
		}
		if (errorCode == 105){
			doConfirm("", lang.FR_SERVICE_UNAVAILABLE, 8, null );
		}
	},
}

Bee.Services.Photo.FlickrClass = flickr;