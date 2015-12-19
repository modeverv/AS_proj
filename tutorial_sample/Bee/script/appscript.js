/*
ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.
 
NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the 
terms of the Adobe license agreement accompanying it.  If you have received this file from a 
source other than Adobe, then your use, modification, or distribution of it requires the prior 
written permission of Adobe.

*/

	//scriptaculous transition
	Effect.Transitions.exponential = function(pos) {
		  return 1-Math.pow(Math.pow(1-pos,2),1.05);
	}
		
	
// ================================================================================
// GLOBALS  	
// ================================================================================
	//used to know what type of effect to be used when changing screens
	var lastSelectedPage = null;	//this is the page one step back
	var prevSelectedPage = null;	//and two steps back
	
	//used for making developing process a little smooth (you can disable animations by
	//setting this to 0 
	//TODO: this should go somewhere in settings;
	
	var transitionTime = 0.45;		
	
	//distance between main pages (blog tab and photo tab) 
	var pageSpan = 110;
	//margins
	var pageMargin = 20;
	
	//used when the user modified content in a post and it needs save before close
	var dirtyCallback = null;
	var dirty = false;
	
	//just to know there is a sync dialog visible
	var isSyncVisible = false;

	//let the user know about any issues in sync proccess
	var isSyncOk = true;
	
	//after closing a modal dialog remember that we should accept drags on form
	var oldAcceptDrag = false;
	
	//used to know if dragging pictures in bee should pass the in a new/opened post
	var isInBlog = false;
	
	//we have two types of modal dialog. use this to make sure you don't hide 
	//the shadow before closing any modal
	var hideShadow = true;
	
	//worpdress.com url for creating new blogs
	var wpNewAccountUrl = "http://wordpress.com/signup/";
	
	//anytime hourglass form is shown this will be true
	var hourglassOn = true;
	
	//cancel or just close upload window
	var shouldCancelUpload = false;
	
	//try to make doConfirm window open just once
	var doConfirmVisible = false;
	
	//esc key function
	var esc = null;
	//esc key prevent in modals
	var oldEsc = null;
	
	var isInMainScreen = true;
	
	//------------------------  SPRY Datasets  ----------------------------
	//global datasets 
	var dsBlogPosts = new Spry.Data.DataSet();	//current blog posts dataset
	var dsBlogCats = new Spry.Data.DataSet();	//current categories dataset	
	var dsBlogs = new Spry.Data.DataSet();		//used to change current wordpress account

	//settings panel datasets
	var dsWordPress = new Spry.Data.DataSet(); 
	var dsFlickr = new Spry.Data.DataSet();
	
	//upload list dataset
	var dsUpload = new Spry.Data.DataSet();
	
	//photosets, account photos and search results datasets
	var dsFlickrPhotosets = new Spry.Data.DataSet();
	var pgFlickrPhotosets = new Spry.Data.PagedView( dsFlickrPhotosets ,{ pageSize: 4 });
	var dsFlickrPhotos = new Spry.Data.DataSet();
	var dsFlickrSearchPhotos = new Spry.Data.DataSet();
	

