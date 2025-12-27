package mobile.psychlua;

import lime.ui.Haptic;
import flixel.util.FlxSave;
import psychlua.CustomSubstate;
import psychlua.FunkinLua;

class MobileFunctions
{
	public static function implement(funk:FunkinLua)
	{
		#if LUA_ALLOWED
		var lua:State = funk.lua;

		#if MOBILE_CONTROLS_ALLOWED
		Convert.addCallback(lua, 'createNewMobileManager', function(name:String):Void
		{
			PlayState.instance.createNewManager(name);
		});

		Convert.addCallback(lua, 'connectControlToNotes', function(?managerName:String, ?control:String):Void
		{
			PlayState.instance.connectControlToNotes(managerName, control);
		});

		//JoyStick
		Convert.addCallback(lua, 'addJoyStick', function(?managerName:String, ?stickPath:String, x:Float, y:Float, radius:Float = 0, ease:Float = 0.25, size:Float = 1, ?addToCustomSubstate:Bool = false, ?posAtCustomSubstate:Int = -1):Void
		{
			var manager = PlayState.checkManager(managerName);
			if (addToCustomSubstate)
			{
				manager.makeJoyStick(stickPath, x, y, radius, ease, size);
				if (manager.joyStick != null)
					CustomSubstate.insertObject(posAtCustomSubstate, manager.joyStick);
			}
			else
				manager.addJoyStick(stickPath, x, y, radius, ease, size);
			if(PlayState.instance.variables.exists(managerName + '_joyStick')) PlayState.instance.variables.set(managerName + '_joyStick', manager.joyStick);
		});

		Convert.addCallback(lua, 'addJoyStickCamera', function(?managerName:String, defaultDrawTarget:Bool = false):Void
		{
			PlayState.checkManager(managerName).addJoyStickCamera(defaultDrawTarget);
		});

		Convert.addCallback(lua, 'removeJoyStick', function(?managerName:String):Void
		{
			PlayState.checkManager(managerName).removeJoyStick();
		});

		Convert.addCallback(lua, 'joyStickPressed', function(?managerName:String, ?position:String):Bool
		{
			return PlayState.checkManager(managerName).joyStick.joyStickPressed(position);
		});

		Convert.addCallback(lua, 'joyStickJustPressed', function(?managerName:String, ?position:String):Bool
		{
			return PlayState.checkManager(managerName).joyStick.joyStickJustPressed(position);
		});

		Convert.addCallback(lua, 'joyStickJustReleased', function(?managerName:String, ?position:String):Bool
		{
			return PlayState.checkManager(managerName).joyStick.joyStickJustReleased(position);
		});

		//Hitbox
		Convert.addCallback(lua, "addHitbox", function(?managerName:String, ?mode:String, ?hints:Bool, ?addToCustomSubstate:Bool = false, ?posAtCustomSubstate:Int = -1):Void
		{
			var manager = PlayState.checkManager(managerName);
			if (addToCustomSubstate)
			{
				manager.makeHitbox(mode, hints);
				if (manager.hitbox != null)
					CustomSubstate.insertObject(posAtCustomSubstate, manager.hitbox);
			}
			else
				manager.addHitbox(mode, hints);
			if(PlayState.instance.variables.exists(managerName + '_hitbox')) PlayState.instance.variables.set(managerName + '_hitbox', manager.hitbox);
		});

		Convert.addCallback(lua, "addHitboxCamera", function(?managerName:String, defaultDrawTarget:Bool = false):Void
		{
			PlayState.checkManager(managerName).addHitboxCamera(defaultDrawTarget);
		});

		Convert.addCallback(lua, "addHitboxDeadZones", function(?managerName:String, buttons:Array<String>):Void
		{
			PlayState.instance.addHitboxDeadZone(managerName, buttons);
		});

		Convert.addCallback(lua, "removeHitbox", function(?managerName:String):Void
		{
			var manager = PlayState.checkManager(managerName);
			manager.hitbox.forEachAlive((button) ->
			{
				if (button.deadZones != []) button.deadZones = [];
			});
			manager.removeHitbox();
		});

		Convert.addCallback(lua, 'hitboxPressed', function(?managerName:String, ?hint:String):Bool
		{
			return PlayState.checkHBoxPress(hint, 'pressed', managerName);
		});

		Convert.addCallback(lua, 'hitboxJustPressed', function(?managerName:String, ?hint:String):Bool
		{
			return PlayState.checkHBoxPress(hint, 'justPressed', managerName);
		});

		Convert.addCallback(lua, 'hitboxReleased', function(?managerName:String, ?hint:String):Bool
		{
			return PlayState.checkHBoxPress(hint, 'released', managerName);
		});

		Convert.addCallback(lua, 'hitboxJustReleased', function(?managerName:String, ?hint:String):Bool
		{
			return PlayState.checkHBoxPress(hint, 'justReleased', managerName);
		});

		//MobilePad
		Convert.addCallback(lua, 'addMobilePad', function(?managerName:String, DPad:String, Action:String, ?addToCustomSubstate:Bool = false, ?posAtCustomSubstate:Int = -1, ?addToCustomSubstate:Bool = false, ?posAtCustomSubstate:Int = -1):Void
		{
			var manager = PlayState.checkManager(managerName);
			if (addToCustomSubstate)
			{
				manager.makeMobilePad(DPad, Action);
				if (manager.mobilePad != null)
					CustomSubstate.insertObject(posAtCustomSubstate, manager.mobilePad);
			}
			else
				manager.addMobilePad(DPad, Action);
			if(PlayState.instance.variables.exists(managerName + '_mobilePad')) PlayState.instance.variables.set(managerName + '_mobilePad', manager.mobilePad);
		});

		Convert.addCallback(lua, 'addMobilePadCamera', function(?managerName:String, defaultDrawTarget:Bool = false):Void
		{
			PlayState.checkManager(managerName).addMobilePadCamera(defaultDrawTarget);
		});

		Convert.addCallback(lua, 'removeMobilePad', function(?managerName:String):Void
		{
			PlayState.checkManager(managerName).removeMobilePad();
		});

		Convert.addCallback(lua, 'mobilePadPressed', function(?managerName:String, ?button:String):Bool
		{
			return PlayState.checkMPadPress(button, 'pressed', managerName);
		});

		Convert.addCallback(lua, 'mobilePadJustPressed', function(?managerName:String, ?button:String):Bool
		{
			return PlayState.checkMPadPress(button, 'justPressed', managerName);
		});

		Convert.addCallback(lua, 'mobilePadReleased', function(?managerName:String, ?button:String):Bool
		{
			return PlayState.checkMPadPress(button, 'released', managerName);
		});

		Convert.addCallback(lua, 'mobilePadJustReleased', function(?managerName:String, ?button:String):Bool
		{
			return PlayState.checkMPadPress(button, 'justReleased', managerName);
		});

		//Extra Things
		Convert.addCallback(lua, "setHitboxVisibilty", function(?managerName:String, enabled:Bool = false):Void
		{
			PlayState.checkManager(managerName).hitbox.visible = enabled;
		});

		Convert.addCallback(lua, "reloadHitbox", function(?managerName:String, ?mode:String):Void
		{
			var manager = PlayState.checkManager(managerName);
			manager.removeHitbox();
			manager.addHitbox(mode);
		});
		#end

		#if mobile
		Convert.addCallback(lua, "vibrate", function(duration:Null<Int>, ?period:Null<Int>)
		{
			if (period == null)
				period = 0;
			if (duration == null)
				return LuaUtils.luaTrace(lua, 'vibrate: No duration specified.');
			return Haptic.vibrate(period, duration);
		});

		Convert.addCallback(lua, "touchJustPressed", ScreenUtil.touch.justPressed);
		Convert.addCallback(lua, "touchPressed", ScreenUtil.touch.pressed);
		Convert.addCallback(lua, "touchJustReleased", ScreenUtil.touch.justReleased);
		Convert.addCallback(lua, "touchPressedObject", function(object:String):Bool
		{
			var obj = PlayState.instance.getLuaObject(object);
			if (obj == null)
			{
				LuaUtils.luaTrace(lua, 'touchPressedObject: $object does not exist.');
				return false;
			}
			return ScreenUtil.touch.overlaps(obj) && ScreenUtil.touch.pressed;
		});

		Convert.addCallback(lua, "touchJustPressedObject", function(object:String):Bool
		{
			var obj = PlayState.instance.getLuaObject(object);
			if (obj == null)
			{
				LuaUtils.luaTrace(lua, 'touchJustPressedObject: $object does not exist.');
				return false;
			}
			return ScreenUtil.touch.overlaps(obj) && ScreenUtil.touch.justPressed;
		});

		Convert.addCallback(lua, "touchJustReleasedObject", function(object:String):Bool
		{
			var obj = PlayState.instance.getLuaObject(object);
			if (obj == null)
			{
				LuaUtils.luaTrace(lua, 'touchJustPressedObject: $object does not exist.');
				return false;
			}
			return ScreenUtil.touch.overlaps(obj) && ScreenUtil.touch.justReleased;
		});

		Convert.addCallback(lua, "touchOverlapsObject", function(object:String):Bool
		{
			var obj = PlayState.instance.getLuaObject(object);
			if (obj == null)
			{
				LuaUtils.luaTrace(lua, 'touchOverlapsObject: $object does not exist.');
				return false;
			}
			return ScreenUtil.touch.overlaps(obj);
		});
		#end
		#end
	}
}

