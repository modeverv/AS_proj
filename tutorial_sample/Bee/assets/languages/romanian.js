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
	SETTINGS_DIV_WP_CREATE: 'Deschide pagina de inregistrare WordPress in browser',
	//SETTINGS_DIV_WP_INFO: "You need to have a WordPress-based blog to use Bee.",
	//SETTINGS_SPAN_ACCINFOLABEL: "Do you have a blog?",
	
	BLOG_CREATEPOST: 'Click aici pentru a crea o noua inregistrare in blog',
	GOTO_PHOTO_PAGE: 'Click aici pentru a vedea poze si a le insera in blog',
	GOTO_BLOG_PAGE: 'Click aici pentru a te intoarce la blog',
	JUST_BROWSE: 'Click aici pentru a rasfoi blogul',
	
	// Settings page (assets/html/settings/main.htm)	
	//SETTINGS_SPAN_LABEL : "Settings",
	//SETTINGS_INPUT_CLOSE : "Close",
	//SETTINGS_INPUT_CANCEL : "Cancel",
	SETTINGS_INPUT_FINISH : "Click aici daca ai fost pe flickr.com in browser si ai Bee",
	SETTINGS_INPUT_CONTINUE : "Click aici daca vrei sa-ti vezi contul de Flickr in Bee",
	//SETTINGS_INPUT_ADDWPACCOUNT : "Add WordPress account",
	//SETTINGS_INPUT_ADDFLKACCOUNT : "Add Flickr account ",
	//SETTINGS_SPAN_ACCINFOLABEL : "Account Settings",
	SETTINGS_SPAN_TITLE : "Numele sub care vrei sa apara blogul in Bee",
	SETTINGS_SPAN_ACCESSPOINT : "Adresa blogului (nu uita sa pui <i>http://</i> in fata",
	SETTINGS_SPAN_USER : "Numele cerut pentru autentificarea pe blog",
	SETTINGS_SPAN_PASSWORD : "Parola care impreuna cu numele de mai sus iti permit sa modifici blogul",
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
	
	
	BEE_SEARCH_PHOTOS:"Cauta in pozele de pe Flickr (inclusiv in ale tale)",
	BEE_UPLOAD_PHOTOS:"Incarca poze in contul curent de Flickr",
	
	// Photo module (assets/html/modules/photo.htm)

	
	//About Page (assets/html/about)
	ABOUT_HEADING1: "Bee, lorem ipsum",
	ABOUT_CLOSE: "Inchide",
	
	//Postedit (/assets/html/modules/postedit.htm)
	//POSTEDIT_WHERE_2POST: "Where to post?",

	// Blog (/assets/html/modules/blog.htm:)
	BLOG_SYNCHRONIZE: "Ultimele schimbari nu au fost trimis; click pentru a incerca sincronizarea",
	BLOG_CREATEPOST: "Click pentru a crea o noua inregistrare in blog",
	//BLOG_POST_TITLE: "Title:",
	//BLOG_POST_CONTENT: "Content:",
	BLOG_POST_BACK: "Renunti la ce ai scris si te intoarci pe blog",
	//BLOG_CATEGORIES: "Alege categoriile acestui articol",
	BLOG_POST_PUBLISH: "Publica aceasta intrare in blog",
	BLOG_POST_SAVEDRAFT: "Salveaza intrarea pentru mai tarziu si se intoarce la blog",
	BLOG_POST_PREVIEW: "Vezi cum va arata articolul pe blog",
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
    WP_SETTINGS_TITLE: "Conturile de WordPress pe care le ai in Bee",
    //NO_WP_ACCOUNT: "You haven't added a Wordpress account yet.",
    FL_SETTINGS_TITLE: "Conturile de Flickr pe care le ai in Bee",
    //NO_FL_ACCOUNT: "You haven't added a Flickr account yet.",
	
	
	// settings create wordpress account
	
	SETTINGS_DIV_WP_CREATE: "Creeaza-ti un blog gratuit pe WordPress.com",
	
	SETTINGS_DIV_WP_INFO: "Ai nevoie de un cont WordPress pentru a utiliza Bee",
	
	SETTINGS_SPAN_ACCINFOLABEL: "Ai un blog?",
};

