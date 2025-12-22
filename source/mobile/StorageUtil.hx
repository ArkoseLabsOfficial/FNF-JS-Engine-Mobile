package mobile;

import lime.system.System as LimeSystem;
import haxe.io.Path;
import haxe.Exception;

import lime.system.System;
import lime.app.Application;
import openfl.Assets;
import haxe.io.Bytes;

/**
 * A simple storage class with lots of feature for mobile.
 * @author ArkoseLabs
 */
class StorageUtil
{
	#if sys
	// root directory, used for handling the saved storage type and path
	public static final rootDir:String = LimeSystem.applicationStorageDirectory;

	#if android
	public static inline function getCustomStoragePath():String
		return AndroidContext.getExternalFilesDir() + '/storageModes.txt';
	#end

	public static inline function getStorageDirectory():String
		return #if android haxe.io.Path.addTrailingSlash(AndroidContext.getExternalFilesDir()) #elseif ios lime.system.System.documentsDirectory #else Sys.getCwd() #end;

	#if android
	public static function getCustomStorageDirectories(?doNotSeperate:Bool):Array<String>
	{
		var curTextFile:String = getCustomStoragePath();
		var ArrayReturn:Array<String> = [];
		for (mode in CoolUtil.coolTextFile(curTextFile))
		{
			if(mode.trim().length < 1) continue;

			//turning the readle to original one (also, much easier to rewrite the code) -ArkoseLabs
			if (mode.contains('Name: ')) mode = mode.replace('Name: ', '');
			if (mode.contains(' Folder: ')) mode = mode.replace(' Folder: ', '|');
			//trace(mode);

			var dat = mode.split("|");
			if (doNotSeperate)
				ArrayReturn.push(mode); //get both as array
			else
				ArrayReturn.push(dat[0]); //get storage name as array
		}
		return ArrayReturn;
	}
	#end

	#if android
	// always force path due to haxe (This shit is dead for now)
	public static var currentExternalStorageDirectory:String;
	public static function initExternalStorageDirectory():String {
		var daPath:String = '';
		#if android
		if (!FileSystem.exists(rootDir + 'storagetype.txt'))
			File.saveContent(rootDir + 'storagetype.txt', ClientPrefs.storageType);

		var curStorageType:String = File.getContent(rootDir + 'storagetype.txt');

		/* Put this there because I don't want to override original paths, also brokes the normal storage system */
		for (line in getCustomStorageDirectories(true))
		{
			if (line.startsWith(curStorageType) && (line != '' || line != null)) {
				var dat = line.split("|");
				daPath = dat[1];
			}
		}

		/* Hardcoded Storage Types, these types cannot be changed by Custom Type */
		switch(curStorageType) {
			case 'EXTERNAL':
				daPath = AndroidEnvironment.getExternalStorageDirectory() + '/.' + lime.app.Application.current.meta.get('file');
			case 'EXTERNAL_OBB':
				daPath = AndroidContext.getObbDir();
			case 'EXTERNAL_MEDIA':
				daPath = AndroidEnvironment.getExternalStorageDirectory() + '/Android/media/' + lime.app.Application.current.meta.get('packageName');
			case 'EXTERNAL_DATA':
				daPath = AndroidContext.getExternalFilesDir();
			default:
				if (daPath == null || daPath == '') daPath = getExternalDirectory(curStorageType) + '/.' + lime.app.Application.current.meta.get('file');
		}
		daPath = Path.addTrailingSlash(daPath);
		currentExternalStorageDirectory = daPath;

		try
		{
			if (!FileSystem.exists(StorageUtil.getStorageDirectory()))
				FileSystem.createDirectory(StorageUtil.getStorageDirectory());
		}
		catch (e:Dynamic)
		{
			CoolUtil.showPopUp('Please create directory to\n${StorageUtil.getStorageDirectory()}\nPress OK to close the game', "Error!");
			lime.system.System.exit(1);
		}

		try
		{
			if (!FileSystem.exists(StorageUtil.getExternalStorageDirectory() + 'mods'))
				FileSystem.createDirectory(StorageUtil.getExternalStorageDirectory() + 'mods');
		}
		catch (e:Dynamic)
		{
			CoolUtil.showPopUp('Please create directory to\n${StorageUtil.getExternalStorageDirectory()}\nPress OK to close the game', "Error!");
			lime.system.System.exit(1);
		}
		#end
		return daPath;
	}
	public static function getExternalStorageDirectory():String
	{
		#if android
		return currentExternalStorageDirectory;
		#elseif ios
		return LimeSystem.documentsDirectory;
		#else
		return Sys.getCwd();
		#end
	}

