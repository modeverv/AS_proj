/*
ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.
 
NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the 
terms of the Adobe license agreement accompanying it.  If you have received this file from a 
source other than Adobe, then your use, modification, or distribution of it requires the prior 
written permission of Adobe.

*/

 Bee.Application = {
 	exiting :false, 
 	nativeWindows:[],
 	html: [],
 	mainWindow: null,
 	windows : [],
 	navigWindows : {}, 
 	invokes : 0, 
	isDraggingOver: false,
 	
 

 	exit: function (){
		Bee.Application.doExit(null);
 		
 	},

	//invoke event (every time user double cliks Bee icon)
 	doInvoke: function(e){
 		if(Bee.Application.invokes){
 			nativeWindow.visible = true;
	 	}
 		Bee.Application.invokes++;
 	},
	
	quitHandled : false,
	
 	//handle quit nicely
 	doExit : function (e){
 		if(Bee.Application.quitHandled) return;
 		Bee.Application.quitHandled = true;
 		
 		var callback = function(ev){
			if(ev)
				air.NativeApplication.nativeApplication.exit();
			
		};
 		if(dirty){
 			closeCreatePost(function(){
 				if(dirty){
	 				if(e) e.preventDefault();
	 				Bee.Application.quitHandled = false;
		 			 callback(false);
		 		}else{
			 		Bee.Application.quitHandled = false;
		 			Bee.Application.exit();
		 		}
 			});
 			return;
 		}
 		config.x = nativeWindow.x;
 		config.y = nativeWindow.y;
 		config.width = nativeWindow.width;
 		config.height = nativeWindow.height;
 		Bee.Application.exiting = true;
 		Bee.Application.quitHandled = false;
 	//TODO: not needed	
	//	Bee.Core.Dispatcher.dispatch(Bee.Events.APP_UNLOAD, Bee.Application, null );
	
		writeConfig();
 	 	try{	
	 		Bee.Storage.Db.unload();
	 	}catch(e){
	 		
	 	}
		callback(true);
	},
	
	//when closing main window don't close app. Just hide main window
 	hideWindow: function (e){
 		Bee.Application.exit();
 		if(!Bee.Application.exiting)
 			e.preventDefault();
 	},
 	
 	doMinimize : function (e){
		if(e.afterDisplayState=='minimized'&&config['noMinimize']){
 			e.preventDefault();
			nativeWindow.visible = false;
		}
 	},
 	
 	
 	/*saveSizePosition : function (e){
 		var rect = e.afterBounds;
 		config.x = rect.x;
 		config.y = rect.y;
 		config.width = rect.width;
 		config.height = rect.height;
 	},*/
 	
	
 	//adding handlers for AIR events
 	init : function(){

 		Bee.Storage.Db.init();
 		
 		try{
	 		Bee.Services.Photo.Flickr = new Bee.Services.Photo.FlickrClass(); 		
			Bee.Application.initServices();
		}catch(e){
			air.trace(e);
		}
// 		Bee.Core.Dispatcher.dispatch(Bee.Events.APP_INIT, Bee.Application, null );

 		air.NativeApplication.nativeApplication.autoExit = false;
 		air.NativeApplication.nativeApplication.addEventListener(  air.InvokeEvent.INVOKE , Bee.Application.doInvoke );
	//	air.NativeApplication.nativeApplication.addEventListener( air.Event.EXITING,  Bee.Application.doExit);
		window.nativeWindow.addEventListener( air.Event.CLOSING, Bee.Application.hideWindow);
		window.nativeWindow.addEventListener( air.NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING, Bee.Application.doMinimize);
		
		//removed since we're not saving config file everytime
		//window.nativeWindow.addEventListener( air.NativeWindowBoundsEvent.MOVING , Bee.Application.saveSizePosition);			
		//window.nativeWindow.addEventListener( air.NativeWindowBoundsEvent.RESIZING , Bee.Application.saveSizePosition);
			
 		if(air.NativeApplication.supportsSystemTrayIcon||air.NativeApplication.supportsDockIcon)
 			Bee.Application.registerNativeApplicationIcon();

 		if(air.NativeApplication.supportsSystemTrayIcon)
 			air.NativeApplication.nativeApplication.icon.tooltip = lang['SHELL_ICON_TIP'];

 		if(air.NativeApplication.supportsMenu||air.NativeWindow.supportsMenu)
 			Bee.Application.registerMenu();

	 	Bee.Application.initMainWindows ();

		nativeWindow.minSize = new air.Point(config.minWidth, config.minHeight);
		nativeWindow.width = config.width;
		nativeWindow.height = config.height;
		nativeWindow.x = config.x;
		nativeWindow.y = config.y;
		
		nativeWindow.menu = Bee.Application.menu;

		//make main window show an always on top DIV element with ondrag events
		nativeWindow.stage.addEventListener( air.NativeDragEvent.NATIVE_DRAG_OVER, function(){

			if(!Bee.Application.isDraggingOver){
						
				Bee.Core.Dispatcher.dispatch(Bee.Events.NATIVE_DRAG_ENTER);
				Bee.Application.isDraggingOver = true;			
			}				
		});
		
		nativeWindow.stage.addEventListener( air.NativeDragEvent.NATIVE_DRAG_EXIT, function(){
			Bee.Core.Dispatcher.dispatch(Bee.Events.NATIVE_DRAG_EXIT);
			Bee.Application.isDraggingOver = false;	
		});


//		Bee.Core.Dispatcher.addEventListener(Bee.Events.ACTIVEWINDOW_TITLE, Bee.Application.refreshMainTitle);
		Bee.Core.Dispatcher.addEventListener(Bee.Events.DOSYNC, Bee.Application.syncBlogs);
		Bee.Core.Dispatcher.addEventListener(Bee.Events.INSERT_PICTURE, function(e){
			Bee.Application.insertFlickr(e);
		});
		
		
 	},
	
	//insert flickr image in current post
	//if there is no post, just create a new on e
	insertFlickr : function (e){
		if(!Bee.Application.navigWindows['post'])
				Bee.Window.gotoCreatePost();
			Bee.Application.navigWindows['post'].insertFlickrPicture(e);
	},
 	
 	//----------------------------- synchronization methods -----------------------
 	blog_services : [],
	blog_services_hash : {},
	syncAgain : false, 
	syncing : false, 
	
 	syncBlogs : function(e){
 		if(e.target) return;

		if(	Bee.Application.syncing ){
			Bee.Application.syncAgain  =true;
			return;
		}

		var haveBlogs = false;
		for(var i=0;i<Bee.Application.blog_services.length;i++)
			if(Bee.Application.blog_services[i])
				haveBlogs = true;
				
		if(!haveBlogs) return;
		
		if(!e.args){
			Bee.Core.Dispatcher.dispatch(Bee.Events.DOSYNC, true);
		}
		Bee.Storage.Db.conn.begin();
		Bee.Application.syncing = true;
		
		var syncFailed = false;
		var syncFailedExp = [];
		var atom = new Bee.Net.AsyncAtom();
	
		atom.onfinish = function (){
			Bee.Application.syncing = false;
			if(syncFailed)
				Bee.Core.Dispatcher.dispatch(Bee.Events.SYNC_FAILED, syncFailedExp);
			else{
				Bee.Core.Dispatcher.dispatch(Bee.Events.SYNC_FINISHED);
				
			Bee.Storage.Db.conn.commit();	
		/*		if(Bee.Application.syncAgain){
					Bee.Application.syncAgain = false;
					Bee.Core.Dispatcher.dispatch(Bee.Events.DOSYNC);
				}*/
			}
		}
		
		atom.addHandler('download', function(i, ok){
			if(ok){
 				Bee.Storage.Db.Blog.upload(Bee.Application.blog_services[i], this.getHandler());
				}else{
					syncFailed = true;
					syncFailedExp.push(Bee.Application.blog_services[i].blogName + ': synchronization failed');
				}
		});

 		for(var i=0;i<Bee.Application.blog_services.length;i++){
 			if(Bee.Application.blog_services[i])
				Bee.Storage.Db.Blog.download(Bee.Application.blog_services[i], atom.getHandler("download", i));
		}
		
		
		atom.finish();
 	},
 	
 	//read accounts from DB and init client objects
 	initServices: function (){
		var services = Bee.Storage.Db.Accounts.getServices();
		for(var i =0;i<services.length;i++){
			var service = services[i];
			var accounts = Bee.Storage.Db.Accounts.getAccountsByService(service.id);
			for(var j=0;j<accounts.length;j++){
				var account = accounts[j];
				switch(service['class']){
				case 1: //wordpress
					////////
					var serviceRules = xmlRpc._unmarshall(service.rules);
					///////
					var accountRules = xmlRpc._unmarshall(account.rules);
					
					var blogs = Bee.Storage.Db.Blog.getBlogs(account.id);
				
					for(var k=0;k<blogs.length;k++){
						var blog = blogs[i];
						var blogRules = xmlRpc._unmarshall(blog.rules);
						
						blogRules.blogId = blog.id;
						
						var wp = new 	Bee.Services.Blog.WordPress(blogRules.user, getSecureStore('blog_password'+blog.id), serviceRules, accountRules, blogRules);
						wp.blogName = account.title+' '+blog.title;
						 
						Bee.Application.blog_services.push(wp);

						Bee.Application.blog_services_hash[blog.id] = Bee.Application.blog_services.length-1;
						
						
						}
					break;
					
					case 2:
					
					
					break;
				}
			}

		}
	},


	//MainWindows initialization
 	initMainWindows : function (){

 		Bee.Application.navigWindows['blog']=new Bee.Display.Blog.Main();
 		Bee.Application.navigWindows['photo']=new Bee.Display.Photo.Main();
 		Bee.Application.navigWindows['settings']=new Bee.Display.Settings.Main();
 	},
 	
 	//load systray or dock icons/menu
 	registerNativeApplicationIcon : function(){
 		var loader = new air.Loader();
 		loader.contentLoaderInfo.addEventListener(window.air.Event.COMPLETE, function(event){
			var loader = air.Loader(event.target.loader);
			var image = air.Bitmap(loader.content);
			air.NativeApplication.nativeApplication.icon.bitmaps=[image];
			var menu = new air.NativeMenu();
			var item_show = new air.NativeMenuItem('Show');
			item_show.name = 'show';
			menu.addItem(item_show);
				item_show.addEventListener( air.Event.SELECT , Bee.Application.menuClick);			
			var item_exit = new air.NativeMenuItem('Exit');
			item_exit.name = 'exit';
			menu.addItem(item_exit);
				item_exit.addEventListener( air.Event.SELECT , Bee.Application.menuClick);
			air.NativeApplication.nativeApplication.icon.addEventListener('click', function(){
			 	nativeWindow.visible=true;
		 	 	nativeWindow.activate();
			});
			air.NativeApplication.nativeApplication.icon.menu = menu;
 		});
 		
 		var request;
 		if(air.NativeApplication.supportsDockIcon)
 		    request = new air.URLRequest("icons/AIRApp_128.png");
 		else
 		    request = new air.URLRequest("icons/AIRApp_16.png");
        loader.load(request);
 	},
 	
 	disableLevel : 0,
 	
 	disableModalMenu: function(enabled){
 		if(Bee.Application.disableLevel>0&&enabled)
	 			Bee.Application.disableLevel--;
 		
		if(!enabled) 
 				Bee.Application.disableLevel++;

 		var enabled = Bee.Application.disableLevel==0 ;
 		for(var i=Bee.Application.menuModalDisabled.length-1;i>=0;i--)
	 		Bee.Application.menuModalDisabled[i].enabled = enabled;
 		
 	},
 	
 	menuModalDisabled : []
 	,
 	
 	registerMenu : function(){

 			var item_settings = new air.NativeMenuItem();
	 		item_settings.label = "Settings...";
	 		item_settings.name = "settings";

	// 		Bee.Application.menuModalDisabled.push(item_settings);

			var item_language = new air.NativeMenuItem();
	 		item_language.label = "Language";
	 		item_language.name = "language";
	 		item_language.submenu = new air.NativeMenu(); 		


			var item_languageEn = new air.NativeMenuItem();
	 		item_languageEn.label = "English";
	 		item_languageEn.name = "languageEn";
	 		item_languageEn.checked =config.langName=='english';
			item_language.submenu.addItem(item_languageEn);


			var item_languageRo = new air.NativeMenuItem();
	 		item_languageRo.label = "Romanian";
	 		item_languageRo.name = "languageRo";
	 		item_languageRo.checked = config.langName=='romanian';
			item_language.submenu.addItem(item_languageRo);


	 		var item_sync = new air.NativeMenuItem();
	 		item_sync.label = "Synchronize";
	 		item_sync.name = "sync";
//	 		item_sync.keyEquivalentModifiers = [];

//	 		item_sync.keyEquivalent = (runtime.flash.ui.Keyboard.F5String+'').toUpperCase();


	 		Bee.Application.menuModalDisabled.push(item_sync);

	 		var bar1 = new air.NativeMenuItem('', true);

	 		var item_exit = new air.NativeMenuItem('Exit');
	 		item_exit.name = "exit";
//	 		item_exit.keyEquivalent = 'Q';


	 		var help_menu = new air.NativeMenuItem('Help');
	 		help_menu.name = 'help';
	 		help_menu.submenu = new air.NativeMenu();
	 		var item_about = new air.NativeMenuItem('About Bee...');
	 		item_about.name = "about";
	 		help_menu.submenu.addItem(item_about);
	 		var item_source = new air.NativeMenuItem('View Sources...');
	 		item_source.name = "sources";
	 		help_menu.submenu.addItem(item_source);

		

	if(air.NativeApplication.nativeApplication.menu){
 			var bee_menu = air.NativeApplication.nativeApplication.menu.getItemAt(0);
			bee_menu.label = "Bee";
			
				//bee_menu.submenu = new air.NativeMenu();

				var bee_menu = new air.NativeMenuItem();
		 		bee_menu.label = "Tools";
		 		bee_menu.name = "tools";


		 		air.NativeApplication.nativeApplication.menu.addItem(bee_menu);

		 		bee_menu.submenu = new air.NativeMenu();
		 		bee_menu.submenu.addItem(item_settings);
				bee_menu.submenu.addItem(item_language);
				bee_menu.submenu.addItem(item_sync);
				
//		 		bee_menu.submenu.addItemAt(bar1, 3);
//			 		bee_menu.submenu.addItem(item_exit);
		

		
 			air.NativeApplication.nativeApplication.menu.addItem(help_menu);

	}else{
 		var menu =  new air.NativeMenu();

 		var bee_menu = new air.NativeMenuItem();
 		bee_menu.label = "Bee";
 		bee_menu.name = "bee";


 		menu.addItem(bee_menu);

 		bee_menu.submenu = new air.NativeMenu();
 		bee_menu.submenu.addItem(item_settings);
		bee_menu.submenu.addItem(item_language);
		bee_menu.submenu.addItem(item_sync);
 		bee_menu.submenu.addItem(bar1);
 		bee_menu.submenu.addItem(item_exit); 		


 		menu.addItem(help_menu);


 		//window.nativeWindow.menu = menu;
 		Bee.Application.menu =  menu;

	}
	

		item_exit.addEventListener( air.Event.SELECT , Bee.Application.menuClick);
		item_languageEn.addEventListener( air.Event.SELECT , Bee.Application.menuClick);
		item_languageRo.addEventListener( air.Event.SELECT , Bee.Application.menuClick);
		item_sync.addEventListener( air.Event.SELECT , Bee.Application.menuClick);

		item_settings.addEventListener( air.Event.SELECT , Bee.Application.menuClick);

		item_about.addEventListener( air.Event.SELECT , Bee.Application.menuClick);
		item_source.addEventListener( air.Event.SELECT , Bee.Application.menuClick);

 	},
	
	
	//----------------------------- editing workflow --------------------
	loadNewPost: function(){		
		Bee.Application.navigWindows['post']=new Bee.Display.Blog.PostEdit();
		return true;
	},
	
	loadPost: function(id){		
		var post = Bee.Storage.Db.Blog.getPost(id);
		if(!post) return false;		
		Bee.Application.navigWindows['post']=new Bee.Display.Blog.PostEdit(post);
		return true;
	},
	
	
	//------------------------------- callbacks --------------------------
 	
 	menuClick: function (e){
		air.debug(e);
 		switch(e.currentTarget.name){
 			case 'languageRo':
				Bee.Application.switchLanguage('romanian');
				break;
 			case 'languageEn':
				Bee.Application.switchLanguage('english');
				break;
 			case 'settings':
 				Bee.Window.showSettings();
 			break;
 			case 'show':
 				nativeWindow.visible=true;
 			break;
 			case 'exit':
	 			Bee.Application.exit();
 			break;
 			case 'sources':

				var sb = air.SourceViewer.getDefault();
				var cfg = {exclude: ['/SourceViewer']};
				sb.setup(cfg);
				sb.viewSource()


 			break;
 			case 'about':
 				//todo: about bee;	
 				
 				showModal('aboutScreen');
 				esc = closeModal;
 			break;
 			case 'sync':
 				Bee.Core.Dispatcher.dispatch(Bee.Events.DOSYNC);
 			break;
 		}
 	},
 	

 			
	getLang : function (){ return lang; },
		
	 	 
	 
		 
	//return a list of blog accounts 
	 blogs: function(){
	 	
		var rblogs = [];
		
		var services = Bee.Storage.Db.Accounts.getServices();
	
		for(var i=0;i<services.length;i++){
			var service = services[i];
			var accounts = Bee.Storage.Db.Accounts.getAccountsByService(service.id);
			var classType = service['class'];
			
			for(var j=0;j<accounts.length;j++){
				var account = accounts[j];
				switch(service['class']){
					case 1:
						var blogs = Bee.Storage.Db.Blog.getBlogs(account.id);
			
						for(var k=0;k<blogs.length;k++){
							var blog = blogs[i];
							
							rblogs.push({ id:blog.id, title: account.title+' ' +blog.title, rules:blog.rules }); 
						}
					break;
				}
			}
			
		}
		
		return rblogs;
	 },
	 
	 
	 //switch language
	 switchLanguage: function(newlang){
		config.langName = newlang;
		alert('Language will be switched after Bee restart!');
	 },
	
	 
//----------------  drag upload functions ------------------
	 acceptDrag : false,
	  
	 uploadFiles : [], 
	 
	 clearUploadFiles  : function (){ Bee.Application.uploadFiles = []; },
	 
	 doDragFiles : function (files){
	 	
	 	if(!Bee.Application.acceptDrag) return;
	 	if(!files) return;
		if(!files.length) return;
		var extensions = {'jpg':1, 'jpeg':1, 'bmp':1, 'gif':1, 'png':1, 'tiff':1, 'tif':1};
		var upfiles = Bee.Application.uploadFiles;
		
		for(var i=0;i<files.length;i++){
			var type="";
			var lastDot = files[i].name.lastIndexOf('.');
			if(lastDot>-1) type = files[i].name.substr(lastDot+1); 
			if(!extensions[type.toLowerCase()]) continue;
			upfiles.push({
				filename: files[i].nativePath,
				src: "file:/"+files[i].nativePath,
				title: files[i].name,
				description: lang['CLICK_TO_ADD_DESCRIPTION'],
				file: files[i]
			});
		}
		
		
		
		Bee.Window.showUpload();
		Bee.Window.dsUpload.setDataFromArray(upfiles);
		if(upfiles.length) //used to be show/hide - changed => bogdan is happy
			Bee.Window.$('ups_upload').disabled=false;
		else
			Bee.Window.$('ups_upload').disabled=true;
		
	 },
	 
	 
	 doUploadFiles:function(files, isInBlog){
	 	
		if( !Bee.Services.Photo.Flickr.loggedIn ){
			
			Bee.Core.Dispatcher.dispatch(Bee.Events.UPLOAD_STATUS, null, {error:'Upload disabled. Create a flickr account first.'});
			return;	
		}
		
		Bee.Application.cancelUpload=false;
		var myfiles = [];
		for(var i=0;i<files.length;i++) 
			myfiles[i] = { id:i, src:'', file:files[i], files:myfiles };
		myfiles.isInBlog = isInBlog;
		
		if(files.length){
			Bee.Core.Dispatcher.dispatch(Bee.Events.UPLOAD_STATUS, null, {progress:true, files:0, fileName: files[0].title, 
						total:myfiles.length, value:0}); 
			Bee.Services.Photo.Flickr.uploadFile(files[0], isInBlog, function (stat, src){
					Bee.Application.uploadCallback(myfiles[0], stat, src) });
		}
		
	 },
	 
	 uploadCallback : function (file, stat, src){
	 	try{
	 	switch(stat){
			case 5: //error source for post
			case 1:	//io_error
				var strUploaded = "";
				var filesNotUploaded = [];
				for(var i=file.id;i<file.files.length;i++){
					if(strUploaded.length) strUploaded+=', ';
						strUploaded+=file.file.file.nativePath ;
					filesNotUploaded.push(file.file);
				}
				
				if(stat==1) err=  " Network IO error. ";
				else err =  "Flickr error.";
				if(file.files.isInBlog){
					if(file.id>0&&confirm('There was a network error, but some pictures could be uploaded. Would you like to insert the uploaded pictures in post?')){
						//insert uploaded photos in post
						var src = "";
						for(var i=0;i<file.id;i++)
							src+=file.files[i].src+"<br />";
						Bee.Application.insertFlickr({args:src});
					}
				}
				//Bee.Services.Photo.Flickr.refreshPhotos();
				Bee.Core.Dispatcher.dispatch(Bee.Events.FR_REFRESH_PHOTOS, null, null);
				Bee.Core.Dispatcher.dispatch(Bee.Events.UPLOAD_STATUS, null, {error:err+'\nFiles not uploaded:'+strUploaded, files:filesNotUploaded});
				
				break;
			case 2: //progress
				
				var prgVal = 100/file.files.length*(file.id+src.bytesLoaded / src.bytesTotal);
				prgVal = Math.round(prgVal);
				
				Bee.Core.Dispatcher.dispatch(Bee.Events.UPLOAD_STATUS, null, {progress: true, files:file.id, fileName:file.file.title,
					total:file.files.length, value:prgVal}); 
				
				break;
			case 4:
			case 3: //complete
				if(stat==4)//get it in post
					file.src = src;
				if(Bee.Application.cancelUpload){
					
					//Bee.Services.Photo.Flickr.refreshPhotos();
					Bee.Core.Dispatcher.dispatch(Bee.Events.FR_REFRESH_PHOTOS, null, null);
					Bee.Core.Dispatcher.dispatch(Bee.Events.UPLOAD_STATUS, null, {cancel:true}); 
				}else if(file.id<file.files.length-1){
					//start uploading next picture
					var nextid = file.id+1;
					Bee.Services.Photo.Flickr.uploadFile(file.files[nextid].file, file.files.isInBlog, function (stat, src){
						 Bee.Application.uploadCallback(file.files[nextid], stat, src) });
					
					var prgVal = 100/file.files.length*(file.id+1);
					
					
					Bee.Core.Dispatcher.dispatch(Bee.Events.UPLOAD_STATUS, null, {progress:true, files:file.id, fileName:file.file.title,
						total:file.files.length, value:prgVal}); 
				}else{
					//upload finished 
					//do smthing
					
					if(file.files.isInBlog){
							//insert uploaded photos in post
						var src = "";
						for(var i=0;i<file.files.length;i++)
							src+=file.files[i].src+"<br />";
						Bee.Application.insertFlickr({args:src});
					}

					//Bee.Services.Photo.Flickr.refreshPhotos();
					Bee.Core.Dispatcher.dispatch(Bee.Events.FR_REFRESH_PHOTOS, null, null);
					Bee.Core.Dispatcher.dispatch(Bee.Events.UPLOAD_STATUS, null, {complete: true});
				} 
				
				break;
		}
		}catch(e){air.trace(e);}
	 }
	 ,
 	


//-------------------- workflow: use hourglass screen to prevent clicking -----------
	showHourglass : function (){
		showHourGlass();
	},
	
	hideHourglass : function (){
		Bee.Window.hideHourGlass();
	},	

//---------------------------- status alert -----------------------------	 	
 	 alert : function (w){
			Bee.Core.Dispatcher.dispatch(Bee.Events.STATUS, null, {text:w});
 	 },

//----- write error to desktop file bee.log 
	 traceErr: function(err){
			return ;
			if(air.File.desktopDirectory.resolvePath)	
				var traceFileRef = air.File.desktopDirectory.resolvePath('bee.log');
			else
			 	var traceFileRef = air.File.desktopDirectory.resolve('bee.log');
				
			var traceFile = new air.FileStream();
			traceFile.open(traceFileRef, air.FileMode.APPEND);
			traceFile.writeUTFBytes( err + '\n');
			traceFile.close();		
		},
 	 

 	 Data : Bee.Data
 	
 };
 

 //onload event
 window.onload = function (){ 
  	langRefreshUi();
  	doLoad();
 	Bee.Application.init(); 
 	afterDoLoad();
 	
 	splash.window.nativeWindow.close();
 	splash = null;
 	
 	setTimeout(function(){

	 	nativeWindow.visible=true;
 	 	nativeWindow.activate();
 	}, 10);
 }
 
 
 
 
 
