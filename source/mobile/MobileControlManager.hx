package mobile;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.util.FlxDestroyUtil;

/**
 * A simple mobile manager for who doesn't want to create these manually, comes with mobile-controls library
 * if you're making big projects or have a experience to how controls work, create the controls yourself
 */
class MobileControlManager {
	public var currentState:Dynamic;

	public var hitboxCam:FlxCamera;
	public var hitbox:FunkinHitbox;

	public function new(state:Dynamic):Void
	{
		this.currentState = state;
		trace("MobileControlManager initialized.");
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

	public function destroy():Void {
		removeHitbox();
	}
}
