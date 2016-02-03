package com.innogames.as3communicator.model.formatters
{

	import com.innogames.as3communicator.errors.AbstractError;
	import com.innogames.as3communicator.model.DisplayObjectUtils;

	import flash.display.DisplayObject;

	import flash.geom.Point;

	/**
	 * The AbstractFormatter provides basic functionality for both formatters, JSON and XML
	 */
	public class AbstractFormatter
	{
		protected function addProperties(child:Object, objDO:DisplayObject, vecProperties:Vector.<String>):void
		{
			var blnAllProperties:Boolean = vecProperties[0].toLowerCase() === "all";
			var vecPropertiesToAdd:Vector.<String>;
			var strPropertyNameForChild:String;
			var currentValue:*;

			vecPropertiesToAdd = DisplayObjectUtils.getClassProperties(objDO);
			if(blnAllProperties)
			{
				vecProperties = vecPropertiesToAdd;
			}
			vecPropertiesToAdd = this.unifyVectors(vecProperties, vecPropertiesToAdd);

			for(var strCurrentProp:String, intLen:int = vecPropertiesToAdd.length - 1; intLen >= 0; --intLen)
			{
				strCurrentProp = vecPropertiesToAdd[intLen] as String;
				if(!DisplayObjectUtils.isNativeType(strCurrentProp, objDO)) continue;

				strPropertyNameForChild = strCurrentProp;

				while(child.hasOwnProperty(strPropertyNameForChild))
				{
					strPropertyNameForChild += '_';
				}

				if(strCurrentProp !== 'x' && strCurrentProp !== 'y')
				{
					currentValue = objDO[strCurrentProp];
				}
				else
				{
					var ptGlobal:Point = objDO.localToGlobal(new Point(objDO.x, objDO.y));
					currentValue = ptGlobal[strCurrentProp];
				}

				this.addPropertyToChild(child, strPropertyNameForChild, currentValue);
			}
		}


		protected function addPropertyToChild(child:Object, propertyName:String, value:*):void
		{
			throw new AbstractError(AbstractError.METHOD_MUST_BE_OVERRIDDEN);
		}


		private function unifyVectors(vecFirst:Vector.<String>, vecSecond:Vector.<String>):Vector.<String>
		{
			var vecResult	:Vector.<String> = new<String>[];
			var strCurrent	:String;
			var intLen		:int = vecFirst.length;
			var i			:int;

			while(--intLen)
			{
				strCurrent = vecFirst[intLen];
				if(vecSecond.indexOf(strCurrent) === -1) continue;

				vecResult[i++] = strCurrent;
			}

			return vecResult;
		}
	}
}
