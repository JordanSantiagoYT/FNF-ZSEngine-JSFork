class DebugTranspiler {
    public static function main() {
        var testScript = 
"! ZS-LUA

local <defaultNotePos> = {}
local <spin> = false
local <arrowMoveX> = 0
local <arrowMoveY> = 0

onCreatePost:
    for <i> = 0, 7 do
        <x> = getPropertyFromGroup(<strumLineNotes>, <i>, <x>)
        <y> = getPropertyFromGroup(<strumLineNotes>, <i>, <y>)
        insert {x, y} to table <defaultNotePos>

onUpdate<elapsed>:
    <songPos> = getPropertyFromClass(<Conductor>,  <songPosition>)
    <currentBeat> = (<songPos> ÷ 50) × (<bpm> ÷ 10)
    if <spin> == true then
        for <i> = 0, 3 do
            setPropertyFromGroup: <strumLineNotes>, <i>, <x> = <defaultNotePos>[<i> + 1][1] + <arrowMoveX> × math.sin((currentBeat + i × 0.1) × math.pi)
            setPropertyFromGroup: <strumLineNotes>, <i>, <y> = <defaultNotePos>[<i> + 1][2] + <arrowMoveY> × math.cos((currentBeat + i × 0.1) × math.pi)

onEvent<name, value1, value2>:
    if <name> == ‘shakey arrows’ then
        if <value1> == ‘normal’ then
            <spin> = false
        else if <value1> == ‘little’ then
            <spin> = true
            <arrowMoveX> = 4
            <arrowMoveY> = 4
        else if <value1> == ‘medium’ then
            <spin> = true
            <arrowMoveX> = 15
            <arrowMoveY> = 15
        else if <value1> == ‘large’ then
            <spin> = true
            <arrowMoveX> = 35
            <arrowMoveY> = 25";
        
        trace("=== ZS DEBUG TRANSPILER ===");
        trace("Original Script:");
        trace(testScript);
        trace("");
        
        // Step 1: Check directive
        trace("Step 1: Checking ! ZS-LUA directive...");
        var lines = testScript.split("\n");
        var directiveFound = false;
        for (i in 0...lines.length) {
            var line = StringTools.trim(lines[i]);
            if (line == "! ZS-LUA") {
                directiveFound = true;
                trace("  ✓ Directive found at line " + (i+1));
                break;
            }
        }
        if (!directiveFound) trace("  ✗ Directive NOT found!");
        trace("");
        
        // Step 2: Test pattern matching
        trace("Step 2: Testing pattern replacement...");
        var testLine = "setProperty: <hitHealth> = 0.5";
        trace('  Testing line: "$testLine"');

        var resultLine = testLine;
        for (pattern in ZSPatterns.patterns) {
            var regex = new EReg(pattern.pattern, "g");
            if (regex.match(resultLine)) {
                trace('  Pattern matched: "${pattern.pattern}"');
                trace('  → Category: ${pattern.category}');
                resultLine = regex.replace(resultLine, pattern.replacement);
            }
        }
        trace('  → Result: "$resultLine"');
        
        // Step 3: Test comment handling
        trace("Step 3: Testing comment handling...");
        var commentLine = "    setProperty: <hitHealth> = 0.5 -/ Change value";
        trace('  Testing: "$commentLine"');
        
        if (commentLine.indexOf(" -/") > -1) {
            trace("  ✓ Inline comment detected");
            var parts = commentLine.split(" -/");
            trace('  → Code part: "${StringTools.trim(parts[0])}"');
            trace('  → Comment part: "${parts[1]}"');
        } else {
            trace("  ✗ Inline comment NOT detected");
        }
        trace("");
        
        // Step 4: Full transpilation test
        trace("Step 4: Running full transpilation...");
        var result = ZSTranspiler.transpile(testScript);
        
        if (result != null) {
            trace("✓ Transpilation successful!");
            trace("");
            trace("=== OUTPUT ===");
            trace(result);
        } else {
            trace("✗ Transpilation failed!");
            trace("");
            trace("=== ERRORS ===");
            for (err in ZSTranspiler.errors) {
                trace(err);
            }
        }
    }
}