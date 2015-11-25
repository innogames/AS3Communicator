package com.innogames.as3communicator.controllers
{

	import avmplus.getQualifiedClassName;

	import com.innogames.as3communicator.controllers.commands.ClickAtPositionCommand;
	import com.innogames.as3communicator.controllers.commands.ClickObjectCommand;
	import com.innogames.as3communicator.controllers.commands.CountObjectsOnStageCommand;
	import com.innogames.as3communicator.controllers.commands.FindObjectVOByNameCommand;
	import com.innogames.as3communicator.controllers.commands.GetObjectPropertyCommand;
	import com.innogames.as3communicator.controllers.commands.SetObjectPropertyCommand;
	import com.innogames.as3communicator.controllers.commands.ToggleHighlightCommand;
	import com.innogames.as3communicator.model.DisplayObjectVO;
	import com.innogames.as3communicator.model.formatters.IResultFormatter;
	import com.innogames.as3communicator.model.formatters.JSONFormatter;
	import com.innogames.as3communicator.model.formatters.XMLFormatter;
	import com.innogames.as3communicator.utils.DebugLogger;
	import com.innogames.as3communicator.utils.DisplayObjectVOIteratorUtil;
	import com.innogames.as3communicator.utils.DisplayObjectVOPool;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;

	/**
	 * APIController that provides all methods that can be used by the Connectors, e.g. to find objects, object's
	 * properties, highlight objects, etc.
	 */
	public class APIController
	{
		use namespace testable;

		public static const JSON_FORMATTER:String = 'json';
		public static const XML_FORMATTER:String = 'xml';

		private static var objInstance:APIController;

		public static function get instance():APIController
		{
			var objInstance:APIController = APIController.objInstance;
			if(objInstance === null)
			{
				objInstance = APIController.objInstance = new APIController(new SingletonEnforcer());
			}

			return objInstance;
		}

		public function APIController(objEnforcer:SingletonEnforcer)
		{
			if(!(objEnforcer is SingletonEnforcer))
			{
				throw new ArgumentError('APIController must be invoked with SingletonEnforcer object. Use'
						+ ' APIController.instance!');
			}

			APIController.objInstance = this;
			this.objResultFormatter = new JSONFormatter();
		}
		private var blnHighlightUnderCursor:Boolean,
				blnTraceCursorPosition:Boolean,
				objPreviousHighlightedObject:DisplayObject,
				objResultFormatter:IResultFormatter,
				objParentContainer:DisplayObjectContainer;

		public function get parentContainer():DisplayObjectContainer
		{
			return this.objParentContainer;
		}

		public function set parentContainer(objParentContainer:DisplayObjectContainer):void
		{
			this.objParentContainer = objParentContainer;
		}

		public function setFormatter(strFormatter:String):String
		{
			switch(strFormatter.toLowerCase())
			{
				case APIController.JSON_FORMATTER:
				{
					this.objResultFormatter = new JSONFormatter();
				}
					break;

				case APIController.XML_FORMATTER:
				{
					this.objResultFormatter = new XMLFormatter();
				}
					break;

				default:
				{
					return 'unsupported formatter "' + strFormatter + '"';
				}
			}

			return 'Formatter set to ' + strFormatter;
		}

		public function countObjectsOnStage():int
		{
			var result:int = new CountObjectsOnStageCommand().execute(this.findAllObjectsOnStage()) as int;

			DisplayObjectVOPool.instance.freeAllElements();

			return result;
		}

		public function getAllObjectsOnStage():String
		{
			var vecAllObjects:Vector.<DisplayObjectVO>;

			vecAllObjects = this.findAllObjectsOnStage();

			var result:String = this.objResultFormatter.formatTreeWithProperties(vecAllObjects);

			DisplayObjectVOPool.instance.freeAllElements();

			return result;
		}

		public function getObjectTree(...args:Array):String
		{
			var vecAllObjects:Vector.<DisplayObjectVO>;

			vecAllObjects = this.findAllObjectsOnStage();

			var result:String;

			if(args.length)
			{
				var vecProperties:Vector.<String>;
				if(args[0] is Array)
				{
					vecProperties = Vector.<String>(args[0]);
				}
				else if(args[0] is String)
				{
					vecProperties = new<String>[args[0] as String];
				}

				result = this.objResultFormatter.formatTreeWithProperties(vecAllObjects, vecProperties);
			}
			else
			{
				result = this.objResultFormatter.formatTree(vecAllObjects);
			}

			DisplayObjectVOPool.instance.freeAllElements();

			return result;
		}

		public function findAllObjectsOnStage():Vector.<DisplayObjectVO>
		{
			var vecDisplayObjects:Vector.<DisplayObjectVO> = DisplayObjectVOIteratorUtil.getChildren(
					this.objParentContainer as DisplayObject);

			return vecDisplayObjects;
		}

		public function clickObject(strName:String):String
		{
			var objectToClick:DisplayObject = this.findObjectByName(strName,
					DisplayObjectVOIteratorUtil.getChildren(this.objParentContainer));

			if(!objectToClick) return 'Object "' + strName + '" not found.';

			var result:String = new ClickObjectCommand().execute(objectToClick) as String;

			DisplayObjectVOPool.instance.freeAllElements();

			return result;
		}

		public function clickAtPosition(x:int,
										y:int):String
		{
			var result:String = new ClickAtPositionCommand().execute(x, y, this.objParentContainer) as String;

			DisplayObjectVOPool.instance.freeAllElements();

			return result;
		}

		public function getObjectProperty(objectName:String,
										  propertyName:String):String
		{
			var targetObject:DisplayObject = this.findObjectByName(objectName, DisplayObjectVOIteratorUtil.getChildren(this.objParentContainer));

			if(!targetObject)
			{
				return 'Couldn\'t find object with name \'' + objectName;
			}

			var result:String = new GetObjectPropertyCommand().execute(targetObject, propertyName).toString();

			DisplayObjectVOPool.instance.freeAllElements();

			return result;
		}

		public function setObjectProperty(objectName:String,
										  propertyName:String,
										  value:String):String
		{
			var targetObject:DisplayObject = this.findObjectByName(objectName, DisplayObjectVOIteratorUtil.getChildren(this.objParentContainer));

			if(!targetObject)
			{
				return 'Couldn\'t find object with name \'' + objectName + '\'';
			}

			var result:String = new SetObjectPropertyCommand().execute(targetObject, propertyName, value) as String;

			DisplayObjectVOPool.instance.freeAllElements();

			return result;
		}

		public function toggleHighlight(objectName:String):String
		{
			var objDO:DisplayObject = this.findObjectByName(objectName,
					DisplayObjectVOIteratorUtil.getChildren(this.objParentContainer));

			if(!objDO) return 'Couldn\'t find object with name "' + objectName + '"';

			var result:String = new ToggleHighlightCommand().execute(objDO) as String;

			DisplayObjectVOPool.instance.freeAllElements();

			return result;
		}

		public function findObject(strName:String):String
		{
			var objDisplayObject:DisplayObjectVO = new FindObjectVOByNameCommand().execute(strName,
							this.findAllObjectsOnStage()) as DisplayObjectVO;

			var result:String = this.objResultFormatter.formatVO(objDisplayObject);

			DisplayObjectVOPool.instance.freeAllElements();

			return result;
		}

		public function toggleCursorPosition():String
		{
			if(this.blnTraceCursorPosition)
			{
				if(this.objParentContainer.hasEventListener(MouseEvent.MOUSE_MOVE))
				{
					this.objParentContainer.removeEventListener(MouseEvent.MOUSE_MOVE, this.mouseMoveHandler);
				}

				this.blnTraceCursorPosition = false;
				return "Tracing cursor position switched off."
			}

			this.objParentContainer.addEventListener(MouseEvent.MOUSE_MOVE, this.mouseMoveHandler);
			this.blnTraceCursorPosition = true;

			return "Tracing cursor position switched on."
		}

		public function getObjectAtPosition(x:int, y:int):String
		{
			var ptDest:Point = new Point(x, y);
			var arrObjects:Array = this.objParentContainer.getObjectsUnderPoint(ptDest);

			if(!arrObjects || !arrObjects.length) return "No object found at position " + x + ", " + y;

			var result:String = '';
			for each(var obj:DisplayObject in arrObjects)
			{
				result += obj.name + '\n';
			}

			return result;
		}


		public function toggleHighlightUnderCursor():String
		{
			if(this.blnHighlightUnderCursor)
			{
				if(this.objParentContainer.hasEventListener(MouseEvent.MOUSE_MOVE))
				{
					this.objParentContainer.removeEventListener(MouseEvent.MOUSE_MOVE, this.highlightMoveHandler);
				}

				this.blnHighlightUnderCursor = false;
				return "Highlighting under cursor switched off.";
			}

			this.objParentContainer.addEventListener(MouseEvent.MOUSE_MOVE, this.highlightMoveHandler);
			this.blnHighlightUnderCursor = true;
			return "Highlighting under cursor switched on.";
		}

		private function mouseMoveHandler(event:MouseEvent):void
		{
			var result:String = 'x:' + this.objParentContainer.mouseX + '\ny:' + this.objParentContainer.mouseY;
			try
			{
				DebugLogger.instance.log(result);
			}
			catch(err:Error)
			{
				trace(result);
			}
		}

		private function highlightMoveHandler(evt:MouseEvent):void
		{
			var objCurrent:DisplayObject;
			var arrObjects:Array = this.objParentContainer.getObjectsUnderPoint(new Point(evt.stageX, evt.stageY));

			for each(var obj:DisplayObject in arrObjects)
			{
				if(obj.parent && obj.parent is InteractiveObject)
				{
					obj = obj.parent;
				}

				DebugLogger.instance.log(this.getFQI(obj));

				if(obj is InteractiveObject && obj.hasEventListener(MouseEvent.CLICK)
						|| obj.hasEventListener(MouseEvent.MOUSE_DOWN))
				{
					objCurrent = obj;
					break;
				}
			}

			DebugLogger.instance.log('----');

			if(!objCurrent || this.objPreviousHighlightedObject === objCurrent) return;

			if(this.objPreviousHighlightedObject && this.objPreviousHighlightedObject.filters
					&& this.objPreviousHighlightedObject.filters.length)
			{
				this.objPreviousHighlightedObject.filters = [];
			}

			if(arrObjects && arrObjects.length)
			{
				this.objPreviousHighlightedObject = objCurrent as DisplayObject;
				this.objPreviousHighlightedObject.filters = [new GlowFilter(0xFF00FF, .65)];

				DebugLogger.instance.log(this.objPreviousHighlightedObject.name);
			}
		}

		testable function findObjectByName(strName:String,
										   vecObjectList:Vector.<DisplayObjectVO>):DisplayObject
		{
			var result:DisplayObjectVO = new FindObjectVOByNameCommand().execute(strName, vecObjectList) as DisplayObjectVO;

			var displayObject:DisplayObject = (result) ? result.displayObject as DisplayObject : null;

			DisplayObjectVOPool.instance.freeAllElements();

			return displayObject;
		}

		testable function getFQI(objDO:DisplayObject):String
		{
			var strFQI:String = objDO.name + '(' + getQualifiedClassName(objDO) + ')';

			while(objDO.parent)
			{
				objDO = objDO.parent;
				strFQI = objDO.name + '(' + getQualifiedClassName(objDO) + ')' + '.' + strFQI;
				if(strFQI['startsWith']('null.'))
				{
					strFQI = strFQI['substringAfter']('null.');
				}
			}

			return strFQI;
		}


		public function get formatter():IResultFormatter
		{
			return this.objResultFormatter;
		}
	}
}

internal class SingletonEnforcer
{
}