// ================================================================================
// DESIGN  	
// ================================================================================
	//--------------------------------  Effects --------------------------------
	//design: slide main pages to the left
	function slideLeft(){
		var width =  $('screens').getWidth()-pageSpan;
		new Effect.Move($('blogPage'), {x:pageMargin,y:0, mode:'absolute', duration:transitionTime, queue:'parallel'});
		fadeOut($('blogPageButton'), true);	
		new Effect.Move($('photoPage'), {x:width+2*pageMargin,y:0, mode:'absolute', duration:transitionTime, queue:'parallel', afterFinish:function(){

			fadeIn($('photoPageButton'));
		}});
		
	}
	//design: slide them back to the right
	function slideRight(){
		var width = $('screens').getWidth()-2*pageSpan;
		new Effect.Move($('blogPage'), {x:-width-2*pageMargin,y:0, mode:'absolute', duration:transitionTime, queue:'parallel'});
					fadeOut($('photoPageButton'), true);		
		new Effect.Move($('photoPage'), {x:pageSpan-1*pageMargin,y:0, mode:'absolute', duration:transitionTime, queue:'parallel', afterFinish:
			function(){
				fadeIn($('blogPageButton'));		

			}});		
		
	}
	
	
	//fade out an element using sync method
	//use fast to make the effect async
	function fadeOut(element, fast){
			new Effect.Opacity(element, {to:0.0, duration:transitionTime*0.5, queue:fast?'parallel':'end', afterFinish:function(){
				element.hide();
			}});
	}

	//fade in an element using sync method
	//use fast to make the effect async
	function fadeIn(element, fast){
		element.show();
		new Effect.Opacity(element, {to:1.0, duration:transitionTime*0.5, queue:fast?'parallel':'end'});
	}

	//--------------------------------  Modal dialogs --------------------------------
	//Shows a modal dialog 
	//e is the dialog type
	//there are two types of dialogs:
	// 	* 'modal' - shown behind (default value);
	//  * 'modal2' - shown in front 
	//example: you are in the settings dialog and synchronization proccess starts
	//		   Bee will show it by fading in synchronization dialog in front of anything 
	function showModal(id, e){
		if(doConfirmVisible) return;
		
		Bee.Application.disableModalMenu(false);
		oldAcceptDrag = Bee.Application.acceptDrag;
		Bee.Application.acceptDrag = false;
		if(!e) e= 'modal';
		
		var shadow = $('shadow');
		var modal = $(e);
		if(e!='modal'){
			 hideShadow = !shadow.visible();
			 oldEsc = esc ;
			 esc = null;
			}else{
				inMainScreen = false;
			}
		shadow.show();
		modal.show();
		new Effect.Opacity(shadow, {to:0.7, duration:transitionTime*0.6, queue:'parallel'});
	
		modal.setOpacity(1);
		modal.style.top= -modal.getHeight()+'px';
		
		new Effect.Move(modal, {y:0, y:0, mode:'absolute', duration:transitionTime, queue:'end'});
		
		hideModals(e);
		
		switch(id){
			
			case 'settingsScreen':
				Bee.Application.navigWindows['settings'].onshow();
			break;
			
		}
		
		$(id).show();
	}
	//Hides all modals of type e
	function hideModals(e){
		if(!e) e= 'modal';
		var screens =  $(e);
		var e = screens.firstChild;
		while(e){
			if(e.nodeType==1&&e.nodeName=='DIV')
				e.hide();	
			e=e.nextSibling;
		}
	
	}
	//Close modals of type e
	function closeModal(e){
		if(!e) 
			e= 'modal';
		var shadow = $('shadow');
		var modal = $(e);
		
		if(e=='modal'||hideShadow)
			new Effect.Opacity(document.getElementById('shadow'), {to:0.0, duration:transitionTime, queue:'parallel'});
		if(e=='modal')
			isInMainScreen = true;
		
		new Effect.Move(modal, {y:0, y:-modal.getHeight(), mode:'absolute', duration:transitionTime, queue:'parallel', afterFinish:function(){
		//new Effect.Opacity(document.getElementById('modal'), {to:0.0, duration:transitionTime, queue:'parallel', afterFinish:function(){
			
			hideModals(e);
			if(e=='modal'||hideShadow)
				shadow.hide();
			modal.hide();
		}});
		
		Bee.Application.acceptDrag = oldAcceptDrag;
		if(e!='modal'&&oldEsc){
			esc = oldEsc;
			oldEsc = null;
		}else{
			esc = null; 
			Bee.Application.disableModalMenu(true);
			
		}
		
	}
	
	
	//shortcuts for type2 dialogs
	function showModal2(id){
		showModal(id, 'modal2');
	}
	function hideModals2(){
		hideModals('modal2');
	}
	function closeModal2(){
		closeModal('modal2');
	}
	
	//------------------------------------ handlers -------------------------------
	
	//design: maintain page span and margins when resizing windows
	function onResize(){
	
		//you should use window.innerWidth or innerHeight as no CSS is applied to any element. 
		//DO NOT use elements width or height, even though they have width:100%
		var width = window.innerWidth-pageSpan;
		var lastX = pageMargin;
	
		var e = screens.firstChild;

		var firstLeft = parseFloat($('blogPage').style.left || 0);
		if(firstLeft<0) lastX=-width+pageSpan-2*pageMargin;

		while(e){
			if(e.nodeType==1&&e.nodeName=='DIV'){
				e.style.left = lastX+'px';
				
				e.style.width = width+'px';
				lastX += width+pageMargin;
			}
	
			e=e.nextSibling;
		}
	}
	
	//------------------------------------ design workflow -------------------------------
	
	//design: Start panel - show/hide methods
	function hideStart(callback){
		var start = $('startPage');
		new Effect.Move(start, {y:-start.getHeight(),x:0, duration: transitionTime*0.6, transition: Effect.Transitions.exponential, queue:'parallel', mode:'absolute', afterFinish:function(){						
				start.hide();
				if(callback)callback();
		}});
	}
	function showStart(){
		var screens = $('startPage');
		screens.show();
		screens.style.top=-screens.getHeight()+'px';
		new Effect.Move(screens, {y:0,x:0, duration: transitionTime, transition: Effect.Transitions.exponential, mode:'absolute', queue:'end'});
	}
	
	
	//Select next page and do proper effects
	// when finished call callback	
	function selectPage(id, callback){
			if(lastSelectedPage == id) { 
				if(callback) callback();
				return;
			}
			switch(id){
				case 'startPage':
					isInMainScreen = false;
					isInBlog = false;
						if(lastSelectedPage)
							fadeOut($('screens'));
					
						if(lastSelectedPage){
							$('startPage').setOpacity(1);
							showStart();
						}
						else
							fadeIn($('startPage'));
				break;
				
				case 'blogPage':
					isInBlog=true;
					isInMainScreen = true;
						if(lastSelectedPage=='startPage')
						{
							hideStart(function(){
								fadeIn($('screens'));
								slideLeft();
								if(callback) callback();							
							});
						}else if(lastSelectedPage==null){
							//var start = $('startPage');
							//start.style.left = -start.getWidth()+'px';
							fadeIn($('screens'));
							setTimeout(function(){
								slideLeft();
								if(callback) callback();
							}, 0);
						}else{
							slideLeft();
							if(callback) callback();
						}
				break;
				
				case 'photoPage':
					isInBlog = false;
					isInMainScreen = true;
						if(lastSelectedPage=='startPage')
						{
							hideStart(function(){
								fadeIn($('screens'));
								slideRight();
								if(callback) callback();								
							});
						}else{
							slideRight();
							if(callback) callback();
						}
				break;
			
			}
			prevSelectedPage = lastSelectedPage;
			lastSelectedPage = id;
	}

