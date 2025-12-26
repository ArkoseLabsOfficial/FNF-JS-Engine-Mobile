#if !macro
import Paths;

#if sys
import sys.*;
import sys.io.*;
#end

#if LUA_ALLOWED
import hxluajit.*;
import hxluajit.Types;
import psychlua.*;
#else
import psychlua.FunkinLua; // TODO: test and seperate this into LuaUtils
// import psychlua.LuaUtils;
import psychlua.HScript;
// import psychlua.ScriptHandler;
#end

#if flxanimate
import flxanimate.*;
import flxanimate.PsychFlxAnimate as FlxAnimate;
#end

//so that it doesn't bring up a "Type not found: Countdown"
import BaseStage.Countdown;

//Flixel
import flixel.sound.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxDestroyUtil;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxObject;
import flixel.util.FlxSave;
import flixel.util.FlxStringUtil;

//others
import openfl.display.BitmapData;
import openfl.net.FileFilter;
import openfl.geom.Rectangle;
import openfl.utils.Assets as OpenFlAssets;
import lime.utils.Assets;
import haxe.Json;

#if MOBILE_CONTROLS_ALLOWED
import mobile.*;
#end
#if mobile
import mobile.psychlua.Functions;
#end
#if android
import android.callback.CallBack as AndroidCallBack;
import android.content.Context as AndroidContext;
import android.widget.Toast as AndroidToast;
import android.os.Environment as AndroidEnvironment;
import android.Permissions as AndroidPermissions;
import android.Settings as AndroidSettings;
import android.Tools as AndroidTools;
import android.os.Build.VERSION as AndroidVersion;
import android.os.Build.VERSION_CODES as AndroidVersionCode;
#end

// utils
import utils.*;

using StringTools;
#end
