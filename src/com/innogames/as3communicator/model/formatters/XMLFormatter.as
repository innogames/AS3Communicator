package com.innogames.as3communicator.model.formatters
{
	import avmplus.getQualifiedClassName;

	import com.innogames.as3communicator.model.DisplayObjectUtils;
	import com.innogames.as3communicator.model.DisplayObjectVO;

	/**
	 * This formatter converts DisplayObjectVOs into valid XML.
	 */
	public class XMLFormatter implements IResultFormatter
	{

		public function XMLFormatter()
		{
		}


		public function formatTree(vecObjects:Vector.<DisplayObjectVO>):String
		{
			var xmlTree:XML = <elements />;

			recursiveGetChildrenToXML(vecObjects, xmlTree);

			return xmlTree.toXMLString();
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
			return DisplayObjectUtils.toXML(objVO.displayObject);
		}


		private function recursiveGetChildrenToXML(vecAllObjects:Vector.<DisplayObjectVO>,
												   objParentNode:XML):void
		{
			for each (var objDO:DisplayObjectVO in vecAllObjects)
			{
				var child:XML = <element name={objDO.displayObject.name}
										 type={getQualifiedClassName(objDO.displayObject)}/>;

				if(objDO.hasChildren)
				{
					var children:XML = <children></children>;
					this.recursiveGetChildrenToXML(objDO.children, children);
					child.appendChild(children);
				}

				objParentNode.appendChild(child);
			}
		}
	}
}