// ================================================================================
// WORKFLOW  	
// ================================================================================

//workflow: show settings modal	
	function showSettings(){
		showModal('settingsScreen');
		esc = closeSettings;
	}
	
	
	//come back from start menu
	//TODO: remove - not used
/*	function backStart(){
		if(prevSelectedPage)
			selectPage(prevSelectedPage);
		else
			gotoBlog();
	}
*/	
	//workflow: go back to start page
	function gotoStartPage(isBack){
		if(config['noShowStart']){
			gotoBlog();
			return;
		}

				
		Bee.Application.acceptDrag = false;
		if(dirty){
			dirtyCallback = gotoStartPage;
			if(!closeCreatePost())  return;
			dirtyCallback = null;
		}
		selectPage('startPage');	
		
	}
	//blog / editing panel - show mothode
	function showBlog(){
		isInBlog=true;
		Bee.Application.acceptDrag = true;
		selectPage('blogPage');
	}
	//workflow: go to blog page
	function gotoBlog()
	{	
		isInBlog=true;
		Bee.Application.acceptDrag = true;
		selectPage('blogPage');
		setBlogState('view', true);
	}
	
	//workflow: goto create/edit panel page
	//use direct to disable effects 
	function gotoCreatePost(direct, id){
		isInBlog=true;
		
		Bee.Application.acceptDrag = true;
			
		
		if(id)
			Bee.Application.loadPost(id);
		else
			Bee.Application.loadNewPost();				
		
		
		if(direct)
			setBlogState('edit', true);
		
		selectPage('blogPage', function(){
			if(!direct)	setBlogState('edit');
		});
	}
	
	//workflow: close current editing post
	function closeCreatePost(callback){
		if(esc) esc();
		selectPage('blogPage');	
		if(dirty){
			if(Bee.Application.navigWindows['post'].post.serverid)
				doConfirm('', lang['DISCARD_CHANGES'], 5, function(e){
						if(e=='yes') e='no';
						 dirtyRead (e); 
						 if(callback) callback();
					});
			else
				doConfirm('', lang['SAVE_POST_DRAFT'], 7, function(e){
					dirtyRead(e);
					if(callback) callback();
					});		
		}
		else
		{
			//	
			setBlogState('view');
		}
		return !dirty;
	
	}
	
	//workflow: change current wordpress account
	function selectBlog(event){
			Bee.Application.navigWindows['blog'].sendCommand('set',{id: new Number(event.target.options[event.target.selectedIndex].value)});
	}
	
	//workflow: close settings modal
	function closeSettings(){
		if(Bee.Application.blogs().length==0){
			if(confirm('You have no WordPress account registered with this application. Bee cannot continue!'))
				Bee.Application.exit();
			else
				return;
		}
		
		closeModal();
	}
	
	var wpInterval = null;
	
	//workflow: show synchronization modal
	function showSync(e){
		
	
		if(e.target){
			if(!isSyncVisible){
				var wpIndex = 0;
				var wpIndexPoints = ['','.','..','...'];
				wpInterval = setInterval(function(){
					if(wpIndex++>=wpIndexPoints.length-1) 
						wpIndex=0;
					$('workingpoints').innerHTML = wpIndexPoints[wpIndex];
				}, 500);
				showModal2('updateScreen');	
				isSyncVisible = true;
			}
			
			$('updateScreen').className = '';
			$('us_err').innerHTML  = '';
			$('us_retry').hide();
			$('us_close').hide();
		}
		
		$('resync').hide();
		isSyncOk = true;
	}
	
	//workflow: hide synchronization modal
	function hideSync(){
		if(isSyncVisible){
			if(wpInterval){
				clearInterval(wpInterval);
				wpInterval = null;
			}
			closeModal2();
			isSyncVisible = false;
			if(isSyncOk)
				$('resync').hide();
			else
				$('resync').show();
		}
					
	}
	//workflow: handles synchronization failure
	function failSync(e){
		isSyncOk = false;
		if(isSyncVisible){
			var err = e.target;
			var errstr = ""; for(var i=0;i<err.length;i++) errstr+=err[i]+'<br />';
			$('updateScreen').className = 'failed';
			$('us_err').innerHTML  = errstr;
			$('us_retry').show();
			$('us_close').show();
		}else
			$('resync').show();
		
		
	}	
	
	//workflow: show hourglass wait modal
	function showHourGlass(){
		oldEsc = esc; esc = null;
		hourglassOn = true;
		var hg = $('hourglass');
		hg.show();
		hg.setOpacity(0.2);
		new Effect.Opacity(hg, {to:0.7, duration:0.4});
		var wpIndex = 0;
		var wpIndexPoints = ['&nbsp;','.','..','...', '....', '.....'];
		wpInterval = setInterval(function(){
			if(wpIndex++>=wpIndexPoints.length-1) 
				wpIndex=0;
			$('hourglasspoints').innerHTML = wpIndexPoints[wpIndex];
		}, 500);
	}
	
	//workflow: hide hourglass wait modal
	function hideHourGlass(){
		if(wpInterval){
			clearTimeout(wpInterval);
			wpInterval = null;
		}
		esc = oldEsc; oldEsc = null;
		hourglassOn = false;
		var hg = $('hourglass');
		new Effect.Opacity(hg, {to:0.7, duration:0.1, afterFinish:function(){ hg.hide(); }});
	}


	//workflow: goto Photo view page
	function gotoPhoto(){
		Bee.Application.acceptDrag = true;
		selectPage('photoPage');
		
	}
		
	//workflow: as long as blog view and post edit go in the same DIV 
	//          we should change that when switching views
	//		fast means no effect is applied
	function setBlogState(state, fast){
		if(state=='view'){
			Bee.Application.disableModalMenu(true);
			
			Bee.Application.navigWindows['post']=null;
			if(fast){
				$('blogViewSubPage').show(); $('blogViewSubPage').setOpacity(1);
				$('blogEditSubPage').hide(); $('blogEditSubPage').setOpacity(0);
			}else{
				fadeOut($('blogEditSubPage'));	
				fadeIn($('blogViewSubPage'));
			}
			dirty=false;
			$('bp_blogSelector').disabled=false;
		}else{
			Bee.Application.disableModalMenu(false);
			
				$('bp_blogSelector').disabled=true;
				dirty = false;
			if(Bee.Application.navigWindows['post'])
				Bee.Application.navigWindows['post'].onshow();
			if(fast){
				$('blogViewSubPage').hide(); $('blogViewSubPage').setOpacity(0);
				$('blogEditSubPage').show(); $('blogEditSubPage').setOpacity(1);
			}else{
				fadeOut($('blogViewSubPage'));
				fadeIn($('blogEditSubPage'));		
			}
//			$('pp_title_txt').focus();
			$('pp_title_txt').select();
		}
		
	}
	
	//workflow : show  upload modal dialog
	function showUpload(){
		if(!uploadVisible){
			
			if( !Bee.Services.Photo.Flickr.loggedIn ){
				alert('Upload disabled. Add your Flickr account first.');
				Bee.Application.clearUploadFiles();
				showSettings();
				return;	
			}
			
			dsUpload.setDataFromArray([]);
				$('ups_upload').disabled=true;
				//$('ups_close').disabled=false;
				//$('ups_close').value = "Close";
				$('ups_browse').disabled=false;
					showModal('uploadScreen');
					esc = closeUpload;
					Bee.Application.acceptDrag = true;
					uploadVisible=true;
		}
	}
	//workflow : hide upload modal dialog
	function closeUpload(){
		if(shouldCancelUpload){
			$('ups_close').disabled = true;
			Bee.Application.cancelUpload = true;
			return;	
		}
		if(!uploadVisible) return;
		closeModal();
		uploadVisible=false;
		Bee.Application.clearUploadFiles();
	}
	
	
	//worflow: browse local file and get it in upload list
	var lastOpenedDir = null;
	function doFileBrowse(){
		if(!lastOpenedDir)
			lastOpenedDir = air.File.desktopDirectory;
		
		lastOpenedDir.addEventListener(air.FileListEvent.SELECT_MULTIPLE , filesSelected);
		var imagesFilter = new air.FileFilter(lang["IMAGES"], "*.jpg;*.gif;*.png;*.tif;*.tiff;*.bmp");
		lastOpenedDir.browseForOpenMultiple('Select pictures', [imagesFilter]);
		
	}
	
	//workflow: upload selected files to flickr
	function doUpload(){
		//$('ups_close').disabled=true;
		//$('ups_close').value = "Cancel";
		shouldCancelUpload = true;
		$('ups_upload').disabled=true;
		$('ups_browse').disabled=true;
		
		var data = dsUpload.getData();
		
		var files = [];
		for(var i =0;i<data.length;i++){
			data[i].title= $('ud_title'+i).value;
			data[i].description= $('ud_mdesc'+i).value;
			if(data[i].description==lang['CLICK_TO_ADD_DESCRIPTION'])
				data[i].description = '';
			files.push(data[i]);
		}
		
		Bee.Application.doUploadFiles(files, isInBlog);
		
	}
	
	
	function showPreview(){
		showModal('previewScreen');
		esc = closePreview;
	}

	function closePreview(){
		closeModal();
	}

	
