package zsscript;

class ZSTranspiler {
    public static var errors:Array<String> = [];
    public static var currentLine:Int = 0;

    public static function transpile(zsSource:String):Null<String> {
        errors = [];
        var luaCode = new StringBuf();
        var lines = zsSource.split("\n");

        if (lines.length == 0 || StringTools.trim(lines[0]) != "! ZS-LUA") {
            errors.push("Error: File must start with \"! ZS-LUA\"");
            return null;
        }

        var indentationStack:Array<Int> = [0];
        var lastIndent = 0;

        for (i in 1...lines.length) {
            currentLine = i + 1;
            var rawLine = lines[i];

            var indent = getIndentLevel(rawLine);
            var trimmedLine = StringTools.trim(rawLine);

            trimmedLine = fixMinusSigns(trimmedLine);

            if (indent < lastIndent) {
                var levelsToClose = 0;
                while (indent < indentationStack[indentationStack.length - 1]) {
                    indentationStack.pop();
                    levelsToClose++;
                }
                for (_ in 0...levelsToClose) {
                    luaCode.add("end\n");
                }
            }

            if (trimmedLine == "" || trimmedLine.startsWith("-/")) {
                if (trimmedLine.startsWith("-/")) {
                    luaCode.add("--" + trimmedLine.substr(2) + "\n");
                } else {
                    luaCode.add("\n");
                }
                lastIndent = indent;
                continue;
            }

            var match = ZSPatterns.matchPattern(trimmedLine);
            if (match != null) {
                try {
                    var luaLine = ZSPatterns.applyPattern(match.pattern, match.args);

                    if (luaLine.indexOf(" then") > -1 || luaLine.indexOf(" do") > -1 || luaLine == "repeat") {
                        indentationStack.push(indent);
                    }

                    luaCode.add(luaLine + "\n");
                } catch(e:Dynamic) {
                    errors.push('Error at line $currentLine: Failed to apply pattern');
                    errors.push('  → $trimmedLine');
                    return null;
                }
            } else {
                luaCode.add(trimmedLine + "\n");
            }

            lastIndent = indent;
        }

        while (indentationStack.length > 1) {
            luaCode.add("end\n");
            indentationStack.pop();
        }

        return luaCode.toString();
    }

    static function getIndentLevel(line:String):Int {
        var spaces = 0;
        for (i in 0...line.length) {
            var char = line.charAt(i);
            if (char == " " || char == "\t") {
                spaces++;
            } else {
                break;
            }
        }
        return spaces;
    }

    static function fixMinusSigns(line:String):String {
        var subtractionRegex = ~/([0-9\)\]\} ]) *- *([0-9\(\[\{])/g;
        line = subtractionRegex.replace(line, "$1 − $2");
        var negativeRegex = ~/(^|[=\(\{,;+*\/÷−]) *- *([0-9])/g;
        line = negativeRegex.replace(line, "$1 -$2");

        return line;
    }
}