	public static function requestPermissions():Void
	{
		if (AndroidVersion.SDK_INT >= AndroidVersionCode.TIRAMISU)
			AndroidPermissions.requestPermissions([
				'READ_MEDIA_IMAGES',
				'READ_MEDIA_VIDEO',
				'READ_MEDIA_AUDIO',
				'READ_MEDIA_VISUAL_USER_SELECTED'
			]);
		else
			AndroidPermissions.requestPermissions(['READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE']);

		if (!AndroidEnvironment.isExternalStorageManager())
			AndroidSettings.requestSetting('MANAGE_APP_ALL_FILES_ACCESS_PERMISSION');
	}

	public static var lastGettedPermission:Int;
	public static function chmodPermission(fullPath:String):Int {
		var process = new Process('stat -c %a ${fullPath}');
		var stringOutput:String = process.stdout.readAll().toString();
		process.close();
		lastGettedPermission = Std.parseInt(stringOutput);
		return lastGettedPermission;
	}

	public static function chmod(permissions:Int, fullPath:String) {
		var process = new Process('chmod -R ${permissions} ${fullPath}');

		var exitCode = process.exitCode();
		if (exitCode == 0)
			trace('Başarılı: ${fullPath} dosyasının izinleri (${permissions}) olarak ayarlandı');
		else
		{
			var errorOutput = process.stderr.readAll().toString();
			trace('HATA: (${fullPath}) dosyası için istenen izin değiştirme isteği başarısız. Çıkış Kodu: ${exitCode}, Hata: ${errorOutput}');
		}
		process.close();
	}

	public static function checkExternalPaths(?splitStorage = false):Array<String>
	{
		var process = new Process('grep -o "/storage/....-...." /proc/mounts | paste -sd \',\'');
		var paths:String = process.stdout.readAll().toString();
		trace(paths);
		if (splitStorage)
			paths = paths.replace('/storage/', '');
		trace(paths);
		return paths.split(',');
	}

	public static function getExternalDirectory(externalDir:String):String
	{
		var daPath:String = '';
		for (path in checkExternalPaths())
			if (path.contains(externalDir))
				daPath = path;

		daPath = haxe.io.Path.addTrailingSlash(daPath.endsWith("\n") ? daPath.substr(0, daPath.length - 1) : daPath);
		return daPath;
	}
	#end

	public static function saveContent(fileName:String, fileData:String, ?alert:Bool = true):Void
	{
		final folder:String = #if android StorageUtil.getExternalStorageDirectory() + #else Sys.getCwd() + #end 'saves/';
		try
		{
			if (!FileSystem.exists(folder))
				FileSystem.createDirectory(folder);

			File.saveContent('$folder/$fileName', fileData);
			if (alert)
				CoolUtil.showPopUp('${fileName} has been saved.', "Success!");
		}
		catch (e:Dynamic)
			if (alert)
				CoolUtil.showPopUp('${fileName} couldn\'t be saved.\n${e.message}', "Error!");
			else
				trace('$fileName couldn\'t be saved. (${e.message})');
	}
	#end

	public static function copySpesificFileFromAssets(filePathInAssets:String, copyTo:String, ?changeable:Bool)
	{
		try {
			if (Assets.exists(filePathInAssets)) {
				var fileData:Bytes = Assets.getBytes(filePathInAssets);
				if (fileData != null) {
					if (FileSystem.exists(copyTo) && changeable) {
						var existingFileData:Bytes = File.getBytes(filePathInAssets);
						if (existingFileData != fileData && existingFileData != null)
							File.saveBytes(copyTo, fileData);
					}
					else if (!FileSystem.exists(copyTo))
						File.saveBytes(copyTo, fileData);

					trace('Copied: $filePathInAssets -> $copyTo');
				} else {
					var textData = Assets.getText(filePathInAssets);
					if (textData != null) {
						if (FileSystem.exists(copyTo) && changeable) {
							var existingTxtData = File.getContent(filePathInAssets);
							if (existingTxtData != textData && existingTxtData != null)
								File.saveContent(copyTo, textData);
						}
						else if (!FileSystem.exists(copyTo))
							File.saveContent(copyTo, textData);
						trace('Copied (text): $filePathInAssets -> $copyTo');
					}
				}
			}
		} catch (e:Dynamic) {
			trace('Error copying file $filePathInAssets: $e');
		}
	}
}