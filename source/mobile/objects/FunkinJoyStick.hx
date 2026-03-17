package mobile.objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.input.touch.FlxTouch;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSpriteUtil;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.Assets;
import openfl.display.BitmapData;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

import mobile.JoyStick;

using StringTools;

class FunkinJoyStick extends JoyStick {
	//FNF Asset Stuff
	override private function loadObjectGraphic(object:FlxSprite, graphic:String, img:String) {
		var fixedModPath:String = graphic;
		if (!graphic.startsWith(MobileConfig.mobileFolderPath))
			graphic = MobileConfig.mobileFolderPath + graphic;

		#if mobile_controls_file_support
		var xmlGraphicExists:Bool = (FileSystem.exists('$graphic.xml') && FileSystem.exists('$graphic.png'));
		var modGraphicXml:String = Paths.modFolders('mobile/$fixedModPath.xml');
		var modGraphicPng:String = Paths.modFolders('mobile/$fixedModPath.png');
		if (FileSystem.exists(modGraphicXml) && FileSystem.exists(modGraphicPng))
			object.loadGraphic(FlxGraphic.fromFrame(FlxAtlasFrames.fromSparrow(BitmapData.fromFile(modGraphicPng), File.getContent(modGraphicXml)).getByName(img)));
		else if (xmlGraphicExists)
			object.loadGraphic(FlxGraphic.fromFrame(FlxAtlasFrames.fromSparrow(BitmapData.fromFile('$graphic.png'), File.getContent('$graphic.xml')).getByName(img)));
		else #end
			object.loadGraphic(FlxGraphic.fromFrame(FlxAtlasFrames.fromSparrow(Assets.getBitmapData('$graphic.png'), Assets.getText('$graphic.xml')).getByName(img)));
	}

	public function new(x:Float = 0, y:Float = 0, ?graphic:String, ?onMove:Float->Float->Float->String->Void)
	{
		super(x, y, graphic, onMove);
	}
}