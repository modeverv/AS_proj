/*
ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.
 
NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the 
terms of the Adobe license agreement accompanying it.  If you have received this file from a 
source other than Adobe, then your use, modification, or distribution of it requires the prior 
written permission of Adobe.
*/

var tooltips = {
		
	//settings create wp account
	SETTINGS_DIV_WP_CREATE: 'Opens WordPress signup page in your browser',
	//SETTINGS_DIV_WP_INFO: "You need to have a WordPress-based blog to use Bee.",
	//SETTINGS_SPAN_ACCINFOLABEL: "Do you have a blog?",
	
	BLOG_CREATEPOST: 'Click here to create a new post with Bee',
	GOTO_PHOTO_PAGE: 'Click here to browse Flickr and insert photos',
	GOTO_BLOG_PAGE: 'Click here to go back to your blog',
	JUST_BROWSE: 'Click here to browse your blog posts',
	
	// Settings page (assets/html/settings/main.htm)	
	//SETTINGS_SPAN_LABEL : "Settings",
	//SETTINGS_INPUT_CLOSE : "Close",
	//SETTINGS_INPUT_CANCEL : "Cancel",
	SETTINGS_INPUT_FINISH : 'Click if you have been to Flickr.com in your browser and authorized Bee',
	SETTINGS_INPUT_CONTINUE : 'Click if you want to view your Flickr accout in Bee',
	//SETTINGS_INPUT_ADDWPACCOUNT : "Add WordPress account",
	//SETTINGS_INPUT_ADDFLKACCOUNT : "Add Flickr account ",
	//SETTINGS_SPAN_ACCINFOLABEL : "Account Settings",
	//SETTINGS_SPAN_TITLE : "Blog name",
	//SETTINGS_SPAN_ACCESSPOINT : "Blog address",
	//SETTINGS_SPAN_USER : "Username",
	//SETTINGS_SPAN_PASSWORD : "Password",
	//SETTINGS_INPUT_ADD : "Add",
	//SETTINGS_INPUT_SAVE : "Save",
	//SETTINGS_CURRENT_LANGUAGE: "Current language",
	//SETTINGS_EDIT_WP_ACCOUNT: "Edit", 
	//SETTINGS_DELETE_WP_ACCOUNT: "Remove",
	//SETTINGS_TEMPLATE_WP_ACCOUNT: "Template",
	//SETTINGS_TEMPLATE_WP_ACCOUNT: "Template",
	//SETTINGS_LOGOUT_FL_ACCOUNT: "Remove",
	//SETTINGS_FR_ADD1: "This program requires your authorization before " +
	//		"it can read or modify your photos and data on Flickr.",
	//SETTINGS_FR_ADD1_MESSAGE: "Authorizing is a simple process which takes " +
	//		"place in your browser. When you're finished, return to this " +
	//		"window to complete the authorization and begin using Bee. <br />" +
	//		"(You must be connected to the internet in order to authorize this program.)",
	//SETTINGS_FR_ADD2: "Return to this window after you have finished the " +
	//		"authorization process on Flickr.com",
	//SETTINGS_FR_ADD2_MESSAGE: "Once you're done in your browser, click the \"Finish\" button " +
	//		"below and you can begin using Bee! <br /> " +
	//		"(You can revoke this program's authorization at any time in " +
	//		"your account page on Flickr.com.)",
	//DROP_BOX: "Drop Box",
	
	BEE_SEARCH_PHOTOS: 'Searches for photos (including your\'s) on Flickr',
	BEE_UPLOAD_PHOTOS: 'Upload photos to your current Flickr account',
	
	
	// Photo module (assets/html/modules/photo.htm)

	
	//About Page (assets/html/about)
	//ABOUT_HEADING1: "Bee, lorem ipsum",
	//ABOUT_CLOSE: "Close",
	
	//Postedit (/assets/html/modules/postedit.htm)
	//POSTEDIT_WHERE_2POST: "Where to post?",

	// Blog (/assets/html/modules/blog.htm:)
	BLOG_SYNCHRONIZE: 'Your latest changes haven\'t been synchronized with your blog; click to attempt synchronization',
	BLOG_CREATEPOST: 'Click to create a new blog entry',
	//BLOG_POST_TITLE: "Title:",
	//BLOG_POST_CONTENT: "Content:",
	BLOG_POST_BACK: 'Discard everything and go back to the post list',

	//BLOG_CATEGORIES: "Choose the categories for this post",
	BLOG_POST_PUBLISH: 'Publish this on your blog for the world to see',
	BLOG_POST_SAVEDRAFT: 'Save this for later and go back to the post list',
	//BLOG_POST_INSERTPICTURE: "Upload & Insert Photos",

    // Post list (/assets/html/blog/list.htm)
    //POST_EDIT: "Edit",
    //POST_DELETE: "Delete",
   

    // Status bar (/assets/html/status.htm)
    //SYNC: "Sync",
    //STATUS_SETTINGS: "Settings",

    // Navig (/assets/htm,l/navig.htm)
	//NAVIG_INFORMATION: "",
    
    // Settings Main Frame (/assets/html/settings/main.htm)
    WP_SETTINGS_TITLE: 'The WordPress accounts you currently manage with Bee',
    //NO_WP_ACCOUNT: "You haven't added a Wordpress account yet.",
    FL_SETTINGS_TITLE: 'The Flickr accounts you currently manage with Bee',
    //NO_FL_ACCOUNT: "You haven't added a Flickr account yet.",
	
	
	// settings create wordpress account
	
	SETTINGS_DIV_WP_CREATE: 'Create a free blog account on wordpress.com',
	
	SETTINGS_DIV_WP_INFO: 'You need to have a WordPress-based blog to use Bee.',
	
	SETTINGS_SPAN_ACCINFOLABEL: 'Do you have a blog?'
};

