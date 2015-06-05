package com.innogames.as3connector.model {
	import avmplus.DescribeTypeJSON;
	import avmplus.DescribeTypeJSON;
	import avmplus.INCLUDE_ACCESSORS;
	import avmplus.INCLUDE_VARIABLES;
	import avmplus.describeType;
	import avmplus.describeTypeJSON;
	import avmplus.getQualifiedClassName;
	import avmplus.getQualifiedSuperclassName;

	import com.innogames.as3connector.model.DisplayObjectUtils;

	import com.innogames.as3connector.model.DisplayObjectUtils;

	import flash.display.DisplayObject;
	import flash.net.getClassByAlias;
	import flash.utils.getDefinitionByName;

	public class DisplayObjectUtils {
		public function DisplayObjectUtils() {
		}

		public static function toObject(displayObject:DisplayObject):Object
		{
			var objResult:Object = {};

			for each(var strKey:Object in displayObject)
			{
				objResult[strKey] = displayObject[strKey];
			}

			return objResult;
		}


		public static function toJSON(displayObject:DisplayObject):String
		{
			var uintFlags			:uint	= avmplus.INCLUDE_ACCESSORS | avmplus.INCLUDE_VARIABLES;
			var strClassType		:String	= getQualifiedClassName(displayObject);
			var strPropName			:String;
			var objClass			:Class	= getDefinitionByName(strClassType) as Class;
			var objClassDescription	:Object	= new DescribeTypeJSON().getInstanceDescription(objClass);
			var vecClassProperties	:Vector.<String> = new <String>[];

			//get accessors
			for each(var objCurrentProp:Object in objClassDescription.traits.accessors)
			{
				strPropName = objCurrentProp.name;

				if (DisplayObjectUtils.isWriteOnly(strPropName, objClassDescription)) continue;

				vecClassProperties[vecClassProperties.length] = strPropName;
			}

			vecClassProperties.sort(DisplayObjectUtils.sortVector);

			var objResultJSON:Object = {};
			for each(var strCurrentProp:String in vecClassProperties)
			{
				if(!DisplayObjectUtils.isNativeType(strCurrentProp, displayObject)) continue;

				objResultJSON[strCurrentProp] = displayObject[strCurrentProp];
			}

			var strResultString:String = JSON.stringify(objResultJSON);

			return strResultString;
		}

		private static function isWriteOnly(
											strPropName			:String,
											objClassDescription	:Object
										   ): Boolean
		{
			var arrAccessors	:Array	= objClassDescription.traits.accessors;

			for each(var objAccessor:Object in arrAccessors)
			{
				if (objAccessor.name !== strPropName) continue;

				if(objAccessor.access === 'writeonly') return true;

				break;
			}

				return false;
		}


		private static function sortVector(
									a: String,
									b: String
								   ): int {
			var intALength		:int	= a.length	,
				intBLength		:int	= b.length	,
				intIndex		:int				,
				intReturnValue	:int	 = -1		,
				strCharA		:String				,
				strCharB		:String				;

			while (true)
			{
				if (intALength > intIndex && intBLength > intIndex)
				{
					strCharA = a.charAt(intIndex);
					strCharB = b.charAt(intIndex);

					if (strCharA > strCharB)
					{
						intReturnValue = 1;
						break;
					}
					else if (strCharA === strCharB)
					{
						++intIndex;
						continue;
					}
					intReturnValue = -1;
					break;
				}
				else
				{
					intReturnValue = 1;
					break;
				}
			}

			return intReturnValue;
		}

		private static function isNativeType(
												strCurrentProp	:String,
												displayObject	:DisplayObject
											):Boolean
		{
			var vecNativeTypes:Vector.<String> = new<String>[
															 'String'	,
															 'Object'	,
															 'Number'	,
//															 'Array'	,
															 'Vector'	,
															 'int'		,
															 'uint'		,
															 'Boolean'
															];

			var strQualifiedClassName: String = getQualifiedClassName(displayObject[strCurrentProp]);

			return (vecNativeTypes.indexOf(strQualifiedClassName) !== -1);
		}
	}

}
