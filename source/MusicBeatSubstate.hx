package;

import Conductor.BPMChangeEvent;
import flixel.FlxBasic;

class MusicBeatSubstate extends FlxSubState
{
	public static var instance:MusicBeatSubstate;
	public static var subInstance:MusicBeatSubstate; //used for gameplay changers
	#if MOBILE_CONTROLS_ALLOWED
	public var mobileManager:MobileControlManager;
	//makes code less messy & easier to write
	public inline function mobileButtonJustPressed(buttons:Dynamic):Bool {
		return mobileManager.mobilePad.buttonJustPressed(buttons);
	}
	public inline function mobileButtonPressed(buttons:Dynamic):Bool {
		return mobileManager.mobilePad.buttonPressed(buttons);
	}
	public inline function mobileButtonReleased(buttons:Dynamic):Bool {
		return mobileManager.mobilePad.buttonJustReleased(buttons);
	}
	#end
	public function new()
	{
		#if MOBILE_CONTROLS_ALLOWED
		trace(controls.isInSubSubstate);
		if (controls.isInSubSubstate)
			subInstance = this;
		else
		#end
			instance = this;

		#if MOBILE_CONTROLS_ALLOWED
		try {
			if (!controls.isInSubSubstate) controls.isInSubstate = true;
		} catch(e:Dynamic) {}
		mobileManager = new MobileControlManager(this);
		#end
		super();
	}
	override function destroy() {
		#if MOBILE_CONTROLS_ALLOWED
		trace(controls.isInSubSubstate);
		if (controls.isInSubSubstate) {
			subInstance = null;
			try {
				controls.isInSubSubstate = false;
			} catch(e:Dynamic) {}
		}
		else
		#end
			instance = null;

		#if MOBILE_CONTROLS_ALLOWED
		if (mobileManager != null) mobileManager.destroy();
		try {
			if (!controls.isInSubSubstate) controls.isInSubstate = false;
		} catch(e:Dynamic) {}
		#end
		super.destroy();
	}

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	var oldStep:Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function update(elapsed:Float)
	{
		if (oldStep != curStep) oldStep = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep/4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = ((Conductor.songPosition - ClientPrefs.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//do literally nothing dumbass
	}
}