#if android
class AndroidFunctions
{
	public static function implement(funk:FunkinLua)
	{
		#if LUA_ALLOWED
		var lua:State = funk.lua;

		Convert.addCallback(lua, "isDolbyAtmos", AndroidTools.isDolbyAtmos());
		Convert.addCallback(lua, "isAndroidTV", AndroidTools.isAndroidTV());
		Convert.addCallback(lua, "isTablet", AndroidTools.isTablet());
		Convert.addCallback(lua, "isChromebook", AndroidTools.isChromebook());
		Convert.addCallback(lua, "isDeXMode", AndroidTools.isDeXMode());
		Convert.addCallback(lua, "backJustPressed", FlxG.android.justPressed.BACK);
		Convert.addCallback(lua, "backPressed", FlxG.android.pressed.BACK);
		Convert.addCallback(lua, "backJustReleased", FlxG.android.justReleased.BACK);
		Convert.addCallback(lua, "menuJustPressed", FlxG.android.justPressed.MENU);
		Convert.addCallback(lua, "menuPressed", FlxG.android.pressed.MENU);
		Convert.addCallback(lua, "menuJustReleased", FlxG.android.justReleased.MENU);
		Convert.addCallback(lua, "getCurrentOrientation", () -> ScreenUtil.getCurrentOrientationAsString());
		Convert.addCallback(lua, "setOrientation", function(hint:Null<String>):Void
		{
			switch (hint.toLowerCase())
			{
				case 'portrait':
					hint = 'Portrait';
				case 'portraitupsidedown' | 'upsidedownportrait' | 'upsidedown':
					hint = 'PortraitUpsideDown';
				case 'landscapeleft' | 'leftlandscape':
					hint = 'LandscapeLeft';
				case 'landscaperight' | 'rightlandscape' | 'landscape':
					hint = 'LandscapeRight';
				default:
					hint = null;
			}
			if (hint == null)
				return LuaUtils.luaTrace(lua, 'setOrientation: No orientation specified.');
			ScreenUtil.setOrientation(FlxG.stage.stageWidth, FlxG.stage.stageHeight, false, hint);
		});
		Convert.addCallback(lua, "minimizeWindow", () -> AndroidTools.minimizeWindow());
		Convert.addCallback(lua, "showToast", function(text:String, duration:Null<Int>, ?xOffset:Null<Int>, ?yOffset:Null<Int>)
		{
			if (text == null)
				return LuaUtils.luaTrace(lua, 'showToast: No text specified.');
			else if (duration == null)
				return LuaUtils.luaTrace(lua, 'showToast: No duration specified.');

			if (xOffset == null)
				xOffset = 0;
			if (yOffset == null)
				yOffset = 0;

			AndroidToast.makeText(text, duration, -1, xOffset, yOffset);
		});
		Convert.addCallback(lua, "isScreenKeyboardShown", () -> ScreenUtil.isScreenKeyboardShown());

		Convert.addCallback(lua, "clipboardHasText", () -> ScreenUtil.clipboardHasText());
		Convert.addCallback(lua, "clipboardGetText", () -> ScreenUtil.clipboardGetText());
		Convert.addCallback(lua, "clipboardSetText", function(text:Null<String>):Void
		{
			if (text != null) return LuaUtils.luaTrace(lua, 'clipboardSetText: No text specified.');
			ScreenUtil.clipboardSetText(text);
		});

		Convert.addCallback(lua, "manualBackButton", () -> ScreenUtil.manualBackButton());

		Convert.addCallback(lua, "setActivityTitle", function(text:Null<String>):Void
		{
			if (text != null) return LuaUtils.luaTrace(lua, 'setActivityTitle: No text specified.');
			ScreenUtil.setActivityTitle(text);
		});
		#end
	}
}
#end