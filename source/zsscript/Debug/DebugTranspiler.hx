class DebugTranspiler {
    public static function main() {
        var testScript = 
"! ZS-LUA

onCreate:
    setProperty: <hitHealth> = 0.5 -/ Change value of settings";
        
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
        
        // Step 2: Check pattern matching for setProperty
        trace("Step 2: Testing pattern matching...");
        var testLine = "setProperty: <hitHealth> = 0.5";
        trace('  Testing line: "$testLine"');
        
        var match = ZSPatterns.matchPattern(testLine);
        if (match != null) {
            trace('  ✓ Pattern matched: "${match.pattern.zs}"');
            trace('  → Category: ${match.pattern.category}');
            trace('  → Args: ${match.args}');
            
            var luaLine = ZSPatterns.applyPattern(match.pattern, match.args);
            trace('  → Lua output: "$luaLine"');
        } else {
            trace('  ✗ No pattern matched!');
            
            // List available patterns
            trace("  Available property patterns:");
            for (p in ZSPatterns.patterns) {
                if (p.category == "properties") {
                    trace('    - "${p.zs}"');
                }
            }
        }
        trace("");
        
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