package mobile.options;

import flixel.input.keyboard.FlxKey;
import options.BaseOptionsMenu;
import options.Option;

class MobileOptionsSubState extends BaseOptionsMenu {
	#if android
	var storageTypes:Array<String> = ["EXTERNAL_DATA", "EXTERNAL_OBB", "EXTERNAL_MEDIA", "EXTERNAL"];
	var externalPaths:Array<String> = StorageUtil.checkExternalPaths(true);
	var customPaths:Array<String> = StorageUtil.getCustomStorageDirectories(false);
	final lastStorageType:String = ClientPrefs.storageType;
	#end

	var option:Option;
	var HitboxTypes:Array<String>;
	public function new() {
		title = 'Mobile Options';
		rpcTitle = 'Mobile Options Menu'; // for Discord Rich Presence, fuck it
		#if android
		storageTypes = storageTypes.concat(customPaths); //Get Custom Paths From File
		storageTypes = storageTypes.concat(externalPaths); //Get SD Card Path
		#end

		HitboxTypes = mergeAllTextsNamed('mobile/Hitbox/HitboxModes/hitboxModeList.txt');

		option = new Option('MobilePad Opacity',
			'Selects the opacity for the mobile buttons (careful not to put it at 0 and lose track of your buttons).',
			'mobilePadAlpha',
			'percent',
			0.6
		);
		option.scrollSpeed = 1;
		option.minValue = 0.001;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		option.onChange = () -> {
			mobileManager.mobilePad.alpha = curOption.getValue();
		};
		addOption(option);

		var option:Option = new Option('Extra Controls',
			'Allow Extra Controls',
			'extraKeys',
			'int',
			2);
		option.scrollSpeed = 1;
		option.minValue = 0;
		option.maxValue = 4;
		option.changeValue = 1;
		option.decimals = 0;
		addOption(option);

		option = new Option('Extra Control Location',
			'Choose Extra Control Location',
			'hitboxLocation',
			'string',
			'Bottom',
			['Bottom', 'Top', 'Middle']
		);
		addOption(option);
		
		//HitboxTypes.insert(0, "Classic");
		option = new Option('Hitbox Mode',
			'Choose your Hitbox Style!',
			'hitboxmode',
			'string',
			'Normal (New)',
			HitboxTypes
		);
		addOption(option);
		
		option = new Option('Hitbox Design',
			'Choose how your hitbox should look like.',
			'hitboxtype',
			'string',
			'Gradient',
			['Gradient', 'No Gradient' , 'No Gradient (Old)']
		);
		addOption(option);

		option = new Option('Hitbox Hint',
			'Hitbox Hint',
			'hitboxhint',
			'bool',
			false);
		addOption(option);

		option = new Option('Hitbox Opacity',
			'Selects the opacity for the hitbox buttons.',
			'hitboxalpha',
			'percent',
			0.7
		);
		option.scrollSpeed = 1;
		option.minValue = 0.001;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		#if mobile
		option = new Option('Wide Screen Mode',
			'If checked, The game will stetch to fill your whole screen. (WARNING: Can result in bad visuals & break some mods that resizes the game/cameras)',
			'wideScreen',
			'bool',
			false);
		option.onChange = () -> ScreenUtil.wideScreen.enabled = ClientPrefs.wideScreen;
		addOption(option);
		#end

		#if android
		option = new Option('Storage Type',
			'Which folder Psych Online should use?',
			'storageType',
			'string',
			'EXTERNAL_DATA',
			storageTypes
		);
		addOption(option);
		#end
		super();
	}

	override public function destroy() {
		super.destroy();

		#if android
		if (ClientPrefs.storageType != lastStorageType) {
			File.saveContent(lime.system.System.applicationStorageDirectory + 'storagetype.txt', ClientPrefs.storageType);
			ClientPrefs.saveSettings();
			StorageUtil.initExternalStorageDirectory();
		}
		#end
	}

	inline public static function mergeAllTextsNamed(path:String, ?defaultDirectory:String = null, allowDuplicates:Bool = false)
	{
		if(defaultDirectory == null) defaultDirectory = Paths.getPreloadPath();
		defaultDirectory = defaultDirectory.trim();
		if(!defaultDirectory.endsWith('/')) defaultDirectory += '/';
		if(!defaultDirectory.startsWith('assets/')) defaultDirectory = 'assets/$defaultDirectory';
		var mergedList:Array<String> = [];
		var paths:Array<String> = directoriesWithFile(defaultDirectory, path);
		var defaultPath:String = defaultDirectory + path;
		if(paths.contains(defaultPath))
		{
			paths.remove(defaultPath);
			paths.insert(0, defaultPath);
		}
		for (file in paths)
		{
			var list:Array<String> = CoolUtil.coolTextFile(file);
			for (value in list)
				if((allowDuplicates || !mergedList.contains(value)) && value.length > 0)
					mergedList.push(value);
		}
		return mergedList;
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
}