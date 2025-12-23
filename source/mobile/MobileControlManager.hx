package mobile;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.util.FlxDestroyUtil;
import mobile.JoyStick;

/**
 * A simple mobile manager for who doesn't want to create these manually
 * if you're making big projects or have a experience to how controls work, create the controls yourself
 */
class MobileControlManager {
	public var currentState:Dynamic;

	public var mobilePad:FunkinMobilePad;
	public var mobilePadCam:FlxCamera;
	public var joyStickCam:FlxCamera;
	public var joyStick:JoyStick;
	public var hitboxCam:FlxCamera;
	public var hitbox:FunkinHitbox;

	public function new(state:Dynamic):Void
	{
		this.currentState = state;
		trace("MobileControlManager initialized.");
	}

	//for lua shit
	public function makeMobilePad(DPad:String, Action:String)
	{
		if (mobilePad != null) removeMobilePad();
		mobilePad = new FunkinMobilePad(DPad, Action, ClientPrefs.data.mobilePadAlpha);
	}

	public function addMobilePad(DPad:String, Action:String)
	{
		makeMobilePad(DPad, Action);
		currentState.add(mobilePad);
	}

	public function removeMobilePad():Void
	{
		if (mobilePad != null)
		{
			currentState.remove(mobilePad);
			mobilePad = FlxDestroyUtil.destroy(mobilePad);
		}

		if(mobilePadCam != null)
		{
			FlxG.cameras.remove(mobilePadCam);
			mobilePadCam = FlxDestroyUtil.destroy(mobilePadCam);
		}
	}

	public function addMobilePadCamera(defaultDrawTarget:Bool = false):Void
	{
		mobilePadCam = new FlxCamera();
		mobilePadCam.bgColor.alpha = 0;
		FlxG.cameras.add(mobilePadCam, defaultDrawTarget);
		mobilePad.cameras = [mobilePadCam];
	}

	public function makeHitbox(?mode:String, ?hints:Bool) {
		if (hitbox != null) removeHitbox();
		hitbox = new FunkinHitbox(mode, hints);
	}

	public function addHitbox(?mode:String, ?hints:Bool) {
		makeHitbox(mode, hints);
		currentState.add(hitbox);
	}

	public function removeHitbox():Void
	{
		if (hitbox != null)
		{
			currentState.remove(hitbox);
			hitbox = FlxDestroyUtil.destroy(hitbox);
		}

		if(hitboxCam != null)
		{
			FlxG.cameras.remove(hitboxCam);
			hitboxCam = FlxDestroyUtil.destroy(hitboxCam);
		}
	}

	public function addHitboxCamera(defaultDrawTarget:Bool = false):Void
	{
		hitboxCam = new FlxCamera();
		hitboxCam.bgColor.alpha = 0;
		FlxG.cameras.add(hitboxCam, defaultDrawTarget);
		hitbox.cameras = [hitboxCam];
	}

	public function makeJoyStick(?stickPath:String, x:Float, y:Float, radius:Float = 0, ease:Float = 0.25, size:Float = 1):Void
	{
		if (joyStick != null) removeJoyStick();
		joyStick = new JoyStick(stickPath, x, y, radius, ease, size);
	}

	public function addJoyStick(?stickPath:String, x:Float, y:Float, radius:Float = 0, ease:Float = 0.25, size:Float = 1):Void
	{
		makeJoyStick(stickPath, x, y, radius, ease, size);
		currentState.add(joyStick);
	}

	public function removeJoyStick():Void
	{
		if (joyStick != null)
		{
			currentState.remove(joyStick);
			joyStick = FlxDestroyUtil.destroy(joyStick);
		}

		if(joyStickCam != null)
		{
			FlxG.cameras.remove(joyStickCam);
			joyStickCam = FlxDestroyUtil.destroy(joyStickCam);
		}
	}

	public function addJoyStickCamera(defaultDrawTarget:Bool = false):Void {
		joyStickCam = new FlxCamera();
		joyStickCam.bgColor.alpha = 0;
		FlxG.cameras.add(joyStickCam, defaultDrawTarget);
		joyStick.cameras = [joyStickCam];
	}

	public function destroy():Void {
		removeMobilePad();
		removeHitbox();
		removeJoyStick();
	}
}
