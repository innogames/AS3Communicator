package com.innogames.as3communicator.model
{
	import flash.display.DisplayObject;

	public class DisplayObjectVO
	{

		public function DisplayObjectVO(displayObject:DisplayObject = null, children:Vector.<DisplayObjectVO> = null)
		{
			this.blnHasChildren = children !== null;
			this.objDisplayObject = displayObject;
			this.vecChildren = children;
		}
		private var blnHasChildren:Boolean,
				objDisplayObject:DisplayObject,
				vecChildren:Vector.<DisplayObjectVO>;

		public function get children():Vector.<DisplayObjectVO>
		{
			return this.vecChildren;
		}

		public function set children(vecChildren:Vector.<DisplayObjectVO>):void
		{
			this.blnHasChildren = vecChildren !== null;
			this.vecChildren = vecChildren;
		}


		public function get displayObject():DisplayObject
		{
			return this.objDisplayObject;
		}

		public function set displayObject(objDO:DisplayObject):void
		{
			this.objDisplayObject = objDO;
		}


		public function get hasChildren():Boolean
		{
			return this.blnHasChildren;
		}
	}

}
