package zsscript;

class ZSTranspiler {
    public static var errors:Array<String> = [];
    public static var currentLine:Int = 0;

    public static function transpile(zsSource:String):Null<String> {
        errors = [];
        var luaCode = new StringBuf();
        var lines = zsSource.split("\n");
        var directiveFound = false;
        var directiveLineIndex = -1;

        for (i in 0...lines.length) {
            var line = StringTools.trim(lines[i]);
            if (line == "" || line.startsWith("-/")) continue;

            if (line == "! ZS-LUA") {
                directiveFound = true;
                directiveLineIndex = i;
                break;
            } else {
                errors.push('Error: File must start with "! ZS-LUA"');
                errors.push('  Found: "$line"');
                return null;
            }
        }

        if (!directiveFound) {
            errors.push('Error: File must start with "! ZS-LUA"');
            return null;
        }

        lines[directiveLineIndex] = "";

        var indentationStack:Array<Int> = [0];
        var lastIndent = 0;
        var inBlockComment = false;

        for (i in 0...lines.length) {
            currentLine = i + 1;
            var rawLine = lines[i];
            var originalIndent = getIndentLevel(rawLine);
            var trimmedLine = StringTools.trim(rawLine);

            trimmedLine = convertQuotes(trimmedLine);
            trimmedLine = fixMinusSigns(trimmedLine);

            if (originalIndent < lastIndent) {
                var levelsToClose = 0;
                while (originalIndent < indentationStack[indentationStack.length - 1]) {
                    indentationStack.pop();
                    levelsToClose++;
                }
                for (_ in 0...levelsToClose) {
                    luaCode.add("end\n");
                }
            }

            if (trimmedLine.indexOf("-/") == 0) {
                for (_ in 0...originalIndent) {
                    luaCode.add(" ");
                }
                luaCode.add("--" + trimmedLine.substr(2) + "\n");
                lastIndent = originalIndent;
                continue;
            }

            if (trimmedLine.indexOf(" -/") > -1) {
                var parts = trimmedLine.split(" -/");
                var codePart = parts[0];
                var commentPart = parts[1];

                var match = ZSPatterns.matchPattern(codePart);
                if (match != null) {
                    var luaLine = ZSPatterns.applyPattern(match.pattern, match.args);
                    for (_ in 0...originalIndent) {
                        luaCode.add(" ");
                    }
                    luaCode.add(luaLine + " --" + commentPart + "\n");
                } else {
                    for (_ in 0...originalIndent) {
                        luaCode.add(" ");
                    }
                    luaCode.add(codePart + " --" + commentPart + "\n");
                }
                lastIndent = originalIndent;
                continue;
            }

            trace('Line $currentLine: raw="$rawLine", trimmed="$trimmedLine", indent=$originalIndent');

            if (!inBlockComment && trimmedLine.indexOf("*/-") == 0) {
                var closePos = trimmedLine.indexOf("/-*");
                if (closePos > 0) {
                    var content = trimmedLine.substring(3, closePos);
                    var afterClose = trimmedLine.substring(closePos + 3);
                    for (_ in 0...originalIndent) {
                        luaCode.add(" ");
                    }
                    luaCode.add("--[[" + content + "]]" + afterClose + "\n");
                } else {
                    inBlockComment = true;
                    for (_ in 0...originalIndent) {
                        luaCode.add(" ");
                    }
                    luaCode.add("--[[" + trimmedLine.substr(3) + "\n");
                }
                lastIndent = originalIndent;
                continue;
            }

            if (inBlockComment) {
                var closePos = trimmedLine.indexOf("/-*");
                if (closePos >= 0) {
                    inBlockComment = false;
                    var beforeClose = trimmedLine.substring(0, closePos);
                    var afterClose = trimmedLine.substring(closePos + 3);
                    for (_ in 0...originalIndent) {
                        luaCode.add(" ");
                    }
                    luaCode.add(beforeClose + "]]" + afterClose + "\n");
                } else {
                    for (_ in 0...originalIndent) {
                        luaCode.add(" ");
                    }
                    luaCode.add(trimmedLine + "\n");
                }
                lastIndent = originalIndent;
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

                    for (_ in 0...originalIndent) {
                        luaCode.add(" ");
                    }

                    var isReturnFreeKeyword = (match.pattern.category == "control" && (match.pattern.zs == "proceed" || match.pattern.zs == "halt" || match.pattern.zs == "haltLua" || match.pattern.zs == "haltScript" || match.pattern.zs == "haltAll"));

                    if (!isReturnFreeKeyword) {
                        if (luaLine.indexOf("function ") == 0 || luaLine.indexOf(" then") > -1 || luaLine.indexOf(" do") > -1 || luaLine == "repeat" || luaLine.indexOf("else") == 0) {
                            indentationStack.push(originalIndent);
                        }
                    }

                    luaCode.add(luaLine + "\n");
                } catch(e:Dynamic) {
                    errors.push('Error at line $currentLine: Failed to apply pattern');
                    errors.push('  → $trimmedLine');
                    return null;
                }
            } else {
                for (_ in 0...originalIndent) {
                    luaCode.add(" ");
                }
                luaCode.add(trimmedLine + "\n");
            }

            lastIndent = originalIndent;
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