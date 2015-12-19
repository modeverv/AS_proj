/*
 * Copyright 2007-2008. Adobe Systems Incorporated.
 * All rights reserved.
 */


var Fresh; if (!Fresh) Fresh = {};
                
Fresh.MainPanel = function() {
	var previewPosition = Ext.state.Manager.get('preview-position', 'bottom');
	var summaryState = Ext.state.Manager.get('summary-state', false);
	var unreadState = Ext.state.Manager.get('unread-state', false);	
	this.preview = new Ext.Panel({
		id: 'preview',
		region: 'south',
		cls: 'preview',
		autoScroll: true,
		listeners: Fresh.Reader.LinkInterceptor,
		
		
		tbar: [{
			id: 'tab',
			text: _T( 'fresh', 'btnViewInNewTab' ),
			iconCls: 'new-tab',
			disabled: true,
			handler: this.openTab,
			scope: this
		}, '-', {
			id: 'win',
			text: _T( 'fresh', 'btnOpenBrowser' ),
			iconCls: 'new-win',
			disabled: true,
			handler: this.openBrowser,
			scope: this
		}],
		
		clear: function(){
			if (!this.rendered) {
				return;
			}
			this.body.update('');
			var items = this.topToolbar.items;
			items.get('tab').disable();
			items.get('win').disable();
		}
	});
	this.grid = new Fresh.FeedGrid(this, {
		tbar: [{
			id: 'mark',
			text: _T( 'fresh', 'btnMarkRead' ),
			tooltip: {title: _T( 'fresh', 'btnMarkAsReadTooltipShort' ), text: _T( 'fresh', 'btnMarkAsReadTooltip' )},
			iconCls: 'mark',
			handler: function() { this.grid.markRead(); },
			scope: this
		}, {
			id: 'refresh',
			text: _T( 'fresh', 'btnRefresh' ),
			tooltip: {title: _T( 'fresh', 'btnRefreshTooltipShort' ), text: _T( 'fresh', 'btnRefreshTooltip' )},
			iconCls: 'refresh',
			handler: function() { this.grid.refreshFeed(); },
			scope: this
		}, 
		'-', {
			id: 'reading',
			split: true,
			text: _T( 'fresh', 'btnReadingPane' ),
			tooltip: {title: _T( 'fresh', 'btnReadingPane' ), text: _T( 'fresh', 'btnReadingPaneTooltip' )},
			iconCls: 'preview-bottom',
			handler: this.movePreview.createDelegate(this, []),  
			menu: {
				id: 'reading-menu',
				cls: 'reading-menu',
				width: 100,
				items: [{
					text: _T( 'fresh', 'mnuReadingPaneBottom' ),
					checked: (previewPosition == 'bottom' ? true : false),
					group: 'rp-group',
					checkHandler: this.movePreview,
					scope: this,
					iconCls: 'preview-bottom',
                    action: "bottom"
				}, {
                    text:_T( 'fresh', 'mnuReadingPaneRight' ),
                    checked: (previewPosition == 'right' ? true : false),
                    group:'rp-group',
                    checkHandler:this.movePreview,
                    scope:this,
                    iconCls:'preview-right',
                    action: "right"
                },{
                    text:_T( 'fresh', 'mnuReadingPaneHide' ),
                    checked: (previewPosition == 'hidden' ? true : false),
                    group:'rp-group',
                    checkHandler:this.movePreview,
                    scope:this,
                    iconCls:'preview-hide',
                    action: "hide"
                }]
			}
		}, '-', {
			pressed: summaryState,
			enableToggle: true,
			text: _T( 'fresh', 'btnSummary' ),
			tooltip: {title: _T( 'fresh', 'btnSummaryTooltipShort' ), text: _T( 'fresh', 'btnSummaryTooltip' )},
			iconCls: 'summary',
			scope: this,
			toggleHandler: function(btn, pressed) {
				Ext.state.Manager.set('summary-state', pressed);
				this.grid.togglePreview(pressed);	
			}
		},{
			pressed: unreadState,
			enableToggle: true,
			text: _T( 'fresh', 'btnShowUnread' ),
			tooltip: {title: _T( 'fresh', 'btnShowUnreadTooltipShort' ), text: _T( 'fresh', 'btnShowUnreadTooltip' )},
			iconCls: 'unreadonly',
			scope: this,
			toggleHandler: function(btn, pressed) {
				Ext.state.Manager.set('unread-state', pressed);
				this.grid.toggleUnread(pressed);	
			}
		}
		]
	});	
	
	Fresh.MainPanel.superclass.constructor.call(this, {
		id: 'main-tabs',
		activeTab: 0,
		region: 'center',
		margins: '0 5 5 0',
		resizeTabs: true,
		tabWidth: 210,
		minTabWidth: 120,
		enableTabScroll: true,
		plugins: new Ext.ux.TabCloseMenu(),
		items: {
			id: 'main-view',
			layout: 'border',
			title: _T( 'fresh', 'lblNoFeedLoaded' ),
			hideMode: 'offsets',
			items: [
				this.grid, 
				{
					id: 'bottom-preview',
					layout: 'fit',
					items: (previewPosition == 'bottom' ? this.preview : null),
					height: 250,
					split: true,
					border: false,
					region: 'south',
					hidden: (previewPosition == 'bottom' ? false : true)
				},
				{
					id: 'right-preview',
					layout: 'fit',
					items: (previewPosition == 'right' ? this.preview : null),
					border: false,
					region: 'east',
					width: 350,
					split: true,
					hidden: (previewPosition == 'right' ? false : true) 
				}
			]
		}
	});
	this.gsm = this.grid.getSelectionModel();
	//
	this.gsm.on('rowselect', function(sm, index, record){
		if (!this.preview.rendered) {
			return;
		}
		Fresh.Reader.getTemplate().overwrite(this.preview.body, record.data);
		var items = this.preview.topToolbar.items;
		items.get('tab').enable();
		items.get('win').enable();
	}, this, {buffer:250});
	//
	this.grid.store.on('beforeload', this.preview.clear, this.preview);
	this.grid.store.on('load', this.gsm.selectFirstRow, this.gsm);
	//
	this.grid.on('rowdblclick', this.openTab, this);
	this.grid.on('opentab', this.openTab, this);
	this.grid.on('openbrowser', this.openBrowser, this);
	this.relayEvents(this.grid, ['selectpanel', 'articleread', 'newarticles', 'refreshfeed', 'feedread']);
}

