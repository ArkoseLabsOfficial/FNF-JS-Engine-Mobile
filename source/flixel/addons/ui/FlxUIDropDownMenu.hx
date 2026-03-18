package flixel.addons.ui;

import openfl.geom.Rectangle;
import flixel.addons.ui.interfaces.IFlxUIClickable;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.interfaces.IHasParams;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxStringUtil;

#if (flixel < version("5.7.0"))
import flixel.ui.FlxButton.NORMAL;
import flixel.ui.FlxButton.HIGHLIGHT;
import flixel.ui.FlxButton.PRESSED;
#else
import flixel.ui.FlxButton.FlxButtonState.NORMAL;
import flixel.ui.FlxButton.FlxButtonState.HIGHLIGHT;
import flixel.ui.FlxButton.FlxButtonState.PRESSED;
import flixel.ui.FlxButton.FlxButtonState.DISABLED;
#end

class FlxUIDropDownMenu extends FlxUIGroup implements IFlxUIWidget implements IFlxUIClickable implements IHasParams
{
	private var currentScroll:Int = 0; //Handles the scrolling
	public var canScroll:Bool = true;

	// Handles mobile swipe / drag detection
	private var touchStartY:Float = 0; 
	private var minSwipeDistance:Float = 15;

	public var skipButtonUpdate(default, set):Bool;
	public var isScrolling:Bool = false;

	private function set_skipButtonUpdate(b:Bool):Bool
	{
		skipButtonUpdate = b;
		header.button.skipButtonUpdate = b;
		return b;
	}

	public var selectedId(get, set):String;
	public var selectedLabel(get, set):String;

	private var _selectedId:String;
	private var _selectedLabel:String;

	private function get_selectedId():String
	{
		return _selectedId;
	}

	private function set_selectedId(str:String):String
	{
		if (_selectedId == str)
			return str;

		var i:Int = 0;
		for (btn in list)
		{
			if (btn != null && btn.name == str)
			{
				var item:FlxUIButton = list[i];
				_selectedId = str;
				if (item.label != null)
				{
					_selectedLabel = item.label.text;
					header.text.text = item.label.text;
				}
				else
				{
					_selectedLabel = "";
					header.text.text = "";
				}
				return str;
			}
			i++;
		}
		return str;
	}

	private function get_selectedLabel():String
	{
		return _selectedLabel;
	}

	private function set_selectedLabel(str:String):String
	{
		if (_selectedLabel == str)
			return str;

		var i:Int = 0;
		for (btn in list)
		{
			if (btn.label.text == str)
			{
				var item:FlxUIButton = list[i];
				_selectedId = item.name;
				_selectedLabel = str;
				header.text.text = str;
				return str;
			}
			i++;
		}
		return str;
	}

	public var header:FlxUIDropDownHeader;
	public var list:Array<FlxUIButton> = [];
	public var dropPanel:FlxUI9SliceSprite;
	public var params(default, set):Array<Dynamic>;

	private function set_params(p:Array<Dynamic>):Array<Dynamic>
	{
		return params = p;
	}

	public var dropDirection(default, set):FlxUIDropDownMenuDropDirection = Automatic;

	private function set_dropDirection(dropDirection):FlxUIDropDownMenuDropDirection
	{
		this.dropDirection = dropDirection;
		updateButtonPositions();
		return dropDirection;
	}

	public static inline var CLICK_EVENT:String = "click_dropdown";
	public var callback:String->Void;

