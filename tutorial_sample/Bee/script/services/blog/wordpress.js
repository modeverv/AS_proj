/*
ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.
 
NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the 
terms of the Adobe license agreement accompanying it.  If you have received this file from a 
source other than Adobe, then your use, modification, or distribution of it requires the prior 
written permission of Adobe.
*/

	function WordPress (username, password, serviceRules, accountRules, blogRules)
	{
		this.user = username;
		this.password = password;
		this.serviceRules = serviceRules;
		this.accountRules = accountRules;
		this.blogRules = blogRules;
		this.serviceProxy = null;
		this.errorBuffer = [];
		this.connected = false;
	
		var xmlRpc = null;
		this.blogRules.blogApiAccessPoint += (this.blogRules.blogApiAccessPoint.charAt(this.blogRules.blogApiAccessPoint.length - 1) == "/" ? "" : "/") + "xmlrpc.php";

		// Import xmlrpc module (xmlrpc.js already included in Start.html)
		try
		{
		    xmlRpc = imprt("xmlrpc");
		} 
		catch(errorCode)
		{
			// Deal with the error
			this.errorBuffer.push(errorCode);
			alert("global : Importing xmlrpc module failed with error:\n" + errorCode);
		};

		this.connect = function(callback)
		{
			// Attempt to connect to access point
			try
			{
				this.serviceProxy = new xmlRpc.ServiceProxy(this.blogRules.blogApiAccessPoint, ['util.notused']);
				
				this.serviceProxy._introspect = function(clb){
                    this._addMethodNames(["system.listMethods", "system.methodHelp", "system.methodSignature"]);
    		        var _this = this;
	        	    this.system.listMethods(function(m, err) {
						if(err) 
							clb(false);
						else{
	        	        	_this._addMethodNames(m);
	            	    	clb(true);
						}
					});
				}
				
				try {
                    this.serviceProxy._introspect(callback);
                }
                catch(e) {
				    callback(false);
                }
				
			}
			catch(errorCode)
			{
				// Deal with the error
				this.errorBuffer.push(errorCode);
				callback(false);
			};		
		};

		// Hello, anybody there?
		this.isConnected = function(callback)
		{
			var that = this;
			try
			{
				this.serviceProxy.blogger.getUsersBlogs( [0, this.user, this.password], 
								function(serverResponse, errorCode)
								{
									if(errorCode)
									{
										that.connected = false;
									}
									else
									{
										that.connected = true; //("Hello!" == serverResponse.toString()) ? true : false;
									}
									callback(that.connected);
									
								} );
								
				
			}
			catch (errorCode)
			{
				
				
				this.connect( function(ok) { 
					that.connected = ok;
					//check method list again
					if(that.connected) 
						that.isConnected (callback);  
					else
						callback(false);
				} );
				 
				// Deal with the error
				this.errorBuffer.push(errorCode);
			}
		};
		
		// Retrieves all posts
		this.getPosts = function(callback)
		{
			try
			{
				this.serviceProxy.metaWeblog.getRecentPosts( [blogRules.blogId, this.user, this.password, 0], 
								function(serverResponse, errorCode)
								{
									var recentBlogPosts = [];
									
									if(serverResponse && serverResponse.length)
									{														
										for(var i=0; i<serverResponse.length; i++)
										{
											recentBlogPosts.push( new blogPost(
																		serverResponse[i].postid,
																		serverResponse[i].dateCreated,
																		1,
																		serverResponse[i].title,
																		serverResponse[i].description,
																		serverResponse[i].link,
																		serverResponse[i].permaLink,
																		serverResponse[i].categories,
																		serverResponse[i].mt_excerpt,
																		serverResponse[i].mt_text_more,
																		serverResponse[i].mt_allow_comments,
																		serverResponse[i].mt_allow_pings,
																		serverResponse[i].wp_slug,
																		serverResponse[i].wp_password,
																		serverResponse[i].wp_author_id,
																		serverResponse[i].wp_author_display_name,
																		0,
																		1
																		));
										} // end for
									} // end if
									
									callback(recentBlogPosts, errorCode);
								} );
			}
			catch(errorCode)
			{
				// Deal with the error
				this.errorBuffer.push(errorCode);
				alert("getPosts : Call to xmlrpc method failed with error:\n" + errorCode);
			};

			return null;
		};
		
		this.Util = {		
			// Parses the blogCat's htmlUrl property to return category slug
			getCatSlugFromHtmlUrl : function(catHtmlUrl)
			{
				if(! isString(catHtmlUrl)) return false;
				var catHtmlUrl = catHtmlUrl.split(/[\/]+/);
				return catHtmlUrl[ catHtmlUrl.length - (catHtmlUrl[catHtmlUrl.length-1] !="" ? 1 : 2) ];
			}
		};
		
		// Retrieves info (userid, firstname, lastname, nickname, email, url) as array about the user assigned to the instantiated object
		this.getUserInfo = function(callback)
		{	
			try
			{
				this.serviceProxy.blogger.getUserInfo( [0, this.user, this.password],
								function(serverResponse, errorCode)
								{
									callback(serverResponse, errorCode);
								} );
			}
			catch(errorCode)
			{
				// Deal with the error
				this.errorBuffer.push(errorCode);
				alert("getUserInfo : Call to xmlrpc method failed with error:\n" + errorCode);	
				return false;			
			};
		};

		// Deletes existing post, returns whatever API returns, check for 'true' though
		this.deletePost = function(postServerId, callback)
		{
			try
			{
				// Intern, metaWeblog.deletePost este un alias pentru blogger.deletePost
				this.serviceProxy.metaWeblog.deletePost( [0, postServerId, this.user, this.password],
								function(serverResponse, errorCode)
								{
									callback(serverResponse, errorCode);
								} );
			}
			catch(errorCode)
			{
				// Deal with the error
				this.errorBuffer.push(errorCode);
				alert("deletePost : Call to xmlrpc method failed with error:\n" + errorCode);
				return false;				
			};
		};
		
		// Edits existing post, returns whatever API returns, check for 'true' though
		this.editPost = function(blogPostInfo, callback)
		{
			var editPostInfo = new Object();

			if(blogPostInfo.date)
			{
				editPostInfo['dateCreated'] = new Date(); // In felul asta, componenta care face mesajul XML, va reprezenta cu tipul iso8601, iar scriptul PHP va interpreta direct intr-un obiect IXR_date, deci va avea metoda getIso(), la linia 1043 unde imi dadea eroarea inainte
				editPostInfo['dateCreated'].setTime(blogPostInfo['date'].valueOf());
			}
			
			if(blogPostInfo.ispost) editPostInfo['post_type'] = (blogPostInfo.ispost ? "post" : "page");
			if(blogPostInfo.title) editPostInfo['title'] = blogPostInfo.title;
			if(blogPostInfo.content) editPostInfo['description'] = blogPostInfo.content;
			if(blogPostInfo.categories) editPostInfo['categories'] = blogPostInfo.categories;
			if(blogPostInfo.excerpt) editPostInfo['mt_excerpt'] = blogPostInfo.excerpt;
			if(blogPostInfo.textmore) editPostInfo['mt_text_more'] = blogPostInfo.textmore;
			if(blogPostInfo.allowcomments) editPostInfo['mt_allow_comments'] = blogPostInfo.allowcomments;
			if(blogPostInfo.allowpings) editPostInfo['mt_allow_pings'] = blogPostInfo.allowpings;
			if(blogPostInfo.slug) editPostInfo['wp_slug'] = blogPostInfo.slug;
			if(blogPostInfo.password) editPostInfo['wp_password'] = blogPostInfo.password;
			if(blogPostInfo.authorid) editPostInfo['wp_author_id'] = blogPostInfo.authorid;
			if(blogPostInfo.authorname) editPostInfo['wp_author_display_name'] = blogPostInfo.authorname;

			try
			{
				this.serviceProxy.metaWeblog.editPost( [blogPostInfo.serverid, this.user, this.password, editPostInfo, blogPostInfo.isdraft ? false : true], 
								function(serverResponse, errorCode)
								{
									callback(serverResponse, errorCode);
								} );
			}
			catch(errorCode)
			{
				// Deal with the error
				this.errorBuffer.push(errorCode);
				alert("editPost : Call to xmlrpc method failed with error:\n" + errorCode);
				return false;
			};
		};
		
		// Publishes new post
		this.newPost = function(blogPostInfo, callback)
		{			
			var newPostInfo = new Object();

			/* Fill the array
			 * This is the only way, since I have to check for every property of blogPostInfo
			 * against null, undefined, empty value, whatever... (If they get into the xmlrpc message as empty values,
			 * the xmlrpc server will scream for null value(s))
			 */
			if(blogPostInfo.date)
			{
				newPostInfo['dateCreated'] = new Date(); // In felul asta, componenta care face mesajul XML, va reprezenta cu tipul iso8601, iar scriptul PHP va interpreta direct intr-un obiect IXR_date, deci va avea metoda getIso(), la linia 1043 unde imi dadea eroarea inainte
				newPostInfo['dateCreated'].setTime(blogPostInfo['date'].valueOf());
			}
			
			if(blogPostInfo.ispost) newPostInfo['post_type'] = (blogPostInfo.ispost ? "post" : "page");
			if(blogPostInfo.title) newPostInfo['title'] = blogPostInfo.title;
			if(blogPostInfo.content) newPostInfo['description'] = blogPostInfo.content;
			if(blogPostInfo.categories) newPostInfo['categories'] = blogPostInfo.categories;
			if(blogPostInfo.excerpt) newPostInfo['mt_excerpt'] = blogPostInfo.excerpt;
			if(blogPostInfo.textmore) newPostInfo['mt_text_more'] = blogPostInfo.textmore;
			if(blogPostInfo.allowcomments) newPostInfo['mt_allow_comments'] = blogPostInfo.allowcomments;
			if(blogPostInfo.allowpings) newPostInfo['mt_allow_pings'] = blogPostInfo.allowpings;
			if(blogPostInfo.slug) newPostInfo['wp_slug'] = blogPostInfo.slug;
			if(blogPostInfo.password) newPostInfo['wp_password'] = blogPostInfo.password;
			if(blogPostInfo.authorid) newPostInfo['wp_author_id'] = blogPostInfo.authorid;
			if(blogPostInfo.authorname) newPostInfo['wp_author_display_name'] = blogPostInfo.authorname;
			
			try
			{
				this.serviceProxy.metaWeblog.newPost( [blogRules.blogId, this.user, this.password, newPostInfo, blogPostInfo.isdraft ? false : true],
								function(serverResponse, errorCode)
								{
									blogPostInfo.serverid = serverResponse;
									callback(serverResponse, errorCode);
								} );
			}
			catch(errorCode)
			{
				// Deal with the error
				this.errorBuffer.push(errorCode);
				alert("newPost : Call to xmlrpc method failed with error:\n" + errorCode);
				return false;
			};
		};
		
		// Get categories
		this.getCats = function(callback)
		{
			var that = this;
			try
			{

				this.serviceProxy.metaWeblog.getCategories( [blogRules.blogId, this.user, this.password], 
								function(serverResponse, errorCode)
								{	
									var catList = [];
									if(serverResponse){
										for(var i=0;i<serverResponse.length;i++)
										{
											catList.push(new Bee.Data.blogCat(
																null,
																null,
																serverResponse[i].categoryId,
																serverResponse[i].parentId,
																serverResponse[i].categoryName,
																that.Util.getCatSlugFromHtmlUrl(serverResponse[i].htmlUrl),
																serverResponse[i].description,
																serverResponse[i].htmlUrl,
																serverResponse[i].rssUrl
														));
										}
									}
									callback(catList, errorCode);
									
								} );
			}
			catch(errorCode)
			{
				// Deal with the error
				this.errorBuffer.push(errorCode);
				callback(null, true);
				alert("getCats : Call to xmlrpc method failed with error:\n" + errorCode);
				return false;
			};
		};
		
		// Create new category
		this.newCat = function(blogCatInfo, callback)
		{
			var newCatInfo = new Object();

			if(blogCatInfo.idpoc && blogCatInfo.serveridpoc) newCatInfo['parent_id'] = blogCatInfo.serveridpoc;
			if(blogCatInfo.name) newCatInfo['name'] = blogCatInfo.name;
			if(blogCatInfo.slug) newCatInfo['slug'] = blogCatInfo.slug;
			if(blogCatInfo.description) newCatInfo['description'] = blogCatInfo.description;	

			try
			{
				this.serviceProxy.wp.newCategory( [blogRules.blogId, this.user, this.password, newCatInfo],
								function(serverResponse, errorCode)
								{
									callback(serverResponse, errorCode);
								} );
			}
			catch(errorCode)
			{
				// Deal with the error
				this.errorBuffer.push(errorCode);
				alert("newCat : Call to xmlrpc method failed with error:\n" + errorCode);
				return false;
			};
		};

		this.setPostCats = function(postServerId, catServerIds, callback)
		{
			/*
			 * postServerId : post's ID on the server
			 * castServerId : Array of category IDs
			 */
			try
			{
				var array = new Object();
				for(var i=0; i<catServerIds.length; i++)
				{
					array[i]['categoryId'] = catServerIds[i];
				}
				
				this.serviceProxy.mt.setPostCategories( [postServerId, this.user, this.password, array],
								function(serverResponse, errorCode)
								{
									callback(serverResponse, errorCode);
								} );
			}
			catch(errorCode)
			{
				// Deal with the error
				this.errorBuffer.push(errorCode);
				alert("setPostCats : Call to xmlrpc method failed with error:\n" + errorCode);
				return false;				
			}
		}
		
		this.getPostCats = function(postServerId, callback)
		{
			try
			{
				this.serviceProxy.mt.setPostCategories( [postServerId, this.user, this.password], 
								function(serverResponse, errorCode)
								{
									callback(serverResponse, errorCode);
								} );
			}
			catch(errorCode)
			{
				// Deal with the error
				this.errorBuffer.push(errorCode);
				alert("getPostCats : Call to xmlrpc method failed with error:\n" + errorCode);
				return false;				
			}
		}
		
	} // end WordPress class definition

	Bee.Services.Blog.WordPress = WordPress;
