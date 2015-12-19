/*
 * Copyright 2007-2008. Adobe Systems Incorporated.
 * All rights reserved.
 */


var Fresh; if (!Fresh) Fresh = {};
             
Fresh.FeedPanel = function(feedDB) {
	Fresh.FeedPanel.superclass.constructor.call(this, {
		id: 'feed-tree',
		region: 'west',
		title: _T( 'fresh', 'lblFeeds' ),
		split: true,
		width: 225,
		minSize: 175,
		maxSize: 400,
		collapsible: true,
		margins: '5 0 5 5',
		cmargins: '5 5 5 5',
		rootVisible: false,
		//lines: false,
		autoScroll: true,
		root: new Ext.tree.TreeNode({text: _T( 'fresh', 'Fresh' ), allowDrop: false}),
		collapsibleFirst: false,
		enableDD: true,
		lines: false,
		
		tbar: [{
			iconCls: 'add-feed',
			text: _T( 'fresh', 'mnuAddFeed' ),
			handler: function() { this.showWindow() },
			scope: this
		}, {
			id: 'delete',
			iconCls: 'delete-icon',
			text: _T( 'fresh', 'mnuRemove' ),
			handler: function(){
				var s = this.getSelectionModel().getSelectedNode();
				if(s){
					if (!s.attributes.special) {
						if (s.attributes.folderId) {
							this.removeFolder(s.attributes.folderId);
						} else if (s.attributes.feedId) {
							this.removeFeed(s.attributes.folderId);
						}
						
					}
				}
			},
			scope: this
		}, {
			iconCls: 'add-folder',
			text: _T( 'fresh', 'btnAddFolder' ),
			handler: this.addFolder,
			scope: this
		}]
	});
	this.feedDB = feedDB;
	// add an inline editor for the nodes
	this.nodeEditor = new Ext.tree.TreeFolderEditor(this, {
		allowBlank:false,
		blankText:_T( 'fresh', 'lblNameRequired' ),
		selectOnFocus:true
	});
	this.nodeEditor.on("beforestartedit", this.beforeNodeEdit, this);
	this.nodeEditor.on('beforeshow', this.beforeEditShow, this)
	this.nodeEditor.on("complete", this.folderEditComplete, this);
	//
// update special date view
	var res = this.feedDB.getArticlesCountByDate();		
	this.views = this.root.appendChild(
		new Ext.tree.TreeNode({
			text: _T( 'fresh', 'treeNodeViews' ),
			cls: 'feeds-node',
			expanded: true,
			special: true,
			allowDrag: false,
			allowDrop: false
		})
	);
	this.allView = this.views.appendChild(
		new Ext.tree.TreeNode({
			text: _T( 'fresh', 'treeNodeAllFormat', [ res[1].unread, res[1].total ] ),
			cls: 'views-node'+ (res[1].unread ? ' unread' : ''),
			expanded: true,
			special: true,
			specialId: 1,
			allowDrag: false,
			allowDrop: false,
			title: _T( 'fresh', 'treeNodeAll' ),
			unreadArticles: res[1].unread,
			totalArticle: res[1].total
		})
	);
	this.todayView = this.views.appendChild(
		new Ext.tree.TreeNode({
			text: _T( 'fresh', 'treeNodeTodayFormat' , [ res[2].unread, res[2].total ] ),
			cls: 'views-node'+ (res[2].unread ? ' unread' : ''),
			expanded: true,
			special: true,
			specialId: 2,
			allowDrag: false,
			allowDrop: false,
			title: _T( 'fresh', 'treeNodeToday' ),
			unreadArticles: res[2].unread,
			totalArticle: res[2].total
		})
	);
	this.weekView = this.views.appendChild(
		new Ext.tree.TreeNode({
			text: _T( 'fresh', 'treeNodeLastWeekFormat', [res[3].unread , res[3].total] ),
			cls: 'views-node'+ (res[3].unread ? ' unread' : ''),
			expanded: true,
			special: true,
			specialId: 3,
			allowDrag: false,
			allowDrop: false,
			title: _T( 'fresh', 'treeNodeLastWeek' ),
			unreadArticles: res[3].unread,
			totalArticle: res[3].total
		})
	);
	this.monthView = this.views.appendChild(
		new Ext.tree.TreeNode({
			text: _T( 'fresh', 'treeNodeLastMonthFormat', [res[4].unread, res[4].total] ),
			cls: 'views-node' + (res[4].unread ? ' unread' : ''),
			expanded: true,
			special: true,
			specialId: 4,
			allowDrag: false,
			allowDrop: false,
			title: _T( 'fresh', 'treeNodeLastMonth' ),
			unreadArticles: res[4].unread,
			totalArticle: res[4].total
			
		})
	);
	this.olderView = this.views.appendChild(
		new Ext.tree.TreeNode({
			text: _T( 'fresh', 'treeNodeOlderFormat', [res[5].unread, res[5].total] ),
			cls: 'views-node'+ (res[5].unread ? ' unread' : ''),
			expanded: true,
			special: true,
			specialId: 5,
			allowDrag: false,
			allowDrop: false,
			title: _T( 'fresh', 'treeNodeOlder' ),
			unreadArticles: res[5].unread,
			totalArticle: res[5].total
		})
	);
	
	this.feeds = this.root.appendChild(
		new Ext.tree.TreeNode({
			text: _T( 'fresh', 'lblFeeds' ),
			cls: 'feeds-node',
			expanded: true,
			special: true,
			allowDrag: false,
			allowDrop: true
		})
	);
	/*
	this.tags = this.root.appendChild(
		new Ext.tree.TreeNode({
			text: 'Tags',
			cls: 'feeds-node',
			expanded: false,
			special: true,
			allowDrag: false,
			allowDrop: false
		})
	);
	*/
	//
	this.getSelectionModel().on({
		'beforeselect': function(sm, node) {
			//return node.isLeaf();
			return true;
		},
		'selectionchange': function(sm, node) {
			if (node) {
				this.fireEvent('feedselect', node.attributes);
			}
			this.getTopToolbar().items.get('delete').setDisabled(!node);
		},
		scope: this
	});
	var _self = this;
	this.on("render", function() {
		_self.getTreeEl().on("keydown", _self.onKeyDown, _self);
	});
	this.addEvents({feedselect: true});
	this.on('contextmenu', this.onContextMenu, this);
	this.on('nodedrop', this.onNodeDropped, this);
};