	public function new(X:Float = 0, Y:Float = 0, DataList:Array<StrNameLabel>, ?Callback:String->Void, ?Header:FlxUIDropDownHeader,
			?DropPanel:FlxUI9SliceSprite, ?ButtonList:Array<FlxUIButton>, ?UIControlCallback:Bool->FlxUIDropDownMenu->Void)
	{
		super(X, Y);
		callback = Callback;
		header = Header;
		dropPanel = DropPanel;

		if (header == null)
			header = new FlxUIDropDownHeader();

		if (dropPanel == null)
		{
			var rect = new Rectangle(0, 0, header.background.width, header.background.height);
			dropPanel = new FlxUI9SliceSprite(0, 0, FlxUIAssets.IMG_BOX, rect, [1, 1, 14, 14]);
		}

		if (DataList != null)
		{
			for (i in 0...DataList.length)
			{
				var data = DataList[i];
				list.push(makeListButton(i, data.label, data.name));
			}
			selectSomething(DataList[0].name, DataList[0].label);
		}
		else if (ButtonList != null)
		{
			for (btn in ButtonList)
			{
				list.push(btn);
				btn.resize(header.background.width, header.background.height);
				btn.x = 1;
			}
		}
		updateButtonPositions();

		dropPanel.resize(header.background.width, getPanelHeight());
		dropPanel.visible = false;
		add(dropPanel);

		for (btn in list)
		{
			add(btn);
			btn.visible = false;
		}

		header.button.onUp.callback = onDropdown;
		add(header);

		dropDirection = Down;
	}

	private function updateButtonPositions():Void
	{
		var buttonHeight = header.background.height;
		dropPanel.y = header.background.y;
		if (dropsUp())
			dropPanel.y -= getPanelHeight();
		else
			dropPanel.y += buttonHeight;

		var offset = dropPanel.y;
		for (button in list)
		{
			button.y = offset;
			offset += buttonHeight;
		}

		//scroll stuff
		var buttonHeight = header.background.height;
		dropPanel.y = header.background.y;
		if (dropsUp())
			dropPanel.y -= getPanelHeight();
		else
			dropPanel.y += buttonHeight;

		var offset = dropPanel.y;
		for (i in 0...currentScroll) {
			var button:FlxUIButton = list[i];
			if(button != null) {
				button.y = -99999;
			}
		}
		for (i in currentScroll...list.length)
		{
			var button:FlxUIButton = list[i];
			if(button != null) {
				button.y = offset;
				offset += buttonHeight;
			}
		}
	}

	override function set_visible(Value:Bool):Bool
	{
		var vDropPanel = dropPanel.visible;
		var vButtons = [];
		for (i in 0...list.length)
		{
			if (list[i] != null)
			{
				vButtons.push(list[i].visible);
			}
			else
			{
				vButtons.push(false);
			}
		}
		super.set_visible(Value);
		dropPanel.visible = vDropPanel;
		for (i in 0...list.length)
		{
			if (list[i] != null)
			{
				list[i].visible = vButtons[i];
			}
		}
		return Value;
	}

	private function dropsUp():Bool
	{
		return dropDirection == Up || (dropDirection == Automatic && exceedsHeight());
	}

	private function exceedsHeight():Bool
	{
		return y + getPanelHeight() + header.background.height > FlxG.height;
	}

	private function getPanelHeight():Float
	{
		return list.length * header.background.height;
	}

	public function setData(DataList:Array<StrNameLabel>):Void
	{
		var i:Int = 0;

		if (DataList != null)
		{
			for (data in DataList)
			{
				var recycled:Bool = false;
				if (list != null)
				{
					if (i <= list.length - 1)
					{
						var btn:FlxUIButton = list[i];
						if (btn != null)
						{
							btn.label.text = data.label;
							list[i].name = data.name;
							recycled = true;
						}
					}
				}
				else
				{
					list = [];
				}
				if (!recycled)
				{
					var t:FlxUIButton = makeListButton(i, data.label, data.name);
					list.push(t);
					add(t);
					t.visible = false;
				}
				i++;
			}

			if (list.length > DataList.length)
			{
				for (j in DataList.length...list.length)
				{
					var b:FlxUIButton = list.pop();
					b.visible = false;
					b.active = false;
					remove(b, true);
					b.destroy();
					b = null;
				}
			}

			selectSomething(DataList[0].name, DataList[0].label);
		}

		dropPanel.resize(header.background.width, getPanelHeight());
		updateButtonPositions();
	}

