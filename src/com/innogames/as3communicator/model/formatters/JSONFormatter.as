package com.innogames.as3communicator.model.formatters
{
	import avmplus.getQualifiedClassName;

	import com.innogames.as3communicator.model.DisplayObjectUtils;
	import com.innogames.as3communicator.model.DisplayObjectVO;

	/**
	 * This formatter converts DisplayObjectVOs into valid JSON.
	 */
	public class JSONFormatter implements IResultFormatter
	{

		public function JSONFormatter()
		{
		}


		public function formatTree(vecObjects:Vector.<DisplayObjectVO>):String
		{
			var strJSON:String;
			var objJSON:Object = {elements: []};

			recursiveGetChildrenToJSON(vecObjects, objJSON.elements);

			strJSON = JSON.stringify(objJSON);

			return strJSON;
		}


		public function formatTreeWithProperties(vecObjects:Vector.<DisplayObjectVO>):String
		{
			var strJSON:String;
			var objJSON:Object = {elements: []};
			for each (var objDO:DisplayObjectVO in vecObjects)
			{
				objJSON.elements[objJSON.elements.length] =
				{
					'type': getQualifiedClassName(objDO.displayObject),
					'properties': DisplayObjectUtils.toJSON(objDO.displayObject)
				};
			}

			strJSON = JSON.stringify(objJSON);

			return strJSON;
		}


		public function formatVO(objVO:DisplayObjectVO):String
		{
			return DisplayObjectUtils.toJSON(objVO.displayObject).toString();
		}


		private function recursiveGetChildrenToJSON(vecAllObjects:Vector.<DisplayObjectVO>,
													arrParent:Array):void
		{
			var index:int = 0;
			for each (var objDO:DisplayObjectVO in vecAllObjects)
			{
				arrParent[index] = {
					'type': getQualifiedClassName(objDO.displayObject),
					'name': objDO.displayObject.name
				};

				if(objDO.hasChildren)
				{
					arrParent[index].children = [];
					this.recursiveGetChildrenToJSON(objDO.children
							as Vector.<DisplayObjectVO>, arrParent[index].children);
				}

				++index;
			}
		}
	}
}
