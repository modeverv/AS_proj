package sudoku{
	
	import flash.display.Sprite;
	import sudoku.PuzzleBox;
	import sudoku.Background;
	import sudoku.Cell;
	import sudoku.Grid;
	import sudoku.Headline;
	import sudoku.RRButton;
	import sudoku.PuzzleLoader;
	import sudoku.LittleProgressBar;
	import sudoku.Random;	// my own generator
	import sudoku.DiffSlider;	// my own slider
	import sudoku.OptionsPanel;
	import fl.controls.CheckBox;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.net.SharedObject;
	import flash.display.DisplayObject;
	import flash.system.Security;
	import flash.system.SecurityPanel;
	
	// Added for AIR portability
	import air.net.URLMonitor;
	import flash.net.URLRequest;
	import flash.events.StatusEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	// ********************************
	
	import flash.text.TextField;
	
	public class Main extends Sprite {
		
		private var optionsPanel:OptionsPanel;
		private var rand:Random;
		private var puzzleSource:uint; // 1=XML, 2=JavaScript, 3=External Sites
		private var puzzleLevel:uint;
		private var progBar:LittleProgressBar;
		private var html:PuzzleLoader;
		
		// Added for AIR portability
		private var monitor:URLMonitor;
		private var puzzleData:FileStream;
		private var updateStream:FileStream;
		private var currentXML:String;
		private var currentLevel:uint;
		// ********************************
		
		// Banner
		private var banner:String;
		private var bannerTimer:Timer;
		private var finishedMsg:Headline;
		
		// Puzzle
		private var puzzleBox:PuzzleBox;
		private var grid:Grid;
		
		// Controls
		private var checkButton:RRButton;
		private var hintsButton:RRButton;
		private var newButton:RRButton;
		private var diffSlider;
		private var resetButton:RRButton;
		private var pauseButton:RRButton;
		private var optionsButton:RRButton;
		private var resumeButton:RRButton 
		private var removedButton:DisplayObject;
		private var optionCB1:CheckBox;
		private var optionCB2:CheckBox;
				
		// Constants
		private const puzzleLeft:int = 50;
		private const puzzleTop:int = 50;
		private const puzzleWidth:int = 450;
		private const cellSize:int = 50;
		
		// Added for AIR portability
		private const LOCAL_FILE_NAME:String = "sudoku.xml";
		public static const STORED_FILE_NAME:String = "sudoku_stored.xml";
		// ********************************
				
		// Added for AIR portability
		private const ON_LINE_OFF_LINE:String = "http://www.google.com";
		// ********************************
		
		// Cheat and mask
		private var cheat:String;
		private var masks:String;
		
		// Miscelaneous
		private var startTime:Date;
		private var savedTime:Number;	// millisconds used before pause
		
		
		public function Main() {
			
			// Added for AIR portability
			monitor = new URLMonitor(new URLRequest(ON_LINE_OFF_LINE));
			monitor.addEventListener(StatusEvent.STATUS, handleOnLineOffLineStatus);
			monitor.start();
						
			var storedFile:File = File.applicationStorageDirectory.resolvePath(STORED_FILE_NAME);
			
			if(!storedFile.exists){
			
				var file:File = File.applicationDirectory.resolvePath(LOCAL_FILE_NAME);
				
				if (file.exists) {
					
					puzzleData = new FileStream()
					puzzleData.addEventListener(Event.COMPLETE, completeDataCopy);
						
					puzzleData.openAsync(file, FileMode.READ);
					
				}
				
			}else {
				
				initGame();
			
			}
			// ********************************
					
			
		}
				
		// Added for AIR portability
		private function completeDataCopy(e:Event):void {
			
			var xdata:XML = XML(puzzleData.readUTFBytes(puzzleData.bytesAvailable));
			
			var folder:File = File.applicationStorageDirectory; 
			var file:File = folder.resolvePath(STORED_FILE_NAME);
			
			var newFile:FileStream = new FileStream();
			newFile.open(file, FileMode.WRITE);
			
			newFile.writeUTFBytes(xdata);
			newFile.close();
			
			initGame();
			
		}
		// ********************************
		
		// Moved contructor
		private function initGame():void {			
						
			savedTime = 0;
			
			cheat = "684251379193687245725943816432598167816734592957126483361875924579412638248369751"; 
			masks = "001100001011101000001010011000100100100000001001001000110010100000101110100001100";
			
			rand = new Random();
			rand.randomize();
			
			puzzleSource = 1; // 1=XML, 2=JavaScript, 3=External Sites
			puzzleLevel = rand.next()*4+1;
			
			// Setup Options Panel
			optionsPanel = new OptionsPanel(50, 50, 446, 446);
			
			optionCB1 =  new CheckBox();
			optionCB1.label = "External source of puzzles";
			optionsPanel.addOption(50, 100, 200, optionCB1);
			
			optionCB2 =  new CheckBox();
			optionCB2.label = "Really big hints";
			optionsPanel.addOption(50, 125, 200, optionCB2);
			
			if (optionsPanel.getOption("External") == undefined) {
				
				optionsPanel.setOption("External", false);
			
			}
						
			if (optionsPanel.getOption("BigHints") == undefined) {
				
				optionsPanel.setOption("BigHints", false);
			
			}

			if (optionsPanel.getOption("External")) {
				
				puzzleSource = 3;	// get puzzle from external source
				puzzleLevel = rand.next()*5;	// 0...4
			
			}
						
			progBar = new LittleProgressBar(175, 10, 200, 5);
			addChild(progBar);
			
			html = new PuzzleLoader(progBar, puzzleSource, puzzleLevel);
			
			// Banner
			finishedMsg = new Headline(550);
			addChild(finishedMsg);
			
			// Puzzle
			addChild(new Background(puzzleLeft, puzzleTop, puzzleWidth));
			
			puzzleBox = new PuzzleBox(puzzleLeft, puzzleTop, cellSize, cellSize);
			addChild(puzzleBox);
			
			grid = new Grid(puzzleLeft, puzzleWidth);
			addChild(grid);	// add the grid on top of the cells
			
			// Controls
			checkButton = new RRButton(50, 505, 60, "Check", onCheckBtn);
			addChild(checkButton);
			
			hintsButton = new RRButton(50, 528, 60, "Hints", onHintsBtn);
			addChild(hintsButton);
			
			newButton = new RRButton(200, 514, 75, "New Puzzle", onNewBtn);
			addChild(newButton);
			
			diffSlider = new DiffSlider(285, 505);
			addChild(diffSlider);
			
			resetButton = new RRButton(440, 528, 60, "Reset", onResetBtn);
			addChild(resetButton);
			
			pauseButton = new RRButton(440, 505, 60, "Pause", onPauseBtn);
			optionsButton = new RRButton(440, 505, 60, "Options", onPauseBtn);
			
			addChild(optionsButton);
			
			resumeButton = new RRButton(440, 505, 60, "Resume", onResumeBtn);

			addChild(optionsPanel);
			
			if (html.ready) {
				
				runPuzzle(null);
			
			} else {
				
				html.addEventListener(html.HTML_READY_EVENT, runPuzzle);
		
			}
			
		}
		
		
		// =============================================
		//	Functions
		// =============================================
		
		// Added for AIR portability
		private function handleOnLineOffLineStatus(e:StatusEvent):void {
			
			if(!monitor.available){
			
				if (puzzleSource == 3) {
					
					puzzleSource = 1;
					
				}
				
				optionsPanel.setOption("External", false);
			
			}
				
		}
		// ************************

		private function permutePuzzleDigits(puzzle:String):String{
			
			// given an 81 character string of digits, or digits and periods
			// randomly permute the digits 1...9
			
			if (puzzle.length != 81) {
				
				return puzzle;
			
			}
			
			// permute digits 1...9
			var digits:Array = [ 1,2,3,4,5,6,7,8,9 ];
			var i:int;
			
			for (i=0; i<20; i++) {
				
				var j:int = rand.next()*9;
				var k:int = rand.next()*9;
				var digit:int = digits[j];
				digits[j] = digits[k];
				digits[k] = digit;
			
			}
			
			// build permuted puzzle
			var newpuzzle:String = "";
			for (i=0; i<81; i++) {
				
				var ch:int = puzzle.charCodeAt(i) - 0x30;
				if ((ch >= 1) && (ch <= 9)) {
					
					ch = digits[ch-1];
				
				}
				
				newpuzzle += String.fromCharCode(ch + 0x30);
			
			}
			
			return newpuzzle;
			
		}

		private function transposePuzzle(puzzle:String):String{
			
			var newpuzzle:String = "";
			var i:int, j:int;
			
			for (i=0; i<9; i++) {
				
				for (j=0; j<9; j++) {
					
					newpuzzle += puzzle.charAt(j*9+i);
				
				}
			
			}
			//trace(puzzle);
			//trace(newpuzzle);
			return newpuzzle;
		
		}		
		
		// =============================================
		//	Event Handlers
		// =============================================
		private function runPuzzle(event:Event):void {
			
			removeChild(progBar);
			progBar = null;
			
			if (html.ready) {
				
				cheat = html.cheat;
				masks = html.masks;
			
			}
			
			cheat = permutePuzzleDigits(cheat);
			
			if (rand.next() > .5) {
				
				cheat = transposePuzzle(cheat);
				masks = transposePuzzle(masks);
			
			}

			puzzleBox.Populate(cheat, masks);
			
			checkButton.enabled = true;
			hintsButton.enabled = true;
			newButton.enabled = true;
			optionsButton.enabled = false;
			addChild(pauseButton);
			pauseButton.enabled = true;
			resetButton.enabled = true;
			
			startTime = new Date();
			finishedMsg.text = "Play Sudoku!!! -- Level: " + html.getDifficulty();

			diffSlider.value = html.difficulty;
			
		}

		private function onCheckBtn(evt:Event):void	{
			
			fixButtonsAndBanner();
			
			var endTime:Date = new Date();
			var solveTime:int = Math.round((endTime.time - startTime.time + savedTime) / 1000);
			var solveMinutes:int = solveTime / 60;
			var solveSeconds:int = solveTime % 60;
			var numCorrect:uint = puzzleBox.Check();
			if (numCorrect == 81) {
				
				// Finished!!
				// disable all buttons except New and Reset
				checkButton.enabled = false;
				hintsButton.enabled = false;
				pauseButton.enabled = false;
				removeChild(pauseButton);
				optionsButton.enabled = true;

				finishedMsg.text = "Congratulations! You took " + solveMinutes + " minutes and " + solveSeconds + " seconds.";
				
				// try to write new average on user's computer
				try {
					
					var solName:String = "average" + html.getDifficulty();
					var pat:RegExp = /[ ]/g;
					var lso:SharedObject = SharedObject.getLocal(solName.replace(pat, "_"));
					var num:uint = 0;
					var ave:uint = 0;
					
					if (lso.data.number) {
						
						num = lso.data.number;
						ave = lso.data.average;
						
					}
					
					ave = (num*ave + solveTime) / (num + 1);
					num++;
					lso.data.number = num;
					lso.data.average = ave;
					var flushResult:String = lso.flush();
					
					if (num > 1) {
						
						banner = "Your average for " + num + " ";
						banner += html.getDifficulty().toLowerCase() + " puzzles is ";
						solveMinutes = ave / 60;
						solveSeconds = ave % 60;
						
						if (solveMinutes > 0) {
							
							banner += solveMinutes + " minutes ";
						}
						
						banner += solveSeconds + " seconds.";
						
						if (bannerTimer == null) {
							
							bannerTimer = new Timer(2000);
							bannerTimer.addEventListener(TimerEvent.TIMER, onRotateBanner);
							
						}
						
						bannerTimer.start();
						
					}
				}
				
				catch(e:Error) {
					
					Security.showSettings(SecurityPanel.LOCAL_STORAGE);
				
				}
				
			} else {
				
				finishedMsg.text = (81-numCorrect) + " to go; time so far is " + solveMinutes + " minutes and " + solveSeconds + " seconds.";
			
			}
		
		}

		private function onRotateBanner(event:TimerEvent):void {
			
			var saveBanner:String = finishedMsg.text;
			finishedMsg.text = banner;
			banner = saveBanner;
		
			}

		private function onHintsBtn(evt:Event):void	{
			
			fixButtonsAndBanner();
			puzzleBox.findPossibles();
			
			if (optionsPanel.getOption("BigHints")) {
				
				puzzleBox.findSingletons();
				
			}
			
		}


		private function onPauseBtn(evt:Event):void {
			
			// exchange Pause and Resume buttons
			addChild(resumeButton);
			resumeButton.enabled = true;
			removedButton = removeChild(DisplayObject(evt.target));
			checkButton.enabled = false;
			hintsButton.enabled = false;
			newButton.enabled = false;
			resetButton.enabled = false;
			
			// save the time
			var pauseTime:Date = new Date();
			savedTime += pauseTime.time - startTime.time;

			// hide the puzzle
			puzzleBox.Hide();
			
			optionCB1.selected = optionsPanel.getOption("External");
			
			trace(optionsPanel.getOption("External"));
			
			// Added for AIR portability
			optionCB1.enabled = monitor.available;
			// *************************
			
			optionCB2.selected = optionsPanel.getOption("BigHints");
			optionsPanel.Show();
			
		}

		private function onResumeBtn(evt:Event = null):void {
			
			optionsPanel.setOption("External", optionCB1.selected);
			optionsPanel.setOption("BigHints", optionCB2.selected);
			optionsPanel.Hide();
			// exchange Pause and Resume buttons
			addChild(removedButton);
			removeChild(resumeButton);
			checkButton.enabled = true;
			hintsButton.enabled = true;
			newButton.enabled = true;
			resetButton.enabled = true;
			
			// show the puzzle
			puzzleBox.Show();
			
			// start the timer
			startTime = new Date();
			
		}

		private function onResetBtn(evt:Event):void {
			
			fixButtonsAndBanner();
			puzzleBox.Reset();
			checkButton.enabled = true;
			hintsButton.enabled = true;
			pauseButton.enabled = true;
			
		}

		private function onNewBtn(evt:Event):void {
			
			fixButtonsAndBanner();

			checkButton.enabled = false;
			hintsButton.enabled = false;
			pauseButton.enabled = false;
			newButton.enabled = false;
			resetButton.enabled = false;

			// which level is selected?
			if (optionsPanel.getOption("External")) {
				puzzleSource = 3;	// get puzzle from external source
				puzzleLevel = diffSlider.value;
			} else {
				puzzleSource = 1;	// get puzzle from my xml file
				puzzleLevel = diffSlider.value;
			}
			
			finishedMsg.text = "";
			savedTime = 0;
			progBar = new LittleProgressBar(175, 10, 200, 5);
			addChild(progBar);
			html = new PuzzleLoader(progBar, puzzleSource, puzzleLevel);
			html.addEventListener(html.HTML_READY_EVENT, runPuzzle);
			
			// Added for AIR portability
			html.addEventListener(UpdateStoredPuzzlesEvent.UPDATE, onPuzzleUpdate);
			// *************************
		
		}
		
		// Added for AIR portability
		private function onPuzzleUpdate(e:UpdateStoredPuzzlesEvent):void {
		
			currentXML = e.puzzle;
			currentLevel = e.level - 1;
			
			var folder:File = File.applicationStorageDirectory; 
			var file:File = folder.resolvePath(STORED_FILE_NAME);
			
			updateStream = new FileStream();
					
			// Define the listener for the FileStream
			updateStream.addEventListener(Event.COMPLETE, onPuzzleFileUpdate);		
								
			// Open the file
			updateStream.openAsync(file, FileMode.UPDATE);
			
		}
		
		private function onPuzzleFileUpdate(e:Event):void {
			
			XML.ignoreWhitespace = true;
			
			var xdata:XML = XML(updateStream.readUTFBytes(updateStream.bytesAvailable));
			
			xdata.puzzle[currentLevel].appendChild(currentXML);
						
			updateStream.position = 0;
			updateStream.truncate();
			
			updateStream.writeMultiByte(xdata, "utf-8");
						
			updateStream.close()
			
		}
		// *************************

		private function fixButtonsAndBanner(){
			
			if (bannerTimer) bannerTimer.stop();
		
		}
		
	}
	
}