package {

	import com.innogames.as3communicator.controllers.APIController;
	import com.innogames.as3communicator.model.DisplayObjectVO;
	import com.innogames.as3communicator.model.formatters.JSONFormatter;
	import com.innogames.as3communicator.model.formatters.XMLFormatter;
	import com.innogames.as3communicator.utils.DisplayObjectVOPool;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;

	import org.fluint.uiImpersonation.UIImpersonator;
	import org.hamcrest.assertThat;
	import org.hamcrest.core.anyOf;

	public class MainTest {

		use namespace testable;

		private var objAS3Selenium		:AS3Communicator;
		private var vecDisplayObjects	:Vector.<DisplayObjectVO>;

		public function MainTest()
		{
		}

		[Before(async,ui)]
		public function setUp():void
		{
			var objMasterDO			:Sprite,
				objZeroChild		:Sprite,
				objFirstChild		:Sprite,
				objFirstChildSprite	:Sprite,
				voMaster			:DisplayObjectVO,
				voZeroChild			:DisplayObjectVO,
				voFirstChild		:DisplayObjectVO,
				voFirstChildSprite	:DisplayObjectVO;

			objMasterDO			= new Sprite();
			objZeroChild		= new Sprite();
			objFirstChild		= new Sprite();
			objFirstChildSprite	= new Sprite();
			objMasterDO			.name	= 'master';
			objZeroChild		.name	= 'zero';
			objFirstChild		.name	= 'first';
			objFirstChildSprite	.name	= 'sprite';

			objMasterDO.addChild(objFirstChild);
			objMasterDO.addChild(objZeroChild);
			objFirstChild.addChild(objFirstChildSprite);
			UIImpersonator.addChild(objMasterDO);

			var objPool:DisplayObjectVOPool = DisplayObjectVOPool.instance;

			voFirstChildSprite	= objPool.getElement(objFirstChildSprite, null);
			voZeroChild			= objPool.getElement(objZeroChild, null);
			voFirstChild		= objPool.getElement(objFirstChild, new<DisplayObjectVO>[voFirstChildSprite]);
			voMaster			= objPool.getElement(objMasterDO, new<DisplayObjectVO>[voZeroChild, voFirstChild]);

			this.vecDisplayObjects = new <DisplayObjectVO>[];
			this.vecDisplayObjects.push(voMaster);

			this.objAS3Selenium = new AS3Communicator();
			UIImpersonator.addChild(this.objAS3Selenium);

			APIController.instance.parentContainer = UIImpersonator.getChildAt(0).parent as DisplayObjectContainer;
		}

		[After(async,ui)]
		public function tearDown():void
		{
			UIImpersonator.removeAllChildren();
			this.vecDisplayObjects = null;
			this.objAS3Selenium = null;
		}

		[Test]
		public function test_getObjectProperty():void
		{
			var strValue:String = APIController.instance.getObjectProperty('master', 'name');

			assertThat(strValue, 'master');
		}

		[Test]
		public function test_setObjectProperty():void
		{
			var result:String = APIController.instance.setObjectProperty('master', 'rotationX', '.123');

			assertThat((UIImpersonator.getChildAt(0) as Sprite).rotationX, '.123');
		}

		[Test]
		public function test_countObjectsOnStage():void
		{
			var result:int = APIController.instance.countObjectsOnStage();

			assertThat(result, 5);
		}

		[Test]
		public function testFindObjectByName_DotNotation():void
		{
			var strToFind	:String = 'master.first.sprite';
			var objResult	:DisplayObject;

			objResult = APIController.instance.findObjectByName(strToFind, this.vecDisplayObjects);

			assertThat(objResult.name, 'sprite');
		}

		[Test]
		public function testFindObjectByName_ArrayNotation_last(): void {
			var strToFind: String = 'master.first[0]';
			var objResult: DisplayObject;

			objResult = APIController.instance.findObjectByName(strToFind, this.vecDisplayObjects);

			assertThat(objResult.name, 'sprite');
		}


		[Test]
		public function testFindObjectByName_ArrayNotation_inbetween(): void {
			var strToFind: String = 'master[1].sprite';
			var objResult: DisplayObject;

			objResult = APIController.instance.findObjectByName(strToFind, this.vecDisplayObjects);

			assertThat(objResult.name, 'sprite');
		}


		[Test]
		public function testFindObjectByName_ArrayNotation_first(): void {
			var strToFind: String = '[0].first.sprite';
			var objResult: DisplayObject;

			objResult = APIController.instance.findObjectByName(strToFind, this.vecDisplayObjects);

			assertThat(objResult.name, 'sprite');
		}


		[Test]
		public function testFindObjectByName_ArrayNotation_only(): void {
			var strToFind: String = '[0][1][0]';
			var objResult: DisplayObject;

			objResult = APIController.instance.findObjectByName(strToFind, this.vecDisplayObjects);

			assertThat(objResult.name, 'sprite');
		}

		[Test]
		public function testFindObjectByName_on_real_example():void
		{
			this.vecDisplayObjects = new <DisplayObjectVO>[];

//			"instance6.instance8.instance163.HudContainer/CONTAINER_BUTTOM_LEFT.PlayerCityMainMenu.instance431.instance585.instance593"
			var objDOVO:DisplayObjectVO;
			var objChild:DisplayObjectVO;
			var vecInstance6Children:Vector.<DisplayObjectVO> = new <DisplayObjectVO>[];

			var objPool:DisplayObjectVOPool = DisplayObjectVOPool.instance;
			
			objDOVO = objPool.getElement(new Sprite(), null);
			objDOVO.displayObject.name = 'root1';
			this.vecDisplayObjects.push(objDOVO);

			objChild = objPool.getElement(new Sprite(), new <DisplayObjectVO>[objPool.getElement(new Sprite(), null)]);
			objChild.displayObject.name = 'instance7';
			vecInstance6Children.push(objChild);

			var subChild: DisplayObjectVO = objPool.getElement(new Sprite(), null);
			subChild.displayObject.name   = 'instance163';
			objChild                    = objPool.getElement(new Sprite(), new <DisplayObjectVO>[subChild]);
			objChild.displayObject.name = 'instance8';
			vecInstance6Children.push(objChild);

			objChild                    = objPool.getElement(new Sprite(), new <DisplayObjectVO>[objPool.getElement(new Sprite(), null)]);
			objChild.displayObject.name = 'instance9';
			vecInstance6Children.push(objChild);

			objChild                    = objPool.getElement(new Sprite(), new <DisplayObjectVO>[objPool.getElement(new Sprite(), null)]);
			objChild.displayObject.name = 'instance10';
			vecInstance6Children.push(objChild);

			objChild                    = objPool.getElement(new Sprite(), new <DisplayObjectVO>[objPool.getElement(new Sprite(), null)]);
			objChild.displayObject.name = 'instance11';
			vecInstance6Children.push(objChild);

			objChild                    = objPool.getElement(new Sprite(), new <DisplayObjectVO>[objPool.getElement(new Sprite(), null)]);
			objChild.displayObject.name = 'instance13';
			vecInstance6Children.push(objChild);

			objChild                    = objPool.getElement(new Sprite(), new <DisplayObjectVO>[objPool.getElement(new Sprite(), null)]);
			objChild.displayObject.name = 'instance59';
			vecInstance6Children.push(objChild);

			objDOVO                    = objPool.getElement(new Sprite(), vecInstance6Children);
			objDOVO.displayObject.name = 'instance6';

			this.vecDisplayObjects.push(objDOVO);

			objDOVO = objPool.getElement(new Sprite(), null);
			objDOVO.displayObject.name = 'instance66';
			this.vecDisplayObjects.push(objDOVO);

			var strToFind:String = 'instance6.instance8.instance163';
			var objResult: DisplayObject;

			objResult = APIController.instance.findObjectByName(strToFind, this.vecDisplayObjects);

			assertThat(objResult.name, 'instance163');
		}


		[Test]
		public function test_formatTreeJSON():void
		{
			var result:String = new JSONFormatter().formatTree(this.vecDisplayObjects);

			assertThat(result, '{"elements":[{"name":"master","children":[{"name":"zero","type":"flash.display::Sprite"},{"name":"first","children":[{"name":"sprite","type":"flash.display::Sprite"}],"type":"flash.display::Sprite"}],"type":"flash.display::Sprite"}]}');
		}


		[Test]
		public function test_formatTreeXML():void
		{
			var result:String = new XMLFormatter().formatTree(this.vecDisplayObjects);

			assertThat(result, "<elements>\n  <element name=\"master\" type=\"flash.display::Sprite\">\n    <children>\n      <element name=\"zero\" type=\"flash.display::Sprite\"/>\n      <element name=\"first\" type=\"flash.display::Sprite\">\n        <children>\n          <element name=\"sprite\" type=\"flash.display::Sprite\"/>\n        </children>\n      </element>\n    </children>\n  </element>\n</elements>");
		}
	}
}
