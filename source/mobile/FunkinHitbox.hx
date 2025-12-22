package mobile;

import mobile.Hitbox;
import openfl.display.BitmapData;
import openfl.display.Shape;
import openfl.geom.Matrix;
import flixel.util.FlxColor;
import objects.Note;

class FunkinHitbox extends Hitbox {
	public var currentMode:String;
	public var showHints:Bool;
	public function new(?mode:String, ?showHints:Bool, ?globalAlpha:Float = 0.7):Void
	{
		super(mode, globalAlpha, true); //true means mobile-controls's hitbox creation is disabled.
		currentMode = mode; //use this there.
		this.showHints = showHints;

		var Custom:String = mode != null ? mode : ClientPrefs.hitboxmode;
		if (!MobileConfig.hitboxModes.exists(Custom))
			throw 'The ${Custom} Hitbox File doesn\'t exists.';

		var currentHint = MobileConfig.hitboxModes.get(Custom).hints;
		if (MobileConfig.hitboxModes.get(Custom).none != null)
			currentHint = MobileConfig.hitboxModes.get(Custom).none;
		if (ClientPrefs.mobileExtraKeys == 1 && MobileConfig.hitboxModes.get(Custom).single != null)
			currentHint = MobileConfig.hitboxModes.get(Custom).single;
		if (ClientPrefs.mobileExtraKeys == 2 && MobileConfig.hitboxModes.get(Custom).double != null)
			currentHint = MobileConfig.hitboxModes.get(Custom).double;
		if (ClientPrefs.mobileExtraKeys == 3 && MobileConfig.hitboxModes.get(Custom).triple != null)
			currentHint = MobileConfig.hitboxModes.get(Custom).triple;
		if (ClientPrefs.mobileExtraKeys == 4 && MobileConfig.hitboxModes.get(Custom).quad != null)
			currentHint = MobileConfig.hitboxModes.get(Custom).quad;
		if (ClientPrefs.mobileExtraKeys != 0 && MobileConfig.hitboxModes.get(Custom).hints != null)
			currentHint = MobileConfig.hitboxModes.get(Custom).hints;

			for (buttonData in currentHint)
			{
				var buttonName:String = buttonData.button;
				var buttonIDs:Array<String> = buttonData.buttonIDs;
				var buttonUniqueID:Int = buttonData.buttonUniqueID;
				var buttonX:Float = buttonData.x;
				var buttonY:Float = buttonData.y;
				var buttonWidth:Int = buttonData.width;
				var buttonHeight:Int = buttonData.height;
				var buttonColor = buttonData.color;
				var buttonReturn = buttonData.returnKey;
				var location = ClientPrefs.hitboxLocation;
				var addButton:Bool = false;
				if (buttonData.buttonUniqueID == null) buttonUniqueID = -1; // -1 means not setted.

				switch (location) {
					case 'Top':
						if (buttonData.topX != null) buttonX = buttonData.topX;
						if (buttonData.topY != null) buttonY = buttonData.topY;
						if (buttonData.topWidth != null) buttonWidth = buttonData.topWidth;
						if (buttonData.topHeight != null) buttonHeight = buttonData.topHeight;
						if (buttonData.topColor != null) buttonColor = buttonData.topColor;
						if (buttonData.topReturnKey != null) buttonReturn = buttonData.topReturnKey;
					case 'Middle':
						if (buttonData.middleX != null) buttonX = buttonData.middleX;
						if (buttonData.middleY != null) buttonY = buttonData.middleY;
						if (buttonData.middleWidth != null) buttonWidth = buttonData.middleWidth;
						if (buttonData.middleHeight != null) buttonHeight = buttonData.middleHeight;
						if (buttonData.middleColor != null) buttonColor = buttonData.middleColor;
						if (buttonData.middleReturnKey != null) buttonReturn = buttonData.middleReturnKey;
					case 'Bottom':
						if (buttonData.bottomX != null) buttonX = buttonData.bottomX;
						if (buttonData.bottomY != null) buttonY = buttonData.bottomY;
						if (buttonData.bottomWidth != null) buttonWidth = buttonData.bottomWidth;
						if (buttonData.bottomHeight != null) buttonHeight = buttonData.bottomHeight;
						if (buttonData.bottomColor != null) buttonColor = buttonData.bottomColor;
						if (buttonData.bottomReturnKey != null) buttonReturn = buttonData.bottomReturnKey;
				}

				if (ClientPrefs.mobileExtraKeys == 0 && buttonData.extraKeyMode == 0 ||
				   ClientPrefs.mobileExtraKeys == 1 && buttonData.extraKeyMode == 1 ||
				   ClientPrefs.mobileExtraKeys == 2 && buttonData.extraKeyMode == 2 ||
				   ClientPrefs.mobileExtraKeys == 3 && buttonData.extraKeyMode == 3 ||
				   ClientPrefs.mobileExtraKeys == 4 && buttonData.extraKeyMode == 4 ||
				   buttonData.extraKeyMode == null)
				{
					addButton = true;
				}

				for (i in 1...5) {
					var buttonString = 'buttonExtra${i}';
					if (buttonData.button == buttonString && buttonReturn == null)
						buttonReturn = ClientPrefs.mobileExtraKeyReturns[i-1];
				}
				if (addButton)
					addHint(buttonName, buttonIDs, buttonUniqueID, buttonX, buttonY, buttonWidth, buttonHeight, Util.colorFromString(buttonColor), buttonReturn);
			}
		}