Ext.extend(Fresh.MainPanel, Ext.TabPanel, {
	focusGrid: function() {
		var s = this.grid.getSelectionModel();
		var r = s.getSelected();
		if (r) {
			this.grid.getView().focusRow(this.grid.store.indexOfId(r.id));
		} else {
			this.grid.getView().focusRow(0);
		}
	},
	
	refreshGrid: function() {
		this.grid.store.reload();
	},
	
	loadFeed : function(feed){
		if (!feed) {
			this.preview.clear();
		}
		this.grid.loadFeed(feed);
		if (feed) {
			if (!feed.special || !!feed.specialId) {
				var items = this.grid.getTopToolbar().items;
				items.get('mark').enable();
				items.get('refresh').enable();
			} else {
				var items = this.grid.getTopToolbar().items;
				items.get('mark').disable();
				items.get('refresh').disable();
			}
		}
		Ext.getCmp('main-view').setTitle(feed ? (feed.title ? feed.title : feed.text) : _T( 'fresh', 'lblNoFeedLoaded' ));
	},
	
	closeTab: function() {
		var tab = this.getActiveTab();
		if (tab && tab.closable) {
			this.remove(tab);
		}
	},
	
	movePreview: function(m, pressed) {
		if(!m){ // cycle if not a menu item click
			var readMenu = Ext.menu.MenuMgr.get('reading-menu');
			readMenu.render();
			var items = readMenu.items.items;
			var b = items[0], r = items[1], h = items[2];
			if(b.checked){
				r.setChecked(true);
			}else if(r.checked){
				h.setChecked(true);
			}else if(h.checked){
				b.setChecked(true);
			}
			return;
		}
		if(pressed){
			var preview = this.preview;
			var right = Ext.getCmp('right-preview');
			var bot = Ext.getCmp('bottom-preview');
			var btn = this.grid.getTopToolbar().items.get('reading');
			switch(m.action){
				case 'bottom':
					right.hide();
					bot.add(preview);
					bot.show();
					bot.ownerCt.doLayout();
					btn.setIconClass('preview-bottom');
					Ext.state.Manager.set('preview-position', 'bottom');
					break;
				case 'right':
					bot.hide();
					right.add(preview);
					right.show();
					right.ownerCt.doLayout();
					btn.setIconClass('preview-right');
					Ext.state.Manager.set('preview-position', 'right');
					break;
				case 'hide':
					preview.ownerCt.hide();
					preview.ownerCt.ownerCt.doLayout();
					btn.setIconClass('preview-hide');
					Ext.state.Manager.set('preview-position', 'hidden');
					break;
			}
		}
	},
	
	openTab: function(record) {
		record = (record && record.data) ? record : this.gsm.getSelected();
        var d = record.data;
        var id = !d.link ? Ext.id() : d.link.replace(/[^A-Z0-9-_]/gi, '');
        var tab;
        if(!(tab = this.getItem(id))){
        	var iframe = Ext.DomHelper.append(document.body, 
    		            {tag: 'iframe', frameBorder: 0, src: d.link, width: '100%', height: '100%'}); 
            tab = new Ext.Panel({
                id: id,
                cls:'preview single-preview',
                title: d.title,
                tabTip: d.title,
                fitToFrame: true,
                contentEl: iframe,
                closable:true,
                autoScroll:true,
                border:true,
            });
            this.add(tab);
        }
        this.setActiveTab(tab);
	},
	
	openBrowser: function() {
		Fresh.Utils.openInBrowser(this.gsm.getSelected().data.link);
	}
});