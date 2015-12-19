// Copyright (c) 2007. Adobe Systems Incorporated.
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
//   * Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//   * Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//   * Neither the name of Adobe Systems Incorporated nor the names of its
//     contributors may be used to endorse or promote products derived from this
//     software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

var Podcast; if (!Podcast) Podcast = {};

Podcast.Player = function () {
	this.initialize.apply(this, arguments);
}

Podcast.Player.appInit =  function() {
		var player = new Podcast.Player();
		window.onresize = function(){ player.resizeSlides(); }
		player.resizeSlides();
		nativeWindow.visible =true;

		Podcast.Player = player;
};

Podcast.Player.prototype = {
	initialize:	function() {
		var self = this;
		nativeWindow.addEventListener(runtime.flash.events.Event.CLOSING, function(){   
			if(self.isAboutOpened){
				self.lastAboutWindow.close();
			}
		});
		
		
		var cbs = {
			loadComplete: this.onConfigReceived.createCallback(this),
			IOError: this.onFeedError.createCallback(this),
			securityError: this.onFeedError.createCallback(this)
		};
		this.loading = document.getElementById("loader");
		this.feedList = document.getElementById("podcasts");
		this.feedImage = document.getElementById("pimage");
		this.feedDescription = document.getElementById("pdesc");
		this.feedArticles = document.getElementById("podcastItems");
		this.nowPlayingHref = document.getElementById("nowPlayingHref");
		
		// add handler
		//this.feedList.addEventListener("change", this.onFeedSelected.createCallback(this));
		//this.feedArticles.addEventListener("change", this.onArticleSelected.createCallback(this));		
		this.soundPlayer = new Podcast.SoundPlayer();
		var configService = new Podcast.URLService("app:/playerconfig.xml", cbs);
		configService.send();
	},
	
	onConfigReceived: function(event) {
		this.feedArray = Podcast.Utils.parseConfig(event.data);
		Podcast.Utils.addPodcasts(this.feedArray, this.feedList, this.onFeedSelected.createCallback(this));
	},
	
	onFeedError: function(event) {
		air.trace(event.text);
	},
	
	onFeedSelected: function(url) {
		this.gotoPage(2);
		this.feedImage.style.visibility="hidden";
		this.feedDescription.innerHTML = "Loading feed....";
		this.feedArticles.innerHTML = '';
		var cbs = {
			loadComplete: this.onFeedReceived.createCallback(this),
			IOError: this.onFeedError.createCallback(this),
			securityError: this.onFeedError.createCallback(this)			
		};
		var service = new Podcast.URLService(url, cbs);
		service.send();
	},
	
	onFeedReceived: function(event) {
		this.gotoPage(2);
		this.currentFeed = Podcast.Utils.parseFeed(event.data);
		this.feedImage.src = this.currentFeed.imageUrl;
		this.feedImage.style.visibility="visible";		
		this.feedDescription.innerHTML = Podcast.Utils.getDescriptionHTML(this.currentFeed);
		Podcast.Utils.addArticles(this.currentFeed.itemArray, this.feedArticles, this.onArticleSelected.createCallback(this));
	},
	
	onArticleSelected: function(title, url) {
		this.gotoPage(3);
		this.nowPlayingHref.style.visibility="visible";
		this.soundPlayer.load(url, title);
	},


	setScroll: function(pos){
		var slideBox = document.getElementById('slideBox');
		var slide = slideBox.firstChild;
		var width = slideBox.clientWidth;
		var start = -pos;
		while(slide){
			if(slide.nodeType==1){
				slide.style.left = start + 'px';
				start+=width;
			}
			slide = slide.nextSibling;
		}
		 
	},
	
	resizeSlides: function(){
		var self = this;
		setTimeout(function(){
			var lastPage = this.lastPage;
			if(!lastPage) lastPage = 1;
			var slideBox = document.getElementById('slideBox');
			
			var width = slideBox.clientWidth;
			var startPixel = width*(lastPage-1);
			
			self.setScroll(startPixel);
		}, 0);
	},
	
	gotoPage: function(page){
		if(this.staticInterval) clearInterval(this.staticInterval);
		var lastPage = this.lastPage;
		if(!lastPage) lastPage = 1;
		var fps = 30;
		var slideBox = document.getElementById('slideBox');
		var width = slideBox.clientWidth;
		var startPixel = width*(lastPage-1);
		var stopPixel = width*(page-1);
		var transition = 0;
		var transitionEffect = function(pos){ return Math.pow(pos,2); }
		var currentEffect  = 0;
		var duration = 0.2;
		var step = 1/(duration*fps);
		var currentPixel = startPixel;

		var self = this;
		
		this.staticInterval = setInterval(function(){
			transition+=step; 
			if(transition>1) transition = 1;
			currentEffect = transitionEffect(transition);
			currentPixel = currentEffect * stopPixel + (1-currentEffect) * startPixel;
			self.setScroll(currentPixel);
			if(transition>=1){
				 clearInterval(self.staticInterval);
				 self.staticInterval = null; 
			}
		}, 1000/fps);
		
		this.lastPage = page;
		
	},
	
	viewAbout: function(){
		var self = this;
		if(self.isAboutOpened){
			self.lastAboutWindow.orderToFront();
			return;
		}
		self.isAboutOpened = true;
		var aboutWindow = window.open("about.html", "About", "resizable=no,centerscreen=yes,scrollbars=no,dialog=yes,modal=yes,width=300,height=150");
		aboutWindow.nativeWindow.addEventListener(runtime.flash.events.Event.CLOSE, function(){ self.isAboutOpened = false; self.lastAboutWindow = null; });
		self.lastAboutWindow = aboutWindow.nativeWindow;
	},
	
	viewSources: function(){
		var sb = air.SourceViewer.getDefault();
		var cfg = {exclude: ['/SourceViewer']};
		sb.setup(cfg);
		sb.viewSource();
	}
	
};
	
	
Function.prototype.createCallback = function(obj, args){
		var method = this;
		return function() {
			var callArgs = args || arguments;
			return method.apply(obj || window, callArgs);
		};
};
