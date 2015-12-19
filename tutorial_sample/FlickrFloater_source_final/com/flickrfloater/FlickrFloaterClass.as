/*

	Part of the application logic used in Flickr Floater has been sourced from
	open source demo code originally provided by Adobe or its staff or representatives, 
	the copyright message below is acknowledgement of that code and the original authors rights
	and responsibilities

*/

/*
	Copyright (c) 2007 Adobe Systems Incorporated
	
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.
*/

import com.flickrfloater.events.SettingsEvent;
import com.flickrfloater.events.SqlDbEvent;
import com.flickrfloater.model.AppSettings;
import com.flickrfloater.view.AppSettingsView;
import com.flickrfloater.view.FlickrAuthorizationView;
import com.flickrfloater.view.PhotoView;

import mx.controls.Alert;
import mx.core.IFlexDisplayObject;
import mx.managers.PopUpManager;

import flash.desktop.NativeApplication;

import org.brandonellis.DataAccess;

public var authorizationData:AppSettings = new AppSettings();

//app settings
[Bindable] private var settings:AppSettings = new AppSettings();
[Bindable] private var da:DataAccess;

// online/offline stuff
[Bindable] private var networked:Boolean = false;	

//app entry point
private function onCreationComplete():void
{ 	
	// online/offline stuff
	NativeApplication.nativeApplication.addEventListener(Event.NETWORK_CHANGE, checkNetworkConnection);
	checkNetworkConnection();
	
	// local instance of DataAccess
	// takes the database file path as the argument
	da = new DataAccess("app:/FfData.db");
	da.addEventListener(SqlDbEvent.SQL_RESPONSE,dbAppInit);
	// open the connection and set the initial data result to view
	da.openConnection("select * from appsettings");	
	dbSettingsSelect();
	
	// code for NativeMenu
	var submenu:NativeMenu = new NativeMenu();
	var photosMI:NativeMenuItem = new NativeMenuItem("Photos");
	photosMI.addEventListener(Event.SELECT,switchToTab);
	var friendsMI:NativeMenuItem = new NativeMenuItem("Friends");
	friendsMI.addEventListener(Event.SELECT,switchToTab);
	var menuItem:NativeMenuItem = new NativeMenuItem("Switch Modes");
	submenu.addItem(photosMI);
	submenu.addItem(friendsMI);
	menuItem.submenu = submenu;
	NativeApplication.nativeApplication.menu.addItem(menuItem);		
}

private function switchToTab(e:Event):void {
	var menuItem:NativeMenuItem = e.target as NativeMenuItem;
	var len:Number = menuItem.menu.items.length;
	var selectedTabIndex:Number = 0;
	for (var i:Number = 0;i<len;i++) {
		if (menuItem.label == menuItem.menu.items[i].label) {
			selectedTabIndex = i;
			break;
		}
	}
	appSectionsTN.selectedIndex = selectedTabIndex;
} 

private function dbSettingsSelect():void {
	var sql:String = "select * from appsettings";
	da.DataAccessSelect(sql);
}

private function dbAppInit(e:Event):void {
	da.removeEventListener(SqlDbEvent.SQL_RESPONSE,dbAppInit);
	if (e.target.dbResult[0].apikey == "" || e.target.dbResult[0].length == 0) {
		openSettings();		
	} else {
		settings.apiKey = e.target.dbResult[0].apikey;
		settings.secret = e.target.dbResult[0].secret;
		settings.authToken = e.target.dbResult[0].authtoken;
		settings.accountName = e.target.dbResult[0].accountname;
		settings.frob = e.target.dbResult[0].frob;
		settings.authorizationURL = e.target.dbResult[0].authorizationurl;
		settings.nsid = e.target.dbResult[0].nsid;	
		
		if(settings.apiKey == null || settings.apiKey.length == 0 || settings.secret == null || settings.secret.length == 0) {
			openSettings();
		} else if (settings.authToken == null || settings.authToken.length == 0) {		
			if (networked == false) {
				// offline/online code
				Alert.show("Flickr Authorization Required.\n\nThe application is currently offline, you need to be online for Flickr to authorise this application to connect.\n\nPlease go online and run the application again.");
			} else {
				openAuthorization();
			}
		} else {
			photoView.settings = settings;
		}
	}
}


