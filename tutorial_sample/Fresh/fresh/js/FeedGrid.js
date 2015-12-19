/*
 * Copyright 2007-2008. Adobe Systems Incorporated.
 * All rights reserved.
 */


var Fresh; if (!Fresh) Fresh = {};

Fresh.FeedGrid = function(viewer, config) {
	var summaryState = Ext.state.Manager.get('summary-state', false);
	var unreadState = Ext.state.Manager.get('unread-state', false);	
	this.viewer = viewer;
	Ext.apply(this, config);
	//
	this.proxy = new Fresh.FeedProxy({});
	this.reader = new Fresh.FeedReader();
	//
	this.store = new Ext.data.Store({
		proxy: this.proxy,
		reader: this.reader
	});
	this.store.setDefaultSort('date', "DESC");
	this.columns = [
		{
			id: 'title',
			header:  _T( 'fresh', 'lblTitle' ) ,
			dataIndex: 'title',           
			sortable: true,
			width: 420,
			render: this.formatTitle
		}, {
			id: 'author',
			header:  _T( 'fresh', 'lblAuthor' ) ,
			dataIndex: 'author',
			width: 100,
			hidden: true,
			sortable: true,
			render: this.formatAuthor
		}, {
			id: 'date',
			header:  _T( 'fresh', 'lblDate' ) ,
			dataIndex: 'date',
			width: 80,
			renderer: this.formatDate,
			sortable: true
	}];
	//
	Fresh.FeedGrid.superclass.constructor.call(this, {
		region: 'center',
		id: 'topic-grid',
		
		loadMask: {msg:  _T( 'fresh', 'lblLoadingFeed' ) },
		sm: new Ext.grid.RowSelectionModel({
			singleSelect:true
		}),
		
		viewConfig: {
			forceFit:true,
			enableRowBody:true,
			showPreview:summaryState,
			showUnread: unreadState,
			getRowClass : this.applyRowClass,
			sortAscText : _T( 'fresh', 'mnuSortAscending' ),
		        sortDescText : _T( 'fresh', 'mnuSortDescending' ),
		        columnsText : _T( 'fresh', 'btnColumns' )
		}
	});
	this.on('rowcontextmenu', this.onContextClick, this);
	var _self = this;
	this.on('render', function() {
		this.gridNav = new Ext.KeyMap(this.getGridEl(), [{
				key: Ext.EventObject.LEFT,
				fn: this.goToPanel,
				scope: this
			},
			{
				key: 't',
				fn: function() { _self.fireEvent('opentab'); }
			},
			{
				key: 'b',
				fn: function() { _self.fireEvent('openbrowser'); }
			},
			{
				key: 'r',
				fn: this.refreshFeed,
				scope: this
			},
			{
				key: 'a',
				fn: this.markRead,
				scope: this
			}, 
			{
				key: ' ',
				fn: function() {
					air.trace("SPACE");
					_self.getSelectionModel().selectNext(false);
				},
			}
		]);
	}, this);
	this.selectedArticleId = -1;
	this.getSelectionModel().on('rowselect', function(selModel, index, record) {
		var index = this.store.indexOf(record);
		air.trace("ROW: " + index);
		if (!record.data.read) {
			//this.view.focusRow(index);
			this.selectedArticleId = record.data.id;
			this.selectedFeedId = record.data.feedid;
		} else {
			this.selectedArticleId = -1;
			this.selectedFeedId = -1;
			if (this.showUnread) {
				this.getSelectionModel().selectNext.defer(1, this, [false]);
			} else {
				//this.view.focusRow(index);
			}
		}
	}, this);
	this.getSelectionModel().on('rowdeselect', this.markArticleRead, this);
}