// ================================================================================
// CALLBACKS  	
// ================================================================================
//callback: doConfirm response for saving changes when closing
	function dirtyRead(ret){
		switch(ret){
			case 'cancel':
				dirtyCallback = null;
				return;
			break;	
			case 'yes':
				Bee.Application.navigWindows['post'].sendCommand('save');
			break;
			case 'no':
			break;
		}
		
		dirty=false;
				
		if(dirtyCallback)
			setTimeout(function(){ setBlogState('view', true);  }, transitionTime*2000.00);
		else				
			setBlogState('view');
		
		if(dirtyCallback) dirtyCallback();
		dirtyCallback = null;
	}
	
	//callback: fired when filters are shown
	function showFilters(){
		var search = Bee.Application.navigWindows['blog'].search;
		if(!search) search = '';
		$('bp_searchBox').value = search;
		$('bp_searchBox').focus();
	}
	
	//callback: after selecting a filter hide spry menubar
	function hideFilters(){
		MenuBar1.clearMenus($('bp_categories'));
	}
	
	//callback: received status information from flickr Uploader
	var uploadVisible = false;
	function setUploadStatus(e){
		var args = e.args;
		if(args.progress){
			
			Bee.Application.acceptDrag = false;
					/*	if(!uploadVisible){
							showModal('uploadScreen');
							uploadVisible=true;
						}*/		
			document.getElementById('prgbar').style.display="block";
			document.getElementById('dragSmt').style.display="none";
			document.getElementById('uploadStatus').style.display="block";
			document.getElementById('uploadStatus').innerHTML = 
					lang['UPLOADING_FILE'].replace('{s1}', (args.files+1)).replace('{s2}', args.total).replace('{s3}', args.fileName);
					//			"Uploading file "+(args.files+1)+" of "+args.total + " - " + args.fileName;
			document.getElementById('bar').style.width=args.value+"%";
			
		}else if(args.complete||args.error){
			shouldCancelUpload = false;
			if(args.error){
				//todo: add revert option
				alert(args.error);
				
			}
			$('ups_close').value = 'Close';
			if(uploadVisible){
				closeUpload();
				
			}
			Bee.Application.clearUploadFiles();
			
			document.getElementById('prgbar').style.display="none";
			document.getElementById('dragSmt').style.display="block";
			document.getElementById('uploadStatus').style.display="none";
		}else if(args.cancel){
			shouldCancelUpload = false;
			$('ups_close').disabled = false;
//			$('ups_close').value = 'Close';
			if(uploadVisible){
				closeUpload();
				
			}
			Bee.Application.clearUploadFiles();
			document.getElementById('prgbar').style.display="none";
			document.getElementById('dragSmt').style.display="block";
			document.getElementById('uploadStatus').style.display="none";
			
		}
		
				
				
	}
	
	//callback: from files browse dialog (inserts files in upload dialog)
	function filesSelected(e){
		if(e.files&&e.files.length){
			Bee.Application.doDragFiles(e.files);
			lastOpenedDir = e.files[0].resolvePath('../');
		}
		lastOpenedDir.removeEventListener( air.FileListEvent.SELECT_MULTIPLE , arguments.callee);
	}
	
	//--------------------------------- workflow handlers ---------------------------
	
	
	// Spry uses eval() function to parse expressions and eval is disabled in order to maintain
	// security. 
	// 
	// In order to maintain some of the spry funcs I've added a new tag in spry: spry:command
	// which adds a new event listener on the element onclick event which fires this doCmd function 
	// arguments: event is spry:command value
	//            target is clicked element
	//
	// fired every time a spry node that has spry:command attribute is clicked 
	function doCmd(event, target){
		
		switch(event.substring(0,2)){
			
			case 'bp':
				//extract clicked element post ID or category ID
				var idNode = target.attributes.getNamedItem('postId');
				if(!idNode) idNode = target.attributes.getNamedItem('catId');
					var id = null;
					if(idNode)
						id = new Number(idNode.value);

				switch(event){
					case 'bp_preview':
						Bee.Application.navigWindows['blog'].sendCommand('preview', {id:id});
					break;	
					case 'bp_edit':
						gotoCreatePost(false, id);
					break;		
					case 'bp_delete':
						Bee.Application.navigWindows['blog'].sendCommand('delete', {id:id});
					break;
					case 'bp_cat':
						Bee.Application.navigWindows['blog'].sendCommand('filter', {id:id});
						
						hideFilters();
						break;
					case 'bp_reset':
						Bee.Application.navigWindows['blog'].sendCommand('filter',{id:-1});
						break;			
				}
			break;
			
			case 'fp':
				var idNode = target.attributes.getNamedItem('photoId');
				var id = null;
				if(idNode){ 
					id = idNode.value;
				}
				switch(event){
					case 'fp_loadPhotoset':
						var idNode = target.attributes.getNamedItem('photosetId');
						var id = null;
						if(idNode){ 
							id = idNode.value;
						}
						Bee.Application.navigWindows['photo'].sendCommand('loadPhotoset', {id: id, pageNo: 1});
						break;		
					
					case 'fp_loadPhoto':
						Bee.Application.navigWindows['photo'].sendCommand('loadPhotoPreview', {id: id});
						break;
					
					case 'fp_deletePhoto':
						Bee.Application.navigWindows["photo"].sendCommand("deletePicture", {id: id});
						break;
						
					case 'fp_blogPhoto':
						Bee.Application.navigWindows["photo"].sendCommand("insertPicture", {id: id});
						break;
						
					case 'fp_acc_goToPage':
						var nrNode = target.attributes.getNamedItem('pageNumber');
						var nr = null;
						if(nrNode){ 
							nr = nrNode.value;
						}
						pgFlickrPhotos.goToPage(nr);
						break;
								
					case 'fp_src_goToPage':
						var nrNode = target.attributes.getNamedItem('pageNumber');
						var nr = null;
						if(nrNode){ 
							nr = nrNode.value;
						}
						pgFlickrSearchPhotos.goToPage(nr);
					break;
					case 'fp_searchFirstPage':
						Bee.Application.navigWindows['photo'].sendCommand("search", { pageNo: 1});
					break;
					case 'fp_searchFirstPublicPage':
						Bee.Application.navigWindows['photo'].sendCommand("searchFirstPublicPage", {});
					break;
					case 'fp_prevPhotosetPage':
						pgFlickrPhotosets.previousPage();
					break;
					case 'fp_nextPhotosetPage':
						pgFlickrPhotosets.nextPage();
					break;
				}
			break;
			
			case 'pp':
				var idNode = target.attributes.getNamedItem('catRow');
				var id = null;
				if(idNode)
					id = new Number(idNode.value);		
						switch(event){
							case 'pp_cat':
								var data = dsBlogCats.getData();
								if(data&&data.length){
									var cat = data[id];

									if(Bee.Application.navigWindows['post'].cats[cat.id])
										delete Bee.Application.navigWindows['post'].cats[cat.id];
									else
										Bee.Application.navigWindows['post'].cats[cat.id]=cat;
									
									var isEmpty = true;
									for(var i in Bee.Application.navigWindows['post'].cats){
										isEmpty = false;
										break;
									}
									
									if(isEmpty){
										var cats = dsBlogCats.getData();
										if(cats.length){
											for(var i=0;i<cats.length;i++)
												if(cats[i].name=='Uncategorized')
												{
													isEmpty=false;
													Bee.Application.navigWindows['post'].cats[cats[i].id]=true;
													break;
												}
											if(isEmpty)
												Bee.Application.navigWindows['post'].cats[cats[0].id]=true;
										}
									}
										
									Spry.Data.updateRegion('pp_cats');
									dirty = true;
								}
								//hideCategories();
								break;
						}
				break;
			
			case 'sp':
				var idNode = target.attributes.getNamedItem('accId');
				
				var id = null;
				if(idNode)
					id = new Number(idNode.value);		
					if(!id) return;
					switch(event){
						case 'sp_edit':
								Bee.Application.navigWindows['settings'].sendCommand('edit', id);
						break;
						case 'sp_delete':
								Bee.Application.navigWindows['settings'].sendCommand('delete', id);
						break;
						case 'sp_template':
								Bee.Application.navigWindows['settings'].sendCommand('template', id);
						break;
					}
			break;
			
			case 'ud':
				var idNode = target.attributes.getNamedItem('rowId');
				var id = null;
				if(idNode)
					id = new Number(idNode.value);		
				switch(event){
					case 'ud_clear':
						if(target.value==lang['CLICK_TO_ADD_DESCRIPTION'])
							target.value = '';
						break;
					case 'ud_remove':
						var data = Bee.Application.uploadFiles;
						
						for(var i =0;i<data.length;i++){
							data[i].title= $('ud_title'+i).value;
							data[i].description= $('ud_mdesc'+i).value;
						}
						
						data.splice(id, 1);

						dsUpload.setDataFromArray(data);
						
						$('ups_upload').disabled = data.length==0;
						break;
				
				}
			break;
			
			
		}
		
	}
