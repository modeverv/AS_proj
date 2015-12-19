//	ADOBE SYSTEMS INCORPORATED
// 	 Copyright 2007 Adobe Systems Incorporated
// 	 All Rights Reserved.
// 
//	NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the 
//	terms of the Adobe license agreement accompanying it.  If you have received this file from a 
//	source other than Adobe, then your use, modification, or distribution of it requires the prior 
//	written permission of Adobe.
//

CREATE TABLE accounts_acc ( id_acc INTEGER PRIMARY KEY AUTOINCREMENT, idsrv_acc INTEGER , title_acc VARCHAR(255) , rules_acc TEXT );
CREATE TABLE blogs_blg ( id_blg INTEGER PRIMARY KEY, serverid_blg INTEGER, idacc_blg INTEGER, rules_blg TEXT , title_blg VARCHAR ( 255 ) );
CREATE TABLE postcategories_poc ( id_poc INTEGER PRIMARY KEY AUTOINCREMENT, idpoc_poc INTEGER, serverid_poc INTEGER, idblg_poc INTEGER, name_poc VARCHAR(255) , description_poc TEXT , htmlurl_poc TEXT, rssurl_poc TEXT);
CREATE TABLE postopoc_psc ( id_psc INTEGER PRIMARY KEY AUTOINCREMENT, idpoc_psc INTEGER, idpos_psc INTEGER );
CREATE TABLE posts_pos ( id_pos INTEGER PRIMARY KEY AUTOINCREMENT, idpos_pos INTEGER, serverid_pos INTEGER, idblg_pos INTEGER , authorid_pos INTEGER, authorname_pos VARCHAR(255), title_pos VARCHAR(255), content_pos TEXT, date_pos VARCHAR(50), ispost_pos BOOLEAN, isdraft_pos BOOLEAN, ispublished_pos BOOLEAN, link_pos TEXT, permalink_pos TEXT, excerpt_pos TEXT, textmore_pos TEXT, allowcomments_pos BOOLEAN, allowpings_pos BOOLEAN, slug_pos VARCHAR (255), password_pos VARCHAR(255) );
CREATE TABLE services_srv ( id_srv INTEGER PRIMARY KEY AUTOINCREMENT, class_srv INTEGER , name_srv VARCHAR(255), rules_srv TEXT );
INSERT INTO services_srv VALUES ('1', '1', 'WordPress 2.2.x', ' ');
INSERT INTO services_srv VALUES ('2', '2', 'Flickr', ' ');


// not needed
// CREATE TABLE pending_pnd ( id_pnd INTEGER PRIMARY KEY AUTOINCREMENT, title_pnd VARCHAR(255), date_pnd DATETIME, counter_pnd INTEGER, type_pnd INTEGER, info_pnd TEXT, path_pnd TEXT );
// CREATE TABLE photocategories_phc ( id_phc INTEGER PRIMARY KEY AUTOINCREMENT, idacc_phc INTEGER, title_phc VARCHAR(255), description_phc TEXT, comments_phc TEXT );
// CREATE TABLE photophc_pct ( id_pct INTEGER PRIMARY KEY AUTOINCREMENT, idphc_pct INTEGER, idpho_pct BIGINTEGER );
// CREATE TABLE photos_pho ( id_pho INTEGER PRIMARY KEY AUTOINCREMENT, idacc_pho INTEGER, title_pho VARCHAR(255), description_pho TEXT, datetaken_pho DATETIME , dateuploaded_pho TIMESTAMP, info_pho TEXT, comments_pho TEXT, tags_pho TEXT, uploadstate_pho INTEGER, safetylevel_pho INTEGER, privacylevel_pho INTEGER, sourcesm_pho TEXT, localthumbnailpath_pho TEXT, localpath_pho TEXT);
// CREATE TABLE pndtopnd_ptp ( id_ptp INTEGER PRIMARY KEY AUTOINCREMENT, idpndpos_ptp INTEGER, idpndpho_ptp INTEGER );
