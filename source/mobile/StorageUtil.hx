package mobile;

import lime.system.System as LimeSystem;
import lime.utils.Assets as LimeAssets;
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

			//turning the read able to original one (also, much easier to rewrite the code) -ArkoseLabs
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

	/**
	 * Dynamically searches all loaded Lime libraries to find the correct prefix for an asset.
	 */
	public static function getFile(file:String):String {
		if (Assets.exists(file))
			return file;

		@:privateAccess
		for (library in LimeAssets.libraries.keys()) {
			if (Assets.exists('$library:$file') && library != 'default')
				return '$library:$file';
		}

		return file;
	}

	/**
	 * Copies a specific file, automatically resolving its library prefix if needed.
	 */
	public static function copySpesificFileFromAssets(filePathInAssets:String, copyTo:String, ?changeable:Bool) {
		var actualPath = getFile(filePathInAssets);

		try {
			if (Assets.exists(actualPath)) {
				var fileData:Bytes = Assets.getBytes(actualPath);
				if (fileData != null) {
					if (FileSystem.exists(copyTo) && changeable) {
						var existingFileData:Bytes = File.getBytes(copyTo);
						if (existingFileData != fileData && existingFileData != null)
							File.saveBytes(copyTo, fileData);
					}
					else if (!FileSystem.exists(copyTo))
						File.saveBytes(copyTo, fileData);

					trace('Copied: $actualPath -> $copyTo');
				} else {
					var textData = Assets.getText(actualPath);
					if (textData != null) {
						if (FileSystem.exists(copyTo) && changeable) {
							var existingTxtData = File.getContent(copyTo);
							if (existingTxtData != textData && existingTxtData != null)
								File.saveContent(copyTo, textData);
						}
						else if (!FileSystem.exists(copyTo))
							File.saveContent(copyTo, textData);
						trace('Copied (text): $actualPath -> $copyTo');
					}
				}
			} else {
				trace('Warning: File not found in assets - $filePathInAssets');
			}
		} catch (e:Dynamic) {
			trace('Error copying file $actualPath: $e');
		}
	}

	/**
	 * Copies recursively the assets folder from the APK to external directory
	 * @param sourcePath Path to the assets folder inside APK (usually "assets/")
	 * @param targetPath Destination path (optional, uses Sys.getCwd() + "assets/" if not specified)
	 * @param library Optional library name to specifically filter assets
	 */
	public static function copyAssetsFromAPK(sourcePath:String = "assets/", targetPath:String = null, library:String = null):Void {
		#if mobile
		if (targetPath == null)
			targetPath = Sys.getCwd() + "assets/";

		try {
			if (!FileSystem.exists(targetPath))
				FileSystem.createDirectory(targetPath);

			copyAssetsRecursively(sourcePath, targetPath, library);

			trace('Assets successfully copied to: $targetPath');
		} catch (e:Dynamic) {
			trace('Error copying assets: $e');
			Application.current.window.alert('Error!','Error copying game files. Check storage permissions or re-open the game to see what happens.');
		}
		#end
	}

	/**
	 * Helper function to copy assets recursively
	 */
	private static function copyAssetsRecursively(sourcePath:String, targetPath:String, libraryFilter:String = null):Void {
		#if mobile
		try {
			var cleanSourcePath = sourcePath;
			if (StringTools.endsWith(cleanSourcePath, "/"))
				cleanSourcePath = cleanSourcePath.substring(0, cleanSourcePath.length - 1);

			var assetList:Array<String> = Assets.list();

			for (assetPath in assetList) {
				var cleanAssetPath = assetPath;
				var libraryPrefix = "";

				var colonIndex = assetPath.indexOf(":");
				if (colonIndex != -1) {
					libraryPrefix = assetPath.substring(0, colonIndex);
					cleanAssetPath = assetPath.substring(colonIndex + 1);
				}

				if (libraryFilter != null && libraryFilter != "" && libraryPrefix != libraryFilter) {
					continue;
				}

				if (StringTools.startsWith(cleanAssetPath, cleanSourcePath)) {
					var relativePath = cleanAssetPath;

					if (StringTools.startsWith(relativePath, "assets/"))
						relativePath = relativePath.substring(7);

					if (relativePath == "") continue;

					var fullTargetPath = targetPath + relativePath;

					var targetDir = haxe.io.Path.directory(fullTargetPath);
					if (targetDir != "" && !FileSystem.exists(targetDir))
						createDirectoryRecursive(targetDir);

					try {
						if (Assets.exists(assetPath)) {
							var fileData:Bytes = Assets.getBytes(assetPath);
							if (fileData != null) {
								File.saveBytes(fullTargetPath, fileData);
								trace('Copied: $assetPath -> $fullTargetPath');
							} else {
								var textData = Assets.getText(assetPath);
								if (textData != null) {
									File.saveContent(fullTargetPath, textData);
									trace('Copied (text): $assetPath -> $fullTargetPath');
								}
							}
						}
					} catch (e:Dynamic) {
						trace('Error copying file $assetPath: $e');
					}
				}
			}
		} catch (e:Dynamic) {
			trace('Error in recursive copy: $e');
			throw e;
		}
		#end
	}

	/**
	 * Creates directories recursively
	 */
	private static function createDirectoryRecursive(path:String):Void {
		#if mobile
		if (FileSystem.exists(path)) return;

		var pathParts = path.split("/");
		var currentPath = "";

		for (part in pathParts) {
			if (part == "") continue;
			currentPath += "/" + part;

			if (!FileSystem.exists(currentPath)) {
				try {
					FileSystem.createDirectory(currentPath);
				} catch (e:Dynamic) {
					trace('Error creating directory $currentPath: $e');
				}
			}
		}
		#end
	}

	/**
	 * Copies assets with progress (advanced version)
	 * @param sourcePath Path to assets folder inside APK
	 * @param targetPath Destination path
	 * @param library Optional library name to filter assets
	 * @param onProgress Optional callback for progress (current file, current count, total files)
	 * @param onComplete Optional callback when finished
	 */
	public static function copyAssetsWithProgress(sourcePath:String = "assets/", targetPath:String = null, library:String = null,
													onProgress:String->Int->Int->Void = null, onComplete:Void->Void = null):Void {
		#if mobile
		if (targetPath == null) {
			targetPath = Sys.getCwd() + "assets/";
		}

		try {
			if (!FileSystem.exists(targetPath)) {
				FileSystem.createDirectory(targetPath);
			}

			var totalFiles = countAssetsFiles(sourcePath, library);
			var currentFile = 0;

			trace('Starting copy of $totalFiles files...');

			var cleanSourcePath = sourcePath;
			if (StringTools.endsWith(cleanSourcePath, "/")) {
				cleanSourcePath = cleanSourcePath.substring(0, cleanSourcePath.length - 1);
			}

			var assetList:Array<String> = Assets.list();

			for (assetPath in assetList) {
				var cleanAssetPath = assetPath;
				var libraryPrefix = "";

				var colonIndex = assetPath.indexOf(":");
				if (colonIndex != -1) {
					libraryPrefix = assetPath.substring(0, colonIndex);
					cleanAssetPath = assetPath.substring(colonIndex + 1);
				}

				if (library != null && library != "" && libraryPrefix != library) {
					continue;
				}

				if (StringTools.startsWith(cleanAssetPath, cleanSourcePath)) {
					var relativePath = cleanAssetPath;

					if (StringTools.startsWith(relativePath, "assets/")) {
						relativePath = relativePath.substring(7);
					}

					if (relativePath == "") continue;

					var fullTargetPath = targetPath + relativePath;

					var targetDir = haxe.io.Path.directory(fullTargetPath);
					if (targetDir != "" && !FileSystem.exists(targetDir)) {
						createDirectoryRecursive(targetDir);
					}

					try {
						if (Assets.exists(assetPath)) {
							var fileData:Bytes = Assets.getBytes(assetPath);
							if (fileData != null) {
								File.saveBytes(fullTargetPath, fileData);
							} else {
								var textData = Assets.getText(assetPath);
								if (textData != null) {
									File.saveContent(fullTargetPath, textData);
								}
							}

							currentFile++;

							if (onProgress != null) {
								onProgress(relativePath, currentFile, totalFiles);
							}

							trace('[$currentFile/$totalFiles] Copied: $relativePath');
						}

					} catch (e:Dynamic) {
						trace('Error copying $assetPath: $e');
					}
				}
			}
			trace('Copy completed! $currentFile files copied.');
			if (onComplete != null) {
				onComplete();
			}
		} catch (e:Dynamic) {
			trace('Error copying assets: $e');
			Application.current.window.alert('Error', 'Error copying game files. Check storage permissions or re-open the game to see what happens.');
		}
		#end
	}

	/**
	 * Counts total number of asset files for progress
	 */
	inline private static function countAssetsFiles(sourcePath:String, library:String = null):Int {
		#if mobile
		var count = 0;
		var cleanSourcePath = sourcePath;
		if (StringTools.endsWith(cleanSourcePath, "/"))
			cleanSourcePath = cleanSourcePath.substring(0, cleanSourcePath.length - 1);
		
		var assetList:Array<String> = Assets.list();

		for (assetPath in assetList) {
			var cleanAssetPath = assetPath;
			var libraryPrefix = "";

			var colonIndex = assetPath.indexOf(":");
			if (colonIndex != -1) {
				libraryPrefix = assetPath.substring(0, colonIndex);
				cleanAssetPath = assetPath.substring(colonIndex + 1);
			}

			if (library != null && library != "" && libraryPrefix != library) {
				continue;
			}

			if (StringTools.startsWith(cleanAssetPath, cleanSourcePath)) {
				var relativePath = cleanAssetPath;

				if (StringTools.startsWith(relativePath, "assets/"))
					relativePath = relativePath.substring(7);

				if (relativePath != "")
					count++;
			}
		}

		return count;
		#else
		return 0;
		#end
	}

	/**
	 * Checks if assets have already been copied
	 */
	inline public static function areAssetsCopied(sourcePath:String = "assets/", targetPath:String = null, library:String = null):Bool {
		#if mobile
		if (targetPath == null)
			targetPath = Sys.getCwd() + "assets/";

		if (!FileSystem.exists(targetPath))
			return false;

		var sourceCount = countAssetsFiles(sourcePath, library);
		var targetCount = countFilesInDirectory(targetPath);

		// Note: targetCount counts ALL files in targetPath. Make sure targetPath points
		// specifically to where this library's assets were dumped if comparing counts directly.
		return sourceCount > 0 && sourceCount == targetCount;
		#else
		return false;
		#end
	}

	/**
	 * Counts files in a directory recursively
	 */
	inline private static function countFilesInDirectory(path:String):Int {
		#if mobile
		if (!FileSystem.exists(path)) return 0;

		var count = 0;
		var items = FileSystem.readDirectory(path);

		for (item in items) {
			var fullPath = path + "/" + item;
			if (FileSystem.isDirectory(fullPath))
				count += countFilesInDirectory(fullPath);
			else
				count++;
		}

		return count;
		#else
		return 0;
		#end
	}
}