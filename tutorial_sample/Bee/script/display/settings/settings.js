/*
ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.
 
NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the 
terms of the Adobe license agreement accompanying it.  If you have received this file from a 
source other than Adobe, then your use, modification, or distribution of it requires the prior 
written permission of Adobe.

*/

//REGEXP 
//to check url
var urlChecker = /(?:http|https):\/\/(?:www.)?(?:(?:[\w-]+\.)*[\w-]+\.[\w]{2,6}|(?:[\w-]+\.?))(?:\:\d{1,5})?(?:\/(?:(?:[\w.-]|(?:\%[A-Z0-9]{2}))+\/?)+)?/gi;
//to trim strings
var trimmer  = /^\s+|\s+$/gi ;

Bee.Display.Settings.Main = function(){
	 Bee.Display.Window.prototype.constructor.call(this, 'Settings', 'assets/html/settings/main.htm',  64);
	 //this.navig = true;
	 this.firsttime = true;
	 
	 this.account = null;
	 
	 var _this = this;
	 
	 
	 Bee.Core.Dispatcher.addEventListener(Bee.Events.SETTINGS_REFRESH, function(){
	 	_this.refresh();
	 });
}
 

Bee.Display.Settings.Main.prototype = new Bee.Display.Window();

Bee.Display.Settings.Main.prototype.refresh = function()
{
	
//		var xmlRpc = imprt("xmlrpc");
		
		/*$('sp_wp_frmedit').style.display="none";
		$('sp_fr_add').style.display="none";
		*/
		
		var services = Bee.Storage.Db.Accounts.getServices();
		
		
		var wp = [];
		var flickr = [];
		
		for(var i=0;i<services.length;i++){
			var service = services[i];
			var accounts = Bee.Storage.Db.Accounts.getAccountsByService(service.id);
			var classType = service['class'];
			
			for(var j=0;j<accounts.length;j++){
				var account = accounts[j];
				switch(service['class']){
					case 1:
						var blogs = Bee.Storage.Db.Blog.getBlogs(account.id);
						var blog = blogs[0];
						var blogRules = xmlRpc._unmarshall(blog.rules);
						account.site = blogRules.blogApiAccessPoint;
						wp.push(account);
					break;
					case 2:
						flickr.push(account);
					break;
				}
			}
			
		}
		
		
		dsWordPress.setDataFromArray(wp, false);
		dsFlickr.setDataFromArray(flickr, false);

		
	/*	var mstr = "Your accounts:<br />";
		var srvtype = "";
		
		
		var services = Bee.Storage.Db.Accounts.getServices();
		
		
		for(var i=0;i<services.length;i++){
			var service = services[i];
			var accounts = Bee.Storage.Db.Accounts.getAccountsByService(service.id);
			var classType = service['class'];
			
			srvtype+="<input type='radio' id='class' name='class' value='"+classType+"' />"+service.name+"<br />";
		
			for(var j=0;j<accounts.length;j++){
				var account = accounts[j];
				switch(service['class']){
					case 1:
						mstr+="Wordpress account: "+account.title+" - <input type='button' id='edit"+account.id+"'  value='edit' /> <input type='button' id='delete"+account.id+"' value='remove' /> <input type='button' id='template"+account.id+"'  value='template' /> <br />";
					break;
					case 2:
						mstr+="Flickr account: "+account.title+" - <input type='button' id='delete"+account.id+"' value='remove' /><br />";
					break;
				}
			}
			
		}
		
		$("serviceTypeContainer").innerHTML = srvtype;
		
		$('sp_accounts').innerHTML = mstr;
		
		
		for(var i=0;i<services.length;i++){
			var service = services[i];
			var accounts = Bee.Storage.Db.Accounts.getAccountsByService(service.id);
			for(var j=0;j<accounts.length;j++){
				var account = accounts[j];
				this.setEditCommand($("edit"+account.id), account.id );
				this.setDeleteCommand($("delete"+account.id), account.id );
				this.setTemplateCommand($("template"+account.id), account.id );
			}
		}
		*/
		
		
}


Bee.Display.Settings.Main.prototype.onshow = function(){
	if(this.firsttime){
		this.refresh();		
		this.firsttime = false;
	}
}

///----------------------------------------------------------------------
///TEMPLATE functions