var lang = {
	lang : "en",
	
	//bee.htm
	PHOTO_VIEW: "<b>Photo</b>View",
	BLOG_VIEW: "<b>Blog</b>View",
	BEE_SEARCH_PHOTOS: "Search",
	BEE_UPLOAD_PHOTOS: "Upload",
	BEE_BLOG_EMPTY: "Your blog is empty <br>",
	BEE_FIRST_POST_WITH_BEE: "<b>Click me to create your first post with Bee</b>",
	BEE_NO_SEARCH_RESULTS: "No search result. Your blog is NOT empty.<br>",
	BEE_SHOW_ALL_POSTS: "<b>Click me to show all posts</b>",
	BEE_ALL_POSTS: "All posts",
	BEE_ALL_POSTS_STAR: "*All posts",
	BEE_DRAFTS_STAR: "*Drafts",
	CLOSE: "Close",
	BEE_CURRENT_BLOG_ACCOUNT: "Current blog: ",
	GOTO_BLOG_PAGE: "", // and it should be empty
	BEE_CURRENT_PHOTO_ACCOUNT: "Current Flickr account: ",
	BEE_NO_FLICKR_ACCOUNT: "You haven't added a Flickr account yet, you can either:",
	BEE_ADD_FLICKR_ACCOUNT_NOW: "add a Flickr account now",
	BEE_OR_SEARCH_PUBLIC_PHOTOS: "search in public photos on Flickr",
	BEE_PHOTOSETS:"Photosets",
	BEE_PHOTOS:"Photos in pages:",
	BEE_SUBTITLE: "Search results:&nbsp;",
	BEE_VIEW_NEXT_PAGE_PUBLIC_RESULTS: "View next pages for public results...",
	BEE_VIEW_PREVIOUS_PAGE_YOUR_RESULTS: "View previous pages for your photos results...",
	GOTO_PHOTO_PAGE: "",
	BEE_BEE_BLOG_EDITOR:"Bee Blog Editor",
	BEE_QUICK_START:"Quick Start",
	QS_BEE_CREATE_NEW_POST:"Create new post",
	QS_BEE_BLOG_ABOUT_PHOTO:"Blog about a photo",
	QS_BEE_JUST_BROWSE:"Browse my blog",
	QS_BEE_DONT_SHOW_AGAIN:"Don't show this again",
	BEE_UPLOAD_CANCEL:"Cancel",
	BEE_UPLOAD_TO_FLICKR:"Upload to Flickr",
	BEE_UPLOAD_BROWSE:"Browse",
	YES:"Yes",
	NO:"No",
	CANCEL:"Cancel",
	OK:"Ok",
	BEE_SYNC_TO_PUBLISH:"sync to publish",
	BEE_FILTER_BY:"Filter by: ",
	BEE_POST_PREVIEW:"Preview",
	BEE_SEARCH_RESULTS:"Search Results",
	BEE_TO_RESULTS_PUBLIC:"Go to results from public photos",
	BEE_TO_RESULTS_YOURS:"Go to results from your photos",
	BEE_RESULTS_IN_PUBLIC_PHOTOS:"Results in public photos",
	BEE_UPLOAD_TITLE:"Photo Upload",
	BEE_PHOTO_REMOVE:"Remove",
	BEE_SETTINGS:"Settings",
	BEE_GOTO_TRAY:"Go to tray instead of minimizing window",
	BEE_DONT_START_SCREEN:"Don't show start screen",
	BEE_DONT_TOOLTIPS:"Don't show tooltips",
	BEE_PHOTO_UPLOADING_OPTIONS:"Photo uploading options",
	BEE_PRIVATE:"Private",
	BEE_FRIENDS:"Friends can see",
	BEE_FAMILY:"Family can see",
	BEE_PUBLIC:"Public",
	BEE_JUST_TELLME_EXISTING_BLOG:"or just tell me about your existing blog",
	BEE_REFRESH_TEMPLATE:"Refresh template",
	BEE_ABOUT_BEE:"About Bee",
	BEE_ABOUT_DBEFPB:"Desktop Blog Editor For Photo Blogging.",
	BEE_ABOUT_USED_LIBRARIES:"Based on:",
	BEE_MODAL12_SYNC_BLOGS:"Synchronizing blogs",
	BEE_MODAL12_RETRY:"Retry",
	BEE_DIRTY_ALERT:"Alert!",
	BEE_DIRTY_DO_YOU_WANT_SAVE:"Do you want to save a draft?",
	BEE_DELETE:"Delete",
	
	// Settings page (assets/html/settings/main.htm)	
	SETTINGS_SPAN_LABEL : "Settings",
	SETTINGS_INPUT_CLOSE : "Close",
	SETTINGS_INPUT_CANCEL : "Cancel",
	SETTINGS_INPUT_FINISH : "Finish",
	SETTINGS_INPUT_CONTINUE : "Continue",
	SETTINGS_INPUT_ADDWPACCOUNT : "Add WordPress account",
	SETTINGS_INPUT_ADDFLKACCOUNT : "Add Flickr account ",
	SETTINGS_SPAN_ACCINFOLABEL : "Account Settings",
	SETTINGS_SPAN_TITLE : "Blog name",
	SETTINGS_SPAN_ACCESSPOINT : "Blog address",
	SETTINGS_SPAN_USER : "Username",
	SETTINGS_SPAN_PASSWORD : "Password",
	SETTINGS_INPUT_ADD : "Add",
	SETTINGS_INPUT_SAVE : "Save",
	SETTINGS_CURRENT_LANGUAGE: "Current language",
	SETTINGS_EDIT_WP_ACCOUNT: "Edit", 
	SETTINGS_DELETE_WP_ACCOUNT: "Remove",
	SETTINGS_TEMPLATE_WP_ACCOUNT: "Template",
	SETTINGS_LOGOUT_FL_ACCOUNT: "Remove",
	SETTINGS_FR_ADD1: "This program requires your authorization before " +
			"it can read or modify your photos and data on Flickr.",
	SETTINGS_FR_ADD1_MESSAGE: "Authorizing is a simple process which takes " +
			"place in your browser. After you press \"Continue\", look for the browser window " +
			"Bee will open. When you're finished, return to this " +
			"window to complete the authorization and begin using Bee. <br/><br/>" +
			"(You must be connected to the internet in order to authorize this program.)",
	SETTINGS_FR_ADD2: "Return to this window after you have finished the " +
			"authorization process on Flickr.com",
	SETTINGS_FR_ADD2_MESSAGE: "Once you're done in your browser, click the \"Finish\" button " +
			"below and you can begin using Bee! <br/><br/> " +
			"(You can revoke this program's authorization at any time in " +
			"your account page on Flickr.com.)",
	DROP_BOX: "Drop Box",
	
	
	
	// Photo module (assets/html/modules/photo.htm)
	PHOTO_TITLE : "Images",
	PHOTO_ACCOUNTS: "Flickr",
	PHOTO_UPLOAD: "Upload",
	PHOTO_SEARCH_TEXT: "Full text",
	PHOTO_SEARCH_TAGS: "Tags only",
	PHOTO_TAGMODE_ALL: "All",
	PHOTO_TAGMODE_ANY: "Any",
	PHOTO_ADVANCED_SEARCH: "Advanced",
	PHOTO_SIMPLE_SEARCH: "Simple",
	PHOTO_SEARCH_BYDATE: "By date",
	PHOTO_ADVSEARCH_TAKEN: "Taken",
	POTO_ADVSEARCH_POSTED: "Posted",
	PHOTO_ADVSEARCH_TAKEN_AFTER: "After",
	MM_DD_YYYY: "mm/dd/yyyy",
	PHOTO_ADVSEARCH_TAKEN_BEFORE: "Before",
	PHOTO_SEARCH: "Go",
	
	
	//About Page (assets/html/about)
	ABOUT_HEADING1: "Bee, lorem ipsum",
	ABOUT_CLOSE: "Close",
	
	//Postedit (/assets/html/modules/postedit.htm)
	POSTEDIT_WHERE_2POST: "Where to post?",

	// Blog (/assets/html/modules/blog.htm:)
	BLOG_SYNCHRONIZE: "Synchronize",
	BLOG_CREATEPOST: "Create post",
	BLOG_POST_TITLE: "Title:",
	BLOG_POST_CONTENT: "Content:",
	BLOG_POST_BACK: "Discard",
	BLOG_CATEGORIES: "Categories",
	BLOG_POST_PUBLISH: "Publish",
	BLOG_POST_SAVEDRAFT: "Save as draft",
	BLOG_POST_INSERTPICTURE: "Upload & Insert Photos",

    // Post list (/assets/html/blog/list.htm)
    POST_EDIT: "Edit",
    POST_DELETE: "Delete",
   

    // Status bar (/assets/html/status.htm)
    SYNC: "Sync",
    STATUS_SETTINGS: "Settings",
	
	SHELL_ICON_TIP: "Bee",

    // Navig (/assets/htm,l/navig.htm)
	NAVIG_INFORMATION: "",
    
    // Settings Main Frame (/assets/html/settings/main.htm)
	WP_SETTINGS_TITLE: "WordPress Acounts",
    NO_WP_ACCOUNT: "You haven't added a Wordpress account yet.",
    FL_SETTINGS_TITLE: "Flickr Accounts",
    NO_FL_ACCOUNT: "You haven't added a Flickr account yet.",

	SETTINGS_SPAN_ACCINFOLABEL_EDIT: 'What changes do you want to make to your blog data?',
	SETTINGS_DIV_WP_INFO_EDIT: '',
	
	// settings create wordpress account
	
	SETTINGS_DIV_WP_CREATE: "Create a free blog account on wordpress.com",
	
	SETTINGS_DIV_WP_INFO_ADD: "You need to have a WordPress-based blog to use Bee.",
	
	SETTINGS_SPAN_ACCINFOLABEL_ADD: "Do you have a blog?",
	FR_AUTHENTICATION_FAILED: "Authentication has failed. Make sure you log in the Flickr " +
			"account in the browser window that Bee opens and allow Bee.",
	FR_IO_ERROR: "Operation failed: Cannot access Flickr.",
	FR_DELETE_FAIL: "Delete failed.",
	FR_DELETE_CONFIRM: "Are you sure you want to delete this photo from your Flickr account?" +
			"<br><br>This operation cannot be undone!",
	FR_SERVICE_UNAVAILABLE: "Flickr service is temporarily unavailable.",
	FR_LOGIN_FAILED: "Bee is no longer allowed to access your account.",
	FR_INVALID_API_KEY: "The API key Bee uses to access Flickr has expired. Please contact us at beeapplication2007@yahoo.com.",

	FR_PHOTOSETS_LOADING_FAILED: "Photosets loading failed.",
	FR_PHOTO_LOADING_FAILED: "Photos loading failed.",

	DISCARD_CHANGES: 'Discard changes?',
	SAVE_POST_DRAFT: 'Save post as a draft?',
	IMAGES: "Images",
	UPLOADING_FILE: "Uploading file {s1} of {s2} - {s3}",
	CLICK_TO_ADD_DESCRIPTION: 'Click to add description',
	TELL_ME:  'and now tell me about your new blog',
	BLOG_INVALID : 'Blog address is invalid. This blog is already registered with Bee!',
};

// 