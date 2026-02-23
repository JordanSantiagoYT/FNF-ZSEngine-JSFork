package;

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
            if (line == "" || line.indexOf("-/") == 0) continue;

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
            trace('=== Processing line $currentLine, current stack: $indentationStack ===');
            var rawLine = lines[i];
            var originalIndent = getIndentLevel(rawLine);
            var trimmedLine = StringTools.trim(rawLine);

            if (!inBlockComment) {
                var codeToCheck = trimmedLine;

                if (trimmedLine.indexOf(" -/") > -1) {
                    var parts = trimmedLine.split(" -/");
                    codeToCheck = parts[0];
                }

                if (codeToCheck.indexOf('"') > -1) {
                    errors.push('Error at line $currentLine: Straight double quotes " are not allowed in ZS');
                    errors.push('  → Use curly quotes “ and ” instead');
                    errors.push('  Found: "$trimmedLine"');
                    return null;
                }
                if (codeToCheck.indexOf("'") > -1) {
                    errors.push('Error at line $currentLine: Straight single quotes \' are not allowed in ZS');
                    errors.push('  → Use curly quotes ‘ and ’ instead');
                    errors.push('  Found: "$trimmedLine"');
                    return null;
                }

                if (codeToCheck.indexOf("~=") > -1) {
                    errors.push('Error at line $currentLine: Lua operator "~=" is not allowed in ZS');
                    errors.push('  → Use "≠" instead');
                    errors.push('  Found: "$trimmedLine"');
                    return null;
                }
                if (codeToCheck.indexOf("<=") > -1) {
                    errors.push('Error at line $currentLine: Lua operator "<=" is not allowed in ZS');
                    errors.push('  → Use "≤" instead');
                    errors.push('  Found: "$trimmedLine"');
                    return null;
                }
                if (codeToCheck.indexOf(">=") > -1) {
                    errors.push('Error at line $currentLine: Lua operator ">=" is not allowed in ZS');
                    errors.push('  → Use "≥" instead');
                    errors.push('  Found: "$trimmedLine"');
                    return null;
                }
                if (codeToCheck.indexOf("-=") > -1) {
                    errors.push('Error at line $currentLine: Lua operator "-=" is not allowed in ZS');
                    errors.push('  → Use "−=" instead');
                    errors.push('  Found: "$trimmedLine"');
                    return null;
                }
                if (codeToCheck.indexOf("*=") > -1) {
                    errors.push('Error at line $currentLine: Lua operator "*=" is not allowed in ZS');
                    errors.push('  → Use "×=" instead');
                    errors.push('  Found: "$trimmedLine"');
                    return null;
                }
                if (codeToCheck.indexOf("/=") > -1) {
                    errors.push('Error at line $currentLine: Lua operator "/=" is not allowed in ZS');
                    errors.push('  → Use "÷=" instead');
                    errors.push('  Found: "$trimmedLine"');
                    return null;
                }
                if (~/[0-9] *- *[0-9]/.match(codeToCheck)) {
                    errors.push('Error at line $currentLine: Hyphen "-" between numbers is not allowed for subtraction');
                    errors.push('  → Use "−" (minus sign) instead');
                    errors.push('  Found: "$trimmedLine"');
                    return null;
                }
                if (~/[0-9]-[0-9]/.match(codeToCheck)) {
                    errors.push('Error at line $currentLine: Hyphen "-" between numbers is not allowed for subtraction');
                    errors.push('  → Use "−" (minus sign) instead');
                    errors.push('  Found: "$trimmedLine"');
                    return null;
                }
                if (~/[0-9] *-[0-9]/.match(codeToCheck)) {
                    errors.push('Error at line $currentLine: Hyphen "-" between numbers is not allowed for subtraction');
                    errors.push('  → Use "−" (minus sign) instead');
                    errors.push('  Found: "$trimmedLine"');
                    return null;
                }
                if (~/[0-9]- *[0-9]/.match(codeToCheck)) {
                    errors.push('Error at line $currentLine: Hyphen "-" between numbers is not allowed for subtraction');
                    errors.push('  → Use "−" (minus sign) instead');
                    errors.push('  Found: "$trimmedLine"');
                    return null;
                }
            }

            trimmedLine = convertQuotes(trimmedLine);
            trimmedLine = fixMinusSigns(trimmedLine);

            trimmedLine = trimmedLine.split("≠").join("~=");
            trimmedLine = trimmedLine.split("≤").join("<=");
            trimmedLine = trimmedLine.split("≥").join(">=");
            trimmedLine = trimmedLine.split("−=").join("-=");
            trimmedLine = trimmedLine.split("×=").join("*=");
            trimmedLine = trimmedLine.split("÷=").join("/=");

            if (originalIndent < lastIndent) {
                trace('DEDENT: from $lastIndent to $originalIndent');
                var levelsToClose = 0;
                while (originalIndent < indentationStack[indentationStack.length - 1]) {
                    indentationStack.pop();
                    levelsToClose++;
                    trace('POP: Line $currentLine, stack=$indentationStack');
                }
                for (_ in 0...levelsToClose) {
                    luaCode.add("end\n");
                    trace('ADDED end for dedent');
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

                if (trimmedLine.indexOf(" -/") > -1) {
                    var parts = trimmedLine.split(" -/");
                    var codePart = parts[0];
                    var commentPart = parts[1];

                    var luaLine = codePart;
                    trace('Processing line: "$luaLine"');

                    for (pattern in ZSPatterns.patterns) {
                        trace('  Trying pattern: ${pattern.pattern}');
                        try {
                            var regex = new EReg(pattern.pattern, "g");
                            var newLine = regex.replace(luaLine, pattern.replacement);
                            if (newLine != luaLine) {
                                trace('    Matched! -> "$newLine"');
                            }
                            luaLine = newLine;
                        } catch (e:Dynamic) {
                            trace('    ERROR with pattern: ${pattern.pattern}');
                            trace('    Error: $e');
                            throw e;
                        }
                    }

                    for (_ in 0...originalIndent) {
                        luaCode.add(" ");
                    }
                    luaCode.add(luaLine + " --" + commentPart + "\n");

                    lastIndent = originalIndent;
                    continue;
                }
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
                trace('In block comment, line: "$trimmedLine", looking for /-* at: ' + trimmedLine.indexOf("/-*"));
                var closePos = trimmedLine.indexOf("/-*");
                if (closePos >= 0) {
                    trace('Found closing at position $closePos');
                    inBlockComment = false;
                    var beforeClose = trimmedLine.substring(0, closePos);
                    var afterClose = trimmedLine.substring(closePos + 3);
                    for (_ in 0...originalIndent) {
                        luaCode.add(" ");
                    }
                    luaCode.add(beforeClose + "]]" + afterClose + "\n");
                } else {
                    trace('No closing on this line');
                    for (_ in 0...originalIndent) {
                        luaCode.add(" ");
                    }
                    luaCode.add(trimmedLine + "\n");
                }
                lastIndent = originalIndent;
                continue;
            }

            if (!inBlockComment && trimmedLine.indexOf("-/") != 0) {
                var codeToCheck = trimmedLine;
                if (trimmedLine.indexOf(" -/") > -1) {
                    var parts = trimmedLine.split(" -/");
                    codeToCheck = parts[0];
                }

                var luaKeywords = ["function", "end", "nil", "--"];
                for (keyword in luaKeywords) {
                    if (codeToCheck.indexOf(keyword) >= 0) {
                        var pattern = new EReg('\\b' + keyword + '\\b', "");
                        if (pattern.match(codeToCheck)) {
                            errors.push('Error at line $currentLine: Lua style "$keyword" is not allowed in ZS');
                            errors.push('  → Use ZS natural syntax instead');
                            errors.push('  Found: "$trimmedLine"');
                            return null;
                        }
                    }
                }
            }

            if (trimmedLine == "" || trimmedLine == null) {
                for (_ in 0...originalIndent) {
                    luaCode.add(" ");
                }
                luaCode.add("\n");
                lastIndent = originalIndent;
                continue;
            }

            if (trimmedLine.indexOf("else if ") == 0) {
                trimmedLine = "elseif " + trimmedLine.substr(8);
            }

            try {
                var luaLine = trimmedLine;

                for (pattern in ZSPatterns.patterns) {
                    var regex = new EReg(pattern.pattern, "g");
                    luaLine = regex.replace(luaLine, pattern.replacement);
                }

                if (luaLine.indexOf("else if ") == 0) {
                    luaLine = "elseif " + luaLine.substr(8);
                }

                for (_ in 0...originalIndent) {
                    luaCode.add(" ");
                }

                if (luaLine.indexOf("function ") == 0 || 
                    luaLine.indexOf(" then") > -1 || 
                    luaLine.indexOf(" do") > -1 || 
                    luaLine == "repeat" || 
                    luaLine.indexOf("else") == 0) {
                    indentationStack.push(originalIndent);
                    trace('PUSH: Line $currentLine, indent=$originalIndent, stack=$indentationStack');
                }

                luaCode.add(luaLine + "\n");
            } catch(e:Dynamic) {
                errors.push('Error at line $currentLine: Failed to apply pattern');
                errors.push('  → $trimmedLine');
                return null;
            }

            lastIndent = originalIndent;
        }

        trace('=== FINAL CLEANUP ===');
        trace('Indentation stack before cleanup: $indentationStack');
        trace('Stack length: ' + indentationStack.length);

        while (indentationStack.length > 1) {
            trace('Adding end, stack length: ' + indentationStack.length);
            luaCode.add("end\n");
            indentationStack.pop();
        }

        trace('Stack after cleanup: $indentationStack');

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