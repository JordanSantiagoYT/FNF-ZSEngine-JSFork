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
        
        // ===== PROPERTY OPERATIONS =====
        {
            pattern: "getProperty\\(<([^>]+)>\\)",
            replacement: 'getProperty("$1")',
            description: "Get property",
            category: "properties"
        },
        {
            pattern: "setProperty: <([^>]+)> = ([^ ]+)",
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
        
        // ===== CONTROL STRUCTURES =====
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
        
        // ===== VARIABLE REFERENCES (must be last) =====
        {
            pattern: "<([^>]+)>",
            replacement: "$1",
            description: "Variable reference",
            category: "variables"
        }
    ];
}