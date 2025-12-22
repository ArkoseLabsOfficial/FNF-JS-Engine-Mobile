package mobile;

import haxe.Json;
import haxe.io.Path;
import flixel.util.FlxSave;
import openfl.utils.Assets;

using StringTools;

enum ButtonsModes
{
	ACTION;
	DPAD;
	HITBOX;
}

class MobileConfig {
	public static var actionModes:Map<String, MobileButtonsData> = new Map();
	public static var dpadModes:Map<String, MobileButtonsData> = new Map();
	public static var hitboxModes:Map<String, CustomHitboxData> = new Map();
	public static var mobileFolderPath:String = 'mobile/';

	public static var save:FlxSave;

	public static function init(saveName:String, savePath:String, mobilePath:String = 'mobile/', folders:Array<String>, modes:Array<ButtonsModes>)
	{
		save = new FlxSave();
		save.bind(saveName, savePath);
		if (mobilePath != null || mobilePath != '') mobileFolderPath = (mobilePath.endsWith('/') ? mobilePath : mobilePath + '/');

		var intNumber:Int = -1;
		for (i in folders) {
			intNumber++;
			switch (modes[intNumber]) {
				case ACTION:
					readDirectoryPart1(mobileFolderPath + i, actionModes, ACTION);
					#if MODS_ALLOWED
					for (folder in directoriesWithFile(Paths.getPreloadPath(), 'mobile/MobilePad/')) (
						trace('called');
						readDirectoryPart1(Path.join([folder, 'ActionModes']), actionModes, ACTION);
					}
					#end
				case DPAD:
					readDirectoryPart1(mobileFolderPath + i, dpadModes, DPAD);
					#if MODS_ALLOWED
					for (folder in directoriesWithFile(Paths.getPreloadPath(), 'mobile/MobilePad/')) (
						trace('called');
						readDirectoryPart1(Path.join([folder, 'DPadModes']), dpadModes, DPAD);
					}
					#end
				case HITBOX:
					readDirectoryPart1(mobileFolderPath + i, hitboxModes, HITBOX);
					#if MODS_ALLOWED
					for (folder in directoriesWithFile(Paths.getPreloadPath(), 'mobile/Hitbox/')) (
						trace('called');
						readDirectoryPart1(Path.join([folder, 'HitboxModes']), hitboxModes, HITBOX);
					}
					#end
			}
		}
	}

	static function directoriesWithFile(path:String, fileToFind:String, mods:Bool = true)
	{
		var foldersToCheck:Array<String> = [];
		#if sys
		if(FileSystem.exists(path + fileToFind))
		#end
			foldersToCheck.push(path + fileToFind);

		#if MODS_ALLOWED
		if(mods)
		{
			// Global mods first
			for(mod in Paths.getGlobalMods())
			{
				var folder:String = Paths.mods(mod + '/' + fileToFind);
				if(FileSystem.exists(folder) && !foldersToCheck.contains(folder)) foldersToCheck.push(folder);
			}

			// Then "PsychEngine/mods/" main folder
			var folder:String = Paths.mods(fileToFind);
			if(FileSystem.exists(folder) && !foldersToCheck.contains(folder)) foldersToCheck.push(Paths.mods(fileToFind));

			// And lastly, the loaded mod's folder
			if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			{
				var folder:String = Paths.mods(Paths.currentModDirectory + '/' + fileToFind);
				if(FileSystem.exists(folder) && !foldersToCheck.contains(folder)) foldersToCheck.push(folder);
			}
		}
		#end
		return foldersToCheck;
	}

	static function readDirectoryPart1(folder:String, map:Dynamic, mode:ButtonsModes)
	{
		trace('' + folder);
		folder = folder.contains(':') ? folder.split(':')[1] : folder;

		#if mobile_controls_file_support if (FileSystem.exists(folder)) #end
		for (file in readDirectoryPart2(folder))
		{
			if (Path.extension(file) == 'json')
			{
				file = Path.join([folder, Path.withoutDirectory(file)]);

				var str:String;
				#if mobile_controls_file_support
				if (FileSystem.exists(file))
					str = FileSystem.getText(file);
				else #end
					str = Assets.getText(file);

				if (mode == HITBOX) {
					var json:CustomHitboxData = cast Json.parse(str);
					var mapKey:String = Path.withoutDirectory(Path.withoutExtension(file));
					map.set(mapKey, json);
				}
				else if (mode == ACTION || mode == DPAD) {
					var json:MobileButtonsData = cast Json.parse(str);
					var mapKey:String = Path.withoutDirectory(Path.withoutExtension(file));
					map.set(mapKey, json);
				}
			}
		}
	}

