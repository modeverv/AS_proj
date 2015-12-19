/*
ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.
 
NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the 
terms of the Adobe license agreement accompanying it.  If you have received this file from a 
source other than Adobe, then your use, modification, or distribution of it requires the prior 
written permission of Adobe.

*/

//Initialize blog view panel
// attach handlers
Bee.Display.Blog.Main = function(){
	 Bee.Display.Window.prototype.constructor.call(this);
	 var that = this;
	 this.filter = -1;
	 //getting first blog and making it current
	 var blogs = Bee.Application.blogs();
	 
	 if(blogs.length){
	 	this.blog = blogs[0];
		if(config['lastBlog']){
			var id=config['lastBlog'];
			for(var i=0;i<blogs.length;i++){
				 if(blogs[i].id==id){ 
				 	this.blog = blogs[i];
					break;				
				 }		 
			}
		}
	 }
	 else
		this.blog = null;
	 
	 //catched when accounts changed
	 
	 Bee.Core.Dispatcher.addEventListener(Bee.Events.BLOG_ACCOUNTS_REFRESH, function(){
		var blogs = Bee.Application.blogs();	
	 	
		if(that.blog){
			var id = that.blog.id;
			
			for(var i=0;i<blogs.length;i++){
				 if(blogs[i].id==id){ 
				 	that.blog = blogs[i];
					config['lastBlog']=that.blog.id;
					break;				
				 }		 
			}
		}else{
			if(blogs.length){
				that.blog = blogs[0];
				config['lastBlog']=that.blog.id;
			}else{
				that.blog = null;
			}
		}
		
		if(that.blog!=null){
				that.refreshBlogs();
				Bee.Core.Dispatcher.dispatch(Bee.Events.DOSYNC);
			}
	 });
	 
	 //catch sync_finished events
	 
	 Bee.Core.Dispatcher.addEventListener(Bee.Events.SYNC_FAILED, function(){
	 	that.refreshBlogs();
	 });
	 
	 Bee.Core.Dispatcher.addEventListener(Bee.Events.SYNC_FINISHED, function(){
	 	//refresh dsBlogPosts
		
	 	that.refreshBlogs();
	 });
	 
	 //catch blog_refresh events
	 Bee.Core.Dispatcher.addEventListener(Bee.Events.BLOG_REFRESH, function(){
	 	//refresh dsBlogPosts
	 	that.refreshBlogs();
	 });
	 
	 //current blog changed - refresh dsBlogPosts
	  Bee.Core.Dispatcher.addEventListener(Bee.Events.BLOG_VIEW_CHANGED, function(e){
	  	that.blog =  e.target; 
		config['lastBlog']=that.blog.id;
	 	that.refreshBlogs();
	 });
}
 

Bee.Display.Blog.Main.prototype = new Bee.Display.Window();