Ext.extend(Fresh.FeedGrid, Ext.grid.GridPanel, {

	loadFeed : function(feed) {
		if (this.selectedArticleId > 0) {
			this.fireEvent('articleread', this.selectedArticleId, this.selectedFeedId);
			this.selectedArticleId = -1;
			this.selectedFeedId = -1;
		}		
		if (!feed) {
			this.store.removeAll();
			return;
		}
		air.trace("Feed: "  + feed.feedId + " -- " + feed.totalArticles + " -- "  + feed.refresh);
		var args = {url: feed.url};
		if (feed.feedId) {
			args.feed_id = feed.feedId;
			if (feed.totalArticles && !feed.refresh) {
				args.database = true;
			} else {
				var _self = this;
				args.callback = function(result, options, success) {
					if (success) {
						if (options.newArticlesCount &&  options.newArticlesCount > 0) {
							_self.fireEvent("newarticles", feed.feedId, options.newArticlesCount, true);
						}
					} else {
						Ext.get(this.bwrap).mask( _T( 'fresh', 'lblErrorLoading', [feed.url]).toString() );
						this.store.removeAll();
					}                     
				}
				args.scope = this;
			}
			this.store.load(args);
		} else if (feed.folderId) {
			args.folder_id = feed.folderId;
			args.database = true;
			this.store.load(args);
		} else if (feed.specialId) {
			args.special_id = feed.specialId;
			args.database = true;
			this.store.load(args);
		} else if (feed.special) {
			this.store.removeAll();	
		}
	},
	
	goToPanel: function () {
		this.fireEvent('selectpanel');
	},
	
	onContextClick : function(grid, index, e){
		if(!this.menu){ // create context menu on first right click
			this.menu = new Ext.menu.Menu({
				id:'grid-ctx',
				items: [{
					text: _T( 'fresh', 'btnViewNewTab' ),
					iconCls: 'new-tab',
					scope:this,
					handler: function(){
						this.viewer.openTab(this.ctxRecord);
					}
				},{
					iconCls: 'new-win',
					text: _T( 'fresh', 'btnGoToPost' ),
					scope:this,
					handler: function(){
						window.open(this.ctxRecord.data.link);
					}
				},'-',{
					iconCls: 'refresh-icon',
					text: _T( 'fresh', 'btnRefresh' ),
					scope:this,
					handler: function(){
                        this.ctxRow = null;
                        this.store.reload();
					}
				}]
			});
			this.menu.on('hide', this.onContextHide, this);
		}
		e.stopEvent();
		if(this.ctxRow){
			Ext.fly(this.ctxRow).removeClass('x-node-ctx');
			this.ctxRow = null;
		}
		this.ctxRow = this.view.getRow(index);
		this.ctxRecord = this.store.getAt(index);
		Ext.fly(this.ctxRow).addClass('x-node-ctx');
		this.menu.showAt(e.getXY());
	},

    // within this function "this" is actually the GridView
	applyRowClass: function(record, rowIndex, p, ds) {
		if (this.showUnread && record.data.read) {
			return 'hide-row';
		}
		if (this.showPreview) {
			var xf = Ext.util.Format;
			p.body = '<p>' + xf.ellipsis(xf.stripTags(record.data.description), 200) + '</p>';
			return 'x-grid3-row-expanded' + (record.data.read ? " read" : " unread");
		}
		return 'x-grid3-row-collapsed' + (record.data.read ? " read" : " unread");
    },

	onContextHide : function(){
		if(this.ctxRow){
			Ext.fly(this.ctxRow).removeClass('x-node-ctx');
			this.ctxRow = null;
		}
	},	
	
	togglePreview : function(show){
		this.view.showPreview = show;
		this.view.refresh();
    },
    
    toggleUnread: function(show) {
		this.view.showUnread = show;
		this.view.refresh();
    },
	
	formatAuthor: function(value, p, record) {
		return value;
	},
	
	formatDate: function(date, p, record) {
		if (!date) return '';
		
		var d = new Date(date);
		var now = new Date();
		var today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
		if (d > today) {
			return d.dateFormat('g:i A');
		}else{
			return Ext.util.Format.date(d) + ' ' + d.dateFormat('g:i A');
		}
	},
	
	formatTitle: function(value, p, record) {
		return String.format('<div class="topic"><b>{0}</b><span class="author">{1}</span></div>',
			value, record.data.author);
	},
	
	markArticleRead: function(selModel, index, record) {
		if (!record.data.read) {
			record.set('read', 1);
			var row = Ext.get(this.view.getRow(index));
			row.removeClass('unread');
			this.fireEvent('articleread', record.data.id, record.data.feedid); 
		}
	},
	
	markRead: function(k, e) {
		if (e) {
			e.stopEvent();
		}
		this.fireEvent('feedread');
	},
	
	refreshFeed: function(k, e) {
		if (e) {
			e.stopEvent();
		}
		this.fireEvent("refreshfeed");
	},

});