package com.innogames.as3connector.utils{public class InitializationUtils{}}

String.prototype['startsWith'] =
		function (strCharacters:String):Boolean
		{
			return this.indexOf(strCharacters) === 0
		};

String.prototype['contains'] =
		function(...arrCharacters:Array):Boolean
		{
			for(var i:int, len:int = arrCharacters.length; i < len; ++i)
			{
				if(this.indexOf(arrCharacters[i] as String) === -1) return false;
			}

			return true;
		};

String.prototype['containsAny'] =
		function (...arrCharacters:Array):Boolean
		{
			for(var i:int, len:int = arrCharacters.length; i < len; ++i)
			{
				if(this.indexOf(arrCharacters[i] as String) === -1) return true;
			}

			return false;
		};

String.prototype['containsIgnoreCase'] =
	   function(strCharacters:String):Boolean
	   {
		 return this.toLowerCase().indexOf(strCharacters.toLowerCase()) !== -1;
	   };

String.prototype['containsBefore'] =
		function(strShouldBeBefore:String,  strShouldBeAfter:String):Boolean
		{
			var intLowIndex:int = this.indexOf(strShouldBeAfter);
			if(intLowIndex === -1)
			{
				return this['contains'](strShouldBeBefore);
			}

			var intHighIndex:int = this.indexOf(strShouldBeBefore);

			if(intHighIndex === -1) return false;

			return intHighIndex < intLowIndex;
		};

String.prototype['substringAfter'] =
		function (strStartCharacters:String): String
		{
			return this.substring(this.indexOf(strStartCharacters) + strStartCharacters.length);
		};

String.prototype['substringBefore'] =
		function (strEndCharacters: String):String
		{
			return this.substring(0, this.indexOf(strEndCharacters));
		};

String.prototype['substringBetween'] =
	   function(strStartCharacters:String, strEndCharacters:String):String
	   {
		   return this.substring(this.indexOf(strStartCharacters) + strStartCharacters.length, this.indexOf(strEndCharacters));
	   };