//fetch rows from Blog db and clone them in dsBlogPosts  
Bee.Display.Blog.Main.prototype.refreshBlogs = function(){
	//if(!this.document)return;
	//if(this.first){return;} this.first = true;
	var bp_blog = $('bp_blog');
	if(bp_blog)
		var oldScroll = $('bp_blog').scrollTop;
	var hasPosts = false;
	
	
	 var blogs = Bee.Application.blogs();
	 
	 if(blogs.length){
	 	if(this.blog)
	    	for(var i=0;i<blogs.length;i++) blogs[i].selected = blogs[i].id==this.blog.id?'1':'0';
		else{
			for(var i=0;i<blogs.length;i++) blogs[i].selected = i==0;
	   	    this.blog= blogs[0];
			config['lastBlog']=this.blog.id;
		}	
		dsBlogs.setDataFromArray(blogs, false);
		
	 }else{
	 	dsBlogs.setDataFromArray([], false);
	 }
	 
	 
	if(this.blog){
	
		var cats = Bee.Storage.Db.Blog.getBlogCats(this.blog.id);
		dsBlogCats.setDataFromArray(cats, false);
		
		$('bp_cat_filter').innerHTML = 'All posts';
		var posts = Bee.Storage.Db.Blog.getBlogPosts(this.blog.id);
		
		hasPosts = posts.length>0;
		if(this.filter>=0){
				for(var i=0;i<cats.length;i++){
					if(cats[i].id == this.filter){
						$('bp_cat_filter').innerHTML = cats[i].name;
						posts = Bee.Storage.Db.Blog.getBlogPostsFilter(this.blog.id, this.filter);
						break;
					}
				}
		}
		
		else if(this.filter==-2){
				posts = Bee.Storage.Db.Blog.getBlogPostsDrafts(this.blog.id);
				$('bp_cat_filter').innerHTML = 'Drafts';
		}else if(this.filter==-3){
			var found = [];
			var words = this.search.toLowerCase().split(' ');
			for(var i=0;i<posts.length;i++){
				var ok = true;
				var str = (posts[i].title+'/'+posts[i].description+'/'+posts[i].content).toLowerCase();
				for(var j=0;j<words.length;j++)
					if(str.indexOf(words[j])<0){
						ok=false;
						break;
					}else{
//						posts[i].title = posts[i].title.replace(words[j], "<b>"+words[j]+"</b>");
					}
				if(ok) found.push(posts[i]);
			}
			posts = found;
			$('bp_cat_filter').innerHTML = 'Searched ['+this.search+']';		
		}
		
		for(var i=0;i<posts.length;i++){
			var postTitle = '[Untitled]';
			if(posts[i].title){
				if(posts[i].title.length>45) postTitle = stripTags(posts[i].title.substr(0, 42))+'<span style="font-size:10px">...</span>';
				else if(posts[i].title.length) postTitle = stripTags(posts[i].title);
			}
			posts[i].title = postTitle;
			posts[i].categories = Bee.Storage.Db.Blog.getPostCatString(posts[i].id);
			
			var date = new Date(posts[i].date);
			var dateStr = date.getFullYear().to2Chars()+"/"+(date.getMonth()+1).to2Chars()+"/"+date.getDate().to2Chars()+" "+date.getHours().to2Chars()+":"+date.getMinutes().to2Chars(); 		
			posts[i].dateShort = dateStr;
		}
		dsBlogPosts.setDataFromArray(posts, false);
		dsBlogPosts.setColumnType("date", "date");	
		dsBlogPosts.sort(['isdraft','date'], 'descending')
	}
	else
		dsBlogPosts.setDataFromArray([], false);
	
	
	if(hasPosts){
		$('bp_empty_blog').hide();
		$('bp_actions').show();
		$('blogRegion').show();
		
	}else{
		$('bp_empty_blog').show();
		$('bp_actions').hide();
		$('blogRegion').hide();
	}
	 if(oldScroll)
		$('bp_blog').scrollTop = oldScroll;
	
}

//main command switch
Bee.Display.Blog.Main.prototype.sendCommand = function (command, obj){
		 	switch(command){
		 		
		 		case 'addpost':
		 			var newpostwindow =  new Bee.Display.Blog.PostEdit();
		 			
					return newpostwindow;
					
		 		break;
		 		
		 		case 'edit':
			 		var post = Bee.Storage.Db.Blog.getPost(obj.id);
			 		if(post){
					
			 			var newpostwindow =  new Bee.Display.Blog.PostEdit(post);
			 			this.posts[post.id] = newpostwindow; 
			 			var posts = this.posts;
			 			newpostwindow.onremovepost = function(){  delete posts[post.id]; }
						
						
			 			newpostwindow.title = "Editing \""+post.title+"\"";
		 				Bee.Application.addActiveWindow(newpostwindow);
						
						
		 				Bee.Application.setActiveWindow(newpostwindow);
						
			 			
			 		}
		 			
		 		break;
		 		
		 		case 'delete':
			 		var post = Bee.Storage.Db.Blog.getPost(obj.id);
			 		if(post){
			 			if(confirm('Delete post "'+post.title+'"?')){
						if(post.ispublished){
				 			post.serverid*=-1;
				 			post.ispublished= 0;}
				 		else{
				 			post.id *=-1;
				 		}
				 			Bee.Storage.Db.savePost(post);
				 			Bee.Application.alert('Post deleted');
				 			this.refreshBlogs();
							if(post.serverid<0)
								Bee.Core.Dispatcher.dispatch(Bee.Events.DOSYNC);
			 			}
			 		}
		 			
		 		break;
				
				case 'set':
					var blogs = Bee.Application.blogs();
					var bp_blog = $('bp_blog');
					if(bp_blog)
						bp_blog.scrollTop = 0;
					if(blogs.length){
						this.blog = blogs[0];
						config['lastBlog']=this.blog.id;
						
						for(var i=0;i<blogs.length;i++){
							 if(blogs[i].id==obj.id){ 
						 		this.blog = blogs[i];
								config['lastBlog']=this.blog.id;
								
								break;
							 }		 
						}
						this.refreshBlogs();
					}
				break;
				
				case 'refresh':
				
					this.refreshBlogs();
				break;
				
				case 'filter':
					this.filter = obj.id;
					this.refreshBlogs();
					break;
					
				case 'search':
					this.filter = -3;
					this.search = obj.search;
					this.refreshBlogs();
					break;
					
					
		}
}