	private function selectSomething(name:String, label:String):Void
	{
		header.text.text = label;
		selectedId = name;
		selectedLabel = label;
	}

	private function makeListButton(i:Int, Label:String, Name:String):FlxUIButton
	{
		var t:FlxUIButton = new FlxUIButton(0, 0, Label);
		t.broadcastToFlxUI = false;
		t.onUp.callback = onClickItem.bind(i);

		t.name = Name;

		t.loadGraphicSlice9([FlxUIAssets.IMG_INVIS, FlxUIAssets.IMG_HILIGHT, FlxUIAssets.IMG_HILIGHT], Std.int(header.background.width),
			Std.int(header.background.height), [[1, 1, 3, 3], [1, 1, 3, 3], [1, 1, 3, 3]], FlxUI9SliceSprite.TILE_NONE);
		t.labelOffsets[PRESSED].y -= 1;

		t.up_color = FlxColor.BLACK;
		t.over_color = FlxColor.WHITE;
		t.down_color = FlxColor.WHITE;

		t.resize(header.background.width - 2, header.background.height - 1);

		t.label.alignment = "left";
		t.autoCenterLabel();
		t.x = 1;

		for (offset in t.labelOffsets)
		{
			offset.x += 2;
		}

		return t;
	}

	public function changeLabelByIndex(i:Int, NewLabel:String):Void
	{
		var btn:FlxUIButton = getBtnByIndex(i);
		if (btn != null && btn.label != null)
		{
			btn.label.text = NewLabel;
		}
	}

	public function changeLabelById(name:String, NewLabel:String):Void
	{
		var btn:FlxUIButton = getBtnById(name);
		if (btn != null && btn.label != null)
		{
			btn.label.text = NewLabel;
		}
	}

	public function getBtnByIndex(i:Int):FlxUIButton
	{
		if (i >= 0 && i < list.length)
		{
			return list[i];
		}
		return null;
	}

	public function getBtnById(name:String):FlxUIButton
	{
		for (btn in list)
		{
			if (btn.name == name)
			{
				return btn;
			}
		}
		return null;
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		checkClickOff();
		checkScroll();
	}
	
	function checkScroll() {
		if (dropPanel.visible && list.length > 1 && canScroll)
		{
			var scrollUp:Bool = false;
			var scrollDown:Bool = false;

			if (FlxG.mouse.wheel > 0 || FlxG.keys.justPressed.UP) scrollUp = true;
			if (FlxG.mouse.wheel < 0 || FlxG.keys.justPressed.DOWN) scrollDown = true;

			var pointerJustPressed = false;
			var pointerPressed = false;
			var pointerY:Float = 0;

			if (FlxG.mouse.justPressed) {
				pointerJustPressed = true;
				pointerY = FlxG.mouse.screenY;
			} else if (FlxG.mouse.pressed) {
				pointerPressed = true;
				pointerY = FlxG.mouse.screenY;
			}

			#if FLX_TOUCH
			for (touch in FlxG.touches.list) {
				if (touch.justPressed) {
					pointerJustPressed = true;
					pointerY = touch.screenY;
				} else if (touch.pressed) {
					pointerPressed = true;
					pointerY = touch.screenY;
				}
			}
			#end

			if (pointerJustPressed) {
				touchStartY = pointerY;
				isScrolling = false;
			} 
			else if (pointerPressed) {
				var dragDist = pointerY - touchStartY;
				
				if (Math.abs(dragDist) > minSwipeDistance) {
					isScrolling = true;
					
					if (dragDist > 0) {
						scrollUp = true;
					} else {
						scrollDown = true;
					}

					touchStartY = pointerY; 
				}
			}

			if (scrollUp) {
				currentScroll--;
				if (currentScroll < 0) currentScroll = 0;
				updateButtonPositions();
			} else if (scrollDown) {
				currentScroll++;
				if (currentScroll >= list.length) currentScroll = list.length - 1;
				updateButtonPositions();
			}
		}
	}
	
