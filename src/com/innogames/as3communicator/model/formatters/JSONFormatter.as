package com.innogames.as3communicator.model.formatters
{
	import avmplus.getQualifiedClassName;

	import com.innogames.as3communicator.model.DisplayObjectUtils;
	import com.innogames.as3communicator.model.DisplayObjectVO;

	import flash.display.DisplayObject;
	import flash.geom.Point;

	/**
	 * This formatter converts DisplayObjectVOs into valid JSON.
	 */
	public class JSONFormatter implements IResultFormatter
	{
		public function formatTree(vecObjects:Vector.<DisplayObjectVO>):String
		{
			var strJSON:String;
			var objJSON:Object = {elements: []};

			recursiveGetChildrenToJSON(vecObjects, objJSON.elements);

			strJSON = JSON.stringify(objJSON);

			return strJSON;
		}


		public function formatTreeWithProperties(vecObjects:Vector.<DisplayObjectVO>, vecProperties:Vector.<String> = null):String
		{
			var strJSON:String;
			var objJSON:Object = {elements: []};

			recursiveGetChildrenToJSON(vecObjects, objJSON.elements, vecProperties);

			strJSON = JSON.stringify(objJSON);

			return strJSON;
		}


		public function formatVO(objVO:DisplayObjectVO):String
		{
			return DisplayObjectUtils.toJSON(objVO.displayObject).toString();
		}


		private function addProperties(objParent:Object, objDO:DisplayObject, vecProperties:Vector.<String>):void
		{
			var blnAllProperties:Boolean = vecProperties[0].toLowerCase() === "all";
			var vecClassProperties: Vector.<String> = DisplayObjectUtils.getClassProperties(objDO);

			for each(var strCurrentProp: String in vecClassProperties)
			{
				if (!DisplayObjectUtils.isNativeType(strCurrentProp, objDO)) continue;

				if(blnAllProperties || vecProperties.indexOf(strCurrentProp) !== -1)
				{
					if(strCurrentProp !== 'x' && strCurrentProp !== 'y')
					{
						objParent[strCurrentProp] = objDO[strCurrentProp];
					}
					else
					{
						var ptGlobal:Point = objDO.localToGlobal(new Point(objDO.x, objDO.y));
						objParent[strCurrentProp] = ptGlobal[strCurrentProp];
					}
				}
			}
		}


		private function recursiveGetChildrenToJSON(vecAllObjects:Vector.<DisplayObjectVO>,
													arrParent:Array,
													vecProperties:Vector.<String> = null):void
		{
			var index:int = 0;
			for each (var objDOVO:DisplayObjectVO in vecAllObjects)
			{
				var objCurrent:Object = {};
				var objDO:DisplayObject = objDOVO.displayObject;

				objCurrent = {
								'type': getQualifiedClassName(objDO),
								'name': objDO.name
							 };

				if(vecProperties)
				{
					this.addProperties(objCurrent, objDO, vecProperties);
				}

				if(objDOVO.hasChildren)
				{
					objCurrent.children = [];
					this.recursiveGetChildrenToJSON(objDOVO.children as Vector.<DisplayObjectVO>,
													objCurrent.children,
													vecProperties);
				}

				arrParent[index] = objCurrent;

				++index;
			}
		}
	}
}
