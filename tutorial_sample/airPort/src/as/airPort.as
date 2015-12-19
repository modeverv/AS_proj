import com.websysd.util.database.*;
import components.dialogs.DlgSendFile;
import components.dialogs.DlgUserInf;
import constants.Constants;
import data.SocketData;
import data.UserInf;
import events.AirDbEvent;
import events.GenEvent;
import events.NetworkDataEvent;
import flash.events.Event;
import flash.net.DatagramSocket;

private var socket:DatagramSocket;
private var response:String;
private var adb:com.websysd.util.database.AirDb_ThisApp;
private var networkDataEvent:NetworkDataEvent;
private var airDbevent:AirDbEvent;
private var genEvent:GenEvent;
private var userInf:data.UserInf;
private var initialSocketData:SocketData;
private var socDataFile:SocketData;
[Bindable]
private var visible_:Boolean = true;
private function init():void {
	try {
		this.adb = new AirDb_ThisApp();
		addEventListener( Constants.CUSTOM_EVENT_TYPE_NWINIT_INITEND, receiveInitSocEnd );
		addEventListener( Constants.CUSTOM_EVENT_TYPE_NWDATA_GOT_FRIEND, receiveDataSoc ); 
		addEventListener( Constants.CUSTOM_EVENT_TYPE_NWDATA_RECEIVE, receiveDataDat );
		addEventListener( Constants.CUSTOM_EVENT_TYPE_DB_GEN_EVENT, dbGenEventHandler );
		addEventListener( Constants.CUSTOM_EVENT_TYPE_DB_ERROR, dbErrorEventHandler );
		adb.addEventListener( Constants.CUSTOM_EVENT_TYPE_DB_RESULT_SET, dbResultEventHandler );
		addEventListener( Constants.CUSTOM_EVENT_TYPE_GEN_EVENT, genEventHandler );
		checkDirectory();
		dbInit();
	} catch ( error:Error ) {
		trace( error );
	}
}
private function checkDirectory():void {
	var f:File = new File( Constants.DEFAULT_USERS_APP_DIRECTORY );
	if ( !f.exists ) f.createDirectory();
	f = new File( Constants.DEFAULT_USERS_FRIENDS_DIRECTORY );
	if ( !f.exists ) f.createDirectory();				
}
private function sendGetUserInfReq():void {
	airDbevent = new AirDbEvent( Constants.CUSTOM_APP_EVENT_TYPE_DB_REQUEST_QUERY );
	airDbevent.req_type = Constants.DB_REQ_TYPE_READ_USER_INF;
	adb.dispatchEvent( airDbevent );
}