// ================================================================================
// UTILS  	
// ================================================================================

	//open external browser and point it to url
	function gotoBrowserWindow(url)
	{
		air.navigateToURL( new air.URLRequest( url ), "_blank" );

		$('sp_wpOr').innerHTML = lang['TELL_ME'];
		$('sp_wpOr').className='created';
	}
	
	//utils: show modal confirm box 
	//use bit mask to hide buttons (1 for yes, 2 for no and 4 for cancel)
	//callback receives a string with button name : 'yes', 'no', 'cancel'
	function doConfirm(title, message, buttons, callback){
	
		$('us_title').innerHTML = title;
		$('us_message').innerHTML = message;
		
		//to add a new button follow the steps below
		$('dirty_yes').style.display=(buttons&1)?'block':'none';
		$('dirty_no').style.display=(buttons&2)?'block':'none';
		$('dirty_cancel').style.display=(buttons&4)?'block':'none';
		$('dirty_ok').style.display=(buttons&8)?'block':'none';		
		// step 1: copy the line above and change $('dirty_cancel') to appropiate element id
		//		   and change 4 to 8 (use power of 2)
		$('dirty_yes').onclick = function(){
			doConfirmVisible = false;
			closeModal2();
			if(callback)callback('yes');
			
		}
		
		$('dirty_no').onclick = function(){
			doConfirmVisible = false;
			closeModal2();
			if(callback)callback('no');

		}
		
		$('dirty_cancel').onclick = function(){
			doConfirmVisible = false;			
			closeModal2();
			if(callback)callback('cancel');
		}
		
		$('dirty_ok').onclick = function(){
			closeModal2();
			doConfirmVisible = false;			
			if(callback)callback('ok');
		}
		// step 2: copy the block above and change $('dirty_cancel') to the same elmenent id
		//		   change callback('cancel') to callback('your_cmmand') 
		// step 3: go to HTML and make a copy of div#dirty_cancel
		
		showModal2('dirtyScreen');
	
		doConfirmVisible = true;
	
		esc = function(){
			//throw cancel
			if(buttons&4)  $('dirty_cancel').onclick();
			//throw no
			else if(buttons&2) $('dirty_no').onclick();
			//throw ok
			else if(buttons&8) $('dirty_ok').onclick();
		}
	}
	
	
	
	//util:  used for debuging 
	function printR(e){		
		var str=""; for(var i in e) try{ str+=i+"="+e[i]+"\n"; } catch(e){ str+=i+"=<error>\n"; } 
		//TODO: disable in order to disable output
	}
	
