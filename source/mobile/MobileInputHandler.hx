package mobile;

import haxe.ds.Map;
import flixel.group.FlxSpriteGroup;

enum ButtonsStates
{
	PRESSED;
	JUST_PRESSED;
	RELEASED;
	JUST_RELEASED;
}

/**
 * A handler for MobileButton.
 * If you don't know what are you doing, do not touch here.
 *
 * @author KralOyuncu 2010x (ArkoseLabs)
 */
class MobileInputHandler extends FlxTypedSpriteGroup<MobileButton>
{
	public var trackedButtons:Map<String, MobileButton> = new Map<String, MobileButton>();

	public function new()
	{
		super();
		updateTrackedButtons();
	}

	public function buttonPressed(button:Dynamic):Bool
		return checkButtonsState((Std.isOfType(button, Array) ? button : [button]), PRESSED);

	public function buttonJustPressed(button:Dynamic):Bool
		return checkButtonsState((Std.isOfType(button, Array) ? button : [button]), JUST_PRESSED);

	public function buttonJustReleased(button:Dynamic):Bool
		return checkButtonsState((Std.isOfType(button, Array) ? button : [button]), JUST_RELEASED);

	function checkButtonsState(Buttons:Array<String>, state:ButtonsStates = JUST_PRESSED):Bool
	{
		if (Buttons == null)
			return false;

		for (button in Buttons) {
			if (trackedButtons.exists(button)) {
				if (state == JUST_RELEASED && trackedButtons.get(button).justReleased ||
				   state == PRESSED && trackedButtons.get(button).pressed ||
				   state == JUST_PRESSED && trackedButtons.get(button).justPressed)
				{
					return true;
				}
			}
		}

		return false;
	}


	public function updateTrackedButtons()
	{
		trackedButtons.clear();
		forEachExists(function(button:MobileButton)
		{
			if (button.IDs != null)
			{
				for (id in button.IDs)
				{
					if (!trackedButtons.exists(id))
						trackedButtons.set(id, button);
				}
			}
		});
	}
}