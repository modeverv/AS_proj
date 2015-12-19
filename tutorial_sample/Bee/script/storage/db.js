/*
ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.
 
NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the 
terms of the Adobe license agreement accompanying it.  If you have received this file from a 
source other than Adobe, then your use, modification, or distribution of it requires the prior 
written permission of Adobe.

*/


/*/================================================
 * DB class usage
 * ================================================
 		
 		var obj = {id:-7, idsrv:10};
 		
 		//deletes account 7
 		DB.saveAccount(obj);
 		
 		//and now isert it back
 		delete obj.id;	// save detects that there is no defined primary key
 		 				// and fires insert sql
 		DB.saveAccount(obj);

 		//and now you know last insert id
 		air.trace(obj.id);
 		
 		var data = AccountsDB.getAccountsByService(6);
 		
 		data[0].id *=-1;
 		data[1].title = 'modifc1';
 		DB.saveAccount(data[0]);
 		DB.saveAccount(data[1]);
 		
 		
 		//var obj = { id:-16, title : 'blog nr 2' };
 		
 		var data  = AccountsDB.getAccountsByService(2);
 		var obj = data[0];
 		
 		obj.title+=" blog vechi";
 		
 		DB.saveAccount(obj);
 		
 		
 		*/
 
 var DB = {
 	
 	conn: null,
 	schema:null,
 	init : function(){
 		
 		var conn = new air.SQLConnection();
 		DB.conn = conn;
 		
 		var file = new air.File("app-storage:/bee.db");
 		
 		var needCreate = !file.exists;

 		
 		conn.open(file);
 		
	 		var schema = null;
			
			try{
  				DB.conn.loadSchema();
	 			schema = DB.conn.getSchemaResult();
	 		}catch(e){
				DB.createTables();
	 			DB.conn.loadSchema();
	 			schema = DB.conn.getSchemaResult();
	 		}
	 		DB.schema = DB.processSchema(schema);

	 		air.debug(DB.schema);
	
 	},
 	
	processSchema: function(schema){
		if(!schema){
			air.error("Table error: no schema!");
			return;
		}
		var result = {};
		for(var i=schema.tables.length-1;i>=0;i--)
		{
			var table = schema.tables[i];
			var columns = [];
			var primaryKey = null;
			for(var l=table.columns.length-1;l>=0;l--){
				var shortName = table.columns[l].name;
				shortName = shortName.substr(0, shortName.length-4);
				var column = { name: table.columns[l].name,  shortName: shortName, primaryKey: table.columns[l].primaryKey};
				if(table.columns[l].primaryKey)
					primaryKey = column;
				columns.push( column );
			}
			result[table.name] = { name: table.name,  columns : columns, primaryKey: primaryKey };
		}
		return result;
	},
 
 	//on first load create tables
 	createTables: function(){
 		
 		var command = new air.SQLStatement();
 		
 		command.sqlConnection = DB.conn;
 		
 		var file = new air.File("app:/storage/data/bee.sql");
 		var filestream = new air.FileStream() ;
 		
 		filestream.open( file , air.FileMode.READ );
 	
 		var sql = filestream.readUTFBytes(file.size);
 		
 		filestream.close();
 	
 		var lines = sql.split('\n');	
 	
 	
 		for(var i=0;i<lines.length;i++){	
 			
 			var line = String(lines[i]).trim();
 			if(line.length==0) continue;
 			if(line.substring(0,2) == '//') continue;
 			
 			command.text = lines[i];
	 		
	 		command.execute();
	 	}
 	
 		
 		
 	},
 	
 	//close DB when app quits
 	unload : function (){
 		DB.conn.clean();
 		DB.conn.close();
 	},
 	
 	//run sql with params
 	//className not supported 
 	execute : function(sql, params, className){
 			
 		
 		var command = new air.SQLStatement();
 		
 		command.sqlConnection = DB.conn;
 		
 		command.text = sql;
 		
 		if((typeof className!='undefined')&&className!=null)
 			command.itemClass =  className;
 		
 		
 		if(typeof params!='undefined'){
 			if(params.size)
 				for(var i=0;i<params.length;i++){
 					if(params[i] instanceof Date){
						command.parameters[i] = params[i].toString();
	 				}else{
	 					command.parameters[i] = params[i];	
					}
 				}
 			else{
 					//alert (print_o(params, 'alert'));
 				for( var j in params){
 					var param = params[j];
 					if(param instanceof Date)
	 					command.parameters[j]=param.toString();
	 				else
	 					command.parameters[j]=param;
	 			}
 				
 				//Object.extend(command.parameters, params);
 				
 				
 				}
 			
 		}
 		
 		try{
 			command.execute();
 		    var data = command.getResult();
	 		air.debug("db.execute: " + sql, sql, params, data);

 			return data;
 		}catch(e){
 			air.error(e, "db.execute: " + sql, sql, params, data);
 			return [];
 		}
 		
 	},
 	
 	//striping last 4 chars in field names
 	//if you use field names like {id_acc, name_acc} it will be usefull to remove last 4 chars
 	tableStrip : function(e){
 		if(e==null) return [];
 		for(var r=0;r<e.length;r++){
 			var row = e[r];
 			for (var i in row)
 			{
 				row[i.substr(0, i.length-4)] = row[i];
 				delete row[i];
 			}
 		}
 		return e;
 	},
 	
 	//update obj row in table
 	update: function (obj, tbl){
 		var sql = 'UPDATE `'+tbl.name+'` SET ';
 		var primary = ' WHERE ';
 		//var sufix = tbl.name.substr(tbl.name.length-4, 4);
 		var j=0;
 		for(var i=tbl.columns.length-1;i>=0;i--){
 			if(typeof obj[tbl.columns[i].shortName]!='undefined'){
 				if(tbl.columns[i].primaryKey)
	 				primary += '`'+tbl.columns[i].name+'`=?';
				else{
					if(j++) sql+=',';
	 				sql+='`'+tbl.columns[i].name+'`=?';
	 			
				}
 			}
 		}
 		
 		sql += primary;
 	
 		var command = new air.SQLStatement();
 		
 		command.sqlConnection = DB.conn;
 		
 		command.text = sql;
 		var j=0;
 		
 		for(var i=tbl.columns.length-1;i>=0;i--){
 			if(!tbl.columns[i].primaryKey){
 				if(typeof obj[tbl.columns[i].shortName]!='undefined'){
					var value = obj[tbl.columns[i].shortName];
					if(value instanceof Date){
						command.parameters[j++]=value.toString();
					}else{
						command.parameters[j++]=value;
					}
				}
			}
		}
 		
 		if(typeof obj[tbl.primaryKey.shortName]!='undefined')
 			command.parameters[j++]=obj[tbl.primaryKey.shortName];
 					
 		command.execute();
 		
 		return true;
 		
 		
 	},
 	
 	//insert new row in table tbl with values from obj
 	insert: function (obj, tbl){
 		var sql = 'INSERT INTO `'+tbl.name+'` (';
 		//var sufix = tbl.name.substr(tbl.name.length-4, 4);
 		var params = '';
 		
 		var j=0;
 		
 		for(var i=tbl.columns.length-1;i>=0;i--){
 			if(typeof obj[tbl.columns[i].shortName]!='undefined'){
	 			if(j++) {sql+=',';params+=',';}
	 			sql+='`'+tbl.columns[i].name+'`';
				params+='?';
 			}
 		}
 		
 		sql = sql + ') values ('+params+')';
 		var command = new air.SQLStatement();
 		
 		command.sqlConnection = DB.conn;

 		command.text = sql;
 		j=0;
 		
 		for(var i=tbl.columns.length-1;i>=0;i--){
 			if(typeof obj[tbl.columns[i].shortName]!='undefined'){
				var value = obj[tbl.columns[i].shortName];
				if(value instanceof Date){
					command.parameters[j++]=value.toString();
				}else{
					command.parameters[j++]=value;
				}
			}
		}
 		
 		command.execute();
 		
 		var result = command.getResult();
 		
		obj[tbl.primaryKey.shortName] = result.lastInsertRowID;

 		return true;
 		
 	},
 	
 	//return table schema from cache
 	getTable : function (table){
 		return DB.schema[table];
 	},
 	
 	//save obj in table
 	save: function (obj, table){
	try{
 		var tbl = DB.getTable(table);

 		air.debug('save', obj, table, tbl);
 	
 		if(tbl==null) return;
 		var isinsert = false;
 		var isremove = false;
 		var primaryName = '';
 		var primaryValue = 0;

		var primaryKey = tbl.primaryKey;
	 	if(typeof obj[primaryKey.shortName]=='undefined')
	 		isinsert = true;
	 	else if(obj[primaryKey.shortName]<0){
	 		primaryValue = -obj[primaryKey.shortName];
	 		isremove = true;
	 	}
 		
 		if(isinsert){
 			return DB.insert(obj, tbl);
 		}else if(isremove){
 			return DB.remove (tbl.name, tbl.primaryKey.name, primaryValue );
 		}else{
 			return DB.update(obj, tbl);
 		}
	}catch(e){
		air.error(e, 'save', obj, table, tbl);
	}
 	},
	
	//delete row from table
 	remove : function(table, column, id){
 		var sql='DELETE FROM `'+table+'` WHERE `'+column+'`=?';
 		var result = DB.execute(sql, [id]);
 		return true;
 	},
	
	///table related shortcuts to save objects
	 	
 	saveAccount : function (obj){
 		return DB.save(obj, 'accounts_acc');
 	},
 	
 	saveService: function (obj){
 		
 		return DB.save(obj, 'services_srv');
 		
 	},
 	
 	savePending:function (obj){
 		
 		return DB.save(obj, 'pending_pnd');
 		
 	},
 	
 	savePhoto:function (obj){
 		
 		return DB.save(obj, 'photos_pho');
 		
 	},
 	savePhotoPhc : function (obj){
 		
 		return DB.save(obj, 'photophc_pct');
 		
 	},
	saveBlog : function (obj){
 		
 		return DB.save(obj, 'blogs_blg');
 		
 	},
 	savePndToPnd : function (obj){
 		
 		return DB.save(obj, 'pnttopnd_ptp');
 		
 	},
 	
 	savePosToPoc : function (obj){
 		
 		return DB.save(obj, 'postopoc_psc');
 		
 	},
 	savePostCategory:function(obj){
 		
 		return DB.save(obj, 'postcategories_poc');
 	},
 	savePhotoCategory:function(obj){
 		
 		return DB.save(obj, 'photocategories_phc');
 	},
 	
 	savePost : function (obj){
 		return DB.save(obj, 'posts_pos');
 	}
 	
 
 	
 };
 

 //====================================
 //sql shortcuts for accounts
 var AccountsDB= {
 	
 	getAccountsByService : function(service){
 		var result = DB.execute('SELECT * FROM accounts_acc WHERE idsrv_acc=:idsrv', {":idsrv":service});
 		return DB.tableStrip(result.data);
 		
 	},
	
	getAccount : function(id){
 		var result = DB.execute('SELECT * FROM accounts_acc where id_acc=?', [id]);
 		
 		var data = DB.tableStrip(result.data);
 		if(data.length)
	 		return data[0];
	 	return null;
 		
 	},
 	
 	getAccountByTitle : function( title ){
 		var result = DB.execute('SELECT * FROM accounts_acc where title_acc=?', [title]);
 		
 		var data = DB.tableStrip(result.data);
 		if(data.length)
	 		return data[0];
	 	return null;
 	},
	
	getService : function(id){
		air.debug("Execute statemnet", DB.execute);
 		var result = DB.execute('SELECT * FROM services_srv where id_srv=?', [id]);
 		var data = DB.tableStrip(result.data);
 		if(data.length)
	 		return data[0];
	 	return null;
 		
 	},
	

 	
 	getAccounts : function(){
 		var result = DB.execute('SELECT * FROM accounts_acc');
 		return DB.tableStrip(result.data);
 	},
 	
 	getServices : function(){
 		
 		var result = DB.execute('SELECT * FROM services_srv');
 		return DB.tableStrip(result.data);
 		
 	},
 	
 	getServicesByType : function (class_srv){
 		
 		var result = DB.execute('SELECT * FROM services_srv WHERE class_srv=:class_srv', {":class_srv":class_srv});
 		return DB.tableStrip(result.data);
 	},
 	
 /*	insertAccount : function (account){
 		with(account){
 			var result = DB.execute('INSERT INTO accounts_acc (idsrv_acc, title_acc, rules_acc) VALUES (?, ?, ?)', 
 					[idsrv, title, rules]);
 			account.id = result.lastInsertRowID;
 		}
 		return account;
 	},
 	
 	updateAccount : function (account){
 		with(account){
 			var result = DB.execute('UPDATE accounts_acc SET idsrv_acc=?, title_acc=?, rules_acc=? WHERE id=?', 
 					[idsrv, title, rules, id]);
 		}
 		return account;
 	},
 	
 	removeAccount : function (id){
 		var result = DB.execute('DELETE FROM accounts_acc WHERE id_acc=?', 
 					[id]);
 	}
 	*/
 }
 //====================================
 //sql shortcuts for blogs
 BlogDB  = {
 	
 	getPosts : function(){
 		var result = DB.execute('SELECT * FROM posts_pos WHERE (ifnull(serverid_pos, 0)>=0) ORDER BY isdraft_pos desc, date(date_pos) desc');
 		return DB.tableStrip(result.data);
 		
 		
 	},
	
	getBlogPosts : function(id){
 		var result = DB.execute('SELECT * FROM posts_pos WHERE (ifnull(serverid_pos, 0)>=0) and idblg_pos=? ORDER BY isdraft_pos desc, date(date_pos) DESC', [id]);
 		return DB.tableStrip(result.data);
 		
 		
 	},

	getBlogPostsDrafts : function(id){
 		var result = DB.execute('SELECT * FROM posts_pos WHERE (ifnull(serverid_pos, 0)>=0) and isdraft_pos=1 and idblg_pos=? ORDER BY date(date_pos) DESC', [id]);
 		return DB.tableStrip(result.data);
 		
 		
 	},

	getBlogPostsFilter : function(id, cat){
 		var result = DB.execute('SELECT posts_pos.* FROM postopoc_psc , posts_pos WHERE id_pos = idpos_psc AND idblg_pos=? AND idpoc_psc = ? ORDER BY isdraft_pos desc, date(date_pos) DESC', [id, cat]);
 		return DB.tableStrip(result.data);
 		
 		
 	},

 	
 	getBlogCats : function(id){
 		var result = DB.execute('SELECT * FROM postcategories_poc WHERE idblg_poc=? ORDER BY name_poc', [id]);
 		return DB.tableStrip(result.data);
 		
 		
 	},
	
	deleteBlogPosts : function(id){
 		var result = DB.execute('DELETE FROM posts_pos WHERE idblg_pos=?', [id]);
 		
 	},
 	
 	getAllPosts: function(){
 		var result = DB.execute('SELECT * FROM posts_pos');
 		return DB.tableStrip(result.data);
 	
 	},
 	
 	getUploadPosts: function (blogid){
 		var result = DB.execute('SELECT * FROM posts_pos WHERE ispublished_pos=0 AND isdraft_pos=0 AND idblg_pos=?', [blogid]);
 		return DB.tableStrip(result.data);
 	
 	},
 	
 	getDownloadPosts : function(blogid){
 		var result = DB.execute('SELECT * FROM posts_pos  WHERE idblg_pos=?', [blogid]);
 		return DB.tableStrip(result.data);
 		
 		
 	},
 	
 	getPost : function(id){
 		var result = DB.execute('SELECT * FROM posts_pos where id_pos=?', [id]);
 		
 		var data = DB.tableStrip(result.data);
 		if(data.length)
	 		return data[0];
	 	return null;
 		
 	},
 	
 	getPostCats : function(id){
 		var result = DB.execute('SELECT idpoc_psc FROM postopoc_psc WHERE idpos_psc=?', [id]);
		var res =  DB.tableStrip(result.data); 
		var ret = {};
		for(var i=0;i<res.length;i++)
			ret[res[i].idpoc] = true;
		
 		return ret;
 	},
 	
 	
 	
 	
 	getPostCatNames : function(id){
 		var result = DB.execute('SELECT name_poc FROM postcategories_poc, postopoc_psc WHERE id_poc=idpoc_psc and idpos_psc = ?', [id]);
		var res =  DB.tableStrip(result.data); 

		var ret = [];
		for(var i=0;i<res.length;i++)
			ret.push(res[i].name);

 		return ret;
 	},
 	
 	getPostCatString: function (id){
 		var result = DB.execute('SELECT name_poc FROM postcategories_poc, postopoc_psc WHERE id_poc=idpoc_psc and idpos_psc = ?', [id]);
		var res =  DB.tableStrip(result.data); 

		var ret = "";
		for(var i=0;i<res.length;i++){
			if(ret.length) ret+=", ";
			ret+=res[i].name;
		}
 		return ret;
 	},
 	
	//unlink all cats from a post
	unlinkPost: function (id){
		var result = DB.execute('DELETE FROM postopoc_psc where idpos_psc=?', [id]);
	},
	
	//link a post to a category
	linkPost: function(id, cat){
		var result = DB.execute('INSERT INTO postopoc_psc (idpos_psc, idpoc_psc) values (?,?)', [id, cat]);
	},
	
	getBlogs : function(id){
 		var result = DB.execute('SELECT * FROM blogs_blg where idacc_blg=?', [id]);
 		

	 	return DB.tableStrip(result.data);
 		
 	},


	
	getBlog : function(id){
 		var result = DB.execute('SELECT * FROM blogs_blg where id_blg=?', [id]);
 		
 		var data = DB.tableStrip(result.data);
 		if(data.length)
	 		return data[0];
	 	return null;
 		
 	},
	
	
	//upload posts to wordpress
	upload : function(blogObj, callback){
		var atom = new Bee.Net.AsyncAtom();
		
		var posts = BlogDB.getUploadPosts(blogObj.blogRules.blogId);
		atom.addHandler('edit', function(i, result, err){
							if(result){
								posts[i].ispublished = 1;
								DB.savePost({id : posts[i].id, ispublished: posts[i].ispublished});
							}
					});
					
		atom.addHandler('insert', function(i,result, err){
							if(result){
								posts[i].ispublished = 1;
								DB.savePost({id : posts[i].id, serverid:posts[i].serverid,  ispublished: posts[i].ispublished});
							}
					});
					

		atom.onfinish = function(){
			if(callback) callback();
		}
		
		
		for (var i=0;i<posts.length;i++){
				if(posts[i].serverid){
					posts[i]['date']=Date.parse(posts[i]['date']);
					posts[i].categories = BlogDB.getPostCatNames(posts[i].id);
					blogObj.editPost(posts[i], atom.getHandler('edit',i));					
				
				}else{
					posts[i]['date']=Date.parse(posts[i]['date']);
					posts[i].categories = BlogDB.getPostCatNames(posts[i].id);				
					blogObj.newPost(posts[i], atom.getHandler('insert', i));
				}
		}
		
		atom.finish();
	},
	
	
	
	//download posts from wordpress
	download : function(blogObj, callback){	
		blogObj.isConnected(function (connected){
			try{
			if(!connected){
				 callback(false);
				 return;				 
				}
			
		    var sqldata = BlogDB.getDownloadPosts(blogObj.blogRules.blogId);


		    var cats = BlogDB.getBlogCats(blogObj.blogRules.blogId);
			   
	
		    var catsHash = {}; 
		    var catsHashId = {};
		    
		    for(var i =0;i<cats.length;i++){
		    	 catsHash[cats[i].name]=cats[i];
		    	 catsHashId[cats[i].id]=cats[i];
		    	}

		    var posts = {};
		    var deleted = {};
			
			
		    for(var i=0;i<sqldata.length;i++) 	{
		    	if(sqldata[i].serverid>=0)
		    		posts[sqldata[i].serverid] = sqldata[i];
		    	else
			    	deleted[-sqldata[i].serverid] = sqldata[i];
		    	}
				
				
		 		blogObj.getPosts(function(data, err){
						if(err){
							var ok = err.faultString.indexOf('there are no posts')>0;
							if(ok){
								for(var i in posts) 
									if(posts[i].ispublished)
										DB.savePost({id:-posts[i]['id']});
							}
							
							callback(ok);
						
						}else{
							var nCatsHash = {};
							var atom = new Bee.Net.AsyncAtom();
					
							atom.addHandler('delete', function(obj, result, err){
								if(result)
									DB.savePost({id:-obj['id']});
								delete this.deleted[obj.serverid];
							});
							
							atom.addHandler('cats', function (obj, result, err){
								
								if(!err){
									for(var i=0;i<result.length;i++)
										if(result[i].name!='Blogroll'){
											var obj = catsHash[result[i].name];
											var shouldSave = true;
											if(obj){
												 result[i].id = obj.id;
												 
												 shouldSave = false;
												 if(result[i].name!=obj.name ||
												 	result[i].serverid!=obj.serverid)
												 		shouldSave=true;
												 	
												 delete catsHashId[result[i].id];
												 //DB.savePostCategory({id:-obj.id});
											}
											if(shouldSave){
												result[i].idblg = blogObj.blogRules.blogId;
												DB.savePostCategory(result[i]);
												nCatsHash[result[i].name] = result[i].id;
											}else{
												nCatsHash[result[i].name] = obj.id;
											}
										}
									
									
									for(var i in catsHashId){
											
											DB.savePostCategory({id:-i});									
									}
									
								}
								
								
								for(var i=0; i<data.length; i++){
				
									data[i].ispublished = 1;
									data[i].isdraft = 0;
									data[i].idblg = blogObj.blogRules.blogId;
									
									var saved = true;
									
									var sqlobj = posts[data[i].serverid];
									
									if(sqlobj){
											if(sqlobj.ispublished){
												data[i].id=sqlobj['id'];
												
												if(data[i].title!=sqlobj.title ||
													data[i].content!=sqlobj.content ||	
														data[i].textmore!=sqlobj.textmore ||
															Date.parse(data[i].date) != Date.parse(sqlobj.date) ){
															DB.savePost(data[i]);
													}
													
											}
											delete posts[data[i].serverid];
									}else{
									
										var delobj = deleted[data[i].serverid];
										
										if(delobj){
											  blogObj.deletePost(data[i].serverid, atom.getHandler('delete', delobj));
											  saved = false;
										}else{
									 		DB.savePost(data[i]);
										}
										
									}
									
									
									
									if(saved){
											if(data[i].categories){
												var dCats = BlogDB.getPostCats(data[i].id);
												var pCats = data[i].categories;
												var sCats = {};
												
												//BlogDB.unlinkPost(data[i].id);
												for(var j=0;j<pCats.length;j++){
													var cat = nCatsHash[pCats[j]];
													if(cat)
													{
														sCats[cat] = true;
														if(!dCats[cat])
															BlogDB.linkPost(data[i].id, cat);
													}
												}
												
												for(var j in dCats){
													if(!sCats[j])
													{
														BlogDB.unlinkPost(data[i].id, j);
													}
												}
											}
									}	
										
										
									
								}
						
							for(var i in posts) 
								if(posts[i].ispublished){
									DB.savePost({id:-posts[i]['id']});
								}
							});
							
							blogObj.getCats( atom.getHandler('cats', null) );

							atom.deleted = deleted;
							
							atom.onfinish=function(){
								var deleted = this.deleted;
								for(var i in deleted) {
									DB.savePost({id:-deleted[i]['id']});
								}		
								callback(true);
							}
							
					
						atom.finish();
						}
				});
					
			}catch(e){ }		
		});

	},

 	
 }
 
 
 Bee.Storage.Db = DB;
 Bee.Storage.Db.Accounts = AccountsDB;
 Bee.Storage.Db.Blog = BlogDB;		
 
 






