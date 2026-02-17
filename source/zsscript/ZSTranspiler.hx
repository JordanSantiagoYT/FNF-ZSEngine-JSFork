package zsscript;

class ZSTranspiler {
    public static var errors:Array<String> = [];
    public static var currentLine:Int = 0;

    public static function transpile(zsSource:String):Null<String> {
        errors = [];
        var luaCode = new StringBuf();
        var lines = zsSource.split("\n");
        var foundDirective = false;
        var startLine = 0;

        for (i in startLine...lines.length) {
            var line = StringTools.trim(lines[i]);
            if (line == "" || line.startsWith("-/")) {
                continue;
            }
            if (line == "! ZS-LUA") {
                foundDirective = true;
                startLine = i + 1;
                break;
            } else {
                errors.push("Error: File must start with \"! ZS-LUA\"");
                errors.push('  Found: "$line"');
                return null;
            }
        }

        if (!foundDirective) {
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

            trimmedLine = convertQuotes(trimmedLine);
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

            if (trimmedLine.indexOf("return") == 0 || trimmedLine.indexOf(" return ") > -1) {
                errors.push('Error at line $currentLine: "return" keyword is not allowed in ZS. Use "proceed" or "halt" instead');
                errors.push('  → $trimmedLine');
                return null;
            }

            var match = ZSPatterns.matchPattern(trimmedLine);
            if (match != null) {
                try {
                    var luaLine = ZSPatterns.applyPattern(match.pattern, match.args);

                    var isReturnFreeKeyword = (match.pattern.category == "control" && (match.pattern.zs == "proceed" || match.pattern.zs == "halt" || match.pattern.zs == "haltLua" || match.pattern.zs == "haltScript" || match.pattern.zs == "haltAll"));

                    if (!isReturnFreeKeyword) {
                        if (luaLine.indexOf(" then") > -1 || luaLine.indexOf(" do") > -1 || luaLine == "repeat") {
                            indentationStack.push(indent);
                        }
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

    static function convertQuotes(line:String):String {
        var result = "";
        var inString = false;

        for (i in 0...line.length) {
            var char = line.charAt(i);

            if (char == "“" || char == "”") {
                result += '"';
            }
            else if (char == "‘" || char == "’") {
                result += "'";
            }
            else {
                result += char;
            }
        }

        return result;
    }
}