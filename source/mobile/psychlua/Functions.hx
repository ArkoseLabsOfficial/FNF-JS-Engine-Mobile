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
		Lua_helper.add_callback(lua, 'createNewMobileManager', function(name:String):Void
		{
			PlayState.instance.createNewManager(name);
		});

		//JoyStick
		Lua_helper.add_callback(lua, 'addJoyStick', function(?managerName:String, ?stickPath:String, x:Float, y:Float, radius:Float = 0, ease:Float = 0.25, size:Float = 1, ?addToCustomSubstate:Bool = false, ?posAtCustomSubstate:Int = -1):Void
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

		Lua_helper.add_callback(lua, 'addJoyStickCamera', function(?managerName:String, defaultDrawTarget:Bool = false):Void
		{
			PlayState.checkManager(managerName).addJoyStickCamera(defaultDrawTarget);
		});

		Lua_helper.add_callback(lua, 'removeJoyStick', function(?managerName:String):Void
		{
			PlayState.checkManager(managerName).removeJoyStick();
		});

		Lua_helper.add_callback(lua, 'joyStickPressed', function(?managerName:String, ?position:String):Bool
		{
			return PlayState.checkManager(managerName).joyStick.joyStickPressed(position);
		});

		Lua_helper.add_callback(lua, 'joyStickJustPressed', function(?managerName:String, ?position:String):Bool
		{
			return PlayState.checkManager(managerName).joyStick.joyStickJustPressed(position);
		});

		Lua_helper.add_callback(lua, 'joyStickJustReleased', function(?managerName:String, ?position:String):Bool
		{
			return PlayState.checkManager(managerName).joyStick.joyStickJustReleased(position);
		});

		//Hitbox
		Lua_helper.add_callback(lua, "addHitbox", function(?managerName:String, ?mode:String, ?hints:Bool, ?addToCustomSubstate:Bool = false, ?posAtCustomSubstate:Int = -1):Void
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

		Lua_helper.add_callback(lua, "addHitboxCamera", function(?managerName:String, defaultDrawTarget:Bool = false):Void
		{
			PlayState.checkManager(managerName).addHitboxCamera(defaultDrawTarget);
		});

		Lua_helper.add_callback(lua, "removeHitbox", function(?managerName:String):Void
		{
			PlayState.checkManager(managerName).removeHitbox();
		});

		Lua_helper.add_callback(lua, 'hitboxPressed', function(?managerName:String, ?hint:String):Bool
		{
			return PlayState.checkHBoxPress(hint, 'pressed', managerName);
		});

		Lua_helper.add_callback(lua, 'hitboxJustPressed', function(?managerName:String, ?hint:String):Bool
		{
			return PlayState.checkHBoxPress(hint, 'justPressed', managerName);
		});

		Lua_helper.add_callback(lua, 'hitboxReleased', function(?managerName:String, ?hint:String):Bool
		{
			return PlayState.checkHBoxPress(hint, 'released', managerName);
		});

		Lua_helper.add_callback(lua, 'hitboxJustReleased', function(?managerName:String, ?hint:String):Bool
		{
			return PlayState.checkHBoxPress(hint, 'justReleased', managerName);
		});

		//MobilePad
		Lua_helper.add_callback(lua, 'addMobilePad', function(?managerName:String, DPad:String, Action:String, ?addToCustomSubstate:Bool = false, ?posAtCustomSubstate:Int = -1, ?addToCustomSubstate:Bool = false, ?posAtCustomSubstate:Int = -1):Void
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

		Lua_helper.add_callback(lua, 'addMobilePadCamera', function(?managerName:String, defaultDrawTarget:Bool = false):Void
		{
			PlayState.checkManager(managerName).addMobilePadCamera(defaultDrawTarget);
		});

		Lua_helper.add_callback(lua, 'removeMobilePad', function(?managerName:String):Void
		{
			PlayState.checkManager(managerName).removeMobilePad();
		});

		Lua_helper.add_callback(lua, 'mobilePadPressed', function(?managerName:String, ?button:String):Bool
		{
			return PlayState.checkMPadPress(button, 'pressed', managerName);
		});

		Lua_helper.add_callback(lua, 'mobilePadJustPressed', function(?managerName:String, ?button:String):Bool
		{
			return PlayState.checkMPadPress(button, 'justPressed', managerName);
		});

		Lua_helper.add_callback(lua, 'mobilePadReleased', function(?managerName:String, ?button:String):Bool
		{
			return PlayState.checkMPadPress(button, 'released', managerName);
		});

		Lua_helper.add_callback(lua, 'mobilePadJustReleased', function(?managerName:String, ?button:String):Bool
		{
			return PlayState.checkMPadPress(button, 'justReleased', managerName);
		});

		//Extra Things
		Lua_helper.add_callback(lua, "setHitboxVisibilty", function(?managerName:String, enabled:Bool = false):Void
		{
			PlayState.checkManager(managerName).hitbox.visible = enabled;
		});

		Lua_helper.add_callback(lua, "reloadHitbox", function(?managerName:String, ?mode:String):Void
		{
			var manager = PlayState.checkManager(managerName);
			manager.removeHitbox();
			manager.addHitbox(mode);
		});
		#end

		#if mobile
		Lua_helper.add_callback(lua, "vibrate", function(duration:Null<Int>, ?period:Null<Int>)
		{
			if (period == null)
				period = 0;
			if (duration == null)
				return funk.luaTrace('vibrate: No duration specified.');
			return Haptic.vibrate(period, duration);
		});

		Lua_helper.add_callback(lua, "touchJustPressed", ScreenUtil.touch.justPressed);
		Lua_helper.add_callback(lua, "touchPressed", ScreenUtil.touch.pressed);
		Lua_helper.add_callback(lua, "touchJustReleased", ScreenUtil.touch.justReleased);
		Lua_helper.add_callback(lua, "touchPressedObject", function(object:String):Bool
		{
			var obj = PlayState.instance.getLuaObject(object);
			if (obj == null)
			{
				funk.luaTrace('touchPressedObject: $object does not exist.');
				return false;
			}
			return ScreenUtil.touch.overlaps(obj) && ScreenUtil.touch.pressed;
		});

		Lua_helper.add_callback(lua, "touchJustPressedObject", function(object:String):Bool
		{
			var obj = PlayState.instance.getLuaObject(object);
			if (obj == null)
			{
				funk.luaTrace('touchJustPressedObject: $object does not exist.');
				return false;
			}
			return ScreenUtil.touch.overlaps(obj) && ScreenUtil.touch.justPressed;
		});

		Lua_helper.add_callback(lua, "touchJustReleasedObject", function(object:String):Bool
		{
			var obj = PlayState.instance.getLuaObject(object);
			if (obj == null)
			{
				funk.luaTrace('touchJustPressedObject: $object does not exist.');
				return false;
			}
			return ScreenUtil.touch.overlaps(obj) && ScreenUtil.touch.justReleased;
		});

		Lua_helper.add_callback(lua, "touchOverlapsObject", function(object:String):Bool
		{
			var obj = PlayState.instance.getLuaObject(object);
			if (obj == null)
			{
				funk.luaTrace('touchOverlapsObject: $object does not exist.');
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

		Lua_helper.add_callback(lua, "isDolbyAtmos", AndroidTools.isDolbyAtmos());
		Lua_helper.add_callback(lua, "isAndroidTV", AndroidTools.isAndroidTV());
		Lua_helper.add_callback(lua, "isTablet", AndroidTools.isTablet());
		Lua_helper.add_callback(lua, "isChromebook", AndroidTools.isChromebook());
		Lua_helper.add_callback(lua, "isDeXMode", AndroidTools.isDeXMode());
		Lua_helper.add_callback(lua, "backJustPressed", FlxG.android.justPressed.BACK);
		Lua_helper.add_callback(lua, "backPressed", FlxG.android.pressed.BACK);
		Lua_helper.add_callback(lua, "backJustReleased", FlxG.android.justReleased.BACK);
		Lua_helper.add_callback(lua, "menuJustPressed", FlxG.android.justPressed.MENU);
		Lua_helper.add_callback(lua, "menuPressed", FlxG.android.pressed.MENU);
		Lua_helper.add_callback(lua, "menuJustReleased", FlxG.android.justReleased.MENU);
		Lua_helper.add_callback(lua, "getCurrentOrientation", () -> ScreenUtil.getCurrentOrientationAsString());
		Lua_helper.add_callback(lua, "setOrientation", function(hint:Null<String>):Void
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
				return funk.luaTrace('setOrientation: No orientation specified.');
			ScreenUtil.setOrientation(FlxG.stage.stageWidth, FlxG.stage.stageHeight, false, hint);
		});
		Lua_helper.add_callback(lua, "minimizeWindow", () -> AndroidTools.minimizeWindow());
		Lua_helper.add_callback(lua, "showToast", function(text:String, duration:Null<Int>, ?xOffset:Null<Int>, ?yOffset:Null<Int>)
		{
			if (text == null)
				return funk.luaTrace('showToast: No text specified.');
			else if (duration == null)
				return funk.luaTrace('showToast: No duration specified.');

			if (xOffset == null)
				xOffset = 0;
			if (yOffset == null)
				yOffset = 0;

			AndroidToast.makeText(text, duration, -1, xOffset, yOffset);
		});
		Lua_helper.add_callback(lua, "isScreenKeyboardShown", () -> ScreenUtil.isScreenKeyboardShown());

		Lua_helper.add_callback(lua, "clipboardHasText", () -> ScreenUtil.clipboardHasText());
		Lua_helper.add_callback(lua, "clipboardGetText", () -> ScreenUtil.clipboardGetText());
		Lua_helper.add_callback(lua, "clipboardSetText", function(text:Null<String>):Void
		{
			if (text != null) return funk.luaTrace('clipboardSetText: No text specified.');
			ScreenUtil.clipboardSetText(text);
		});

		Lua_helper.add_callback(lua, "manualBackButton", () -> ScreenUtil.manualBackButton());

		Lua_helper.add_callback(lua, "setActivityTitle", function(text:Null<String>):Void
		{
			if (text != null) return funk.luaTrace('setActivityTitle: No text specified.');
			ScreenUtil.setActivityTitle(text);
		});
		#end
	}
}
#end