// ================================================================================
// APPLICATION START  	
// ================================================================================
	
	
	// Load everythink, hide modals, attach resize handler start sync
	// First stage : used to render everything before HTML control is visible to the user
	// 	             splash screen is shown while running first stage
	function doLoad(){
		$('startPage').setOpacity(0);
		$('startPage').hide();
		$('screens').hide();
		$('screens').setOpacity(0);
		$('shadow').setOpacity(0);
		$('modal').setOpacity(0);
		$('shadow').hide();
		$('modal').hide(); 
		$('modal2').hide(); 
		$('modal2').setOpacity(0);
		$('resync').hide();
		
		$('hourglass').hide();
		
		setBlogState('view', true);
		window.onresize = onResize;
		
		onResize();
		hideModals();
		hideModals2();
		
		//if ( config['noShowStart'] ){
		//	showBlog();	
		//}
		//else{
			gotoStartPage();
		//}

		//TODO: removed since we use just one window
		Bee.Window = window;
		
		
		//attach handlers to catch sync start and stop
		Bee.Core.Dispatcher.addEventListener(Bee.Events.DOSYNC, showSync );
		Bee.Core.Dispatcher.addEventListener(Bee.Events.SYNC_FINISHED, hideSync );
		Bee.Core.Dispatcher.addEventListener(Bee.Events.SYNC_FAILED, failSync );
		
		//TinyMCE uses eval() function so put it in a DownPrivileged iframe
		//in order to get and set content to TinyMCE use bridge object
		$('pp_content_txt').contentWindow.parentSandboxBridge = {
			trace:function(e){ air.trace(e);},  //used for debuging
			
			//let us know when user changes content
			changed : function(){
				dirty = true;
			},
			//handle insert image toolbar icon 
			insertImage: function(){
				gotoPhoto();
			},
			
			insertReadMore : function(){
				$('pp_content_txt').contentWindow.childSandboxBridge.addElement(moreBar);
			}
		};

		//disable dragging in start screen
		enableDrag(false);
		Bee.Core.Dispatcher.addEventListener(Bee.Events.NATIVE_DRAG_ENTER, function(){ if(enableDrag) enableDrag(true); });
		Bee.Core.Dispatcher.addEventListener(Bee.Events.NATIVE_DRAG_EXIT, function(){ if(enableDrag) enableDrag(false); });
		
		//reset uploader screen uploadstatus 
		
		Bee.Core.Dispatcher.addEventListener(Bee.Events.UPLOAD_STATUS, setUploadStatus);
				
		$('prgbar').style.display=  'none';
		
		$('sp_noShowStart').checked = config['noShowStart'] ? true : false; 
		$('ss_noShowStart').checked = config['noShowStart'] ? true : false; 
		$('sp_noShowTips').checked = config['noShowTip'] ? true : false; 
		$('sp_noMinimize').checked = config['noMinimize'] ? true : false; 
		
		//catch esc key
		document.addEventListener('keydown', 
			function(e){
//				air.trace('===========================');
//				print_o(e, 'write');	
				switch(e.which){
					case 27:
						if(esc) esc();
					break;
					case 37:	
						if(e.srcElement instanceof HTMLInputElement) return;
						
						if(isInBlog==false&&isInMainScreen)
							gotoBlog();
							break;
					case 39:
						if(e.srcElement instanceof HTMLInputElement) return;
					
						if(isInBlog==true&&isInMainScreen)
							gotoPhoto();
							break;
						break;
				}
		}, true);
	}
	
	//used to let HTML render something before waiting some servers commands
	//second stage HTML loading 	
	function afterDoLoad(){
		Bee.Application.navigWindows['blog'].sendCommand('refresh');
		Bee.Application.navigWindows['photo'].sendCommand('doInit');
		var blogs = Bee.Application.blogs();
		if(blogs.length==0){
			showModal('settingsScreen');
			Bee.Application.navigWindows['settings'].sendCommand('add', 'wordpress');
		}else
			setTimeout(function(){
																//command // noshowsync
				Bee.Core.Dispatcher.dispatch(Bee.Events.DOSYNC, false, true); 
			}, 0);
	}

