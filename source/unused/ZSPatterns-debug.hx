package;

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
        // ===== VARIABLE DECLARATIONS =====
        {
            zs: "local <{0}> = {1}",
            lua: "local {0} = {1}",
            description: "Local variable declaration",
            category: "variables"
        },
        {
            zs: "global <{0}> = {1}",
            lua: "{0} = {1}",
            description: "Global variable declaration", 
            category: "variables"
        },
        {
            zs: "local <{0}>",
            lua: "local {0}",
            description: "Local variable declaration without value",
            category: "variables"
        },

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
            zs: "setPropertyFromGroup: <{0}>, {1}, <{2}> = {3}",
            lua: "setPropertyFromGroup(\"{0}\", {1}, \"{2}\", {3})",
            description: "Set property on group member",
            category: "groups"
        },
        {
            zs: "getPropertyFromGroup(<{0}>, {1}, <{2}>)",
            lua: "getPropertyFromGroup(\"{0}\", {1}, \"{2}\")",
            description: "Get property from group member",
            category: "groups"
        },
        {
            zs: "setPropertyFromGroup: {0}, {1}, {2} = {3}",
            lua: "setPropertyFromGroup({0}, {1}, {2}, {3})",
            description: "Set property on group member (with dynamic values)",
            category: "groups"
        },
        {
            zs: "getPropertyFromGroup({0}, {1}, {2})",
            lua: "getPropertyFromGroup({0}, {1}, {2})",
            description: "Get property from group member (with dynamic values)",
            category: "groups"
        },
        {
            zs: "setPropertyFromGroup: <{0}>, <{1}>, <{2}> = {3}",
            lua: "setPropertyFromGroup(\"{0}\", {1}, \"{2}\", {3})",
            description: "Set property on group member (with noun symbol)",
            category: "groups"
        },
        {
            zs: "getPropertyFromGroup(<{0}>, <{1}>, <{2}>)",
            lua: "getPropertyFromGroup(\"{0}\", {1}, \"{2}\")",
            description: "Get property from group member (with noun symbol)",
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
            zs: "onEvent<{0}, {1}, {2}>:",
            lua: "function onEvent({0}, {1}, {2})",
            description: "Event handler with parameters",
            category: "events"
        },
        {
            zs: "onEvent<{0}>:",
            lua: "function onEvent({0})",
            description: "Event handler with one parameter",
            category: "events"
        },
        {
            zs: "onEvent:",
            lua: "function onEvent()",
            description: "Event handler with no parameters",
            category: "events"
        },
        {
            zs: "trigger event: {0}, {1}, {2}",
            lua: "triggerEvent({0}, {1}, {2})",
            description: "Trigger an event with parameters",
            category: "events"
        },
        {
            zs: "trigger event: {0}, {1}",
            lua: "triggerEvent({0}, {1})",
            description: "Trigger an event with two parameters",
            category: "events"
        },
        {
            zs: "trigger event: {0}",
            lua: "triggerEvent({0})",
            description: "Trigger an event with one parameter",
            category: "events"
        },
        {
            zs: "call function: {0}({1})",
            lua: "{0}({1})",
            description: "Call a custom function",
            category: "events"
        },

        // ===== SONG EVENT FUNCTIONS (from Lua callbacks) =====
        {
            zs: "onSongStart:",
            lua: "function onSongStart()",
            description: "Called when song starts",
            category: "events"
        },
        {
            zs: "onBeatHit:",
            lua: "function onBeatHit()",
            description: "Called on beat hit",
            category: "events"
        },
        {
            zs: "onStepHit:",
            lua: "function onStepHit()",
            description: "Called on step hit",
            category: "events"
        },
        {
            zs: "onCountdownTick<{0}>:",
            lua: "function onCountdownTick({0})",
            description: "Called on countdown tick",
            category: "events"
        },
        {
            zs: "onTimerCompleted<{0}, {1}, {2}>:",
            lua: "function onTimerCompleted({0}, {1}, {2})",
            description: "Called when timer completes",
            category: "events"
        },
        {
            zs: "onTweenCompleted<{0}, {1}>:",
            lua: "function onTweenCompleted({0}, {1})",
            description: "Called when tween completes",
            category: "events"
        },
        {
            zs: "onSoundFinished<{0}>:",
            lua: "function onSoundFinished({0})",
            description: "Called when sound finishes",
            category: "events"
        },
        {
            zs: "onNextDialogue:",
            lua: "function onNextDialogue()",
            description: "Called on next dialogue",
            category: "events"
        },
        {
            zs: "onSkipDialogue:",
            lua: "function onSkipDialogue()",
            description: "Called on skip dialogue",
            category: "events"
        },
        {
            zs: "onPause:",
            lua: "function onPause()",
            description: "Called when game pauses",
            category: "events"
        },
        {
            zs: "onResume:",
            lua: "function onResume()",
            description: "Called when game resumes",
            category: "events"
        },
        {
            zs: "onEndSong:",
            lua: "function onEndSong()",
            description: "Called when song ends",
            category: "events"
        },
        {
            zs: "onGameOver:",
            lua: "function onGameOver()",
            description: "Called on game over",
            category: "events"
        },
        {
            zs: "onGameOverStart:",
            lua: "function onGameOverStart()",
            description: "Called when game over starts",
            category: "events"
        },
        {
            zs: "onNoteHit<{0}, {1}, {2}, {3}>:",
            lua: "function onNoteHit({0}, {1}, {2}, {3})",
            description: "Called when note is hit",
            category: "events"
        },
        {
            zs: "onNoteMiss<{0}, {1}, {2}, {3}>:",
            lua: "function onNoteMiss({0}, {1}, {2}, {3})",
            description: "Called when note is missed",
            category: "events"
        },
        {
            zs: "onGhostTap<{0}>:",
            lua: "function onGhostTap({0})",
            description: "Called on ghost tap",
            category: "events"
        },
        {
            zs: "onPlayerHit<{0}>:",
            lua: "function onPlayerHit({0})",
            description: "Called when player hits note",
            category: "events"
        },
        {
            zs: "onDadHit<{0}>:",
            lua: "function onDadHit({0})",
            description: "Called when dad hits note",
            category: "events"
        },

        // ===== CORE GAME EVENTS =====
        {
            zs: "onCreate:",
            lua: "function onCreate()",
            description: "Called when script is created",
            category: "events"
        },
        {
            zs: "onCreatePost:",
            lua: "function onCreatePost()",
            description: "Called after onCreate",
            category: "events"
        },
        {
            zs: "onUpdate<{0}>:",
            lua: "function onUpdate({0})",
            description: "Called every frame",
            category: "events"
        },
        {
            zs: "onUpdatePost<{0}>:",
            lua: "function onUpdatePost({0})",
            description: "Called after onUpdate",
            category: "events"
        },
        {
            zs: "onDestroy:",
            lua: "function onDestroy()",
            description: "Called when script is destroyed",
            category: "events"
        },
        {
            zs: "onFocus:",
            lua: "function onFocus()",
            description: "Called when game gains focus",
            category: "events"
        },
        {
            zs: "onFocusLost:",
            lua: "function onFocusLost()",
            description: "Called when game loses focus",
            category: "events"
        },
        {
            zs: "onResize<{0}, {1}>:",
            lua: "function onResize({0}, {1})",
            description: "Called when window resizes",
            category: "events"
        },
        {
            zs: "onSectionHit:",
            lua: "function onSectionHit()",
            description: "Called on section hit",
            category: "events"
        },
        {
            zs: "onSubstateOpen<{0}>:",
            lua: "function onSubstateOpen({0})",
            description: "Called when substate opens",
            category: "events"
        },
        {
            zs: "onSubstateClose:",
            lua: "function onSubstateClose()",
            description: "Called when substate closes",
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

        // ===== NOTE EVENTS =====
        {
            zs: "onEventPushed<{0}, {1}, {2}>:",
            lua: "function onEventPushed({0}, {1}, {2})",
            description: "Called when event is pushed",
            category: "events"
        },
        {
            zs: "goodNoteHitPre<{0}, {1}, {2}>:",
            lua: "function goodNoteHitPre({0}, {1}, {2})",
            description: "Called before player hits a note",
            category: "events"
        },
        {
            zs: "opponentNoteHitPre<{0}, {1}, {2}>:",
            lua: "function opponentNoteHitPre({0}, {1}, {2})",
            description: "Called before opponent hits a note",
            category: "events"
        },
        {
            zs: "goodNoteHit<{0}, {1}, {2}>:",
            lua: "function goodNoteHit({0}, {1}, {2})",
            description: "Called when player hits a note",
            category: "events"
        },
        {
            zs: "opponentNoteHit<{0}, {1}, {2}>:",
            lua: "function opponentNoteHit({0}, {1}, {2})",
            description: "Called when opponent hits a note",
            category: "events"
        },
        {
            zs: "noteMiss<{0}, {1}, {2}>:",
            lua: "function noteMiss({0}, {1}, {2})",
            description: "Called when note is missed",
            category: "events"
        },
        {
            zs: "noteMissPress<{0}>:",
            lua: "function noteMissPress({0})",
            description: "Called when key is pressed without a note",
            category: "events"
        },
        {
            zs: "noteEarlyPress<{0}>:",
            lua: "function noteEarlyPress({0})",
            description: "Called when note is pressed too early",
            category: "events"
        },
        {
            zs: "onSpawnNote<{0}, {1}, {2}, {3}>:",
            lua: "function onSpawnNote({0}, {1}, {2}, {3})",
            description: "Called when note spawns",
            category: "events"
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
            zs: "proceed",
            lua: "return Function_Continue",
            description: "Continue script execution",
            category: "control"
        },
        {
            zs: "halt",
            lua: "return Function_Stop",
            description: "Stop this script only",
            category: "control"
        },
        {
            zs: "haltLua",
            lua: "return Function_StopLua",
            description: "Stop Lua scripts",
            category: "control"
        },
        {
            zs: "haltScript",
            lua: "return Function_StopHScript", 
            description: "Stop HScripts",
            category: "control"
        },
        {
            zs: "haltAll",
            lua: "return Function_StopAll",
            description: "Stop all scripts",
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
        regexStr = "^" + regexStr + "$";

        trace('Pattern: $pattern');
        trace('Regex: $regexStr');
        trace('Line: "$line"');

        var regex = new EReg(regexStr, "");
        if (regex.match(line)) {
            trace('✓ MATCHED!');
            trace('Matched groups:');
            var args = [];
            for (i in 1...5) {
                try {
                    var arg = regex.matched(i);
                    if (arg != null) args.push(StringTools.trim(arg));
                    trace('  Group $i: "$arg"');
                } catch(e:Dynamic) {
                    break;
                }
            }
            trace('Args: $args');
            return args;
        }
        trace('✗ NOT MATCHED');
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