Ext.extend(Fresh.FeedPanel, Ext.tree.TreePanel, {
	init: function() {
		this.refreshFeeds(true);
		//this.refreshTags();
	},
	
	refreshFeeds: function(deleteTree) {
		var _self = this;
		try{
			if (deleteTree) {
				while (this.feeds.firstChild) {
					this.feeds.removeChild(this.feeds.firstChild);
				}
			}
			var feedsCount = this.feedDB.getFeedsCount();
			var feedHash = [];
			feedsCount.forEach(function(feed) {
				var f = feedHash[feed.feedId] || {total: 0, unread: 0};
				f.total += feed.total;
				if (feed.read == 0) f.unread += feed.total; 
				feedHash[feed.feedId] = f;
			});		
	
			// create folder list
			var folders = this.feedDB.getFolders();
			var foldersCount = this.feedDB.getFoldersCount();
			var folderHash = [];
			foldersCount.forEach(function(folder) {
				var f = folderHash[folder.folderId] || {total: 0, unread: 0};
				f.total += folder.total;
				if (folder.read == 0) f.unread += folder.total; 
				folderHash[folder.folderId] = f;
			});
			folders.forEach(function(folder) {
				var f = folderHash[folder.folder_id] || {total: 0, unread: 0}; 
				var	folderText = folder.folder_name + ' ' + f.unread + '/' + f.total;
				var node = null;
				if (deleteTree) {
					// create folder node
					node = this.feeds.appendChild(
						new Ext.tree.TreeNode({
							text: folderText,
							cls: 'folder-node' + (f.unread ? ' unread' : ''),
							expanded: true,
							id: 'folder_' + folder.folder_id,
							allowDrag: false,
							folderId: folder.folder_id,
							title: folder.folder_name,
							totalFeeds: f.total,
							unreadFeeds: f.unread
						})		
					)
				} else {
					node = this.findNodeByAttr('folderId', folder.folder_id);
					air.trace("Search folder: " + folder.folder_name + " node: " + node);
					if (node) {
						node.setText(folderText);
						if (f.unread) {
							node.getUI().addClass('unread');
						} else {
							node.getUI().removeClass('unread');
						}
						node.attributes.totalFeeds = f.total;
						node.attributes.unreadFeeds = f.unread;
					}
				}
				// create feeds node for this folder
				var feeds = this.feedDB.getFeeds(folder.folder_id);
				feeds.forEach(function(feed) {
					var f = feedHash[feed.feed_id] || {total: 0, unread: 0};
					var feedText = feed.feed_title + ' ' + f.unread + "/" + f.total;
					if (deleteTree) {
						node.appendChild(
							new Ext.tree.TreeNode({
								text: feedText,
								cls: 'feed'  + (f.unread ? ' unread' : ''),
								iconCls: 'feed-icon',
								leaf:true,					
								id: 'feed_' + feed.feed_id,
								database: true,
								url: feed.feed_xmlUrl,
								feedId: feed.feed_id,
								parentId: folder.folder_id,
								title: feed.feed_title,
								totalArticles: f.total,
								unreadArticles: f.unread
							})		
						)
					} else {
						var child = this.findNodeByAttr('feedId', feed.feed_id);
						air.trace("Search feed: " + feed.feed_title + " node: " + child);
						if (child) {
							child.setText(feedText);
							child.attributes.totalArticles = f.total;
							child.attributes.unreadArticles = f.unread;
							if (f.unread) {
								child.getUI().addClass('unread');
							} else {
								child.getUI().removeClass('unread');
							}
						}
					}
				}, this);
			}, this);
			// create feeds without folder
			var feeds = this.feedDB.getFeeds();
			feeds.forEach(function(feed) {
				var f = feedHash[feed.feed_id] || {total: 0, unread: 0};
				var feedText = feed.feed_title + ' ' + f.unread + "/" + f.total;
				if (deleteTree) {
					this.feeds.appendChild(
						new Ext.tree.TreeNode({
							text: feedText,
							cls: 'feed'  + (f.unread ? ' unread' : ''),
							iconCls: 'feed-icon',
							leaf:true,					
							id: 'feed_' + feed.feed_id,
							database: true,
							url: feed.feed_xmlUrl,
							feedId: feed.feed_id,
							title: feed.feed_title,
							totalArticles: f.total,
							unreadArticles: f.unread				
						})		
					)
				} else {
					var child = this.findNodeByAttr('feedId', feed.feed_id);
					air.trace("Search feed: " + feed.feed_title + " node: " + child);
					if (child) {
						child.setText(feedText);
						child.attributes.totalArticles = f.total;
						child.attributes.unreadArticles = f.unread;
						if (f.unread) {
							child.getUI().addClass('unread');
						} else {
							child.getUI().removeClass('unread');
						}
					}
				}
			}, this);
			this.feeds.expand();
			this.updateDateViews();
			this.refreshCurrentFeed();
		}catch(e) {
			air.trace("Error refreshing feeds: " + e);
		}
	},
	
	refreshTags: function() {
		while (this.tags.firstChild) {
			this.tags.removeChild(this.tags.firstChild);
		}
		this.tags.childrenRendered = false;
		
		// create tags list
		var tags = this.feedDB.getTags();
		tags.forEach(function(tag) {
			this.tags.appendChild(
				new Ext.tree.TreeNode({
					text: tag.tag_name,
					cls: 'tag-node',
					iconCls: 'tag-icon',
					id: 'tag_' + tag.tag_id,
					leaf: true,
					allowDrag: false,
					allowDrop: false,
					special: true,
					tagId: tag.tag_id
				})		
			)
		}, this);
	},
	
	onKeyDown: function(e) {
		var k = e.getKey();
		switch(k) {
			case e.RIGHT:
				var s = this.getSelectionModel().getSelectedNode();
				if (!s) {
					return;
				}
				if (s.hasChildNodes()) {
					return;
				}
				this.fireEvent("selectgrid");
				break;
			case e.DELETE:
				var s = this.getSelectionModel().getSelectedNode();
				if (!s) {
					return;
				}
				if (s.attributes.special) {
					return;
				}
				if (s.attributes.feedId) {
					this.removeFeed(s.attributes.feedId);
				} else if (s.attributes.folderId) {
					this.removeFolder(s.attributes.folderId);
				}				
				break;
		}
	},
	
	onContextMenu : function(node, e){
		if(!this.menu){ // create context menu on first right click
			this.menu = new Ext.menu.Menu({
				id:'feeds-ctx',
				items: [{
					id:'load',
					iconCls:'load-icon',
					text:_T( 'fresh', 'mnuLoadFeed' ),
					scope: this,
					handler:function(){
						this.ctxNode.select();
					}
				},{
					text: _T( 'fresh', 'mnuRemove' ),
					iconCls:'delete-icon',
					scope: this,
					handler:function(){
						this.ctxNode.ui.removeClass('x-node-ctx');
						if (this.ctxNode.attributes.feedId) {
							this.removeFeed(this.ctxNode.attributes.feedId);
							this.ctxNode = null;
						} else if (this.ctxNode.attributes.folderId) {
							this.removeFolder(this.ctxNode.attributes.folderId);
							this.ctxNode = null;
						}
					}
				},'-',{
					iconCls:'add-feed',
					text:_T( 'fresh', 'mnuAddFeed' ),
					handler: function() {this.showWindow(this.ctxNode)},
					scope: this
				},'-', {
					text: _T( 'fresh', 'mnuExpandAll' ),
					handler: function() {this.expandAll();},
					scope: this
				},{
					text: _T( 'fresh', 'mnuCollapseAll' ),
					handler: function() {this.collapseAll();},
					scope: this
				}]
			});
			this.menu.on('hide', this.onContextHide, this);
		}
		if(this.ctxNode){
			this.ctxNode.ui.removeClass('x-node-ctx');
			this.ctxNode = null;
		}
		if (node.attributes.special) {
			return;
		}
		
		if(node.attributes.feedId || node.attributes.folderId){
			this.ctxNode = node;
			this.ctxNode.ui.addClass('x-node-ctx');
			this.menu.items.get('load').setDisabled(node.isSelected() || node.attributes.folderId);
			this.menu.showAt(e.getXY());
		}
    },
	
	onContextHide : function(){
		if(this.ctxNode){
			this.ctxNode.ui.removeClass('x-node-ctx');
			this.ctxNode = null;
		}
	},
	
	showWindow : function(node, feed){
		if(!this.win){
			this.win = new Fresh.FeedWindow();
			this.win.on('validfeed', this.addFeed, this);
		}
		if (node) {
			this.ctxAddNode = node;
		} else {
			this.ctxAddNode = null;
		}
		this.win.show(feed);
	},
	
	removeFeed: function(id){
		var node = this.findNodeByAttr('feedId', id);
		var _self = this;
		if(node){
			Ext.MessageBox.show({
				title: _T( 'fresh', 'lblDeleteFeedConfirmTitle' ),
				msg: _T( 'fresh', 'lblDeleteFeedConfirm', [node.attributes.title] ),
				buttons: Ext.Msg.YESNO,
				minWidth: 400,
				animEl: node.ui.elNode,
				icon: Ext.MessageBox.WARNING,
				fn: function(btn) {
					if (btn == 'yes') {
						if (!_self.feedDB.deleteFeed(node.attributes.feedId)) {
							return;
						}
						
						_self.updateDateViews();
						//
						var parentNode = node.parentNode;
						if (parentNode && !parentNode.attributes.special) {
							var unread = parentNode.attributes.unreadFeeds;
							parentNode.attributes.totalFeeds -= node.attributes.totalArticles;
							parentNode.attributes.unreadFeeds -= node.attributes.unreadArticles;
							parentNode.setText(parentNode.attributes.title + ' ' + parentNode.attributes.unreadFeeds + '/' + parentNode.attributes.totalFeeds);
							if (unread && parentNode.attributes.unreadFeeds == 0) {
								parentNode.getUI().removeClass('unread');
							}
						} 
						node.unselect();
						Ext.fly(node.ui.elNode).ghost('l', {
							callback: node.remove, scope: node, duration: .4
						});
						_self.fireEvent('feedselect');
					}
				}
			});
		}
	},
	
	removeFolder: function(id) {
		var node = this.findNodeByAttr('folderId', id);
		var _self = this;
		if(node){
			Ext.MessageBox.show({
				title: _T( 'fresh', 'lblDeleteFolderConfirmTitle' ),
				msg: _T( 'fresh', 'lblDeleteFolderConfirm', [node.attributes.title] ),
				buttons: Ext.Msg.YESNO, 
				minWidth: 400,
				animEl: node.ui.elNode,
				icon: Ext.MessageBox.WARNING,
				fn: function(btn) {
					if (btn == 'yes') {
						if (!_self.feedDB.deleteFolder(node.attributes.folderId)) {
							return;
						}
						_self.updateDateViews();
						if (node.hasChildNodes() || node.isExpanded()) {
							node.collapse(true, false);
						}
						node.unselect();
						Ext.fly(node.ui.elNode).ghost('l', {
							callback: node.remove, scope: node, duration: .4
						});
						_self.fireEvent('feedselect');
					}
				}
			});
		}
	},

	addFeed : function(attrs, inactive, preventAnim){
		var exists = this.findNodeByAttr('url',attrs.url);
		if(exists){
			if(!inactive){
				exists.select();
				exists.ui.highlight();
				Ext.fly(exists.ui.elNode).highlight("ffff9c", {
					attr: "background-color",
				    easing: 'easeIn',
    				duration: 1
				});				
			}
			return;
		}
		var feedId = this.feedDB.saveFeed(attrs.url, attrs.parsed);
		var total = attrs.parsed.records.length;
		Ext.apply(attrs, {
			text: attrs.parsed.feed.title + ' ' + total + '/' + total,
			iconCls: 'feed-icon',
			leaf:true,
			cls:'feed unread',
			id: 'feed_' + feedId,
			database: true,
			url: attrs.url,
			feedId: feedId,
			unreadArticles: total,
			totalArticles: total,
			title: attrs.parsed.feed.title
		});
		var node = new Ext.tree.TreeNode(attrs);
		var selectedNode = this.ctxAddNode || this.getSelectionModel().getSelectedNode();
		if (!selectedNode) {
			selectedNode = this.feeds;
		}
		if (!!selectedNode.attributes.special) {
			selectedNode = this.feeds;
		}
		 if (!selectedNode.hasChildNodes()) {
		 	if (selectedNode.parentNode) {
		 		selectedNode = selectedNode.parentNode;
		 	} else {
		 		selectedNode = this.feeds;
		 	}
		}
		if (selectedNode.attributes.folderId) {
			this.feedDB.moveFeed(feedId, selectedNode.attributes.folderId);
			node.attributes.parentId = selectedNode.attributes.folderId;
			var unread = selectedNode.attributes.unreadFeeds;
			selectedNode.attributes.totalFeeds += total;
			selectedNode.attributes.unreadFeeds += total;
			selectedNode.setText(selectedNode.attributes.title + ' ' + selectedNode.attributes.unreadFeeds + '/' + selectedNode.attributes.totalFeeds);
			if (unread == 0 && selectedNode.attributes.unreadFeeds) {
				selectedNode.getUI().addClass('unread');
			}			
			
		}
		selectedNode.appendChild(node);
		if(!inactive){
			if(!preventAnim){
				Ext.fly(node.ui.elNode).slideIn('l', {
					callback: node.select, scope: node, duration: .4
				});
			}else{
				node.select();
			}
		}
		this.updateDateViews();
		return node;
	},
	
	addFolder: function() {
		var node = this.feeds.appendChild(new Ext.tree.TreeNode({
			text: _T( 'fresh', 'lblFolder', null ),
			iconCls: 'folder-icon', 
			cls: 'folder',
			allowDrag:false,
			isNew: true
		}));
		this.getSelectionModel().select(node);
		var that = this;
		setTimeout(function(){
			that.nodeEditor.editNode = node;
			that.nodeEditor.startEdit(node.ui.textNode);
		}, 10);
	},
	
	folderEditComplete: function(editor, value, startValue) {
		air.trace("Edit complete: " + value);
		var node = editor.editNode;
		var attr = editor.editNode.attributes;
		if (!attr.folderId) {
			var folderId = this.feedDB.addFolder(value);
			attr.folderId = folderId;
			attr.title = value;
			attr.unreadFeeds = 0;
			attr.totalFeeds = 0;
			delete attr.isNew;
			if (!folderId) {
				// TODO: delete the new node
			}			
		} else if (value != startValue && value != attr.title) {
			this.feedDB.renameFolder(attr.folderId, value);
			attr.title = value;
		}
		var val = attr.title + ' ' + attr.unreadFeeds + '/' + attr.totalFeeds;
		node.setText.defer(1, node, [val]);
	},
	
	beforeNodeEdit: function(editor, el, value) {
		air.trace(editor.editNode.attributes);
		if (!editor.editNode.attributes.isNew && !editor.editNode.attributes.folderId) {
			return false;
		}
	},
	
	beforeEditShow: function(editor) {
		var title = editor.editNode.attributes.title;
		editor.setValue(title);
	},	
	
	markArticlesRead: function() {
		var node = this.getSelectionModel().getSelectedNode();
		if (!node) {
			return;
		}
		if (!!node.attributes.special) {
			return;
		}
		if (node.hasChildNodes()) {
			return;
		}
		air.trace("Marking feed read: " + node.attributes.feedId);
		this.feedDB.markFeedRead(node.attributes.feedId, true);
		this.fireEvent('feedread', node.attributes.feedId);
		// update attributes
		node.setText(node.attributes.title + ' 0/' + node.attributes.totalArticles);
		node.getUI().removeClass('unread');
		if (node.parentNode && !node.parentNode.attributes.special) {
			var attr = node.parentNode.attributes;
			attr.unreadFeeds -= node.attributes.unreadArticles;
			node.parentNode.setText(attr.title + ' ' + attr.unreadFeeds + '/' + attr.totalFeeds);
			if (attr.unreadFeeds == 0) {
				node.parentNode.getUI().removeClass('unread');
			}
		}
		node.attributes.unreadArticles = 0;
		this.updateDateViews();
	},
	
	markArticleRead: function(articleId, feedId) {
		node = this.findNodeByAttr('feedId', feedId);
		if (!node ) {
			return;
		}
		if (node.attributes.unreadArticles == 0) {
			return;
		}
		this.feedDB.markArticleRead(articleId, true);

		node.attributes.unreadArticles -= 1;
		// update attributes
		node.setText(node.attributes.title + ' ' + node.attributes.unreadArticles + '/' + node.attributes.totalArticles);
		if (node.attributes.unreadArticles == 0) {
				node.getUI().removeClass('unread');
		}
		if (node.parentNode && !node.parentNode.attributes.special) {
			var attr = node.parentNode.attributes;
			attr.unreadFeeds -= 1;
			node.parentNode.setText(attr.title + ' ' + attr.unreadFeeds + '/' + attr.totalFeeds);
			if (attr.unreadFeeds == 0) {
				node.parentNode.getUI().removeClass('unread');
			}
		}
		this.updateDateViews();
	},
	
	findNodeByAttr: function(attr,id) {
		var cs = this.feeds.childNodes;
		var node;
		for(var i = 0, len = cs.length; i < len; i++) {
			if (cs[i].attributes[attr] == id) {
				return cs[i];
			}
			if (cs[i].attributes.folderId) {
				node = cs[i].findChild(attr, id);
				if (node) return node;
			}
		}
		return null;
	},
	
	findNodebyFolderId: function(id) {
		return this.feeds.findChild('folderId', id);
	},
	
	updateDateViews: function() {
		// update special date view
		var res = this.feedDB.getArticlesCountByDate();
		// all articles
		var unread = this.allView.attributes.unreadArticles;
		this.allView.attributes.totalArticles = res[1].total;
		this.allView.attributes.unreadArticles = res[1].unread;
		this.allView.setText(this.allView.attributes.title + ' ' + res[1].unread + '/' + res[1].total);
		if (unread && res[1].unread == 0) {
			this.allView.getUI().removeClass('unread');
		} else if (unread == 0 && res[1].unread){
			this.allView.getUI().addClass('unread');
		}
		// today articles
		unread = this.todayView.attributes.unreadArticles;
		this.todayView.attributes.totalArticles = res[2].total;
		this.todayView.attributes.unreadArticles = res[2].unread;
		this.todayView.setText(this.todayView.attributes.title + ' ' + res[2].unread + '/' + res[2].total);
		if (unread && res[2].unread == 0) {
			this.todayView.getUI().removeClass('unread');
		} else if (unread == 0 && res[2].unread){
			this.todayView.getUI().addClass('unread');
		}
		// last week articles
		unread = this.weekView.attributes.unreadArticles;
		this.weekView.attributes.totalArticles = res[3].total;
		this.weekView.attributes.unreadArticles = res[3].unread;
		this.weekView.setText(this.weekView.attributes.title + ' ' + res[3].unread + '/' + res[3].total);
		if (unread && res[3].unread == 0) {
			this.weekView.getUI().removeClass('unread');
		} else if (unread == 0 && res[3].unread){
			this.weekView.getUI().addClass('unread');
		} 
		// last month articles
		unread = this.monthView.attributes.unreadArticles;
		this.monthView.attributes.totalArticles = res[4].total;
		this.monthView.attributes.unreadArticles = res[4].unread;
		this.monthView.setText(this.monthView.attributes.title + ' ' + res[4].unread + '/' + res[4].total);
		if (unread && res[4].unread == 0) {
			this.monthView.getUI().removeClass('unread');
		} else if (unread == 0 && res[4].unread){
			this.monthView.getUI().addClass('unread');
		} 
		// older articles
		unread = this.olderView.attributes.unreadArticles;
		this.olderView.attributes.totalArticles = res[5].total;
		this.olderView.attributes.unreadArticles = res[5].unread;
		this.olderView.setText(this.olderView.attributes.title + ' ' + res[5].unread + '/' + res[5].total);
		if (unread && res[5].unread == 0) {
			this.olderView.getUI().removeClass('unread');
		} else if (unread == 0 && res[5].unread){
			this.olderView.getUI().addClass('unread');
		} 
		
	},
	
	onNodeDropped: function(de) {
		var target = (de.point == "append") ? de.target : de.target.parentNode;
		var unread;
		var parentId = de.dropNode.attributes.parentId ? de.dropNode.attributes.parentId : null;
		if (target == this.feeds) {
			this.feedDB.moveFeed(de.dropNode.attributes.feedId);
			if (parentId) {
				delete de.dropNode.attributes.parentId;
			}
		} else {
			this.feedDB.moveFeed(de.dropNode.attributes.feedId, target.attributes.folderId);
			de.dropNode.attributes.parentId = target.attributes.folderId;
			unread = target.attributes.unreadFeeds;
			target.attributes.totalFeeds += de.dropNode.attributes.totalArticles;
			target.attributes.unreadFeeds += de.dropNode.attributes.unreadArticles;
			target.setText(target.attributes.title + ' ' + target.attributes.unreadFeeds + '/' + target.attributes.totalFeeds);
			if (unread == 0 && target.attributes.unreadFeeds) {
				target.getUI().addClass('unread');
			}
		}
		// update parent nodes
		var parentNode = null;
		if (parentId) {
			parentNode = this.findNodeByAttr('folderId', parentId);
		}
		if (!parentNode) {
			return;
		}
		//
		unread = parentNode.attributes.unreadFeeds;
		parentNode.attributes.totalFeeds -= de.dropNode.attributes.totalArticles;
		parentNode.attributes.unreadFeeds -= de.dropNode.attributes.unreadArticles;
		parentNode.setText(parentNode.attributes.title + ' ' + parentNode.attributes.unreadFeeds + '/' + parentNode.attributes.totalFeeds);
		if (unread && parentNode.attributes.unreadFeeds == 0) {
			parentNode.getUI().removeClass('unread');
		}		
	},
	
	feedUpdated: function(feedId, newArticlesCount, noRefresh) {
		air.trace("Feed updated: " + feedId);
		var node = this.findNodeByAttr('feedId', feedId);
		if (!node) {
			return;
		}
		node.attributes.totalArticles += newArticlesCount;
		node.attributes.unreadArticles += newArticlesCount;
		node.getUI().addClass('unread');
		node.setText(node.attributes.title + ' ' + node.attributes.unreadArticles + '/' + node.attributes.totalArticles);
		var parentNode = node.parentNode;
		if (parentNode != this.feeds) {
			parentNode.attributes.totalFeeds += newArticlesCount;
			parentNode.attributes.unreadFeeds += newArticlesCount;
			parentNode.getUI().addClass('unread');
			parentNode.setText(parentNode.attributes.title + ' ' + parentNode.attributes.unreadFeeds + '/' + parentNode.attributes.totalFeeds);
		}
		this.updateDateViews();
		if (node.isSelected() && noRefresh) {
			this.fireEvent('feedselect', node.attributes);
		}
		Ext.fly(node.ui.elNode).highlight("ffff9c", {
					attr: "background-color",
				    easing: 'easeIn',
    				duration: 1
			});
	},
	
	emptyCache: function() {
		var _self = this;
		Ext.MessageBox.show({
			title: _T( 'fresh', 'lblDeleteCacheConfirmTitle' ),
			msg: _T( 'fresh', 'lblDeleteCacheConfirm' ),
			buttons: Ext.Msg.YESNO,
			minWidth: 400,
			icon: Ext.MessageBox.WARNING,
			fn: function(btn) {
				if (btn == 'yes') {
					if (!_self.feedDB.deleteAllArticles()) {
						return;
					}
					_self.refreshFeeds();
					_self.fireEvent("emptycache");
				}
			}
		});
	},
	
	refreshCurrentFeed: function() {
		var node = this.getSelectionModel().getSelectedNode();
		if (!node) {
			return;
		}
		if (!node.attributes.feedId) {
			return;
		}
		var args = {feedId: node.attributes.feedId, title: node.attributes.title, url: node.attributes.url, totalArticles: node.attributes.totalArticles, refresh: true};
		this.fireEvent('feedselect', args);
	},
	
	markCurrentFeedRead: function() {
		var node = this.getSelectionModel().getSelectedNode();
		if (!node) {
			return;
		}
		if (node.attributes.special && !node.attributes.specialId) {
			return;
		}
		if (node.attributes.feedId) {
			var unread = node.attributes.unreadArticles;
			this.feedDB.markFeedRead(node.attributes.feedId, true);
			node.attributes.unreadArticles = 0;
			node.getUI().removeClass('unread');
			node.setText(node.attributes.title + ' ' + node.attributes.unreadArticles + '/' + node.attributes.totalArticles);
			var parentNode = node.parentNode;
			if (parentNode != this.feeds) {
				if (parentNode.attributes.unreadFeeds == unread) {
					parentNode.getUI().removeClass('unread');	
				}
				parentNode.attributes.unreadFeeds -= unread;
				parentNode.setText(parentNode.attributes.title + ' ' + parentNode.attributes.unreadFeeds + '/' + parentNode.attributes.totalFeeds);
			}			
		} else if (node.attributes.folderId) {
			this.feedDB.markFolderRead(node.attributes.folderId, true);
			this.refreshFeeds();
		} else if (node.attributes.specialId) {
			this.feedDB.markReadByDate(node.attributes.specialId, true);
			this.refreshFeeds();
		}
		this.updateDateViews();
		this.fireEvent('feedselect', node.attributes);
	},
	
	updateNodeDetails: function(node) {
		
	},
	
    // prevent the default context menu when you miss the node
	afterRender : function(){
		Fresh.FeedPanel.superclass.afterRender.call(this);
			this.el.on('contextmenu', function(e){
			e.preventDefault();
		});
	},
});