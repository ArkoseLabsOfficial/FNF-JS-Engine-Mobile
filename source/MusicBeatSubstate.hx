package;

import Conductor.BPMChangeEvent;
import flixel.FlxBasic;

class MusicBeatSubstate extends FlxSubState
{
	public static var instance:MusicBeatSubstate;
	#if MOBILE_CONTROLS_ALLOWED
	public var mobileManager:MobileControlManager;
	private function createMobileManager() {
		if (mobileManager == null) mobileManager = new MobileControlManager(this);
	}
	#end
	public function new()
	{
		trace('called');
		instance = this;
		trace('called');
		super();
		trace('called');
		#if MOBILE_CONTROLS_ALLOWED
		try {
			if (controls != null) controls.isInSubstate = true;
		} catch(e:Dynamic) {}
		trace('called');
		createMobileManager();
		trace('called');
		#end
	}
	override function destroy() {
		#if MOBILE_CONTROLS_ALLOWED
		trace('called');
		if (mobileManager != null) mobileManager.destroy();
		trace('called');
		#end
		super.destroy();
		trace('called');
		instance = null;
		trace('called');
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