// ================================================================================
// DRAGGING  	
// ================================================================================

	
	function enableDrag(ok){
		var dropBox = $('dropBox');
		$('dropBox').style.visibility=ok?"visible":"hidden";
		$('dropBox').style.left = ok?"0px":"-16000px";
	}
	
	//fired when search is clicked in photo page
	//get search results from flickr
	function searchFlickr(){
		var text = Bee.Window.$('fp_searchInput').value;
		if (text.length == 0)
			return false;
		Bee.Application.navigWindows['photo'].sendCommand('search', text);
	}
	
	
	
	
	//dragging
	

var DropFiles = [];
			

//prevent default handler on drag enter
// TODO: check file type before sending it to UPLOAD			
function doDragEnter(event)
{
	// this handler acts as the receiver
	event.preventDefault();
}
function doDragOver(event)
{
	// this handler acts as the receiver
	event.preventDefault();
}
function doDragLeave(event)
{
	event.preventDefault();
}

function doDrop(event)
{
  var fileList = event.dataTransfer.getData("application/x-vnd.adobe.air.file-list");
  //var canvas = event.dataTransfer.getData("image/x-vnd.adobe.air.bitmap");
  //var uriList = event.dataTransfer.getData("text/uri-list");
  Bee.Application.doDragFiles(fileList);
}

