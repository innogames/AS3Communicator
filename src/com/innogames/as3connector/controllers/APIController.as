package com.innogames.as3connector.controllers
{

	import avmplus.getQualifiedClassName;

	import com.innogames.as3connector.model.DisplayObjectUtils;
	import com.innogames.as3connector.model.DisplayObjectVO;
	import com.innogames.as3connector.utils.DebugLogger;

	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.utils.getTimer;

	/**
	 * APIController that provides all methods that can be used by the Connectors, e.g. to find objects, object's
	 * properties, highlight objects, etc.
	 */
	public class APIController
	{
		use namespace testable;

		private static const BRACKET_CLOSE:String = ']';
		private static const BRACKET_OPEN:String  = '[';
		private static const DOT:String           = '.';

		private static var objInstance:APIController;

		private var blnHighlightUnderCursor:Boolean,
					blnTraceCursorPosition:Boolean,
					objPreviousHighlightedObject:DisplayObject,
					objStage:Stage;


		public function APIController(objEnforcer:SingletonEnforcer)
		{
			if(!(
							objEnforcer
					) is SingletonEnforcer)
			{
				throw new ArgumentError('APIController must be invoked with SingletonEnforcer object. Use'
										+ ' APIController.instance!');
			}

			APIController.objInstance = this;
		}


		public static function get instance():APIController
		{
			var objInstance:APIController = APIController.objInstance;
			if(objInstance === null)
			{
				objInstance = APIController.objInstance = new APIController(new SingletonEnforcer());
			}

			return objInstance;
		}


		public function countObjectsOnStage():int
		{
			var vecObjects:Vector.<DisplayObjectVO> = this.findAllObjectsOnStage();
			var intTotalNumberOfObjects:int         = 0;

			for(var i:int = 0, len:int = vecObjects.length; i < len; ++i)
			{
				intTotalNumberOfObjects += this.countObjectsRecursive(vecObjects[i]);
			}

			intTotalNumberOfObjects += len;

			return intTotalNumberOfObjects;
		}


		private function countObjectsRecursive(objParent:DisplayObjectVO):int
		{
			var intChildCount:int = 0;
			if(objParent.hasChildren)
			{
				for(var i:int = 0, len:int = objParent.children.length; i < len; ++i)
				{
					intChildCount += this.countObjectsRecursive(objParent.children[i]);
				}

				intChildCount += len;
			}

			return intChildCount;
		}


		public function getAllObjectsOnStage(blnCreateJSONData:Boolean = false):String
		{
			var vecAllObjects:Vector.<DisplayObjectVO>;

			vecAllObjects = this.findAllObjectsOnStage(blnCreateJSONData);

			var strJSON:String;
			var objJSON:Object = {elements:[]};
			for each (var objDO:DisplayObjectVO in vecAllObjects)
			{
				objJSON.elements[objJSON.elements.length] = {
					'type'      :getQualifiedClassName(objDO.displayObject),
					'properties':objDO.objectData
				};
			}

			strJSON = JSON.stringify(objJSON);

			return strJSON;
		}


		public function getObjectTree():String
		{
			var vecAllObjects:Vector.<DisplayObjectVO>;

			vecAllObjects = this.findAllObjectsOnStage(true);

			var strJSON:String;
			var objJSON:Object = {elements:[]};

			recursiveGetChildrenToJSON(vecAllObjects, objJSON.elements);

			strJSON = JSON.stringify(objJSON);

			return strJSON;
		}


		private function recursiveGetChildrenToJSON(
				vecAllObjects:Vector.<DisplayObjectVO>,
				arrParent:Array
		):void
		{
			var index:int = 0;
			for each (var objDO:DisplayObjectVO in vecAllObjects)
			{
				arrParent[index] = {
					'type':getQualifiedClassName(objDO.displayObject),
					'name':objDO.displayObject.name
				};

				if(objDO.hasChildren)
				{
					arrParent[index].children = [];
					this.recursiveGetChildrenToJSON(objDO.children
													as Vector.<DisplayObjectVO>, arrParent[index].children);
				}

				++index;
			}
		}


		public function findAllObjectsOnStage(blnCreateJSONData:Boolean = false):Vector.<DisplayObjectVO>
		{
			var vecDisplayObjects:Vector.<DisplayObjectVO> = this.getChildren(this.objStage, blnCreateJSONData);

			return vecDisplayObjects;
		}


		public function getChildren(
				objParent:DisplayObject,
				blnCreateJSONData:Boolean = false
		):Vector.<DisplayObjectVO>
		{
			var i:int,
				len:int,
				objCurrentDisplayChild:DisplayObject,
				objCurrentChildVO:DisplayObjectVO,
				objParentContainer:DisplayObjectContainer,
				vecChildren:Vector.<DisplayObjectVO>;

			if(!(objParent is DisplayObjectContainer)) return null;

			objParentContainer = objParent as DisplayObjectContainer;

			if(objParentContainer.numChildren === 0) return null;

			len         = objParentContainer.numChildren;
			vecChildren = new Vector.<DisplayObjectVO>(len, true);
			do
			{
				objCurrentDisplayChild = objParentContainer.getChildAt(i);
				objCurrentChildVO      = new DisplayObjectVO(objCurrentDisplayChild, this.getChildren(objCurrentDisplayChild, blnCreateJSONData));
				if(blnCreateJSONData)
				{
					objCurrentChildVO.jsonData   = DisplayObjectUtils.toJSON(objCurrentDisplayChild).toString();
					objCurrentChildVO.objectData = JSON.parse(objCurrentChildVO.jsonData);
				}
				vecChildren[i] = objCurrentChildVO;
			}
			while(++i !== len);

			return vecChildren;
		}


		public function clickObject(strName:String):String
		{
			var objectToClick:DisplayObject = this.findObjectByName(strName, this.getChildren(this.objStage));

			if(!objectToClick) return 'Object "' + strName + '" not found.';

			if(!(
							objectToClick is InteractiveObject
					))
			{
				if(objectToClick.parent && objectToClick.parent is InteractiveObject)
				{
					objectToClick = objectToClick.parent;
				}
			}

			if((
							objectToClick is InteractiveObject
					))
			{
				this.emulateClickOnObject(objectToClick as InteractiveObject);
				return 'Object \'' + strName + '\' clicked';
			}

			return 'Object \'' + strName + '\' is not an interactive object and cannot be clicked!';
		}


		private function emulateClickOnObject(objectToClick:InteractiveObject):void
		{
			objectToClick.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
			objectToClick.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			objectToClick.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
		}


		public function clickAtPosition(
				x:int,
				y:int
		):String
		{
			var ptDest:Point     = new Point(x, y);
			var ptLocal:Point    = this.objStage.globalToLocal(ptDest);
			var arrObjects:Array = this.objStage.getObjectsUnderPoint(ptDest);
			var objCurrentObject:DisplayObject;

			var evt:MouseEvent;
			evt = new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, ptLocal.x, ptLocal.y);
			this.objStage.dispatchEvent(evt);
			evt = new MouseEvent(MouseEvent.CLICK, true, false, ptLocal.x, ptLocal.y);
			this.objStage.dispatchEvent(evt);
			evt = new MouseEvent(MouseEvent.MOUSE_UP, true, false, ptLocal.x, ptLocal.y);
			this.objStage.dispatchEvent(evt);

			if(arrObjects.length)
			{
				for(var len:int = arrObjects.length, i:int = len; --i < len;)
				{
					objCurrentObject = arrObjects[i];
					if(!(
									objCurrentObject is InteractiveObject
							))
					{
						if(objCurrentObject.parent && objCurrentObject.parent is InteractiveObject)
						{
							objCurrentObject = objCurrentObject.parent;
						}
					}
					if(objCurrentObject is InteractiveObject)
					{
						ptLocal = (
								objCurrentObject as InteractiveObject
						).globalToLocal(ptDest);
						evt     = new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, ptLocal.x, ptLocal.y);
						(
								objCurrentObject as InteractiveObject
						).dispatchEvent(evt);
						evt     = new MouseEvent(MouseEvent.CLICK, true, false, ptLocal.x, ptLocal.y);
						(
								objCurrentObject as InteractiveObject
						).dispatchEvent(evt);
						evt     = new MouseEvent(MouseEvent.MOUSE_UP, true, false, ptLocal.x, ptLocal.y);
						(
								objCurrentObject as InteractiveObject
						).dispatchEvent(evt);
						return "Clicking object " + objCurrentObject.name;
					}
				}
			}

			return "No clickable object found.";
		}


		testable function findObjectByName(
				strName:String,
				vecObjectList:Vector.<DisplayObjectVO>
		):DisplayObject
		{
			var result:DisplayObjectVO = this.findObjectVOByName(strName, vecObjectList);

			if(result) return result.displayObject;

			return null;
		}


		testable function findObjectVOByName(
				strName:String,
				vecObjectList:Vector.<DisplayObjectVO>
		):DisplayObjectVO
		{
			var blnFound:Boolean,
				blnLookingForFQI:Boolean,
				childObject:DisplayObjectVO,
				currentDO:DisplayObjectVO,
				currentNamePart:String,
				restNamePart:String;

			//implement array syntax "myObject[0]"

			/**
			 * First look at dot-notation "parent.child.subchild"
			 */
			if(strName['containsBefore'](DOT, BRACKET_OPEN))
			{
				currentNamePart  = strName['substringBefore'](DOT);
				restNamePart     = strName['substringAfter'](DOT);
				blnLookingForFQI = true;
			}

			/**
			 * Then look at array-access "parent[0].subchild"
			 */
			else if(strName['contains'](BRACKET_OPEN, BRACKET_CLOSE))
			{
				if(!strName['startsWith'](BRACKET_OPEN))
				{
					currentNamePart  = strName['substringBefore'](BRACKET_OPEN);
					restNamePart     = strName['substringAfter'](currentNamePart);
					blnLookingForFQI = true;
				}
				else
				{
					var childIndex:int = parseInt(strName['substringBetween'](BRACKET_OPEN, BRACKET_CLOSE));
					restNamePart       = strName['substringAfter'](BRACKET_CLOSE);

					/**
					 * Starting from parent[0].subchild
					 * we'd now have the remaining .subchild, so we need to cut off the dot, to have accurate naming
					 */
					if(restNamePart['startsWith'](DOT))
					{
						restNamePart = restNamePart['substringAfter'](DOT)
					}

					if(vecObjectList && vecObjectList.length > childIndex)
					{
						childObject   = vecObjectList[childIndex];
						vecObjectList = childObject.children;
					}
					else
					{
						return null;
					}
				}

				if(!childObject)
				{
					childObject = this.findObjectVOByName(currentNamePart, vecObjectList);
					if(childObject)
					{
						vecObjectList = childObject.children;
					}
				}

				if(restNamePart)
				{
					return this.findObjectVOByName(restNamePart, vecObjectList);
				}

				return childObject;
			}

			/**
			 * Then fall back to regular name "uniqueChild"
			 */
			else
			{
				currentNamePart = strName;
			}

			var i:int   = -1,
				len:int = vecObjectList.length;
			while(++i !== len)
			{
				currentDO = vecObjectList[i] as DisplayObjectVO;
				if(currentDO.displayObject.name === currentNamePart)
				{
					blnFound = true;

					// not looking for children, return the final object
					if(!restNamePart) return currentDO;

					/**
					 * we're looking for children, but the currentDO doesn't have any, so return null, since we can't
					 * find something where nothing is.
					 */
					if(!currentDO.hasChildren) return null;
				}

				var blnTraverse:Boolean = (
												  !blnLookingForFQI && !blnFound
										  ) || (
												  blnFound && blnLookingForFQI
										  );
				if(blnTraverse && currentDO.hasChildren)
				{
					if(!restNamePart)
					{
						restNamePart = currentNamePart;
					}

					childObject = this.findObjectVOByName(restNamePart, currentDO.children);

					restNamePart = null;

					if(blnLookingForFQI && !childObject) return null;

					if(childObject !== null) return childObject;
				}
			}

			return null;
		}


		public function getObjectProperty(
				objectName:String,
				propertyName:String
		):String
		{
			var start:int                  = getTimer();
			var targetObject:DisplayObject = this.findObjectByName(objectName, this.getChildren(this.objStage));
			var diff:int                   = getTimer() - start;

			if(!targetObject)
			{
				return 'Couldn\'t find object with name \'' + objectName + '\' in \'' + diff + '\'ms';
			}

			if(!targetObject.hasOwnProperty(propertyName))
			{
				return 'Couldn\'t find property \'' + propertyName + '\' on object \'' + objectName + '\' in \'' + diff
					   + '\'ms';
			}

			return propertyName + '=' + targetObject[propertyName];
		}


		public function toggleHighlight(objectName:String):String
		{
			var objDO:DisplayObject = this.findObjectByName(objectName, this.getChildren(this.objStage));

			if(!objDO) return 'Couldn\'t find object with name "' + objectName + '"';

			if(objDO.filters.length)
			{
				objDO.filters = [];

				return 'removed highlight from "' + objectName + '".';
			}

			objDO.filters = [
				new GlowFilter(0xFF00FF, .65)
			];

			return 'added highlight to "' + objectName + '".';
		}


		public function setObjectProperty(
				objectName:String,
				propertyName:String,
				value:String
		):String
		{
			var targetObject:DisplayObject = this.findObjectByName(objectName, this.getChildren(this.objStage));

			if(!targetObject)
			{
				return 'Couldn\'t find object with name \'' + objectName + '\'';
			}

			if(!targetObject.hasOwnProperty(propertyName))
			{
				return 'Couldn\'t find property \'' + propertyName + '\' on object \'' + objectName + '\'';
			}

			try
			{
				if(value['containsAny'](['0','1','2','3','4','5','6','7','8','9','.']))
				{
					targetObject[propertyName] = parseFloat(value);
				}
				else if(value['containsAny'](['true', 'false']))
				{
					targetObject[propertyName] = value.toLowerCase() === 'true';
				}
				else
				{
					targetObject[propertyName] = value;
				}

				return propertyName + '=' + targetObject[propertyName];
			}
			catch(e:Error)
			{
				return e.toString();
			}
		}


		public function findObject(strName:String):String
		{
			var objDisplayObject:DisplayObjectVO = this.findObjectVOByName(strName, this.findAllObjectsOnStage());

			objDisplayObject.jsonData   = DisplayObjectUtils.toJSON(objDisplayObject.displayObject).toString();

			return objDisplayObject.jsonData;
		}


		public function toggleCursorPosition():String
		{
			if(this.blnTraceCursorPosition)
			{
				if(this.objStage.hasEventListener(MouseEvent.MOUSE_MOVE))
				{
					this.objStage.removeEventListener(MouseEvent.MOUSE_MOVE, this.mouseMoveHandler);
				}

				this.blnTraceCursorPosition = false;
				return "Tracing cursor position switched off."
			}

			this.objStage.addEventListener(MouseEvent.MOUSE_MOVE, this.mouseMoveHandler);
			this.blnTraceCursorPosition = true;

			return "Tracing cursor position switched on."
		}


		private function mouseMoveHandler(event:MouseEvent):void
		{
			var result:String = 'x:' + this.objStage.mouseX + '\ny:' + this.objStage.mouseY;
			try
			{
				DebugLogger.instance.log(result);
			}
			catch(err:Error)
			{
				trace(result);
			}
		}


		public function getObjectAtPosition(
				x:int,
				y:int
		):String
		{
			var ptDest:Point     = new Point(x, y);
			var arrObjects:Array = this.objStage.getObjectsUnderPoint(ptDest);

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
				if(this.objStage.hasEventListener(MouseEvent.MOUSE_MOVE))
				{
					this.objStage.removeEventListener(MouseEvent.MOUSE_MOVE, this.highlightMoveHandler);
				}

				this.blnHighlightUnderCursor = false;
				return "Highlighting under cursor switched off.";
			}

			this.objStage.addEventListener(MouseEvent.MOUSE_MOVE, this.highlightMoveHandler);
			this.blnHighlightUnderCursor = true;
			return "Highlighting under cursor switched on.";
		}


		private function getFQI(objDO:DisplayObject):String
		{
			var strFQI:String = objDO.name;

			while(objDO.parent)
			{
				objDO  = objDO.parent;
				strFQI = objDO.name + '.' + strFQI;
				if(strFQI['startsWith']('null.'))
				{
					strFQI = strFQI['substringAfter']('null.');
				}
			}

			return strFQI;
		}


		private function highlightMoveHandler(evt:MouseEvent):void
		{
			var objCurrent:DisplayObject;
			var arrObjects:Array = this.objStage.getObjectsUnderPoint(new Point(evt.stageX, evt.stageY));

			for each(var obj:DisplayObject in arrObjects)
			{
				if(obj.parent && obj.parent is InteractiveObject)
				{
					obj = obj.parent;
				}

				DebugLogger.instance.log(this.getFQI(obj) + '' + obj);

				if(obj is InteractiveObject && obj.hasEventListener(MouseEvent.CLICK)
				   || obj.hasEventListener(MouseEvent.MOUSE_DOWN))
				{
					objCurrent = obj;
					break;
				}
			}

			DebugLogger.instance.log('----');

			if(!objCurrent) return;

			if(this.objPreviousHighlightedObject === objCurrent) return;

			if(this.objPreviousHighlightedObject && this.objPreviousHighlightedObject.filters
			   && this.objPreviousHighlightedObject.filters.length)
			{
				this.objPreviousHighlightedObject.filters = [];
			}

			if(arrObjects && arrObjects.length)
			{
				this.objPreviousHighlightedObject         = objCurrent as DisplayObject;
				this.objPreviousHighlightedObject.filters = [new GlowFilter(0xFF00FF, .65)];

				DebugLogger.instance.log(this.objPreviousHighlightedObject.name);
			}
		}


		public function get stage():Stage
		{
			return this.objStage;
		}


		public function set stage(objStage:Stage):void
		{
			this.objStage = objStage;
		}
	}
}

internal class SingletonEnforcer
{
}