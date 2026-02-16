package zsscript;

import haxe.Json;
import haxe.ds.StringMap;

typedef Pattern = {
    zs:String,
    lua:String,
    description:String,
    category:String
}

class ZSPatterns {
    public static var patterns:Array<Pattern> = [
        // ===== PROPERTY OPERATIONS =====
        {
            zs: "setProperty: <{0}> = {1}",
            lua: "setProperty(\"{0}\", {1})",
            description: "Set any property",
            category: "properties"
        },
        {
            zs: "getProperty(<{0}>)",
            lua: "getProperty(\"{0}\")",
            description: "Get any property",
            category: "properties"
        },
        {
            zs: "set <{0}> to {1}",
            lua: "setProperty(\"{0}\", {1})",
            description: "Short form set property",
            category: "properties"
        },
        
        // ===== GROUP OPERATIONS =====
        {
            zs: "setPropertyFromGroup: {0}, {1}, <{2}> = {3}",
            lua: "setPropertyFromGroup({0}, {1}, \"{2}\", {3})",
            description: "Set property on group member",
            category: "groups"
        },
        {
            zs: "getPropertyFromGroup({0}, {1}, <{2}>)",
            lua: "getPropertyFromGroup({0}, {1}, \"{2}\")",
            description: "Get property from group member",
            category: "groups"
        },
        {
            zs: "add <{0}> to group <{1}>",
            lua: "addToGroup(\"{1}\", \"{0}\")",
            description: "Add object to group",
            category: "groups"
        },
        {
            zs: "remove <{0}> from group <{1}>",
            lua: "removeFromGroup(\"{1}\", \"{0}\")",
            description: "Remove object from group",
            category: "groups"
        },
        
        // ===== SHADER OPERATIONS =====
        {
            zs: "register shader: <{0}>",
            lua: "initLuaShader(\"{0}\")",
            description: "Register a new shader",
            category: "shaders"
        },
        {
            zs: "set <{0}> to shader <{1}>",
            lua: "setSpriteShader(\"{0}\", \"{1}\")",
            description: "Apply shader to sprite",
            category: "shaders"
        },
        {
            zs: "set Shader({3}): <{0}>(<{1}>) = {2}",
            lua: "setShader{3}(\"{0}\", \"{1}\", {2})",
            description: "Set shader uniform",
            category: "shaders"
        },
        
        // ===== ANIMATION OPERATIONS =====
        {
            zs: "play animation: <{0}>, {1}, {2}, {3}",
            lua: "playAnim(\"{0}\", {1}, {2}, {3})",
            description: "Play animation on character",
            category: "animations"
        },
        {
            zs: "add animation: <{0}>, {1}, {2}, {3}, {4}",
            lua: "addAnimation(\"{0}\", {1}, {2}, {3}, {4})",
            description: "Add animation to character",
            category: "animations"
        },
        {
            zs: "add animation by prefix: <{0}>, {1}, {2}, {3}, {4}",
            lua: "addAnimationByPrefix(\"{0}\", {1}, {2}, {3}, {4})",
            description: "Add animation by prefix",
            category: "animations"
        },
        {
            zs: "set <{0}> animation to {1}",
            lua: "setProperty(\"{0}.animation.curAnim.name\", {1})",
            description: "Set current animation",
            category: "animations"
        },
        
        // ===== CAMERA OPERATIONS =====
        {
            zs: "set camera follow: <{0}>, {1}",
            lua: "setCameraFollow(\"{0}\", {1})",
            description: "Set camera follow target",
            category: "camera"
        },
        {
            zs: "set camera zoom: {0}, {1}",
            lua: "setCameraZoom({0}, {1})",
            description: "Set camera zoom",
            category: "camera"
        },
        {
            zs: "set camera focus: <{0}>",
            lua: "setCameraFocus(\"{0}\")",
            description: "Focus camera on object",
            category: "camera"
        },
        {
            zs: "shake camera: {0}, {1}",
            lua: "cameraShake({0}, {1})",
            description: "Shake the camera",
            category: "camera"
        },
        
        // ===== CHARACTER OPERATIONS =====
        {
            zs: "set character <{0}> to {1}",
            lua: "setCharacter(\"{0}\", {1})",
            description: "Change character",
            category: "characters"
        },
        {
            zs: "set <{0}> health to {1}",
            lua: "setProperty(\"{0}.health\", {1})",
            description: "Set character health",
            category: "characters"
        },
        {
            zs: "set <{0}> position: x={1}, y={2}",
            lua: "setProperty(\"{0}.x\", {1}); setProperty(\"{0}.y\", {2})",
            description: "Set character position",
            category: "characters"
        },
        
        // ===== SOUND OPERATIONS =====
        {
            zs: "play sound: {0}, {1}",
            lua: "playSound({0}, {1})",
            description: "Play a sound",
            category: "sounds"
        },
        {
            zs: "play music: {0}, {1}",
            lua: "playMusic({0}, {1})",
            description: "Play background music",
            category: "sounds"
        },
        {
            zs: "stop sound: {0}",
            lua: "stopSound({0})",
            description: "Stop a sound",
            category: "sounds"
        },
        
        // ===== EVENT OPERATIONS =====
        {
            zs: "trigger event: {0}, {1}, {2}",
            lua: "triggerEvent({0}, {1}, {2})",
            description: "Trigger an event",
            category: "events"
        },
        {
            zs: "call function: {0}({1})",
            lua: "{0}({1})",
            description: "Call a custom function",
            category: "events"
        },
        
        // ===== VISUAL OPERATIONS =====
        {
            zs: "set <{0}> color to {1}",
            lua: "setProperty(\"{0}.color\", {1})",
            description: "Set object color",
            category: "visuals"
        },
        {
            zs: "set <{0}> alpha to {1}",
            lua: "setProperty(\"{0}.alpha\", {1})",
            description: "Set transparency",
            category: "visuals"
        },
        {
            zs: "set <{0}> scale to x={1}, y={2}",
            lua: "setProperty(\"{0}.scale.x\", {1}); setProperty(\"{0}.scale.y\", {2})",
            description: "Set object scale",
            category: "visuals"
        },
        {
            zs: "set <{0}> visible to {1}",
            lua: "setProperty(\"{0}.visible\", {1})",
            description: "Show/hide object",
            category: "visuals"
        },
        
        // ===== TWEEN OPERATIONS =====
        {
            zs: "tween <{0}> to {1} over {2} with {3}",
            lua: "doTween(\"{0}\", \"{0}\", {1}, {2}, {3})",
            description: "Tween object property",
            category: "tweens"
        },
        {
            zs: "tween color of <{0}> to {1} over {2}",
            lua: "doTweenColor(\"{0}\", \"{0}\", {1}, {2})",
            description: "Tween color",
            category: "tweens"
        },
        {
            zs: "tween alpha of <{0}> to {1} over {2}",
            lua: "doTweenAlpha(\"{0}\", \"{0}\", {1}, {2})",
            description: "Tween transparency",
            category: "tweens"
        },
        
        // ===== NOTE OPERATIONS =====
        {
            zs: "set note {0} to {1}",
            lua: "setPropertyFromGroup(\"notes\", {0}, {1})",
            description: "Set note property",
            category: "notes"
        },
        {
            zs: "get note {0} {1}",
            lua: "getPropertyFromGroup(\"notes\", {0}, {1})",
            description: "Get note property",
            category: "notes"
        },
        {
            zs: "set all notes to {0}",
            lua: "setProperty(\"notes.{0}\", {1})",
            description: "Set property on all notes",
            category: "notes"
        },

        // ===== CONTROL STRUCTURES =====
        {
            zs: "if {0} then",
            lua: "if {0} then",
            description: "If statement",
            category: "control"
        },
        {
            zs: "else if {0} then",
            lua: "elseif {0} then", 
            description: "Else if statement",
            category: "control"
        },
        {
            zs: "else:",
            lua: "else",
            description: "Else statement",
            category: "control"
        },
        {
            zs: "for {0} = {1}, {2} do",
            lua: "for {0} = {1}, {2} do",
            description: "Numeric for loop",
            category: "control"
        },
        {
            zs: "for {0} in {1} do",
            lua: "for {0} in {1} do", 
            description: "Generic for loop",
            category: "control"
        },
        {
            zs: "for {0} = {1}, {2}, {3} do",
            lua: "for {0} = {1}, {2}, {3} do",
            description: "Numeric for loop with step",
            category: "control"
        },
        {
            zs: "for <{0}> = {1}, {2} do",
            lua: "for {0} = {1}, {2} do",
            description: "Numeric for loop with noun symbol",
            category: "control"
        },
        {
            zs: "for <{0}> = {1}, {2}, {3} do",
            lua: "for {0} = {1}, {2}, {3} do",
            description: "Numeric for loop with step and noun symbol",
            category: "control"
        },
        {
            zs: "for <{0}> in {1} do",
            lua: "for {0} in {1} do",
            description: "Generic for loop with noun symbol",
            category: "control"
        },
        {
            zs: "while {0} do",
            lua: "while {0} do",
            description: "While loop",
            category: "control"
        },
        {
            zs: "repeat",
            lua: "repeat",
            description: "Repeat start",
            category: "control"
        },
        {
            zs: "until {0}",
            lua: "until {0}",
            description: "Repeat condition",
            category: "control"
        },
        {
            zs: "break",
            lua: "break",
            description: "Break loop",
            category: "control"
        },
        {
            zs: "continue",
            lua: "continue",
            description: "Continue loop", 
            category: "control"
        },
        {
            zs: "return {0}",
            lua: "return {0}",
            description: "Return value",
            category: "control"
        },
        {
            zs: "return",
            lua: "return",
            description: "Return",
            category: "control"
        }
    ];