function doDragEnd(event)
{
}			
	

	
			
// ================================================================================
// SPRY evals  	
// ================================================================================


//spry uses eval() to parse expressions
//spry_eval.js hacks spry a little bit by overriding eval()
//use it like this spry:if="$funcname({dsName::field})"

function havePhotosetPrevPage(){
	return pgFlickrPhotosets.getCurrentPage() > 1;
}
function havePhotosetNextPage(){
	return pgFlickrPhotosets.getCurrentPage() < pgFlickrPhotosets.getPageCount();
}

function haveNoPhotos(){
	return (Bee.Application.navigWindows['photo'].currentSearch.totalPages <= 0);
}

function havePublicPhotos(){
	var data = dsFlickrSearchPhotos.getData();
	if(data&&data.length){
		return(data[data.length-1].divClass != 'fp_s_photo_mine');
	}
	return false;
}

function haveMyPhotos(){
	var data = dsFlickrSearchPhotos.getData();
	if(data&&data.length){
			return(data[0].divClass=='fp_s_photo_mine');
	}
	return false;
}

function havePagedMyPhotos(){
	if(haveMyPhotos()) return false;
	return (Bee.Application.navigWindows['photo'].currentSearch.myTotal > 0);
}

function havePagedPublicPhotos(){
	if(havePublicPhotos()) return false;
	return (Bee.Application.navigWindows['photo'].currentSearch.publicTotal > 0);
}

function isPostCat(cat){
	var cat = new Number(cat);
	if(Bee.Application.navigWindows['post']&&Bee.Application.navigWindows['post'].cats[cat]) 
		return true;
	return false;
}

function hasResults(){
	var data = dsBlogPosts.getData();
	return (data&&data.length&&data.length>0);
}