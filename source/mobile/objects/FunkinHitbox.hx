package mobile.objects;

import mobile.Hitbox;
import openfl.display.BitmapData;
import openfl.display.Shape;
import openfl.geom.Matrix;
import flixel.util.FlxColor;

class FunkinHitbox extends Hitbox {
	public var currentMode:String;
	public var showHints:Bool;
	public function new(?mode:String, ?showHints:Bool):Void
	{
		super(mode, false); //false means library's hitbox creation is disabled.
		currentMode = mode; //use this there.
		this.showHints = showHints;

		var Custom:String = mode != null ? mode : ClientPrefs.hitboxMode;

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
			var buttonX:Float = buttonData.position[0];
			var buttonY:Float = buttonData.position[1];
			var buttonWidth:Int = buttonData.scale[0];
			var buttonHeight:Int = buttonData.scale[1];
			var buttonColor = buttonData.color;
			var buttonReturn = buttonData.returnKey;
			var location = ClientPrefs.hitboxLocation;
			var addButton:Bool = false;
			if (buttonData.buttonUniqueID == null) buttonUniqueID = -1; // -1 means not setted.

			switch (location) {
				case 'Top':
					if (buttonData.topPosition != null) {
						buttonX = buttonData.topPosition[0];
						buttonY = buttonData.topPosition[1];
					}
					if (buttonData.topScale != null) {
						buttonWidth = buttonData.topScale[0];
						buttonHeight = buttonData.topScale[1];
					}
					if (buttonData.topColor != null) buttonColor = buttonData.topColor;
					if (buttonData.topReturnKey != null) buttonReturn = buttonData.topReturnKey;
				case 'Middle':
					if (buttonData.middlePosition != null) {
						buttonX = buttonData.middlePosition[0];
						buttonY = buttonData.middlePosition[1];
					}
					if (buttonData.middleScale != null) {
						buttonWidth = buttonData.middleScale[0];
						buttonHeight = buttonData.middleScale[1];
					}
					if (buttonData.middleColor != null) buttonColor = buttonData.middleColor;
					if (buttonData.middleReturnKey != null) buttonReturn = buttonData.middleReturnKey;
				case 'Bottom':
					if (buttonData.bottomPosition != null) {
						buttonX = buttonData.bottomPosition[0];
						buttonY = buttonData.bottomPosition[1];
					}
					if (buttonData.bottomScale != null) {
						buttonWidth = buttonData.bottomScale[0];
						buttonHeight = buttonData.bottomScale[1];
					}
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

		scrollFactor.set();
		updateTrackedButtons();

		instance = this;
	}

	override function createHintGraphic(Width:Int, Height:Int, Color:Int = 0xFFFFFF, ?isLane:Bool = false):BitmapData
	{
		var shape:Shape = new Shape();
		shape.graphics.beginFill(Color);
		switch (ClientPrefs.hitboxType) {
			case "No Gradient":
				var matrix:Matrix = new Matrix();
				matrix.createGradientBox(Width, Height, 0, 0, 0);
				if (isLane)
					shape.graphics.beginFill(Color);
				else
					shape.graphics.beginGradientFill(RADIAL, [Color, Color], [0, alpha], [60, 255], matrix, PAD, RGB, 0);
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
					shape.graphics.beginGradientFill(RADIAL, [Color, FlxColor.TRANSPARENT], [alpha, 0], [0, 255], null, null, null, 0.5);
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

		if (showHints) {
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
			if (hint.alpha != alpha)
				hint.alpha = alpha;
			if ((hint.hintUp?.alpha != 0.00001 || hint.hintDown?.alpha != 0.00001) && hint.hintUp != null && hint.hintDown != null)
				hint.hintUp.alpha = hint.hintDown.alpha = 0.00001;
		}
		hint.onOut.callback = hint.onUp.callback = function()
		{
			onButtonUp?.dispatch(hint, name, uniqueID);
			if (hint.alpha != 0.00001)
				hint.alpha = 0.00001;
			if ((hint.hintUp?.alpha != alpha || hint.hintDown?.alpha != alpha) && hint.hintUp != null && hint.hintDown != null)
				hint.hintUp.alpha = hint.hintDown.alpha = alpha;
		}
		#if FLX_DEBUG
		hint.ignoreDrawDebug = true;
		#end
		return hint;
	}
}