    public static function matchPattern(line:String):Null<{pattern:Pattern, args:Array<String>}> {
        for (pattern in patterns) {
            var args = extractArgs(pattern.zs, line);
            if (args != null) {
                return {pattern: pattern, args: args};
            }
        }
        return null;
    }

    static function extractArgs(pattern:String, line:String):Null<Array<String>> {
        var regexStr = pattern.split("{0}").join("(.*?)");
        regexStr = regexStr.split("{1}").join("(.*?)");
        regexStr = regexStr.split("{2}").join("(.*?)");
        regexStr = regexStr.split("{3}").join("(.*?)");
        regexStr = regexStr.split("{4}").join("(.*?)");
        regexStr = "^" + StringTools.replace(regexStr, "?", "\\?") + "$";

        var regex = new EReg(regexStr, "");
        if (regex.match(line)) {
            var args = [];
            for (i in 1...5) {
                try {
                    var arg = regex.matched(i);
                    if (arg != null) args.push(StringTools.trim(arg));
                } catch(e:Dynamic) {
                    break;
                }
            }
            return args;
        }
        return null;
    }

    public static function applyPattern(pattern:Pattern, args:Array<String>):String {
        var result = pattern.lua;
        for (i in 0...args.length) {
            result = StringTools.replace(result, '{$i}', args[i]);
        }
        return result;
    }
}