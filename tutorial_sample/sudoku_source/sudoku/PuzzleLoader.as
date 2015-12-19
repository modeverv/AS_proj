﻿package sudoku {	import flash.display.DisplayObjectContainer;	import flash.display.Shape;	import flash.display.Sprite;	import flash.text.TextField;	import flash.events.Event;	import flash.events.ProgressEvent;	import flash.net.URLLoader;	import flash.net.URLRequest;    import flash.external.ExternalInterface;    import sudoku.LittleProgressBar;	import sudoku.Random;			import flash.display.Sprite;			// Added for AIR portability	import flash.filesystem.File;	import flash.filesystem.FileStream;	import flash.filesystem.FileMode;	// ********************************	// This class extends TextField, to support one cell in the Sudoku grid.	// The field knows how to format itself, choosing font size according to the number of characters.	// A field can be read-only, for the original puzzle digits, or read/write, for the digits enetered by the player.	// Characters are limited to digits 1-9.	public class PuzzleLoader extends Sprite {		private var _bar:LittleProgressBar;		private var _source:uint;		private var _level:uint;				private var answerString:String;				public var cheat:String = "";		public var masks:String = "";		public const HTML_READY_EVENT:String = "puzzleReady";		public var ready:Boolean = false;        		private var isJavascriptAvailable:Boolean = false;//ExternalInterface.available;		private var objectID:String = ExternalInterface.objectID;		private var ran:Random = new Random();				private var puzzleData:FileStream;				private var xmlPuzzles:XML;		private var xmlReady:Boolean = false;		private var loader:URLLoader;		private var cannedPuzzles:XML =			<sudoku>				<puzzle>					<key>7...98..3.157..82.3..16.5...49.......6.....3.......95...7.89..5.81..367.4..27...8</key>					<key>5947....831.......8...654.36..31795...........59248..72.597...6.......724....6819</key>				</puzzle>				<puzzle>					<key>5........4..2...86...61.79..32.7.96.....6.....56.9.43..18.27...94...1..7........1</key>				</puzzle>				<puzzle>					<key>.5.9.......86.3..164....8........6.83.62.87.98.2........9....677..1.29.......9.8.</key>				</puzzle>				<puzzle>					<key>..1.........392..46..4...8..2...5..1..8.2.9..3..1...2..9...8..24..263.........8..</key>				</puzzle>						</sudoku>		;				// -----------------------------------------------------		//	CONSTRUCTOR:  PuzzleLoader		// -----------------------------------------------------								public function PuzzleLoader(bar:LittleProgressBar, source:uint=1, level:uint=2) {						_bar = bar;			_source = source;			_level = level;			ran.randomize();			// various ways to load a puzzle, controlled by const			switch(source) {				case 1: loadXML(); break;				case 2: loadJavascript(); break;				case 3: loadFromExternalSite(); break;			}		}		public function get difficulty() {			return _level;		}				public function getDifficulty():String		{			var str:String;			switch (_level) {				case 1: str= "Easy"; break;				default:				case 2: str= "Medium"; break;				case 3: str= "Hard"; break;				case 4: str= "Very Hard"; break;			}			return str;		}		// =========================================================		//	Load puzzles from XML file locally or from same site		// =========================================================		private function loadXML():void		{			//	Load xmlPuzzles from an external file "sudoku.xml"			// xmlPuzzles = new XML();						// Added for AIR portability			var storedFile:File = File.applicationStorageDirectory.resolvePath(Main.STORED_FILE_NAME);						if (storedFile.exists) {										puzzleData = new FileStream()					puzzleData.addEventListener(Event.COMPLETE, completeDataRead);					puzzleData.addEventListener(ProgressEvent.PROGRESS, handleProgress);											puzzleData.openAsync(storedFile, FileMode.READ);									}						// var xmlPuzzlesURL:URLRequest = new URLRequest(Main.storedFile);						//	loader = new URLLoader(xmlPuzzlesURL);			//	loader.addEventListener(Event.COMPLETE, xmlLoaded);			//	loader.addEventListener(ProgressEvent.PROGRESS, handleProgress);		}				// Added for AIR portability		private function completeDataRead(e:Event):void {						xmlPuzzles = XML(puzzleData.readUTFBytes(puzzleData.bytesAvailable));			xmlLoaded();						puzzleData.close();					}		// ********************************				// ----------------------------------------------------------		//	xmlLoaded() -- After sudoku.xml has been loaded, obtain a puzzle		// ----------------------------------------------------------		private function xmlLoaded(/*event:Event*/):void		{			// randomize		/*	ran.randomize();			if (_level == 0) {				_level = ran.next() * 4 + 1;	// 1...4			}						// parse the XML and find the level we want			xmlPuzzles = XML(event.target.data);*/			var puzzle:XML = xmlPuzzles.puzzle[_level - 1];			// count puzzles, skip to the level we want			var numPuzzles:uint = puzzle.elements("key").length();			if (numPuzzles < 1) {				puzzle = cannedPuzzles.puzzle[_level - 1];				numPuzzles = puzzle.elements("key").length();			}			// pick a puzzle			var puzzleIndex:uint = ran.next()*numPuzzles;			var puzz:String = puzzle.key[puzzleIndex];						// format the puzzle and solve it			var pat:RegExp = /\./g;			masks = puzz.replace(pat, "0");			cheat = solveIt(puzz);						xmlReady = true;			ready = true;			dispatchEvent(new Event(HTML_READY_EVENT));		}								// =========================================================		//	Load puzzles using JavaScript		// =========================================================		private function loadJavascript()		{			var results:String;			if (isJavascriptAvailable) {				// we are running in an HTML page or in Flash Test Movie				trace("inside an HTML page", ", objectID = ", objectID);				try {					results = ExternalInterface.call("getPuzzle", "swf", _level);				}				finally {					trace("finally");				}			if (results) {				trace(results);			} else {				trace("External Interface did not work");			}			}			if (results != null) {				decipherSource0(results);				ready = true;				dispatchEvent(new Event(HTML_READY_EVENT));			} else {				loadFromExternalSite();			}		}				// =========================================================		//	Load puzzles from external site		// =========================================================		//	Pick a site according to _level:		//	0: randomly choose between dailysudoku and USAToday		//	1-4: WebSudoku at difficulty 1-4		//	5: dailysudoku		//	6: USA Today		private function loadFromExternalSite ():void		{			if (_level == 0 || _level > 6) {				// Get today's daily puzzle from dailysudoku.com or USA Today				_level = ran.next()*2 + 5; // 5 or 6			}			var url:String = "http://www.txbobsc.com/misc/sdk/getwsdk.php/?level=" + _level;			loadData(url);		}						private function loadData(url:String):void {			trace(url);						var loader:URLLoader = new URLLoader();			loader.addEventListener(Event.COMPLETE, handleComplete);			loader.addEventListener(ProgressEvent.PROGRESS, handleProgress);			loader.load(new URLRequest(url));		}				private function handleComplete(event:Event):void {			var loader:URLLoader = URLLoader(event.target);			var html:String = loader.data;						if (_level < 5) {				decipherSource1234(html);			}			else if (_level == 5) {				decipherSource0(html);			} else {				decipherSourceUSAT(html);			}			ready = true;			dispatchEvent(new Event(HTML_READY_EVENT));								}						// =========================================================		//	Extract and Decipher a puzzle		// =========================================================				// ---------------------------------------------------------		// Decipher puzzle from http://www.dailysudoku.com/cgi-bin/sudoku/get_board.pl		// ---------------------------------------------------------		private function decipherSource0(html:String):void {			//{"difficulty":1,			//"numbers":"5...46.9.93..1......8...351..4.37.1829.....6318.62.5..815...6......5..87.2.46...5",			//"title":"Daily Sudoku: Fri 16-Mar-2007",			//"clues":"5...46.9.93..1......8...351..4.37.1829.....6318.62.5..815...6......5..87.2.46...5",			//"type":""}			cheat = html.substr(html.search("numbers") + 10, 81);//cheat = "......2...5...43914...73.5.794815..3.6.......38.629.7.2..4..76.97.5.84...41.....8";//cheat = "......2.........914...73.5.7...1...3.6........8.629.7.2..4......7.5.8.....1.....8";//cheat = "...97..4.5..4.3.9.79..5.83..........1..7....2.8..6175...5......473.861..9621.....";//cheat = ".3...1......2.85..8...57....836...911564....2..9....5..2.59..6..74....8..917.324.";//cheat = "......7..391...6.......5.2..1.654..3..........8..2......8...9..6.57.83...4...2..8";//cheat = "......2........97.8....4.3.7.1.568...9.3......8..21..46.8...4..9..6......52.13...";//trace(cheat);			var pat:RegExp = /\./g;			masks = cheat.replace(pat, "0");			cheat = solveIt(cheat);			var diff:String = html.substr(html.search("difficulty") + 12, 1); // 1...4			_level = int(diff);		}				// ---------------------------------------------------------		// Decipher puzzle from http://www.websudoku.com/?level=		// ---------------------------------------------------------		private function decipherSource1234(html:String):void {			cheat = html.substr(html.search("cheat") + 7, 81);			masks = "";var dotPuzz:String = "";			for (var i=0; i<81; i++) {				var row:int = i%9;				var col:int = i/9;				var name:String = "c" + row + col;				var cell:String = html.substr(html.search(name), 80);				if (cell.search("READONLY") > 0) {					masks += "1";dotPuzz += cheat.charAt(i);					} else {					masks += "0";dotPuzz += ".";				}			}		dispatchEvent(new UpdateStoredPuzzlesEvent(_level, "<key>" + dotPuzz + "</key>"));		}				// ---------------------------------------------------------		// Decipher puzzle from http://picayune.uclick.com (via getUSAT.php)		// ---------------------------------------------------------		/*		<Sudoku>			<Date v="070419" />			<Code v="ussud" />			<Difficulty v="4" />			<Score v="75" />			<Range v="1,2,3,4,5,6,7,8,9" />			<layout>				<l1 v="89------2" />				<l2 v="----12-8-" />				<l3 v="---3--7--" />				<l4 v="--167---9" />				<l5 v="-2--9--6-" />				<l6 v="5---214--" />				<l7 v="--4--6---" />				<l8 v="-1-53----" />				<l9 v="9------26" />			</layout>			<solution>				<l1 v="893754612" />				<l2 v="675912384" />				<l3 v="142368795" />				<l4 v="481673259" />				<l5 v="327495168" />				<l6 v="569821473" />				<l7 v="754286931" />				<l8 v="216539847" />				<l9 v="938147526" />			</solution>		</Sudoku>		*/		private function decipherSourceUSAT(html:String):void {			xmlPuzzles = XML(html);			var diff:String = xmlPuzzles.Difficulty..@v;			// convert from range 1...9 to range 1...4			_level = ((int(diff) - 1) * 4 / 9) + 1;			var puzzle:XMLList = xmlPuzzles.layout;			masks = puzzle.l1..@v + puzzle.l2..@v + puzzle.l3..@v					+ puzzle.l4..@v + puzzle.l5..@v + puzzle.l6..@v					+ puzzle.l7..@v + puzzle.l8..@v + puzzle.l9..@v;			puzzle = xmlPuzzles.solution;			cheat = puzzle.l1..@v + puzzle.l2..@v + puzzle.l3..@v					+ puzzle.l4..@v + puzzle.l5..@v + puzzle.l6..@v					+ puzzle.l7..@v + puzzle.l8..@v + puzzle.l9..@v;							}				private function reduceRange(value:int, in0:int, in1:int, out0:int, out1:int):int {			var ret:int = (value - in0) * out1;			ret = (ret / in1) + out0;			return ret;		}				// =========================================================		//	Progress Bar		// =========================================================		private function handleProgress(event:ProgressEvent):void {//trace("progress " + event);			var estTotal = 15600;			if (event.bytesTotal > 0) {				estTotal = event.bytesTotal;			}			_bar.setProgressBar(event.bytesLoaded, estTotal);		}		// =========================================================		//	Solve a puzzle		// =========================================================		private var recursionCount:uint = 0;		private function solveIt(puzzle:String):String		{			var puzz:Array = new Array();			for (var i:uint=0; i<81; i++) {				puzz[i] = puzzle.charCodeAt(i) - 0x30;				if (puzz[i] < 1 || puzz[i] > 9) {					puzz[i] = 0;				}			}			recursionCount = 0;			recursiveSolver(puzz, 81);			trace("recursionCount = " + recursionCount);			return answerString;		}				private function recursiveSolver(puzzle:Array, p:int):Boolean		{			recursionCount++;			var finished:Boolean = false;			var u:uint = 0;			var i:int;			while (--p >= 0 && puzzle[p] > 0) {				// we already know this digit			} 			if(p < 0) {				// we have a solution				finished = true;					for (i=0; i<81; i++) {					answerString += puzzle[i];				}			} else {				for (i=81; i-- > 0; i) {					// is cell i in same row, column, or box as cell p?					u |= (p-i)%9 * (p/9^i/9) * (p/27^i/27|p%9/3^i%9/3)==0 ? 1 << puzzle[i] : 0;				}				for (puzzle[p] = 10; --puzzle[p] > 0;) {					if ((u >> puzzle[p] & 1) < 1){						finished = recursiveSolver(puzzle, p);						if (finished) break;					}				}			}			return finished;		}	}}