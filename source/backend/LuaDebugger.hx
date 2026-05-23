package backend;

import haxe.CallStack;
import sys.io.File;
import sys.FileSystem;
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import openfl.Lib;

#if LUA_ALLOWED
import psychlua.FunkinLua;
#end

import cpp.RawPointer;

class LuaDebugger
{
    public static var enabled:Bool = true;
    public static var logToFile:Bool = true;
    public static var logPath:String = "";
    public static var verbose:Bool = true;

    static inline var RESET = "\x1b[0m";
    static inline var RED = "\x1b[31m";
    static inline var GREEN = "\x1b[32m";
    static inline var YELLOW = "\x1b[33m";
    static inline var BLUE = "\x1b[34m";
    static inline var MAGENTA = "\x1b[35m";
    static inline var CYAN = "\x1b[36m";

    static function getLogPath():String
    {
        if (logPath == "")
        {
            var date = Date.now();
            var dateStr = date.getFullYear() + "-" + (date.getMonth() + 1) + "-" + date.getDate() + "_" + date.getHours() + "-" + date.getMinutes() + "-" + date.getSeconds();
            logPath = "./debug/Lua/Lua-debug-" + dateStr + ".log";
        }
        return logPath;
    }

    public static function log(message:String, ?level:String = "INFO"):Void
    {
        if (!enabled) return;

        var timestamp = Date.now().toString();
        var logMessage = '[$timestamp] [$level] $message';

        var color = switch(level) {
            case "ERROR": RED;
            case "WARNING": YELLOW;
            case "SUCCESS": GREEN;
            case "LUA": MAGENTA;
            default: CYAN;
        }

        Sys.println(color + logMessage + RESET);

        if (logToFile)
        {
            try {
                var path = getLogPath();
                var file = sys.io.File.append(path, false);
                file.writeString(logMessage + "\n");
                file.close();
            } catch(e:Dynamic) {}
        }
    }

    public static function logLua(scriptPath:String, message:String, ?level:String = "LUA"):Void
    {
        log('[$scriptPath] $message', level);
    }

    public static function checkLuaFile(path:String):Bool
    {
        if (!FileSystem.exists(path))
        {
            log('Lua file not found: $path', "ERROR");
            return false;
        }

        var content = File.getContent(path);
        var lineCount = content.split("\n").length;
        log('Lua file found: $path ($lineCount lines)', "SUCCESS");
        return true;
    }

    #if LUA_ALLOWED
    public static function testLuaScript(scriptPath:String):Void
    {
        log('Testing Lua script: $scriptPath', "INFO");

        if (!checkLuaFile(scriptPath)) return;

        var content = File.getContent(scriptPath);

        var issues:Array<String> = [];

        if (content.indexOf("function onCreate") == -1)
            issues.push("Missing onCreate function");

        if (content.indexOf("function onUpdate") == -1 && content.indexOf("function onBeatHit") == -1)
            issues.push("No event handlers found (onUpdate/onBeatHit missing)");

        if (content.indexOf("print") == -1)
            issues.push("No print statements (add print() for debugging)");

        if (content.indexOf("trace") == -1)
            issues.push("No trace statements (add trace() for debugging)");

        if (issues.length > 0)
        {
            log('Issues found in $scriptPath:', "WARNING");
            for (issue in issues)
                log('  - $issue', "WARNING");
        }
        else
        {
            log('No issues found in $scriptPath', "SUCCESS");
        }

        try {
            var lua = new FunkinLua(scriptPath);
            log('Lua script compiled successfully: $scriptPath', "SUCCESS");
        } catch(e:Dynamic) {
            log('Lua compilation failed: $scriptPath - $e', "ERROR");
        }
    }
    #end

    public static function scanModsForLua():Void
    {
        log('Scanning mods for Lua scripts...', "INFO");

        var modsPath = "mods/";
        if (!FileSystem.exists(modsPath))
        {
            log('Mods folder not found', "WARNING");
            return;
        }

        var mods = FileSystem.readDirectory(modsPath);
        var foundScripts:Array<String> = [];

        for (mod in mods)
        {
            var scriptPath = modsPath + mod + "/scripts/";
            if (FileSystem.exists(scriptPath))
            {
                var scripts = FileSystem.readDirectory(scriptPath);
                for (script in scripts)
                {
                    if (script.endsWith(".lua"))
                    {
                        var fullPath = scriptPath + script;
                        foundScripts.push(fullPath);
                        log('Found Lua script: $fullPath', "SUCCESS");
                        #if LUA_ALLOWED
                        testLuaScript(fullPath);
                        #end
                    }
                }
            }
        }

        log('Total Lua scripts found: ' + foundScripts.length, "INFO");
    }

    public static function watchLuaCalls(scriptPath:String, functionName:String, args:Array<Dynamic>):Void
    {
        if (!enabled) return;

        var argsStr = "";
        if (args != null)
        {
            var strArgs = [];
            for (arg in args)
                strArgs.push(Std.string(arg));
            argsStr = strArgs.join(", ");
        }

        log('Calling $functionName($argsStr) in $scriptPath', "LUA");
    }

    public static function logError(error:Dynamic, stack:Array<StackItem>):Void
    {
        log('=== LUA ERROR ===', "ERROR");
        log('Error: $error', "ERROR");
        log('Stack trace:', "ERROR");

        for (item in stack)
        {
            log('  $item', "ERROR");
        }

        log('================', "ERROR");
    }

    public static function clearLog():Void
    {
        var path = getLogPath();
        if (FileSystem.exists(path))
            FileSystem.deleteFile(path);
        log('Log cleared: $path', "INFO");
    }

    public static function printLuaState(scriptPath:String):Void
    {
        log('=== LUA STATE: $scriptPath ===', "INFO");
        log('Checking script status...', "INFO");
        #if LUA_ALLOWED
        if (FileSystem.exists(scriptPath))
        {
            var content = File.getContent(scriptPath);
            var lines = content.split("\n");
            log('Lines: ' + lines.length, "INFO");

            log('First 10 lines:', "INFO");
            var maxLines = Std.int(Math.min(10, lines.length));
            for (i in 0...maxLines)
            {
                log('  ${i+1}: ${lines[i]}', "INFO");
            }
        }
        else
        {
            log('Script not found: $scriptPath', "ERROR");
        }
        #end
        log('==============================', "INFO");
    }

    public static function captureLuaPrint(luaState:Dynamic, scriptPath:String):Void
    {
        #if LUA_ALLOWED
        try
        {
            Lua.getglobal(luaState, "print");
            Lua.pop(luaState, 1);

            var callback = function(l:Dynamic):Int
            {
                var argCount = Lua.gettop(l);
                var args = [];
                for (i in 1...argCount + 1)
                {
                    var arg = Lua.tostring(l, i);
                    if (arg == null) arg = "nil";
                    args.push(arg);
                }
                var message = args.join("\t");
                logLua(scriptPath, message, "PRINT");
                return 0;
            };

            Lua.pushstring(luaState, "print");
            Lua.pushcfunction(luaState, cast callback);
            Lua.settable(luaState, -3);

            logLua(scriptPath, "Print capture installed", "SUCCESS");
        }
        catch(e:Dynamic)
        {
            logLua(scriptPath, 'Failed to capture print: $e', "ERROR");
        }
        #end
    }
}