private function checkNetworkConnection(event:Event=null):void{
	var headRequest:URLRequest = new URLRequest();
	headRequest.method = "HEAD";
	headRequest.url = "http://api.flickr.com/services/rest/?method=flickr.test.echo";	
	var connectTest:URLLoader = new URLLoader(headRequest);
	connectTest.addEventListener(HTTPStatusEvent.HTTP_STATUS, connectHttpStatusHandler);
	connectTest.addEventListener(Event.COMPLETE, connectCompleteHandler);
	connectTest.addEventListener(IOErrorEvent.IO_ERROR, connectErrorHandler);  
}

private function connectHttpStatusHandler(event:*=null):void{
	if (event.status == "0" ? networked = false:networked = true);
}			

private function connectErrorHandler(event:IOErrorEvent):void{
	networked = false;
	Alert.show("You do not currently have a network connection");
}

private function connectCompleteHandler(event:Event):void{
	networked = true;
}

//open the settings panel
private function openSettings():void
{
	var p:IFlexDisplayObject = PopUpManager.createPopUp(this, AppSettingsView, true);
	p.addEventListener(Event.CLOSE, onSettingsClose);
	p.addEventListener(SettingsEvent.SETTINGS_CHANGED, onSettingsChange);
	
	AppSettingsView(p).settings = settings;
	PopUpManager.centerPopUp(p);
}

//settings panel close event
private function onSettingsClose(event:Event):void
{
	closePopup(IFlexDisplayObject(event.target));
	if(settings.authToken == null || settings.authToken.length == 0) {
		if (networked == false) {
			// offline/online code
			Alert.show("Flickr Authorization Required.\n\nThe application is currently offline, you need to be online for Flickr to authorise this application to connect.\n\nPlease go online and run the application again.");
		} else {
			openAuthorization();
		}
	}	
}

private function openAuthorization():void {
	if (settings.authorizationURL == null || settings.authorizationURL.length == 0) {
		var auth:IFlexDisplayObject = PopUpManager.createPopUp(this, FlickrAuthorizationView, true);
		auth.addEventListener(Event.CLOSE, onSettingsClose);
		auth.addEventListener(SettingsEvent.SETTINGS_CHANGED, onSettingsChange);
		
		FlickrAuthorizationView(auth).settings = settings;
		PopUpManager.centerPopUp(auth);			
	}	
}

//settings have been updated
private function onSettingsChange(e:SettingsEvent):void
{
	saveSettings(AppSettings(e.settings));
}

//serialize the passed in settings to the file system
private function saveSettings(s:AppSettings):void
{
	settings = s;
	var sql:String = "update appsettings set apikey = "; 
		sql += '"' + s.apiKey + '"';
		sql += ", secret = "; 
		sql += '"' + s.secret + '"';
		sql += ", authtoken = "; 
		sql += '"' + s.authToken + '"';
		sql += ", accountname = "; 
		sql += '"' + s.accountName + '"';
		sql += ", frob = "; 
		sql += '"' + s.frob + '"';
		sql += ", authorizationurl = "; 
		sql += '"' + s.authorizationURL + '"';	
		sql += ", nsid = "; 
		sql += '"' + s.nsid + '"';														
		
	var sql2:String = "select * from appsettings";
	
	// adds debug code at bottom of script block for monitoring
	// da.addEventListener(SqlDbEvent.SQL_RESPONSE,sqlResult);
	da.DataAccessInsert(sql, sql2);
	photoView.settings = s;
}

//remove a popup window
private function closePopup(p:IFlexDisplayObject):void
{
	PopUpManager.removePopUp(p);
}
