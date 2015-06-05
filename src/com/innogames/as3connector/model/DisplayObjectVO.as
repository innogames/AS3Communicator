package com.innogames.as3connector.model
{
	import flash.display.DisplayObject;

	public class DisplayObjectVO
	{

		private var	blnHasChildren		:Boolean					,
					objDisplayObject	:DisplayObject				,
					strJSONData			:String						,
					vecChildren			:Vector.<DisplayObjectVO>	,
		 			objData				:Object						;

		public function DisplayObjectVO(displayObject:DisplayObject, children:Vector.<DisplayObjectVO>)
		{
			this.blnHasChildren		= children !== null;
			this.objDisplayObject	= displayObject;
			this.vecChildren		= children;
		}


		public function get children():Vector.<DisplayObjectVO>
		{
			return this.vecChildren;
		}


		public function get displayObject():DisplayObject
		{
			return this.objDisplayObject;
		}


		public function get hasChildren():Boolean
		{
			return this.blnHasChildren;
		}


		public function get jsonData():String
		{
			return this.strJSONData;
		}

		public function set jsonData(value:String):void
		{
			this.strJSONData = value;
		}


		public function get objectData():Object {return this.objData;}

		public function set objectData(value: Object): void {this.objData = value;}
	}

}
