package 
{
	import com.gestureworks.cml.core.CMLObjectList;
	import com.gestureworks.cml.core.CMLParser;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	
	import com.gestureworks.cml.components.Component;
	import com.gestureworks.cml.components.MediaViewer;
	
	import com.gestureworks.cml.elements.Container;
	import com.gestureworks.cml.elements.Slideshow;
	import com.gestureworks.cml.elements.Button;
	
	import com.gestureworks.cml.events.StateEvent;

	import com.gestureworks.cml.utils.*;

	import com.gestureworks.core.GestureWorks;
	
	import com.gestureworks.events.GWGestureEvent;
	
	import flash.events.Event;
	import flash.text.TextField;
	import flash.utils.Timer;
	

	[SWF(width = "1920", height = "1080", backgroundColor = "0x000000", frameRate = "30")]
	public class Main extends GestureWorks
	{	
		/**
		 * Einige private Felder...
		 */
		private var currentMap:Component;
		private var photoDict:Dictionary = new Dictionary();
		private var maps:Array = new Array(10);
		
		private var fading:Boolean = false;
		
		/**
		 * Main-Methode; Hier geht's los
		 */
		public function Main() 
		{
			super();

			//fullscreen = true;
			gml = "library/gml/gestures.gml";
			cml = "library/cml/main.cml";

			CMLParser.debug = false;
			CMLParser.addEventListener(CMLParser.COMPLETE, cmlComplete);
		}
		
		/**
		 * Initialisierungs-Methode; die brauchen wir nicht zu füllen
		 */
		override protected function gestureworksInit():void
		{
		}
		
		/**
		 * Handler für das Event, dass der Status einer SlideShow sich geändert hat
		 * @param	event
		 */
		private function slideshowStateEventHandler(event:StateEvent):void
		{
			this.currentMap.visible = true;
			this.fading = false;
		}

		/**
		 * Handler für das Event, dass der Status eines Buttons sich geändert hat (idR. weil er angetippt wurde)
		 * @param	event
		 */
		private function btnStateEventHandler(event:StateEvent):void
		{   
			if (this.fading) return;
			
			var offscene:Component;
			var newscene:Component;
			var slideshow:Slideshow;
			var button:Button;
			
			var currentMapIndex:int = this.maps.indexOf(this.currentMap);
			
			if (event.value == "NextMap" && currentMapIndex < this.maps.length && this.maps[currentMapIndex + 1] != undefined) 
			{
				this.fading = true;
				this.currentMap.visible = false;
				
				slideshow = CMLObjectList.instance.getId("mainslideshow");
				slideshow.next();
				
				this.currentMap = this.maps[currentMapIndex + 1];
			}

			if (event.value == "PrevMap" && currentMapIndex > 0) 
			{
				this.fading = true;
				this.currentMap.visible = false;
				
				slideshow = CMLObjectList.instance.getId("mainslideshow");
				slideshow.previous();
				
				this.currentMap = this.maps[currentMapIndex - 1];
			}
			
			currentMapIndex = this.maps.indexOf(this.currentMap);
			
			button = CMLObjectList.instance.getId("btn-nextmap");
			button.visible = !(currentMapIndex == this.maps.length || this.maps[currentMapIndex + 1] == undefined);
			
			button = CMLObjectList.instance.getId("btn-prevmap");
			button.visible = !(currentMapIndex == 0);
		}
		
		/**
		 * Handler für das Event, dass die CML-Datei vollständig geladen wurde
		 * @param	event
		 */
		private function cmlComplete(event:Event):void
        {
			CMLParser.removeEventListener(CMLParser.COMPLETE, cmlComplete);
			
			// Die Szenen holen und merken
			this.maps[0] = CMLObjectList.instance.getId("scene1");
			this.maps[1] = CMLObjectList.instance.getId("scene2");
			this.maps[2] = CMLObjectList.instance.getId("scene3");
			this.maps[3] = CMLObjectList.instance.getId("scene4");
			
			// Wir fangen mit Szene "0" an
			this.currentMap = this.maps[0];
			
			// Die Blätter-Schaltflächen scharfschalten
			var btn:Button = CMLObjectList.instance.getId("btn-nextmap");
			btn.addEventListener(StateEvent.CHANGE, btnStateEventHandler);

			btn = CMLObjectList.instance.getId("btn-prevmap");
			btn.addEventListener(StateEvent.CHANGE, btnStateEventHandler);
			
			// Hintergrund-Slideshow holen
			var slideshow:Slideshow = CMLObjectList.instance.getId("mainslideshow");
			slideshow.addEventListener(StateEvent.CHANGE, slideshowStateEventHandler);
			
			var viewers:LinkedMap = CMLObjectList.instance.getClass(MediaViewer);
			while (viewers.hasNext()) {
				var viewer:MediaViewer = viewers.currentValue as MediaViewer;
				viewer.addEventListener(StateEvent.CHANGE, popUpPlacementHandler);
				viewers.next();
			}			
		}
		
		/**
		 * Handler für das Event, dass ein Foto eingeblendet und platziert werden soll. 
		 * @param	event
		 */
		private function popUpPlacementHandler(event:StateEvent):void
		{
			// always open close to center but offset based on hotspot location
			if (event.property == "hotspot") 
			{	
				var viewer:MediaViewer = document.getElementById(event.target.id) as MediaViewer;
				
				if (this.photoDict[viewer] == undefined)
				{
					viewer.x = (DefaultStage.instance.stage.stageWidth *.5 - viewer.x)*.1 + DefaultStage.instance.stage.stageWidth*.6;
					viewer.y = (DefaultStage.instance.stage.stageHeight * .5 - viewer.y) * .1 + DefaultStage.instance.stage.stageHeight * .2;
					viewer.rotation = this.randomRange(10, -10);
					this.photoDict[viewer] = true;
				}
			}			
		}		
		
		/**
		 * Erzeugt eine Zufallszahl in einem gegebenen Wertebereich
		 * @param	max	Maximalwert
		 * @param	min	Minimalwert
		 * @return	die Zufallszahl
		 */
		private function randomRange(max:Number, min:Number = 0):Number
		{
			 return Math.random() * (max - min) + min;
		}		
	}
}