private var ff:File;
private var fs:FileStream;
private function fileSelected(event:Event):void {
	fs = new FileStream();
	fs.open( ff, FileMode.READ );
	fs.readObject();
	trace( ff.nativePath );
}
private function sendDataReq():void {								
}
private function sendInitialSocketEvent():void { 
	var oo:Object = new Object();
	oo.userName = this.userInf.userName;
	oo.userComment = this.userInf.userComment;
	oo.iconFileName = this.userInf.iconFileName;
	oo.userIp = this.initialSocketData.originAddress;
	oo.userPort = this.initialSocketData.originPort;
	var icon:File = new File( Constants.DEFAULT_USERS_APP_DIRECTORY + "/" + this.userInf.iconFileName );
	initialSocketData.setSendData_FileContent( "localhost", 0, icon, null, this.applicationError );
	initialSocketData.dataContentData_.strData_ = Constants.DEFAULT_USERS_FRIENDS_DIRECTORY + "/" + this.userInf.iconFileName; //Friends用ファイル名（フルパス：受信時に使用)
	initialSocketData.dataContentData_.objData_ = oo;
	var ev:NetworkDataEvent = new NetworkDataEvent( Constants.CUSTOM_APP_EVENT_TYPE_NWINIT_INIT, this.initialSocketData, true, true );
	ev.socketData.dataContentData_.type_ = Constants.SOC_INIT_TYPE_START;
	this.netDeviceInf.dispatchEvent( ev );
}
private function addFriendToList( socData:SocketData ):void {
	var dd:data.UserInf = new data.UserInf();
	dd.userName = socData.dataContentData_.objData_.userName;
	dd.userComment = socData.dataContentData_.objData_.userComment;
	dd.iconFileName = Constants.DEFAULT_USERS_FRIENDS_DIRECTORY + "/" + socData.dataContentData_.objData_.iconFileName;
	dd.userIp = socData.dataContentData_.objData_.userIp;
	dd.userPort = socData.dataContentData_.objData_.userPort;
	var ge:GenEvent = new GenEvent( Constants.CUSTOM_APP_EVENT_TYPE_GEN_EVENT, true, true );
	ge.genEventType = Constants.GEN_EVENT_TYPE_ADD_FRIEND_TO_USER_LIST;
	ge.obj = dd;
	panel_comm.dispatchEvent( ge );
}
private function receiveInitSocEnd(event:events.NetworkDataEvent):void {
	trace( "App. receiveDataSoc(). " + event.type );				
	var socData:SocketData = event.socketData;
	switch ( socData.dataContentData_.type_ ) {
		case Constants.SOC_INIT_TYPE_INIT_END:
			this.initialSocketData = new SocketData( Constants.SOC_INIT_TYPE_START );
			this.initialSocketData.originAddress = socData.originAddress;
			this.initialSocketData.originPort = socData.originPort;
			this.sendInitialSocketEvent();
	}
}
private function receiveDataSoc(event:events.NetworkDataEvent):void {
	trace( "App. receiveDataSoc(). " + event.type );				
	var socData:SocketData = event.socketData;
	switch ( socData.dataContentData_.type_ ) {
		case Constants.SOC_DATA_TYPE_GOT_FRIEND:
			trace( "App. receiveDataSoc(). addr=" + socData.originAddress + ", port=" + socData.originPort );
			networkConnectable.dispatchEvent( event );
			addFriendToList( event.socketData );						
			break;
	}
}
private function receiveDataDat(event:events.NetworkDataEvent):void {
	trace( "App. receiveDataDat(). " + event.type );				
	var socData:SocketData = event.socketData;
	switch ( socData.dataContentData_.type_ ) {
		case Constants.SOC_RECEIVE_DATA_TYPE_STRING:
			trace( "App. receiveDataDat(String). addr=" + socData.originAddress + ", port=" + socData.originPort );	
			genEvent = new GenEvent( Constants.CUSTOM_APP_EVENT_TYPE_GEN_EVENT );
			genEvent.genEventType = Constants.GEN_EVENT_TYPE_NWDATA_STRING_RECEIVED;
			genEvent.obj = socData.dataContentData_;
			panel_msgDisp.dispatchEvent( genEvent );
			break;
		case Constants.SOC_RECEIVE_DATA_TYPE_TEXTFLOW:
			trace( "App. receiveDataDat(String). addr=" + socData.originAddress + ", port=" + socData.originPort );					
			break;
		case Constants.SOC_RECEIVE_DATA_TYPE_FILE:
			trace( "App. receiveDataDat(File). addr=" + socData.originAddress + ", port=" + socData.originPort + ", filename=" + socData.dataContentData_.strData_ + ", username=" + socData.dataContentData_.objData_.userName + ", comment=" + socData.dataContentData_.objData_.comment );
			var o:Object = new Object();
			o.name = socData.dataContentData_.strData_;
			o.sentby = socData.dataContentData_.objData_.userName;
			o.comment = socData.dataContentData_.objData_.comment;
			o.file = new File( Constants.DEFAULT_USERS_APP_DIRECTORY + "/" + socData.dataContentData_.strData_ );
			this.genEvent = new GenEvent( Constants.CUSTOM_APP_EVENT_TYPE_GEN_EVENT );
			genEvent.genEventType = Constants.GEN_EVENT_TYPE_NWDATA_FILE_RECEIVED;
			genEvent.obj = o;
			this.panel_myBox.dispatchEvent( genEvent );
			break;
		
	}
}
private function dbInit():void {
	adb.dbFileName = Constants.DEFAULT_AIR_DB_FILENAME;
	if ( !adb.dbConnect() ) {
		trace( "App. dbInit(). creating DataBase.. " );
		adb.createTable( Constants.DB_TABLE_NAME_SYSDAT, Constants.DB_TABLE_SCHEMA_SYSDAT );
		adb.createInitialRecords();						
	} else {
		this.sendGetUserInfReq();
	}
}
private function dbGenEventHandler( event:events.AirDbEvent ):void {
	switch ( event.dataTypeId ) {
		case Constants.DB_GEN_EVENT_TYPE_OPEN_SUCCESS:
			break;
	}
}
private function dbResultEventHandler( event:events.AirDbEvent ):void {
	switch ( event.dataTypeId ) {
		case Constants.DB_RESULT_SET_TYPE_SYSDAT:
			trace( "App. dbResultEventHandler(). :DB_RESULT_SET_TYPE_SYSDAT" );	
			break;
		case Constants.DB_RESULT_SET_TYPE_USER_INF:
			trace( "App. dbResultEventHandler(). :DB_RESULT_SET_TYPE_USER_INF" );	
			this.userInf = event.obj as data.UserInf;
			this.genEvent = new GenEvent( Constants.CUSTOM_APP_EVENT_TYPE_GEN_EVENT );
			genEvent.genEventType = Constants.GEN_EVENT_TYPE_USER_INF;
			genEvent.obj = event.obj;
			panel_selfProfile.dispatchEvent( genEvent );
			var ev:NetworkDataEvent = new NetworkDataEvent( Constants.CUSTOM_APP_EVENT_TYPE_NWINIT_INIT, new SocketData( Constants.SOC_INIT_TYPE_INIT ), false, true );
			this.netDeviceInf.dispatchEvent( ev );
			break;
	}
}
private function genEventHandler( event:events.GenEvent ):void {
	switch ( event.genEventType ) {
		case Constants.GEN_EVENT_TYPE_REG_USER:
			this.userInf = event.obj as data.UserInf;
			
			var ev2:AirDbEvent = new AirDbEvent( Constants.CUSTOM_APP_EVENT_TYPE_DB_REQUEST_QUERY, true, true );
			ev2.obj = event.obj;
			ev2.req_type = Constants.DB_REQ_TYPE_REG_USER_INF;
			trace( "App. genEventHandler(). type=GEN_EVENT_TYPE_REG. " + (event.obj as data.UserInf).userName );	
			adb.dispatchEvent( ev2 );
			this.sendInitialSocketEvent();
			this.genEvent = new GenEvent( Constants.CUSTOM_APP_EVENT_TYPE_GEN_EVENT, true, true );
			genEvent.genEventType = Constants.GEN_EVENT_TYPE_USER_INF;
			genEvent.obj = this.userInf; 
			panel_selfProfile.dispatchEvent( genEvent );
			break;
		
		case Constants.GEN_EVENT_TYPE_NWDATA_FILE_OPEN_DIALOG:
			dlgSendFile.visible = true;
			break;
		case Constants.GEN_EVENT_TYPE_NWDATA_SENDING_FILE_SELECTED:
			var obj:Object = new Object();
			obj.file = event.obj.sendingFile as File;
			obj.comment = event.obj.comment;
			obj.userName = this.userInf.userName;
			this.sendFileReq( obj );
			break;
		case Constants.GEN_EVENT_TYPE_USER_SELF_DATA_EDIT_PROFILE:
			dlgUserInf.visible= true;
			
			this.genEvent = new GenEvent( Constants.CUSTOM_APP_EVENT_TYPE_GEN_EVENT );
			genEvent.genEventType = Constants.GEN_EVENT_TYPE_USER_INF;
			genEvent.obj = this.userInf;
			dlgUserInf.dispatchEvent( genEvent );
			break;
		case Constants.GEN_EVENT_TYPE_USER_LIST_HOVERED:
		case Constants.GEN_EVENT_TYPE_USER_LIST_OUT:
		case Constants.GEN_EVENT_TYPE_USER_LIST_CLICKED:
			this.genEvent = new GenEvent( Constants.CUSTOM_APP_EVENT_TYPE_GEN_EVENT );
			genEvent.genEventType = event.genEventType;
			genEvent.obj = event.obj as data.UserInf;
			panel_comm.dispatchEvent( genEvent );
			break;
		case Constants.GEN_EVENT_TYPE_NWDATA_STRING_SEND_REQ:
			var socData:SocketData = new SocketData( Constants.SOC_RECEIVE_DATA_TYPE_STRING );
			socData.dataContentData_.objData_ = this.userInf;
			socData.setSendData_DataContentString( "", Constants.DEFAULT_PORT_DATA, event.obj as String  ); //Class = String
			networkDataEvent = new NetworkDataEvent( Constants.CUSTOM_APP_EVENT_TYPE_NWDATA_SEND, socData, false, false);
			netDeviceInf.dispatchEvent( networkDataEvent );
			break;
		case Constants.GEN_EVENT_TYPE_APP_QUIT:
			NativeApplication.nativeApplication.exit();			
			break;
		
	}
}
private function dbErrorEventHandler( event:events.AirDbEvent ):void {
	trace( "App. dbErrorEventHandler()." + event );	
}
private function applicationError( event:Event ):void {
	trace( "App. applicationError. : " + event );				
}
private function sendFileReq( obj:Object ):void {  
	socDataFile = new SocketData( Constants.SOC_RECEIVE_DATA_TYPE_FILE );
	socDataFile.setSendData_FileContent( "", Constants.DEFAULT_PORT_FILE, obj.file as File, callbackSendFileReq, callbackSendFileReq_Error, obj );			
}
public function callbackSendFileReq():void {
	networkDataEvent = new NetworkDataEvent( Constants.CUSTOM_APP_EVENT_TYPE_NWFILE_SEND, socDataFile, false, false);
	netDeviceInf.dispatchEvent( networkDataEvent );				
}
public function callbackSendFileReq_Error(event:Event):void {
	trace( "App. callbackSendFileReq_Error(). " + event.type );								
}

