package backend;

import haxe.CallStack;
import sys.io.File;
import sys.FileSystem;
import crowplexus.iris.Iris;
import crowplexus.iris.IrisConfig;
import psychlua.HScript;

class HaxeDebugger
{
    public static var enabled:Bool = true;
    public static var logToFile:Bool = true;
    public static var logPath:String = "";

    static inline var RESET = "\x1b[0m";
    static inline var RED = "\x1b[31m";
    static inline var GREEN = "\x1b[32m";
    static inline var YELLOW = "\x1b[33m";
    static inline var MAGENTA = "\x1b[35m";
    static inline var CYAN = "\x1b[36m";

    static function getLogPath():String
    {
        if (logPath == "")
        {
            var date = Date.now();
            var dateStr = date.getFullYear() + "-" + (date.getMonth() + 1) + "-" + date.getDate() + "_" + date.getHours() + "-" + date.getMinutes() + "-" + date.getSeconds();
            logPath = "./debug/Haxe/Haxe-debug-" + dateStr + ".log";
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
            case "HSCRIPT": MAGENTA;
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

    public static function logScript(scriptPath:String, message:String, ?level:String = "HSCRIPT"):Void
    {
        log('[$scriptPath] $message', level);
    }

    public static function checkHxFile(path:String):Bool
    {
        if (!FileSystem.exists(path))
        {
            log('Haxe script not found: $path', "ERROR");
            return false;
        }

        var content = File.getContent(path);
        var lineCount = content.split("\n").length;
        log('Haxe script found: $path ($lineCount lines)', "SUCCESS");
        return true;
    }

    public static function testHxScript(scriptPath:String):Void
    {
        log('Testing Haxe script: $scriptPath', "INFO");

        if (!checkHxFile(scriptPath)) return;

        var content = File.getContent(scriptPath);

        var issues:Array<String> = [];

        if (content.indexOf("function") == -1)
            issues.push("No functions found");

        if (content.indexOf("trace") == -1 && content.indexOf("log") == -1)
            issues.push("No trace/log statements");

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
            var config:IrisConfig = cast {
                name: scriptPath,
                autoRun: false,
                autoPreset: true
            };

            var content = File.getContent(scriptPath);
            var iris = new Iris(content, config);
            iris.execute();
            log('Haxe script initialized successfully: $scriptPath', "SUCCESS");
        } catch(e:Dynamic) {
            log('Haxe script initialization failed: $scriptPath - $e', "ERROR");
        }
    }

    public static function executeHxScript(scriptPath:String, ?functionName:String = null, ?args:Array<Dynamic> = null):Dynamic
    {
        log('Executing Haxe script: $scriptPath', "INFO");

        if (!checkHxFile(scriptPath)) return null;

        try {
            var config:IrisConfig = cast {
                name: scriptPath,
                autoRun: true,
                autoPreset: true
            };

            var content = File.getContent(scriptPath);
            var iris = new Iris(content, config);

            if (functionName != null)
            {
                log('Calling function: $functionName', "SUCCESS");
                var result = iris.call(functionName, args != null ? args : []);
                log('Function returned: $result', "INFO");
                return result;
            }

            log('Script executed successfully', "SUCCESS");
            return true;

        } catch(e:Dynamic) {
            log('Script execution failed: $e', "ERROR");
            return null;
        }
    }

    public static function scanModsForHx():Void
    {
        log('Scanning mods for Haxe scripts...', "INFO");

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
            if (mod.indexOf(".") != -1) continue;

            var scriptPath = modsPath + mod + "/scripts/";
            if (FileSystem.exists(scriptPath))
            {
                var scripts = FileSystem.readDirectory(scriptPath);
                for (script in scripts)
                {
                    if (script.endsWith(".hx"))
                    {
                        var fullPath = scriptPath + script;
                        foundScripts.push(fullPath);
                        log('Found Haxe script: $fullPath', "SUCCESS");
                        testHxScript(fullPath);
                    }
                }
            }
        }

        log('Total Haxe scripts found: ' + foundScripts.length, "INFO");
    }

    public static function logError(error:Dynamic, stack:Array<StackItem>):Void
    {
        log('=== HAXE SCRIPT ERROR ===', "ERROR");
        log('Error: $error', "ERROR");
        log('Stack trace:', "ERROR");

        for (item in stack)
        {
            log('  $item', "ERROR");
        }

        log('=========================', "ERROR");
    }

    public static function clearLog():Void
    {
        var path = getLogPath();
        if (FileSystem.exists(path))
            FileSystem.deleteFile(path);
        log('Log cleared: $path', "INFO");
    }

    public static function printScriptState(scriptPath:String):Void
    {
        log('=== HAXE SCRIPT STATE: $scriptPath ===', "INFO");

        if (FileSystem.exists(scriptPath))
        {
            var content = File.getContent(scriptPath);
            var lines = content.split("\n");
            log('Lines: ' + lines.length, "INFO");

            log('First 15 lines:', "INFO");
            var maxLines = Std.int(Math.min(15, lines.length));
            for (i in 0...maxLines)
            {
                log('  ${i+1}: ${lines[i]}', "INFO");
            }
        }
        else
        {
            log('Script not found: $scriptPath', "ERROR");
        }

        log('======================================', "INFO");
    }

    public static function captureHScriptTrace(script:HScript, scriptPath:String):Void
    {
        #if HSCRIPT_ALLOWED
        try
        {
            script.set("trace", function(v:Dynamic) {
                logScript(scriptPath, Std.string(v), "TRACE");
                Sys.println(v);
                return null;
            });

            logScript(scriptPath, "Trace capture installed", "SUCCESS");
        }
        catch(e:Dynamic)
        {
            logScript(scriptPath, 'Failed to capture trace: $e', "ERROR");
        }
        #end
    }
}