Bee.Display.Settings.Main.prototype.getTemplate =  function(id, callback){
		//var blogs = Bee.Storage.Db.Blog.getBlogs(id);
		//var blog = blogs[0];
		var blog = {id:id};
		var i = Bee.Application.blog_services_hash[blog.id];
		var blogObj = Bee.Application.blog_services[i];
		showHourGlass();
		blogObj.isConnected(function(ok){
			if(!ok){
			 hideHourGlass();
			 return;
			}
			var irnd = Math.random();
			var post = {title:'{testTitle_'+irnd+'}', content:'{testContent_'+irnd+'}', isdraft:false, date:new Date("1/1/1997")};
						
			blogObj.newPost(post, function(result, err){
				
				if(err) return;
	
				var postId = result;
				var url = blogObj.blogRules.blogApiAccessPoint.replace('xmlrpc.php', '?p='+result);
				
				//var urlError = blogObj.blogRules.blogApiAccessPoint.replace('xmlrpc.php', '?p='+(new Number(result)+1000).toString());
				
				var atom = new Bee.Net.AsyncAtom();
				atom.addHandler('completeUrl', function(obj){ 
				this.postTemp = obj.data ; });
				
				//atom.addHandler('completeError', function(obj){ this.postError = obj.data; });

				var loaderUrl = new air.URLLoader();
				loaderUrl.addEventListener(air.Event.COMPLETE, atom.getHandler('completeUrl', loaderUrl));
				loaderUrl.load(new air.URLRequest(url));

				/*var loaderError = new air.URLLoader();
				loaderError.addEventListener(air.Event.COMPLETE, atom.getHandler('completeError', loaderError));
				loaderError.load(new air.URLRequest(urlError));
				*/
				
				atom.onfinish = function(){	
					try{
					var domParser = new HTMLParser();
					var parseAtom = new Bee.Net.AsyncAtom();
					var xmlPost = null;
					var xmlError = null;
					parseAtom.addHandler('postTemp', function(obj,e){
						// in AIR 1.5, a DOCUMENT_TYPE_NODE is the first child
						for (var i=0;i<e.childNodes.length;i++)
						{
						  var child = e.childNodes[i]; 
						  if (child.nodeType != 1 /* ELEMENT_NODE */) continue;
							xmlPost = child;
						}
					});
				/*	parseAtom.addHandler('postError', function(obj, e){
						xmlError = e.firstChild;
					});*/
					this.postTemp = this.postTemp.replace(/(?:<script.*?>)((\n|\r|.)*?)(?:<\/script>)/ig, '');
					domParser.parseFromString(this.postTemp, parseAtom.getHandler('postTemp'));
					//domParser.parseFromString(this.postError, parseAtom.getHandler('postError')); 
					
					parseAtom.onfinish = function(){
						blogObj.deletePost(post.serverid, function(){});	
						
						///stripping
						xmlPost.ownerDocument.body.setAttribute('onload',"return false;");
						var tags = xmlPost.ownerDocument.getElementsByTagName('*');
						for(var z=0;z<tags.length;z++){
						
							if(tags[z].onclick)	tags[z].onclick = "";
							
							if(tags[z].nodeName.toLowerCase()=='a'&&
									tags[z].href) tags[z].href = "";
							if(tags[z].nodeName.toLowerCase()=='script'){
								tags[z].parentNode.removeChild(tags[z]);
							}
						
							if(tags[z].nodeName.toLowerCase()=='form'){
								tags[z].action="";
								tags[z].setAttribute('onsubmit',"return false;");
							}
						}
						/*
						//Here I tried to get exactly the post but feature dropped because
						 * it is pretty useless when blog uses some unusual layouts like
						 * headings and backgrounds or floats. 
						 * /
						
						var nodeRoute = findInDom(xmlPost, post['title']);
							if(nodeRoute)
								nodeRoute = nodeRoute.reverse();

						var nodeContent = findInDom(xmlPost, post['content']);
							if(nodeContent) 
								nodeContent = nodeContent.reverse();
						
						
						var neededElements = [];
						for(var z=0;z<nodeContent.length;z++) neededElements.push(nodeContent[z]);
						for(var z=0;z<nodeRoute.length;z++) neededElements.push(nodeRoute[z]);
							
						nodeRoute.pop();
						nodeContent.pop();

						
						var l = nodeRoute.length>nodeContent.length?nodeContent.length:nodeRoute.length;
					
						var  e = xmlError;
						for(var i=0;i<l;i++){
							e = getSameElem(e, nodeRoute[i].elem, nodeRoute[i].pos);
							if(e==null)
								break;
							e=e.firstChild;
						}
						
						for(var i=0;i<l;i++)
							if(nodeRoute[i].elem!=nodeContent[i].elem) break;
						i--;
						*/
						try{
							//var postElem = nodeRoute[i].elem.outerHTML;
							
						
							
							//clearElement(nodeRoute[i].elem.parentNode, neededElements);
						/*	var tags = xmlPost.ownerDocument.body.getElementsByTagName('*');
							
							for(var z=0;z<tags.length;z++){
								var tag = tags[z];
								var found = false;
								for(var i=0;i<neededElements.length;i++)
									if(neededElements[i].elem==tag){
										found=true;
										break;
									}
								if(tag.parentNode&&!found)
										tag.parentNode.removeChild(tag);
							}*/
							
							
							//BOG: you should use xmlPost: this is post DOM
							air.info('creating dir');
							//var traceDirRef = air.File.createTempDirectory();
							var templateNumber = blog.id*100; 
							var traceDirRef = air.File.applicationStorageDirectory.resolvePath('template'+templateNumber);
							
							while(traceDirRef.exists){
								templateNumber++;
								traceDirRef = air.File.applicationStorageDirectory.resolvePath('template'+templateNumber);
							}
							traceDirRef.createDirectory();
							air.info('dir created: '+traceDirRef.nativePath);
							var sw = new modSaveWebPage(blogObj.blogRules.blogApiAccessPoint.replace('xmlrpc.php',''), traceDirRef, xmlPost, function(){
								air.info('saved web');
								var saveBlogBasePath = traceDirRef.resolvePath('index.html').nativePath;
								config['previewPath'+blog.id] = saveBlogBasePath;
								config['previewTitle'+blog.id] = post['title'];
								config['previewContent'+blog.id] = post['content'];
								air.info('contentSaved');
								
								hideHourGlass();	
								if(callback) callback();
							});
						}catch(e){
							air.error(e);
						}
						
					}
					parseAtom.finish();
					}catch(e){ air.error(e); }
		};		
		atom.finish();
	});
});

}