		scrollFactor.set();
		updateTrackedButtons();

		instance = this;
	}

	override function createHintGraphic(Width:Int, Height:Int, Color:Int = 0xFFFFFF, ?isLane:Bool = false):BitmapData
	{
		var guh:Float = globalAlpha;
		var shape:Shape = new Shape();
		shape.graphics.beginFill(Color);
		switch (ClientPrefs.hitboxtype) {
			case "No Gradient":
				var matrix:Matrix = new Matrix();
				matrix.createGradientBox(Width, Height, 0, 0, 0);
				if (isLane)
					shape.graphics.beginFill(Color);
				else
					shape.graphics.beginGradientFill(RADIAL, [Color, Color], [0, guh], [60, 255], matrix, PAD, RGB, 0);
				shape.graphics.drawRect(0, 0, Width, Height);
				shape.graphics.endFill();
			case "No Gradient (Old)":
				shape.graphics.lineStyle(10, Color, 1);
				shape.graphics.drawRect(0, 0, Width, Height);
				shape.graphics.endFill();
			case "Gradient":
				shape.graphics.lineStyle(3, Color, 1);
				shape.graphics.drawRect(0, 0, Width, Height);
				shape.graphics.lineStyle(0, 0, 0);
				shape.graphics.drawRect(3, 3, Width - 6, Height - 6);
				shape.graphics.endFill();
				if (isLane)
					shape.graphics.beginFill(Color);
				else
					shape.graphics.beginGradientFill(RADIAL, [Color, FlxColor.TRANSPARENT], [guh, 0], [0, 255], null, null, null, 0.5);
				shape.graphics.drawRect(3, 3, Width - 6, Height - 6);
				shape.graphics.endFill();
		}

		var bitmap:BitmapData = new BitmapData(Width, Height, true, 0);
		bitmap.draw(shape);
		return bitmap;
	}

	override public function createHint(name:Array<String>, uniqueID:Int, x:Float, y:Float, width:Int, height:Int, color:Int = 0xFFFFFF, ?returned:String):MobileButton
	{
		var hint:MobileButton = new MobileButton(x, y, returned);
		hint.loadGraphic(createHintGraphic(width, height, color));
		var VSliceAllowed:Bool = (currentMode == 'V Slice' && Note.maniaKeys != 20 && Note.maniaKeys != 55);

		if (showHints && !VSliceAllowed) {
			var doHeightFix:Bool = false;
			if (height == 144) doHeightFix = true;

			//Up Hint
			hint.hintUp = new FlxSprite();
			hint.hintUp.loadGraphic(createHintGraphic(width, Math.floor(height * (doHeightFix ? 0.060 : 0.020)), color, true));
			hint.hintUp.x = x;
			hint.hintUp.y = hint.y;

			//Down Hint
			hint.hintDown = new FlxSprite();
			hint.hintDown.loadGraphic(createHintGraphic(width, Math.floor(height * (doHeightFix ? 0.060 : 0.020)), color, true));
			hint.hintDown.x = x;
			hint.hintDown.y = hint.y + hint.height / (doHeightFix ? 1.060 : 1.020);
		}

		hint.solid = false;
		hint.immovable = true;
		hint.scrollFactor.set();
		hint.alpha = 0.00001;
		hint.IDs = name;
		hint.uniqueID = uniqueID;
		hint.onDown.callback = function()
		{
			onButtonDown?.dispatch(hint, name, uniqueID);
			if (hint.alpha != globalAlpha && !VSliceAllowed)
				hint.alpha = globalAlpha;
			if ((hint.hintUp?.alpha != 0.00001 || hint.hintDown?.alpha != 0.00001) && hint.hintUp != null && hint.hintDown != null && !VSliceAllowed)
				hint.hintUp.alpha = hint.hintDown.alpha = 0.00001;
		}
		hint.onOut.callback = hint.onUp.callback = function()
		{
			onButtonUp?.dispatch(hint, name, uniqueID);
			if (hint.alpha != 0.00001 && !VSliceAllowed)
				hint.alpha = 0.00001;
			if ((hint.hintUp?.alpha != globalAlpha || hint.hintDown?.alpha != globalAlpha) && hint.hintUp != null && hint.hintDown != null && !VSliceAllowed)
				hint.hintUp.alpha = hint.hintDown.alpha = globalAlpha;
		}
		#if FLX_DEBUG
		hint.ignoreDrawDebug = true;
		#end
		return hint;
	}
}