var lang = {
	lang : "ro",
	
	//bee.htm
	PHOTO_VIEW: "<b>Photo</b>View",
	BLOG_VIEW: "<b>Blog</b>View",
	BEE_SEARCH_PHOTOS: "Cauta poze",
	BEE_UPLOAD_PHOTOS: "Incarca poze",
	BEE_BLOG_EMPTY: "Blogul este gol <br>",
	BEE_FIRST_POST_WITH_BEE: "<b>Click pentru a scrie primul articol cu Bee</b>",
	BEE_NO_SEARCH_RESULTS: "Cautarea nu a intors rezultate. Blogul NU este gol.<br>",
	BEE_SHOW_ALL_POSTS: "<b>Click aici pentru a vedea tot blogul</b>",
	BEE_ALL_POSTS: "Toate articolele",
	BEE_ALL_POSTS_STAR: "*Toate articolele",
	BEE_DRAFTS_STAR: "*Ciorne",
	CLOSE: "Inchide",
	BEE_CURRENT_BLOG_ACCOUNT: "Blogul curent: ",
	GOTO_BLOG_PAGE: "", // it should be empty
	BEE_CURRENT_PHOTO_ACCOUNT: "Contul Flickr curent: ",
	BEE_NO_FLICKR_ACCOUNT: "Nu ai inca un cont de Flickr, poti sa",
	BEE_ADD_FLICKR_ACCOUNT_NOW: "adaugi un cont de Flickr acum",
	BEE_OR_SEARCH_PUBLIC_PHOTOS: "cauti poze publice de pe Flickr",
	BEE_PHOTOSETS:"Seturi de fotografii",
	BEE_PHOTOS:"Pagini de poze",
	BEE_SUBTITLE: "Rezultate:&nbsp;",
	BEE_VIEW_NEXT_PAGE_PUBLIC_RESULTS: "Pagina urmatoare cu rezultate publice...",
	BEE_VIEW_PREVIOUS_PAGE_YOUR_RESULTS: "Pagini precedente cu rezultate...",
	GOTO_PHOTO_PAGE: "",
	BEE_BEE_BLOG_EDITOR:"Bee Blog Editor",
	BEE_QUICK_START:"Acces rapid",
	QS_BEE_CREATE_NEW_POST:"Creeaza un articol nou",
	QS_BEE_BLOG_ABOUT_PHOTO:"Scrie despre o poza",
	QS_BEE_JUST_BROWSE:"Rasfoieste blogul",
	QS_BEE_DONT_SHOW_AGAIN:"Nu mai arata",
	BEE_UPLOAD_CANCEL:"Renunta",
	BEE_UPLOAD_TO_FLICKR:"Incarca pe Flickr",
	BEE_UPLOAD_BROWSE:"Cauta local",
	YES:"Da",
	NO:"Nu",
	CANCEL:"Renunta",
	OK:"Ok",
	BEE_SYNC_TO_PUBLISH:"se publica la sincronizare",
	BEE_FILTER_BY:"Filtreaza dupa: ",
	BEE_POST_PREVIEW:"Poza",
	BEE_SEARCH_RESULTS:"Rezultate",
	BEE_TO_RESULTS_PUBLIC:"Mergi la rezultate publice",
	BEE_TO_RESULTS_YOURS:"Mergi la rezultate din pozele tale",
	BEE_RESULTS_IN_PUBLIC_PHOTOS:"Rezultate in poze publice",
	BEE_UPLOAD_TITLE:"Incarcare poze",
	BEE_PHOTO_REMOVE:"Sterge",
	BEE_SETTINGS:"Setari",
	BEE_GOTO_TRAY:"Minimizeaza in tray",
	BEE_DONT_START_SCREEN:"Nu mai arata ecranul de start",
	BEE_DONT_TOOLTIPS:"Nu arata tooltips",
	BEE_PHOTO_UPLOADING_OPTIONS:"Optiuni incarcare poze",
	BEE_PRIVATE:"Privat",
	BEE_FRIENDS:"Prietenii pot vedea",
	BEE_FAMILY:"Familia poate vedea",
	BEE_PUBLIC:"Public",
	BEE_JUST_TELLME_EXISTING_BLOG:"sau spune-mi despre blogul tau",
	BEE_REFRESH_TEMPLATE:"Actualizeaza aspectul",
	BEE_ABOUT_BEE:"Despre Bee",
	BEE_ABOUT_DBEFPB:"Desktop Blog Editor For Photo Blogging",
	BEE_ABOUT_USED_LIBRARIES:"",
	BEE_MODAL12_SYNC_BLOGS:"Sincronizez",
	BEE_MODAL12_RETRY:"Reincearca",
	BEE_DIRTY_ALERT:"Alerta!",
	BEE_DIRTY_DO_YOU_WANT_SAVE:"Vrei sa salvezi o ciorna?",
	BEE_DELETE:"Sterge",
	
	// Settings page (assets/html/settings/main.htm)	
	SETTINGS_SPAN_LABEL : "Setari",
	SETTINGS_INPUT_CLOSE : "Inchide",
	SETTINGS_INPUT_CANCEL : "Renunta",
	SETTINGS_INPUT_FINISH : "Gata",
	SETTINGS_INPUT_CONTINUE : "Continua",
	SETTINGS_INPUT_ADDWPACCOUNT : "Adauga cont de WordPress",
	SETTINGS_INPUT_ADDFLKACCOUNT : "Adauga cont de Flickr",
	SETTINGS_SPAN_ACCINFOLABEL : "Setarile conturilor",
	SETTINGS_SPAN_TITLE : "Numele blogului",
	SETTINGS_SPAN_ACCESSPOINT : "Adresa blogului",
	SETTINGS_SPAN_USER : "Utilizator",
	SETTINGS_SPAN_PASSWORD : "Parola",
	SETTINGS_INPUT_ADD : "Adauga",
	SETTINGS_INPUT_SAVE : "Salveaza",
	SETTINGS_CURRENT_LANGUAGE: "Limba curenta",
	SETTINGS_EDIT_WP_ACCOUNT: "Editeaza", 
	SETTINGS_DELETE_WP_ACCOUNT: "Sterge",
	SETTINGS_TEMPLATE_WP_ACCOUNT: "Paginare",
	SETTINGS_LOGOUT_FL_ACCOUNT: "Sterge",
	SETTINGS_FR_ADD1: "Acest program are nevoie de acordul tau inainte sa " +
			"citeasca sau modifice poze de pe Flickr",
	SETTINGS_FR_ADD1_MESSAGE: "Acordul il dai intr-o fereastra de browser nou deschisa " +
			". Apasa \"Continua\" si uita-te dupa o fereastra nou deschisa" +
			"Cand ai terminat, intoarce-te la Bee. <br />" +
			"(Trebuie sa fii conectat la internet)",
	SETTINGS_FR_ADD2: "Intoarce-te la fereastra aceasta dupa ce ai terminat " +
			"autorizarea pe Flickr.com",
	SETTINGS_FR_ADD2_MESSAGE: "Dupa ce ai terminat in browser, apasa \"Gata\" " +
			"si te poti intoarce in Bee! <br /> " +
			"(Poti revoca autorizatia in orice moment din pagina ta de Flickr.) " ,
	DROP_BOX: "Drop Box",
	
	
	/*
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
	*/
	
	//About Page (assets/html/about)
	//ABOUT_HEADING1: "Bee, lorem ipsum",
	ABOUT_CLOSE: "Close",
	

	// Blog (/assets/html/modules/blog.htm:)
	BLOG_SYNCHRONIZE: "Sincronizeaza",
	BLOG_CREATEPOST: "Creeaza articol",
	BLOG_POST_TITLE: "Titlu:",
	BLOG_POST_CONTENT: "Continut:",
	BLOG_POST_BACK: "Renunta",
	BLOG_CATEGORIES: "Categorii",
	BLOG_POST_PUBLISH: "Publica",
	BLOG_POST_SAVEDRAFT: "Salveaza ciorna",
	BLOG_POST_INSERTPICTURE: "Incarca si adauga poze",
	BLOG_POST_PREVIEW: "Vizualizeaza pagina",

    // Post list (/assets/html/blog/list.htm)
    POST_EDIT: "Editeaza",
    POST_DELETE: "Sterge",
   

    // Status bar (/assets/html/status.htm)
    SYNC: "Sync",
    STATUS_SETTINGS: "Setari",

    // Navig (/assets/htm,l/navig.htm)
	NAVIG_INFORMATION: "",
    
    // Settings Main Frame (/assets/html/settings/main.htm)
    WP_SETTINGS_TITLE: "Conturi de WordPress",
    NO_WP_ACCOUNT: "Nu ai inca nici un cont de WordPress",
    FL_SETTINGS_TITLE: "Conturi de Flickr",
    NO_FL_ACCOUNT: "Nu ai inca nici un cont de Flickr",
	
	
	// settings create wordpress account
	
	SETTINGS_DIV_WP_CREATE: "Creeaza un cont gratuit pe WordPress.com",
	
	SETTINGS_DIV_WP_INFO: "Trebuie sa ai un cont WordPress pentru a utiliza Bee.",
	
	SETTINGS_SPAN_ACCINFOLABEL: "Ai un blog?",
	
	FR_AUTHENTICATION_FAILED: "Autentificare esuata. Verifica-ti contul de Flickr",
	FR_IO_ERROR: "Operatie esuata: nu pot accesa contul de Flickr.",
	FR_DELETE_FAIL: "Nu am resuit sa sterg",
	FR_DELETE_CONFIRM: "Esti sigur ca vrei sa stergi poza aceasta din contul de Flickr?" +
			"<br><br>Stergerea este definitiva!",
	
	DISCARD_CHANGES: 'Vrei sa anulezi modificarile?',
	SAVE_POST_DRAFT: 'Vrei sa salvezi postul ca draft?',
	IMAGES: "Imagini",
	UPLOADING_FILE: "Uploadez fisierul {s1} din {s2} - {s3}",
	
	CLICK_TO_ADD_DESCRIPTION: 'Da click pentru a adauga descriere',
	BLOG_INVALID : 'Adresa este invalida, exista deja instalata pe Bee!',

	SETTINGS_SPAN_ACCINFOLABEL_EDIT: 'Ce schimbari vrei sa faci blogului tau?',
	SETTINGS_DIV_WP_INFO_EDIT: '',
	
	SETTINGS_DIV_WP_INFO_ADD: "Ai nevoie de un blog pe WordPress pentru a utiliza Bee.",
	SETTINGS_SPAN_ACCINFOLABEL_ADD: "Ai un blog?",
	
	
};

// 