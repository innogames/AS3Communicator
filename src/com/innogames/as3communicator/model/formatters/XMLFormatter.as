package com.innogames.as3communicator.model.formatters
{
	import avmplus.getQualifiedClassName;

	import com.innogames.as3communicator.model.DisplayObjectUtils;
	import com.innogames.as3communicator.model.DisplayObjectVO;

	import flash.display.DisplayObject;

	/**
	 * This formatter converts DisplayObjectVOs into valid XML.
	 */
	public class XMLFormatter extends AbstractFormatter implements IResultFormatter
	{
		public function formatTree(vecObjects:Vector.<DisplayObjectVO>):String
		{
			var xmlTree:XML = <elements />;

			recursiveGetChildrenToXML(vecObjects, xmlTree);

			return xmlTree.toXMLString();
		}


		public function formatTreeWithProperties(vecObjects:Vector.<DisplayObjectVO>, vecProperties:Vector.<String> = null):String
		{
			var xmlTree:XML = <elements />;

			recursiveGetChildrenToXML(vecObjects, xmlTree, vecProperties);

			return xmlTree.toXMLString();
		}


		public function formatVO(objVO:DisplayObjectVO):String
		{
			return DisplayObjectUtils.toXML(objVO.displayObject);
		}


		final override protected function addPropertyToChild(child:Object, propertyName:String, value:*):void
		{
			if(!(child is XML)) throw new ArgumentError('Given child has to be XML. '+ typeof child +'given.');

			child.@[propertyName] = value;
		}


		private function recursiveGetChildrenToXML(vecAllObjects:Vector.<DisplayObjectVO>,
												   objParentNode:XML, vecProperties:Vector.<String> = null):void
		{
			for(var objDOVO:DisplayObjectVO, intLen:int = vecAllObjects.length, i:int = 0; i < intLen; ++i)
			{
				objDOVO = vecAllObjects[i] as DisplayObjectVO;
				var objDO:DisplayObject = objDOVO.displayObject;
				var child:XML = <element objectName={objDO.name}
										 objectType={getQualifiedClassName(objDO)}/>;

				if(vecProperties)
				{
					super.addProperties(child, objDO, vecProperties);
				}

				if(objDOVO.hasChildren)
				{
					this.recursiveGetChildrenToXML(objDOVO.children, child, vecProperties);
				}

				objParentNode.appendChild(child);
			}
		}
	}
}
