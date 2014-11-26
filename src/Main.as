package 
{
	import com.gestureworks.cml.core.CMLObjectList;
	import com.gestureworks.cml.core.CMLParser;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	
	import com.gestureworks.cml.components.Component;
	
	import com.gestureworks.cml.elements.Container;
	import com.gestureworks.cml.elements.Slideshow;
	import com.gestureworks.cml.elements.Button;
	
	import com.gestureworks.cml.events.StateEvent;
	
	import com.gestureworks.core.GestureWorks;
	
	import com.gestureworks.events.GWGestureEvent;
	
	import flash.events.Event;
	import flash.text.TextField;
	import flash.utils.Timer;
	

	[SWF(width = "1920", height = "1080", backgroundColor = "0x000000", frameRate = "30")]
	public class Main extends GestureWorks
	{	
		private var currentMap:Component;
		private var fadeInDict:Dictionary = new Dictionary();
		private var fadeOutDict:Dictionary = new Dictionary();
		private var maps:Array = new Array(10);
		
		private var fading:Boolean = false;
		
		public function Main() 
		{
			super();

			//fullscreen = true;
			gml = "library/gml/gestures.gml";
			cml = "library/cml/main.cml";

			CMLParser.addEventListener(CMLParser.COMPLETE, cmlComplete);
		}
		
		override protected function gestureworksInit():void
		{
		}
		
		private function slideshowStateEventHandler(event:StateEvent):void
		{
			this.currentMap.visible = true;
			this.fading = false;
		}


		private function btnStateEventHandler(event:StateEvent):void
		{   
			if (this.fading) return;
			
			var offscene:Component;
			var newscene:Component;
			var slideshow:Slideshow;
			
			var currentMapIndex:int = this.maps.indexOf(this.currentMap);
			
			if (event.value == "NextMap" && currentMapIndex < this.maps.length && this.maps[currentMapIndex + 1] != undefined) 
			{
				this.fading = true;
				this.currentMap.visible = false;
				
				var slideshow:Slideshow = CMLObjectList.instance.getId("mainslideshow");
				slideshow.next();
				
				this.currentMap = this.maps[currentMapIndex + 1];
			}

			if (event.value == "PrevMap" && currentMapIndex > 0) 
			{
				this.fading = true;
				this.currentMap.visible = false;
				
				var slideshow:Slideshow = CMLObjectList.instance.getId("mainslideshow");
				slideshow.previous();
				
				this.currentMap = this.maps[currentMapIndex - 1];
			}			
		}
		
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
		}		
	}
}
