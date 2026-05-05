package zsscript;

typedef Pattern = {
    pattern:String,
    replacement:String,
    description:String,
    category:String
}

class ZSPatterns {
    public static var patterns:Array<Pattern> = [
        // ===== TRIGGER EVENT (must come before generic event) =====
        {
            pattern: "trigger event: ([^,]+), ([^,]+), (.+)",
            replacement: "triggerEvent($1, $2, $3)",
            description: "Trigger event",
            category: "events"
        },
        {
            pattern: "call function: (.+)\\((.+)\\)",
            replacement: "$1($2)",
            description: "Call a custom function",
            category: "events"
        },

        // ===== PROPERTY OPERATIONS =====
        {
            pattern: "getProperty\\(<([^>]+)>\\)",
            replacement: 'getProperty("$1")',
            description: "Get property",
            category: "properties"
        },
        {
            pattern: "setProperty: <([^>]+)> = (.+)",
            replacement: 'setProperty("$1", $2)',
            description: "Set property",
            category: "properties"
        },

        // ===== SHADER OPERATIONS =====
        {
            pattern: "register shader: <([^>]+)>",
            replacement: 'initLuaShader("$1")',
            description: "Register shader",
            category: "shaders"
        },
        {
            pattern: "set <([^>]+)> to <([^>]+)>",
            replacement: 'setSpriteShader("$1", "$2")',
            description: "Apply shader to sprite",
            category: "shaders"
        },
        {
            pattern: "set Shader\\((Float|Int|Bool)\\): <([^>]+)>\\(<([^>]+)>\\) = (.+)",
            replacement: "setShader$1(\"$2\", \"$3\", $4)",
            description: "Set shader uniform",
            category: "shaders"
        },

        // ===== VARIABLE DECLARATIONS =====
        {
            pattern: "local <([^>]+)> = (.+)",
            replacement: "local $1 = $2",
            description: "Local variable",
            category: "variables"
        },
        {
            pattern: "global <([^>]+)> = (.+)",
            replacement: "$1 = $2",
            description: "Global variable",
            category: "variables"
        },

        // ===== EVENTS =====
        {
            pattern: "([a-zA-Z]+)<([^>]+)>:",
            replacement: "function $1($2)",
            description: "Event with parameters",
            category: "events"
        },
        {
            pattern: "([a-zA-Z]+):",
            replacement: "function $1()",
            description: "Event without parameters",
            category: "events"
        },

        // ===== GROUP OPERATIONS =====
        {
            pattern: "setPropertyFromGroup: <([^>]+)>, <([^>]+)>, <([^>]+)> = (.+)",
            replacement: 'setPropertyFromGroup("$1", $2, "$3", $4)',
            description: "Set property on group member",
            category: "groups"
        },
        {
            pattern: "getPropertyFromGroup\\(<([^>]+)>, <([^>]+)>, <([^>]+)>\\)",
            replacement: 'getPropertyFromGroup("$1", $2, "$3")',
            description: "Get property from group member",
            category: "groups"
        },
        {
            pattern: "add <([^>]+)> to group <([^>]+)>",
            replacement: 'addToGroup("$2", "$1")',
            description: "Add object to group",
            category: "groups"
        },
        {
            pattern: "remove <([^>]+)> from group <([^>]+)>",
            replacement: 'removeFromGroup("$2", "$1")',
            description: "Remove object from group",
            category: "groups"
        },

        // ===== CLASS PROPERTY OPERATIONS =====
        {
            pattern: "getPropertyFromClass\\(<([^>]+)>, <([^>]+)>\\)",
            replacement: 'getPropertyFromClass("$1", "$2")',
            description: "Get property from class",
            category: "properties"
        },
        {
            pattern: "setPropertyFromClass: <([^>]+)>, <([^>]+)> = (.+)",
            replacement: 'setPropertyFromClass("$1", "$2", $3)',
            description: "Set property on class",
            category: "properties"
        },

        // ===== CONTROL STRUCTURES =====
        {
            pattern: "if (.+) then",
            replacement: "if $1 then",
            description: "If statement",
            category: "control"
        },
        {
            pattern: "else if (.+) then",
            replacement: "elseif $1 then",
            description: "Else if statement",
            category: "control"
        },

        // ===== RETURN-FREE KEYWORDS =====
        {
            pattern: "\\bproceed\\b",
            replacement: "return Function_Continue",
            description: "Continue script execution",
            category: "control"
        },
        {
            pattern: "\\bhalt\\b",
            replacement: "return Function_Stop",
            description: "Stop this script only",
            category: "control"
        },
        {
            pattern: "\\bhaltLua\\b",
            replacement: "return Function_StopLua",
            description: "Stop Lua scripts",
            category: "control"
        },
        {
            pattern: "\\bhaltScript\\b",
            replacement: "return Function_StopHScript",
            description: "Stop HScripts",
            category: "control"
        },
        {
            pattern: "\\bhaltAll\\b",
            replacement: "return Function_StopAll",
            description: "Stop all scripts",
            category: "control"
        },

        // ===== ANIMATION OPERATIONS =====
        {
            pattern: "play animation: <([^>]+)>, (.+), (.+), (.+)",
            replacement: 'playAnim("$1", $2, $3, $4)',
            description: "Play animation on character",
            category: "animations"
        },
        {
            pattern: "add animation: <([^>]+)>, (.+), (.+), (.+), (.+)",
            replacement: 'addAnimation("$1", $2, $3, $4, $5)',
            description: "Add animation to character",
            category: "animations"
        },
        {
            pattern: "add animation by prefix: <([^>]+)>, (.+), (.+), (.+), (.+)",
            replacement: 'addAnimationByPrefix("$1", $2, $3, $4, $5)',
            description: "Add animation by prefix",
            category: "animations"
        },
        {
            pattern: "set <([^>]+)> animation to (.+)",
            replacement: 'setProperty(\"$1.animation.curAnim.name\", $2)',
            description: "Set current animation",
            category: "animations"
        },

        // ===== CAMERA OPERATIONS =====
        {
            pattern: "set camera follow: <([^>]+)>, (.+)",
            replacement: 'setCameraFollow("$1", $2)',
            description: "Set camera follow target",
            category: "camera"
        },
        {
            pattern: "set camera zoom: (.+), (.+)",
            replacement: "setCameraZoom($1, $2)",
            description: "Set camera zoom",
            category: "camera"
        },
        {
            pattern: "set camera focus: <([^>]+)>",
            replacement: 'setCameraFocus("$1")',
            description: "Focus camera on object",
            category: "camera"
        },
        {
            pattern: "shake camera: (.+), (.+)",
            replacement: "cameraShake($1, $2)",
            description: "Shake the camera",
            category: "camera"
        },

        // ===== CHARACTER OPERATIONS =====
        {
            pattern: "set character <([^>]+)> to (.+)",
            replacement: 'setCharacter("$1", $2)',
            description: "Change character",
            category: "characters"
        },
        {
            pattern: "set <([^>]+)> health to (.+)",
            replacement: 'setProperty("$1.health", $2)',
            description: "Set character health",
            category: "characters"
        },
        {
            pattern: "set <([^>]+)> position: x=(.+), y=(.+)",
            replacement: 'setProperty("$1.x", $2)\nsetProperty("$1.y", $3)',
            description: "Set character position",
            category: "characters"
        },

        // ===== SOUND OPERATIONS =====
        {
            pattern: "play sound: (.+), (.+)",
            replacement: "playSound($1, $2)",
            description: "Play a sound",
            category: "sounds"
        },
        {
            pattern: "play music: (.+), (.+)",
            replacement: "playMusic($1, $2)",
            description: "Play background music",
            category: "sounds"
        },
        {
            pattern: "stop sound: (.+)",
            replacement: "stopSound($1)",
            description: "Stop a sound",
            category: "sounds"
        },

        // ===== VISUAL OPERATIONS =====
        {
            pattern: "set <([^>]+)> color to (.+)",
            replacement: 'setProperty("$1.color", $2)',
            description: "Set object color",
            category: "visuals"
        },
        {
            pattern: "set <([^>]+)> alpha to (.+)",
            replacement: 'setProperty("$1.alpha", $2)',
            description: "Set transparency",
            category: "visuals"
        },
        {
            pattern: "set <([^>]+)> scale to x=(.+), y=(.+)",
            replacement: 'setProperty("$1.scale.x", $2)\nsetProperty("$1.scale.y", $3)',
            description: "Set object scale",
            category: "visuals"
        },
        {
            pattern: "set <([^>]+)> visible to (.+)",
            replacement: 'setProperty("$1.visible", $2)',
            description: "Show/hide object",
            category: "visuals"
        },

        // ===== TWEEN OPERATIONS =====
        {
            pattern: "tween <([^>]+)> to (.+) over (.+) with (.+)",
            replacement: 'doTween("$1", "$1", $2, $3, $4)',
            description: "Tween object property",
            category: "tweens"
        },
        {
            pattern: "tween color of <([^>]+)> to (.+) over (.+)",
            replacement: 'doTweenColor("$1", "$1", $2, $3)',
            description: "Tween color",
            category: "tweens"
        },
        {
            pattern: "tween alpha of <([^>]+)> to (.+) over (.+)",
            replacement: 'doTweenAlpha("$1", "$1", $2, $3)',
            description: "Tween transparency",
            category: "tweens"
        },

        // ===== NOTE OPERATIONS =====
        {
            pattern: "set note (.+) to (.+)",
            replacement: 'setPropertyFromGroup("notes", $1, $2)',
            description: "Set note property",
            category: "notes"
        },
        {
            pattern: "get note (.+) (.+)",
            replacement: 'getPropertyFromGroup("notes", $1, $2)',
            description: "Get note property",
            category: "notes"
        },
        {
            pattern: "set all notes to (.+)",
            replacement: 'setProperty("notes.$1", $2)',
            description: "Set property on all notes",
            category: "notes"
        },

        // ===== LOOPS =====
        {
            pattern: "for <([^>]+)> = (.+) do",
            replacement: "for $1 = $2 do",
            description: "Numeric for loop (any expression)",
            category: "control"
        },

        // ===== TABLE OPERATIONS =====
        {
            pattern: "<([^>]+)>\\[([^]]+)\\]",
            replacement: "$1[$2]",
            description: "Table access (any index)",
            category: "tables"
        },
        {
            pattern: "({.+?})",
            replacement: "$1",
            description: "Table literal (any content)",
            category: "tables"
        },
        {
            pattern: "insert (.+) to table <([^>]+)>",
            replacement: "table.insert($2, $1)",
            description: "Insert value into table",
            category: "tables"
        },

        // ===== VARIABLE REFERENCES (must be last) =====
        {
            pattern: "<([^>]+)>",
            replacement: "$1",
            description: "Variable reference",
            category: "variables"
        }
    ];
}