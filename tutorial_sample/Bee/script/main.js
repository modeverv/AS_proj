/*
ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.
 
NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the 
terms of the Adobe license agreement accompanying it.  If you have received this file from a 
source other than Adobe, then your use, modification, or distribution of it requires the prior 
written permission of Adobe.

*/ 



 var Bee = {
 	
 	Version: "1.0",
 	
 	Debug : false, 
 	//Application instance
 	
 	Application : null,
 	
 	//User interface
 	Display :  {Blog:{}, Photo:{}, Settings:{}},
 	
 	//Remoting tools XML/RPC/Upload/Download
 	Net : {},
 	
 	//Data classes  
 	Data : {},
 	
 	//API Bussiness logic
 	Services: {Blog:{}, Photo:{}},
 	
 	//Storage
 	Storage : {},
 	
 	//Graphics editor and encoders 
 	Graphics: {},
 	
 	//Core communication
 	Core: {},
 	
 	
 	//functions
 	Util : {
 	//importing js
	 	_import : function(script){
	 		//Async version
	 		/*var script_tag = document.createElement("script");
			script_tag.type = "text/javascript";
			script_tag.src = script;
			document.getElementsByTagName("head")[0].appendChild(script_tag);*/
	 		//sync version
		    document.write('<script type="text/javascript" src="'+script+'"></script>');
	 	}
 	},
 	
 	Events :{
 		APP_LOAD: 'appload',
 		APP_INIT: 'appinit',
 		APP_UNLOAD: 'appunload',
 		NETWORK_CHANGE : 'networkchanged',
 		
		DRAG_ENTER : 'dragenter',
 		DRAG_DROP: 'dragdrop',
		
		NATIVE_DRAG_ENTER : 'nativedragenter',
		NATIVE_DRAG_EXIT: 'nativedragexit',
		
 		NATIVEWINDOW_CLOSE : 'nativewindowclose',
 		WINDOW_CLOSE : 'windowclose',
 		ACTIVEWINDOW_CHANGED: 'door_activewindowchanged',
 		NEWACTIVEWINDOW:'door_newactivewindow',
 		REMOVEACTIVEWINDOW: 'door_removeactivewindow',
 		ACTIVEWINDOW_CLOSED: 'activewindowclosed',
 		ACTIVEWINDOW_TITLE:'door_activewindowtitle',
 		STATUS:'door_status',
 		SYNC_FAILED: 'door_sync_failed',
 		SYNC_FINISHED: 'door_sync_finished',
		DOSYNC: 'door_dosync',
		
		SETTINGS_REFRESH: 'settingsrefresh',

		FR_SERVICE_INIT: 'fr_login',
		FR_LOAD_PHOTOSETS: 'fr_loadphotosets',
		FR_LOAD_PHOTOS: 'fr_loadphotos',
		FR_SEARCH: 'fr_search',
		FR_LOAD_PHOTO_INFORMATION: 'fr_loadphotoinformation',
		FR_LOGOUT: 'fr_logout',
		FR_ADDUSER_START: 'fr_adduser_start',
		FR_ADDUSER_FINISH: 'fr_adduser_finish',
		FR_REFRESH_PHOTOS: 'fr_refresh_photos',
		FR_USER_REMOVED: 'fr_user_removed',
		FR_INVALID_API_KEY: 'fr_invalidapikey',
		FR_SERVICE_UNAVAILABLE: 'fr_serviceunavailable',
		FR_LOGIN_FAILED: 'fr_loginfailed',
		FR_DELETE_DONE: 'fr_deletedone',
		FR_LOAD_INFO: 'fr_loadinfo',
		FR_LOAD_SIZES: 'fr_loadsizes',
		
		//FR_CLEANPAGE : 'flickrcleanpage',
		//FR_NO_ACCOUNT : 'flickrnoaccount',
		
		INSERT_PICTURE: 'insertpicture',
	
		BLOG_ACCOUNTS_REFRESH: 'blog_account_refreh',
		BLOG_REFRESH: 'blog_refresh',
		
		POST_EDIT_SHOWBLOGS: 'door_edit_showblogs',		
		POST_EDIT_HIDEBLOGS: 'door_edit_hideblogs',
		POST_EDIT_SENDBLOG: 'door_edit_sendblog',
		
		BLOG_VIEW_CHANGED: 'door_view_changed',
		
		
		UPLOAD_STATUS: 'door_upload_status'
 	},
 	
 	Constants: {
 		FR_SERVICE: 2,
 	}
 };


function isDebug(){
	return Bee.Debug;
	
}



var langNameByte = config['langName'];
			
if(langNameByte&&langNameByte.toString()=='romanian') 
	langName = 'romanian';
else 
	langName = 'english';

Bee.Util._import('assets/languages/'+langName+'.js');
 
 
Bee.Util._import("script/net/async.js"); 
Bee.Util._import("script/core.js");
 
 
Bee.Util._import("script/display/ui.js");


Bee.Util._import("script/display/blog/blog.js");

Bee.Util._import("script/display/blog/postEdit.js");
Bee.Util._import("script/display/blog/template.js");
 
Bee.Util._import("script/storage/db.js");



Bee.Util._import("script/basics.js");

Bee.Util._import("script/services/blog/generic.js");
Bee.Util._import("script/services/blog/wordpress.js");


Bee.Util._import("script/display/services/photo/photo.js")

Bee.Util._import("script/services/photo/flickr.js");

Bee.Util._import("script/display/settings/settings.js");

  
Bee.Util._import("script/application.js");