	function checkClickOff()
	{
		var justPressed:Bool = false;

		if (FlxG.mouse.justPressed) justPressed = true;
		
		#if FLX_TOUCH
		if (FlxG.touches.justStarted().length > 0) justPressed = true;
		#end

		if (dropPanel.visible && justPressed)
		{
			if (header.button.justPressed)
				return;
			
			for (button in list)
			{
				if (button.justPressed)
					return;
			}
			
			showList(false);
		}
	}

	override public function destroy():Void
	{
		super.destroy();

		dropPanel = FlxDestroyUtil.destroy(dropPanel);

		list = FlxDestroyUtil.destroyArray(list);
		callback = null;
	}

	private function showList(b:Bool):Void
	{
		for (button in list)
		{
			button.visible = b;
			button.active = b;
		}

		dropPanel.visible = b;

		FlxUI.forceFocus(b, this);
	}

	private function onDropdown():Void
	{
		(dropPanel.visible) ? showList(false) : showList(true);
	}

	private function onClickItem(i:Int):Void
  {
		if (isScrolling) return;

		var item:FlxUIButton = list[i];
		selectSomething(item.name, item.label.text);
		showList(false);

		if (callback != null)
		{
			callback(item.name);
		}

		if (broadcastToFlxUI)
		{
			FlxUI.event(CLICK_EVENT, this, item.name, params);
		}
	}

	public static function makeStrIdLabelArray(StringArray:Array<String>, UseIndexID:Bool = false):Array<StrNameLabel>
	{
		var strIdArray:Array<StrNameLabel> = [];
		for (i in 0...StringArray.length)
		{
			var ID:String = StringArray[i];
			if (UseIndexID)
			{
				ID = Std.string(i);
			}
			strIdArray[i] = new StrNameLabel(ID, StringArray[i]);
		}
		return strIdArray;
	}
}

class FlxUIDropDownHeader extends FlxUIGroup
{
	public var background:FlxSprite;
	public var text:FlxUIText;
	public var button:FlxUISpriteButton;

	public function new(Width:Int = 120, ?Background:FlxSprite, ?Text:FlxUIText, ?Button:FlxUISpriteButton)
	{
		super();

		background = Background;
		text = Text;
		button = Button;

		if (background == null)
		{
			background = new FlxUI9SliceSprite(0, 0, FlxUIAssets.IMG_BOX, new Rectangle(0, 0, Width, 20), [1, 1, 14, 14]);
		}

		if (button == null)
		{
			button = new FlxUISpriteButton(0, 0, new FlxSprite(0, 0, FlxUIAssets.IMG_DROPDOWN));
			button.loadGraphicSlice9([FlxUIAssets.IMG_BUTTON_THIN], 80, 20, [FlxStringUtil.toIntArray(FlxUIAssets.SLICE9_BUTTON)],
				FlxUI9SliceSprite.TILE_NONE, -1, false, FlxUIAssets.IMG_BUTTON_SIZE, FlxUIAssets.IMG_BUTTON_SIZE);
		}
		button.resize(background.height, background.height);
		button.x = background.x + background.width - button.width;

		button.width = Width;
		button.offset.x -= (Width - button.frameWidth);
		button.x = offset.x;
		button.label.offset.x += button.offset.x;

		if (text == null)
		{
			text = new FlxUIText(0, 0, Std.int(background.width));
		}
		text.setPosition(2, 4);
		text.color = FlxColor.BLACK;

		add(background);
		add(button);
		add(text);
	}

	override public function destroy():Void
	{
		super.destroy();

		background = FlxDestroyUtil.destroy(background);
		text = FlxDestroyUtil.destroy(text);
		button = FlxDestroyUtil.destroy(button);
	}
}

enum FlxUIDropDownMenuDropDirection
{
	Automatic;
	Down;
	Up;
}