	static function readDirectoryPart2(directory:String):Array<String>
	{
		var dirs:Array<String> = [];

		#if mobile_controls_file_support
		return FileSystem.readDirectory(directory);
		#else
		var dirs:Array<String> = [];
		for(dir in Assets.list().filter(folder -> folder.startsWith(directory)))
		{
			@:privateAccess
			for(library in lime.utils.Assets.libraries.keys())
			{
				if(library != 'default' && Assets.exists('$library:$dir') && (!dirs.contains('$library:$dir') || !dirs.contains(dir)))
					dirs.push('$library:$dir');
				else if(Assets.exists(dir) && !dirs.contains(dir))
					dirs.push(dir);
			}
		}
		return dirs;
		#end
	}
}

typedef MobileButtonsData =
{
	buttons:Array<ButtonsData>
}

typedef CustomHitboxData =
{
	hints:Array<HitboxData>, //support old jsons
	//Shitty but works (as said, if it works don't touch)
	none:Array<HitboxData>,
	single:Array<HitboxData>,
	double:Array<HitboxData>,
	triple:Array<HitboxData>,
	quad:Array<HitboxData>,
	mania1:Array<HitboxData>,
	mania2:Array<HitboxData>,
	mania3:Array<HitboxData>,
	mania4:Array<HitboxData>,
	mania5:Array<HitboxData>,
	mania6:Array<HitboxData>,
	mania7:Array<HitboxData>,
	mania8:Array<HitboxData>,
	mania9:Array<HitboxData>,
	mania20:Array<HitboxData>,
	mania55:Array<HitboxData>,
	test:Array<HitboxData>
}

typedef HitboxData =
{
	button:String, // what Hitbox Button should be used, must be a valid Hitbox Button var from Hitbox as a string.
	buttonIDs:Array<String>, // what Hitbox Button Iad should be used, If you're using a the library for PsychEngine 0.7 Versions, This is useful.
	buttonUniqueID:Dynamic, // the button's special ID for button
	//if custom ones isn't setted these will be used
	x:Dynamic, // the button's X position on screen.
	y:Dynamic, // the button's Y position on screen.
	width:Dynamic, // the button's Width on screen.
	height:Dynamic, // the button's Height on screen.
	color:String, // the button color, default color is white.
	returnKey:String, // the button return, default return is nothing (please don't add custom return if you don't need).
	extraKeyMode:Null<Int>,
	//Top
	topX:Dynamic,
	topY:Dynamic,
	topWidth:Dynamic,
	topHeight:Dynamic,
	topColor:String,
	topReturnKey:String,
	topExtraKeyMode:Null<Int>,
	//Middle
	middleX:Dynamic,
	middleY:Dynamic,
	middleWidth:Dynamic,
	middleHeight:Dynamic,
	middleColor:String,
	middleReturnKey:String,
	middleExtraKeyMode:Null<Int>,
	//Bottom
	bottomX:Dynamic,
	bottomY:Dynamic,
	bottomWidth:Dynamic,
	bottomHeight:Dynamic,
	bottomColor:String,
	bottomReturnKey:String,
	bottomExtraKeyMode:Null<Int>
}

typedef ButtonsData =
{
	button:String, // what MobileButton should be used, must be a valid MobileButton var from MobilePad as a string.
	buttonIDs:Array<String>, // what MobileButton Button Iad should be used, If you're using a the library for PsychEngine 0.7 Versions, This is useful.
	buttonUniqueID:Dynamic, // the button's special ID for button
	graphic:String, // the graphic of the button, usually can be located in the MobilePad xml.
	x:Float, // the button's X position on screen.
	y:Float, // the button's Y position on screen.
	color:String, // the button color, default color is white.
	bg:String, // the button background for MobilePad, default background is `bg`.
	scale:Null<Float> // the button scale, default scale is 1.
}