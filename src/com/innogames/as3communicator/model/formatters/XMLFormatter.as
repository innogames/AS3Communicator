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


		private function addProperties(child:XML, objDOVO:DisplayObjectVO, vecProperties:Vector.<String>):void
		{
			var blnAllProperties:Boolean = vecProperties[0].toLowerCase() === "all";
			var vecClassProperties:Vector.<String> = DisplayObjectUtils.getClassProperties(objDOVO.displayObject);

			for each(var strCurrentProp:String in vecClassProperties)
			{
				if(!DisplayObjectUtils.isNativeType(strCurrentProp, objDOVO.displayObject)) continue;

				if(blnAllProperties || vecProperties.indexOf(strCurrentProp) !== -1)
				{
					child.@[strCurrentProp] = objDOVO.displayObject[strCurrentProp];
				}
			}
		}


		private function recursiveGetChildrenToXML(vecAllObjects:Vector.<DisplayObjectVO>,
												   objParentNode:XML, vecProperties:Vector.<String> = null):void
		{
			for each (var objDOVO:DisplayObjectVO in vecAllObjects)
			{
				var child:XML = <element name={objDOVO.displayObject.name}
										 type={getQualifiedClassName(objDOVO.displayObject)}/>;

				if(vecProperties)
				{
					this.addProperties(child, objDOVO, vecProperties);
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