function clearElement(parent_elem, child_elems){
	var e = parent_elem.firstChild;
	while(e){
		var n = e.nextSibling;
		var found = false;
		
		for(var i=0;i<child_elems.length;i++)
			if(child_elems[i].elem==e){
				found=true;
				break;
			}
				
		if(!found)
			parent_elem.removeChild(e);
			
		e=n;
	}

	if(parent_elem.nodeName.toLowerCase()=='body')
		return;
	if(parent_elem.parentNode)
		clearElement(parent_elem.parentNode, parent_elem);
}

function attributes(e){
	
	var str = "";
	for(var i=0;i<e.attributes.length;i++){
		str+=" "+e.attributes[i].name+"='"+e.attributes[i].nodeValue.replace("'", "\'")+"'";
	}
	return str;
}

function findInDom(e, str){
	var i = 0;
	while(e){
		switch(e.nodeType){
			case 1:
				if(e.firstChild) {
					var result =  findInDom(e.firstChild, str);
					if(result!=null){
						result.push({elem:e, pos:i});
						return result;	
					}
				}
			break;
			case 3:
				if(e.nodeValue.indexOf(str)!=-1&&e.parentNode.nodeName.toLowerCase()!='title'){
					//found key & return
					return [];
				}
			break;
		}
		i++;
		e=e.nextSibling;
	}
	
	return null;
	
}

function checkAttributes (node, like){
	for(var i=0;i<like.attributes.length;i++){
		var aname  = like.attributes[i].name;
		if((typeof (node.attributes.getNamedItem(aname)))=='undefined') return false;
		if( node.attributes.getNamedItem(aname).value !=  like.attributes[i].value) return false;
	}
	return true;
}

function getSameElem(e, like, pos){
	for(var i=0;i<pos;i++) {
		if(e)
			e=e.nextSibling;
		else
			break;			
	}
	if(e){
		if(e.nodeName!=like.nodeName) return null;
		if(!checkAttributes(e, like)||!checkAttributes(like, e)) return null; 
	}
	return e;
}

function checkUrl(str){
			var matches = str.match(urlChecker);
			if(matches&&matches.length==1) {
				if(matches[0].length==str.length-1){
					return str[str.length-1]=='/';			
				} else {
					
					if(str.length > matches[0].length){
						var xmlrpc = /.*xmlrpc\.php$/g;
						if(str.search(xmlrpc) > matches[0].length - 1)
							return true;
					}
					
					return matches[0]==str;
				}
			}
			return false;
		}
		
