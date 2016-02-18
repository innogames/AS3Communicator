package com.innogames.as3communicator.model.formatters
{
	import avmplus.getQualifiedClassName;

	import com.innogames.as3communicator.model.DisplayObjectVO;

	import flash.display.DisplayObject;

	/**
	 * This formatter converts DisplayObjectVOs into valid JSON.
	 */
	public class JSONFormatter extends AbstractFormatter implements IResultFormatter
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


		public function formatVO(objVO:DisplayObjectVO, vecProperties:Vector.<String>):String
		{
			if(vecProperties && vecProperties.length)
			{
				return this.formatTreeWithProperties(new<DisplayObjectVO>[objVO], vecProperties);
			}

			return this.formatTree(new<DisplayObjectVO>[objVO]);
		}


		final override protected function addPropertyToChild(child:Object, propertyName:String, value:*):void
		{
			child[propertyName] = value;
		}


		private function recursiveGetChildrenToJSON(vecAllObjects:Vector.<DisplayObjectVO>,
													arrParent:Array,
													vecProperties:Vector.<String> = null):void
		{
			var index:int = 0;
			for(var objDOVO:DisplayObjectVO, intLen:int = vecAllObjects.length, i:int = 0; i < intLen; ++i)
			{
				objDOVO = vecAllObjects[i] as DisplayObjectVO;
				var objCurrent:Object = {};
				var objDO:DisplayObject = objDOVO.displayObject;

				objCurrent = {
								'objectType': getQualifiedClassName(objDO),
								'objectName': objDO.name
							 };

				if(vecProperties)
				{
					super.addProperties(objCurrent, objDO, vecProperties);
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
