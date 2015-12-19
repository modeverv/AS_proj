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
 * PostEdit class : used to sync display with post objects - also includes some app logic
 * 		- takes values from screen and outputs them in DB storage
 * 		- publishes posts
 * 		- edit posts
 * 		- create new posts
 * 
 */
var moreBar = '<img width="100%" height="10px" border="0" class="morebar" src="/assets/images/spacer.gif">';
Bee.Display.Blog.PostEdit = function( post ){
	
	Bee.Window.$('pp_content_txt').contentWindow.childSandboxBridge.cleanup();
									
									
	this.cats = {  };

	var dbCats = dsBlogCats.getData();
	if(dbCats.length)
		this.cats[dbCats[0].id]=true;

	
	if(post){
		this.post = post;
		this.cats = Bee.Storage.Db.Blog.getPostCats(this.post.id);
		
		if(this.post.content==null) 
			this.post.content = "";
		else 
			this.post.content = this.post.content.replace(/\n/g, '<br />');

		if(this.post.textmore==null) 
			this.post.textmore = "";
		else 
			this.post.textmore = this.post.textmore.replace(/\n/g, '<br />');	
			
	}
	else {
		
		
		//get current blog
		var blog = Bee.Application.navigWindows['blog'].blog;
		var idblg = 0;
		if(blog) idblg = blog.id;
				
		this.post = { title:'Post title', content:'', isdraft: true,  date:new Date(), idblg:idblg};
		
		/*
		 * TODO: can't save drafts from the begining
		 */
		
		/*
			Bee.Storage.Db.savePost(this.post);
			Bee.Application.alert('New post saved as draft');
		*/
	}
	

	
	this.first = true;	
	Bee.Display.Window.prototype.constructor.call(this);
}
 

Bee.Display.Blog.PostEdit.prototype = new Bee.Display.Window();

Bee.Display.Blog.PostEdit.prototype.insertFlickrPicture = function(e){
	Bee.Window.dirty = true;
	Bee.Window.$('pp_content_txt').contentWindow.childSandboxBridge.addElement(e.args);
	Bee.Window.showBlog();
	
}


Bee.Display.Blog.PostEdit.prototype.updateForm = function (){
		$('pp_title_txt').value =this.post.title;
	

		if(this.post.textmore&&this.post.textmore.length){
			$('pp_content_txt').contentWindow.childSandboxBridge.setContent(this.post.content+moreBar+this.post.textmore);
		}
		else{
			$('pp_content_txt').contentWindow.childSandboxBridge.setContent( this.post.content );
		}
			
		$('pp_saveDraft').style.display = this.post.isdraft ? 'block' : 'none' ; 	

	Spry.Data.updateRegion('pp_cats');
}
//save all the form values in object this.post
Bee.Display.Blog.PostEdit.prototype.saveForm = function (){
	this.post.title = $('pp_title_txt').value;
	this.post.content = $('pp_content_txt').contentWindow.childSandboxBridge.getContent();

	//this.post.content = $('pp_content_txt').innerHTML;
	//check for <!--more--> tag
	var i = this.post.content.indexOf(moreBar);

	if(i!=-1){
		this.post.textmore = this.post.content.substr(i).replace(moreBar, '');
		this.post.content = this.post.content.substr(0, i);
	}else
		this.post.textmore = '';
	
}


Bee.Display.Blog.PostEdit.prototype.onshow = function (){
	if(this.first)	
	{
			//first time init form values
			this.updateForm();
			this.first = false;
	}

/*
 * TODO: change/use this events
 * 
 */
	/*if(this.canChangeBlog )
		Bee.Core.Dispatcher.dispatch(Bee.Events.POST_EDIT_SHOWBLOGS);
	else
		Bee.Core.Dispatcher.dispatch(Bee.Events.POST_EDIT_HIDEBLOGS);	
	*/
	
	
}

