package com.innogames.as3communicator.model.formatters
{
	import com.innogames.as3communicator.model.*;

	/**
	 * This is the common interface for the formatters, which are responsible for converting the DisplayObjectVOs
	 * into the appropriate format, like JSON or XML.
	 */
	public interface IResultFormatter
	{
		function formatTree(vecObjects:Vector.<DisplayObjectVO>):String;

		function formatTreeWithProperties(vecObjects:Vector.<DisplayObjectVO>, vecProperties:Vector.<String> = null):String;

		function formatVO(objVO:DisplayObjectVO, vecProperties:Vector.<String>):String;
	}
}