//check that we add a new accesspoint
function checkNewAccessPoint(url){
	var blogs = Bee.Application.blogs();
//	var xmlRpc = imprt("xmlrpc");
	
	for(var i=0;i<blogs.length;i++)
		{
			try{
				var blogRules = xmlRpc._unmarshall(blogs[i].rules);
				if(blogRules.blogApiAccessPoint==url) return false;
			}catch(e){
				
			}
			
		}
	return true; 
}
//main command control
Bee.Display.Settings.Main.prototype.sendCommand = function (command, obj, callback){
		 		
		 	switch(command){
		 		case 'add':
		 					
					this.lastConfirm = 'confirmadd';
					if (obj != null && obj != undefined){
					
						switch (obj ){
							case 'wordpress':
							
							
								if(Bee.Application.navigWindows['post']){
					 				doConfirm('', 'You are editing a post and WordPress-related settings are disabled!', 8);
				 					return;
			 					}
			 					
			 					$('frmEditAccounTitle').innerHTML = lang['SETTINGS_SPAN_ACCINFOLABEL_ADD'];
								$('sp_wpInfo').innerHTML = lang['SETTINGS_DIV_WP_INFO_ADD'];
								$('sp_wpCreate').show();
								$('sp_wpOr').show();
							
								$('sp_wpOr').innerHTML = lang['BEE_JUST_TELLME_EXISTING_BLOG'];
								$('sp_wpOr').className = "";
		
								$('sp_addCmd').style.display = "";
								$('sp_saveCmd').style.display = "none";
							
								$('sp_user').value = '';
								$('sp_password').value ='';
								$('sp_accesspoint').value = 'http://';
								$('sp_title').value = 'My blog';
								$('sp_wp_frmedit').style.display = "block";
							break;
						
							case 'flickr':
								$('sp_fr_add1').style.display = "";
								$('sp_fr_add2').style.display = "none";
								
								$('sp_fr_continueCmd').disabled = false;
								$('sp_fr_continueCmd').style.display = "";
								
								$('sp_fr_finishCmd').style.display = "none";
								$('sp_fr_add').style.display = "block";
							break;
						}
					}	
					
				break;
				
				case 'confirmadd':
//					var xmlRpc = imprt("xmlrpc");
					
					var service = Bee.Storage.Db.Accounts.getService(1);
					
					var user = $('sp_user').value;
					var password = $('sp_password').value;
					var accesspoint  = $('sp_accesspoint').value.replace(trimmer, '');
					var title =  $('sp_title').value.replace(trimmer, '');
					if(!checkUrl(accesspoint)){
						alert('Blog address is invalid. Check blog address!');
						return;
					}
					if(!checkNewAccessPoint(accesspoint))
					{
						alert(lang['BLOG_INVALID']);
						return;
					}
					var account = {title : title, idsrv:1, rules:''};
					
					var rules = {user:user,  blogApiAccessPoint: accesspoint};
					var rulesStr = xmlRpc.marshall(rules);
					
					var blog = { title:'', rules: rulesStr};
					
					
					
					//rules.blogId = blog.id;
					
					var serviceRules = xmlRpc._unmarshall(service.rules);
				    
					var blogobj = new Bee.Services.Blog.WordPress(user, password, serviceRules , {}, rules);
					blogobj.blogName = title;
					Bee.Application.showHourglass();
					blogobj.isConnected(function(ok){
						try{
										Bee.Application.hideHourglass();
										if(ok){
											$('sp_wp_frmedit').style.display="none";
											$('sp_fr_add').style.display="none";
						
										Bee.Storage.Db.saveAccount(account);
										blog.idacc = account.id;
										Bee.Storage.Db.saveBlog(blog);
										blogobj.blogRules.blogId = blog.id;
										setSecureStore('blog_password'+blog.id, password);
											Bee.Application.blog_services.push(blogobj);
											Bee.Application.blog_services_hash[blog.id] = Bee.Application.blog_services.length-1;							
										
			
										
											Bee.Core.Dispatcher.dispatch(Bee.Events.SETTINGS_REFRESH);
											Bee.Core.Dispatcher.dispatch(Bee.Events.BLOG_ACCOUNTS_REFRESH);
			
											Bee.Application.navigWindows['blog'].sendCommand('set',{id: blog.id });
																						
											closeSettings();
											gotoStartPage();
		
										}else{
											alert('Connection failed! Check URL, user or password!');
											
										}
								}catch(e){ print_o(e,'write'); }					
					});
					
					
					
					/*$('sp_wp_frmedit').style.display="none";
					$('sp_fr_add').style.display="none";
					Bee.Core.Dispatcher.dispatch(Bee.Events.SETTINGS_REFRESH);
					Bee.Core.Dispatcher.dispatch(Bee.Events.BLOG_ACCOUNTS_REFRESH);
					*/
					
					

					
				
					//$('sp_wp_frmedit').style.display="none";
				break;
				
				case 'confirmsave':
					
					if(this.account){
					
//						var xmlRpc = imprt("xmlrpc");
						
						var service = Bee.Storage.Db.Accounts.getService(1);
						
						var blogs = Bee.Storage.Db.Blog.getBlogs(this.account);
						var blog = blogs[0];
						
						var user = $('sp_user').value;
						var password = $('sp_password').value;
						var accesspoint  = $('sp_accesspoint').value.replace(trimmer, '');
						var title =  $('sp_title').value.replace(trimmer, '');
						if(!checkUrl(accesspoint)){
							alert('Blog address is invalid. Check blog address!');
							return;
						}
						try{
							var blogRules = xmlRpc._unmarshall(blog.rules);
							if(blogRules.blogApiAccessPoint!=accesspoint&&!checkNewAccessPoint(accesspoint))
							{
								alert('Blog address is invalid. This blog is already registered with Bee!');
								return;
							}
						}catch(e){
							
						}
						var account = {id:this.account, title : title, idsrv:1, rules:''};
						
						
						
						var rules = {user:user, blogApiAccessPoint: accesspoint};
						var rulesStr = xmlRpc.marshall(rules);
						
						var blog = {id:blog.id,  title:'', rules: rulesStr};
						
						
						
						var serviceRules = xmlRpc._unmarshall(service.rules);
				
						var i = Bee.Application.blog_services_hash[blog.id];
						
						rules.blogId = blog.id;
						
						if((typeof i)!='undefined'){
									Bee.Application.showHourglass();	
									var blogobj  = new Bee.Services.Blog.WordPress(user, password, serviceRules , {}, rules);
									blogobj.isConnected(function(ok){
										Bee.Application.hideHourglass();
										if(ok){
											$('sp_wp_frmedit').style.display="none";
											$('sp_fr_add').style.display="none";
														
											blog.idacc = account.id;
										
											Bee.Storage.Db.saveAccount(account);
											Bee.Storage.Db.saveBlog(blog);	

											setSecureStore('blog_password'+blog.id, password);
											
											Bee.Application.blog_services[i] = blogobj;
											Bee.Application.blog_services[i].blogName = title;
											
											
											Bee.Core.Dispatcher.dispatch(Bee.Events.SETTINGS_REFRESH);
											Bee.Core.Dispatcher.dispatch(Bee.Events.BLOG_ACCOUNTS_REFRESH);
											
											Bee.Application.navigWindows['blog'].sendCommand('set',{id: blog.id });
																						
											closeSettings();
											gotoStartPage();
										}else{
											alert('Connection failed! Check URL, user or password!');
										}
									});
									
									
						}
						
					}
					
					this.refresh();
					//$('sp_wp_frmedit').style.display="none";
				break;
				
		 		case 'edit':
		 			
		 		
		 			this.lastConfirm =  'confirmsave';
					var id = obj;
					this.account = id;
					var account =  Bee.Storage.Db.Accounts.getAccount(id);
					
					switch(account.idsrv){
						case 1:
							if(Bee.Application.navigWindows['post']){
				 				doConfirm('', 'You are editing a post and wordpress related settings are disabled!', 8);
			 					return;
		 					}
								$('frmEditAccounTitle').innerHTML = lang['SETTINGS_SPAN_ACCINFOLABEL_EDIT'];
								$('sp_wpInfo').innerHTML  =	 lang['SETTINGS_DIV_WP_INFO_EDIT'];
								$('sp_wpCreate').hide();
								$('sp_wpOr').show();
								
								$('sp_wpOr').innerHTML = ' tell me about your blog';
								$('sp_wpOr').className='';
		
//							var xmlRpc = imprt("xmlrpc");
							$('sp_wp_frmedit').style.display="block";
							
							var blogs = Bee.Storage.Db.Blog.getBlogs(account.id);
							
							var blog = blogs[0];
							
							var blogRules = xmlRpc._unmarshall(blog.rules);
								
							$('sp_user').value = blogRules.user ;
							$('sp_password').value = getSecureStore('blog_password'+blog.id);
							$('sp_accesspoint').value = blogRules.blogApiAccessPoint ;
							//prevent spaces in title 
							var title = '';
							if(account.title!='') title+=account.title;
							if(blog.title!='') title+=blog.title;
							$('sp_title').value = title;
							
							$('sp_addCmd').style.display = "none";
							$('sp_saveCmd').style.display = "";
							
							
						break;
						case 2:
							//not implemented
							
						break;
					}
					
				break;
				
				case 'delete':
					
				
					var id = obj;
					var account =  Bee.Storage.Db.Accounts.getAccount(id);
					switch(account.idsrv){
						case 1:
							var blogs = Bee.Storage.Db.Blog.getBlogs(account.id);
							var blog = blogs[0];
							
							
	
		 					if(Bee.Application.navigWindows['post']){
				 				doConfirm('', 'You are editing a post and wordpress related settings are disabled!', 8);
			 					return;
		 					}

							//prevent spaces in title 
							var title = '';
							if(account.title!='') title+=account.title;
							if(blog.title!='') title+=blog.title;
							$('sp_title').value = title;
							if(confirm('Are you sure you want to remove WordPress account "' + title+'" from Bee?')){
								
								Bee.Storage.Db.saveAccount({id:-account.id});
								Bee.Storage.Db.saveBlog({id: -blog.id});
								
								
								
								var index = Bee.Application.blog_services_hash[blog.id];
								
								if((typeof index)!='undefined')
									Bee.Application.blog_services[index] = null;

//								Bee.Application.blog_services = Bee.Application.blog_services.compact(); 
								
								delete Bee.Application.blog_services_hash[blog.id];
																
								Bee.Storage.Db.Blog.deleteBlogPosts(blog.id);
								
								Bee.Core.Dispatcher.dispatch(Bee.Events.SETTINGS_REFRESH);
								Bee.Core.Dispatcher.dispatch(Bee.Events.BLOG_ACCOUNTS_REFRESH);
								
								
								Bee.Application.navigWindows['blog'].sendCommand('set',{id: -1 });
											
								//del from serv array
							}
						break;
						case 2:
							if(confirm('Are you sure you want to logout from \"' + account.title + '\" Flickr account?')){
								Bee.Storage.Db.saveAccount({id:-account.id});
								Bee.Core.Dispatcher.dispatch(Bee.Events.FR_LOGOUT, null, account.title); 
							}
						break;
					}
					
					this.refresh();
					
				break;
				
				case 'template':
					this.getTemplate(new Number(obj), callback);
				
				break;
				
				case 'continue':
					Bee.Services.Photo.Flickr.openAuthorizeWindow();
					
					$('sp_fr_continueCmd').disabled=true;
					setTimeout( 
						function(){
							$('sp_fr_add1').style.display="none";
							$('sp_fr_add2').style.display="block";
							$('sp_fr_continueCmd').style.display="none";
							$('sp_fr_finishCmd').style.display="";
						}, 1000);
				break;
				
				case 'finish':
					Bee.Services.Photo.Flickr.registerUser();
					
					$('sp_wp_frmedit').style.display="none";
					$('sp_fr_add').style.display="none";
					
					this.refresh();
				break;
				
				case 'cancel':
					$('sp_wp_frmedit').style.display="none";
					$('sp_fr_add').style.display="none";
				break;
				
				case 'refresh':
					this.refresh();
				break;
				
				case 'setUploadPrivacy':
					if ($('sp_up_private').checked){
						$('sp_up_friends').disabled = false;
						$('sp_up_family').disabled = false;
						config['uploadIsPublic'] = "0";
						config['uploadIsFriend'] = $('sp_up_friends').checked?"1":"0";
						config['uploadIsFamily'] = $('sp_up_family').checked?"1":"0";
					}
					else{
						config['uploadIsPublic'] = "1";
						config['uploadIsFriend'] = "0";
						config['uploadIsFamily'] = "0";
						$('sp_up_friends').disabled = true;
						$('sp_up_family').disabled = true;
					}
				break;
				
				case 'noShowStart':
					config['noShowStart'] = obj;
					$('sp_noShowStart').checked = config['noShowStart'] ? true : false; 
					$('ss_noShowStart').checked = config['noShowStart'] ? true : false; 
					
				break;

				case 'noMinimize':
					config['noMinimize'] = obj;
				break;
				
				case 'noShowTip':
					config['noShowTip'] = obj;
				break;
				
				case 'setPreview':
				break;
				case 'confirm':
					this.sendCommand(this.lastConfirm,  obj, callback);
				break;
			}
			
}