//save object this.post in DB (eventually publish it)
Bee.Display.Blog.PostEdit.prototype.save = function(){
				//check for blank fields
					if(this.post['title'].blank()&&this.post['content'].blank()){
							this.post['title']='Untitled';
							this.updateForm();
						}

			 			this.post['ispublished']=0;
			 	//		this.post['date']=new Date();
			 			
			 			this.post['ispost']=1;
			 		DB.savePost(this.post);
					
					Bee.Storage.Db.Blog.unlinkPost(this.post.id);
					
					
					for(var i in this.cats){
						Bee.Storage.Db.Blog.linkPost(this.post.id, i);
					}
					
					/*
					 * not needed anymore
					 */
					//this.canChangeBlog = false;
					//Bee.Core.Dispatcher.dispatch(Bee.Events.POST_EDIT_HIDEBLOGS);
					
					//send fake refresh command to blog viewer
					Bee.Core.Dispatcher.dispatch(Bee.Events.BLOG_REFRESH);
				
					if(!this.post['isdraft']){
						Bee.Core.Dispatcher.dispatch(Bee.Events.DOSYNC);
					}
	
}
Bee.Display.Blog.PostEdit.prototype.sendCommand = function (command, obj){
		 	switch(command){
		 		case 'publish':
		 		case 'save':

					this.saveForm(); 			
				//	this.post.ispublished=false;
					if(this.post.serverid)
						this.post.isdraft = false;
					else
						this.post.isdraft = command !='publish';
					
		 			this.save();
			 		
			 		Bee.Application.alert('Post saved');
		 			
		 		break;
		 		
		 		
		 		
		 		case 'close':
		 			this.close();
		 		break;
		 		
		 		/*case 'delete':
		 			var post = Bee.Storage.Db.Blog.getPost(this.post.id);
					
			 		if(post){
			 			if(confirm('Delete post "'+post.title+'"?')){
							if(post.ispublished){
					 			post.serverid*=-1;
					 			post.ispublished= 0;

								}
					 		else{
					 			post.id *=-1;
					 		}
				 			Bee.Storage.Db.savePost(post);
							
				 			Bee.Application.alert('Post deleted');
						
							//if(post.ispublished){
								
							
				 				Bee.Core.Dispatcher.dispatch(Bee.Events.DOSYNC);
								
							//	}
						
							this.close();
			 			}
			 		}
		 		break;*/
		 		
		 		/*case 'draft':
		 			
		 			this.saveForm();
			 		
			 		this.post.isdraft = true;
			 			
			 		DB.savePost(this.post);
			 		
			 		Bee.Application.alert('Post saved as draft');
			 		
			 		
		 		break;*/
		 		
		 		case 'changed':
		 			this.saveForm();
		 			
		 			/*if(this.post.id)
		 				this.setTitle('Editing "'+this.post.title+'"');
					else
			 			this.setTitle('New post "'+this.post.title+'"');*/
			 			
		 			
		 		break;
				
				case 'preview':
					this.saveForm();
					this.sendCommand('postPreview', this.post);
					showPreview();
					break;
				
				case 'set_blog':
					this.post['idblg']=obj.idblg;
					Bee.Storage.Db.savePost({id:this.post['id'], idblg:this.post['idblg']});
				break;
		 		
		 		case 'template':
		 			var that = this;
		 			Bee.Application.navigWindows['settings'].sendCommand('template',this.post['idblg'], function(){
		 					that.sendCommand('postPreview', that.post);
		 			});
		 			
		 			break;
		 		case 'postPreview':	
					var post = obj;
							var traceStr = '';
							var title = '';
							var content = '';
							var traceFileRef2 = null;	
							if(config['previewPath'+post.idblg]){
				 				var traceFileRef = new air.File(config['previewPath'+post.idblg]);
								var traceFile = new air.FileStream();
								traceFile.open(traceFileRef, air.FileMode.READ);
								traceStr = traceFile.readUTFBytes(traceFileRef.size);
								traceFile.close();
								title = config['previewTitle'+post.idblg];
								content = config['previewContent'+post.idblg];
								traceFileRef2 = traceFileRef.resolvePath("../preview.htm");
								if(!post['content']) post['content']= '';
							if(!post['title']) post['title']= '';
														
							
							}else{
								traceStr = "<h1>{title}</h1><p>{content}</p>";
								title = '{title}';
								content = '{content}';
								traceFileRef2 = air.File.applicationStorageDirectory.resolvePath('temp.htm');
							}
							
							if(post['textmore']&&post['textmore'].length)
								traceStr = traceStr.replaceAll(content, post['content']+ " <br /><hr /><br />"+post['textmore']);
							else
								traceStr = traceStr.replaceAll(content, post['content']);							
 							traceStr = traceStr.replaceAll(title, post['title']);
							
							
							var traceFile = new air.FileStream();
							traceFile.open(traceFileRef2, air.FileMode.WRITE);
							traceFile.writeUTFBytes(traceStr);
							traceFile.close();	
							
							//air.navigateToURL( new air.URLRequest('file:/'+traceFileRef2.nativePath ), "_blank" );
							$('previewFrame').src = 'file:/'+traceFileRef2.nativePath;
							
		 		break;
		 		
		 		
		 	}
	}