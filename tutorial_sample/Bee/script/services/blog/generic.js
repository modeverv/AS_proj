/*
ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.
 
NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the 
terms of the Adobe license agreement accompanying it.  If you have received this file from a 
source other than Adobe, then your use, modification, or distribution of it requires the prior 
written permission of Adobe.
*/


	// las atatia parametri, ca sa nu fie nevoie sa mai fac un vector cu chei ca apoi sa-l trimit, deci sa recopiez datele in plus
	function blogPost (postServerId, postDate, isPost, postTitle, postContent, postLink, postPermalink, postCategories, postExcerpt, postTextMore, postAllowComments, postAllowPings, postSlug, postPassword, postAuthorId, postAuthorName, isDraft, isPublished)
	{
		function isGood(expression)
		{
			return (typeof expression == "undefined" || typeof expression == "null" ? false : true);
		}
		
		//this.id = postId ? postId : null; // Nu completezi cand pregatesti un nou post, sunt completate de .newPost() pe baza informatiilor din blogRules
		this.serverid = postServerId ? postServerId : null;
		this.authorid = postAuthorId ? postAuthorId : 0; // Nu completezi cand pregatesti un nou post
		this.authorname = postAuthorName ? postAuthorName : null; // Nu completezi cand pregatesti un nou post
		this.title = postTitle ? postTitle : null;
		this.content = postContent ? postContent : null;
		this.date = postDate ? postDate : new Date();
		this.ispost = isPost ? 1 : 0;
		this.isdraft = isDraft ? 1 : 0;
		this.ispublished = isPublished ? 1 : 0;
		this.link = postLink ? postLink : null; // Nu completezi cand pregatesti un nou post
		this.permalink = postPermalink ? postPermalink : null; // Nu completezi cand pregatesti un nou post
		this.categories = postCategories ? postCategories : null;
		this.excerpt = postExcerpt ? postExcerpt : null;
		this.textmore = postTextMore ? postTextMore : null;
		this.allowcomments = (postAllowComments == 0 ? 0 : 1);
		this.allowpings = (postAllowPings == 0 ? 0 : 1);
		this.slug = postSlug ? postSlug : null;
		this.password = postPassword ? postPassword : null;
	}
	
	function blogCat (catId, catParentId, catServerId, catParentServerId, catName, catSlug, catDescription, catHtmlUrl, catRssUrl)
	{
		//this.id = catId ? catId : null;
		this.idpoc = catParentId ? catParentId : null;
		this.serverid = catServerId ? catServerId : null;
		this.serveridpoc = catParentServerId ? catParentServerId : null;
		this.name = catName ? catName : null;
		this.slug = catSlug ? catSlug : null;
		this.description = catDescription ? catDescription : null;
		this.htmlurl = catHtmlUrl ? catHtmlUrl : null;
		this.rssurl = catRssUrl ? catRssUrl : null;
	}
	
	Bee.Data.blogPost = blogPost;
	
	Bee.Data.blogCat = blogCat;