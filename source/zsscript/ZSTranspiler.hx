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
        var blockStack:Array<Int> = [0];
        var currentIndent:Int = 0;
        var expectingBlockContent:Bool = false;
        var lastNonEmptyLine:Int = -1;

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
                } else if (codeToCheck.indexOf("'") > -1) {
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
                } else if (codeToCheck.indexOf("<=") > -1) {
                    errors.push('Error at line $currentLine: Lua operator "<=" is not allowed in ZS');
                    errors.push('  → Use "≤" instead');
                    errors.push('  Found: "$trimmedLine"');
                    return null;
                } else if (codeToCheck.indexOf(">=") > -1) {
                    errors.push('Error at line $currentLine: Lua operator ">=" is not allowed in ZS');
                    errors.push('  → Use "≥" instead');
                    errors.push('  Found: "$trimmedLine"');
                    return null;
                } else if (codeToCheck.indexOf("-=") > -1) {
                    errors.push('Error at line $currentLine: Lua operator "-=" is not allowed in ZS');
                    errors.push('  → Use "−=" instead');
                    errors.push('  Found: "$trimmedLine"');
                    return null;
                } else if (codeToCheck.indexOf("*=") > -1) {
                    errors.push('Error at line $currentLine: Lua operator "*=" is not allowed in ZS');
                    errors.push('  → Use "×=" instead');
                    errors.push('  Found: "$trimmedLine"');
                    return null;
                } else if (codeToCheck.indexOf("/=") > -1) {
                    errors.push('Error at line $currentLine: Lua operator "/=" is not allowed in ZS');
                    errors.push('  → Use "÷=" instead');
                    errors.push('  Found: "$trimmedLine"');
                    return null;
                }

                // Check for hyphen subtraction with numbers AND noun variables
                var patterns = [
                    // Standard numbers
                    ~/[0-9] *- *[0-9]/,
                    ~/[0-9]-[0-9]/,
                    ~/[0-9] *-[0-9]/,
                    ~/[0-9]- *[0-9]/,

                    // Variables with noun symbols
                    ~/> *- *</,           // <x> - <y>
                    ~/>-</,               // <x>-<y>
                    ~/> *-</,             // <x> -<y>
                    ~/>- *</,             // <x>- <y>

                    // Mixed numbers and variables
                    ~/[0-9] *- *</,       // 5 - <y>
                    ~/[0-9]- *</,         // 5- <y>
                    ~/[0-9] *-</,         // 5 -<y>
                    ~/> *- *[0-9]/,       // <x> - 3
                    ~/>- *[0-9]/,         // <x>- 3
                    ~/> *-[0-9]/,         // <x> -3

                    // Multiplication with nouns
                    ~/> *\* *</,
                    ~/>\*</,
                    ~/> *\*</,
                    ~/>\* *</,

                    // Division with nouns
                    ~/> *\/ *</,
                    ~/>\/</,
                    ~/> *\/</,
                    ~/>\/ *</
                ];

                for (pattern in patterns) {
                    if (pattern.match(codeToCheck)) {
                        var opType = "operator";
                        if (trimmedLine.indexOf("-") > -1 && trimmedLine.indexOf("*") == -1 && trimmedLine.indexOf("/") == -1) {
                            opType = "subtraction";
                        } else if (trimmedLine.indexOf("*") > -1) {
                            opType = "multiplication";
                        } else if (trimmedLine.indexOf("/") > -1) {
                            opType = "division";
                        }

                        var correctSymbol = opType == "subtraction" ? "−" : (opType == "multiplication" ? "×" : "÷");

                        errors.push('Error at line $currentLine: Hyphen "$opType" between values is not allowed');
                        errors.push('  → Use "$correctSymbol" instead');
                        errors.push('  Found: "$trimmedLine"');
                        return null;
                    }
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

                if (trimmedLine.indexOf(" -/") > -1) {
                    var parts = trimmedLine.split(" -/");
                    var codePart = parts[0];
                    var commentPart = parts[1];

                    var luaLine = codePart;

                    for (pattern in ZSPatterns.patterns) {
                        var regex = new EReg(pattern.pattern, "g");
                        luaLine = regex.replace(luaLine, pattern.replacement);
                    }

                    for (_ in 0...originalIndent) {
                        luaCode.add(" ");
                    }
                    luaCode.add(luaLine + " --" + commentPart + "\n");

                    lastIndent = originalIndent;
                    continue;
                }
            }

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

            var isStarter = isBlockStarter(trimmedLine);

            if (expectingBlockContent) {
                var expectedMinIndent = blockStack[blockStack.length - 1] + 4;
                if (originalIndent < expectedMinIndent) {
                    errors.push('Error at line $currentLine: Expected indented block (at least $expectedMinIndent spaces, got $originalIndent)');
                    errors.push('  → "$trimmedLine"');
                    return null;
                }
                expectingBlockContent = false;
            }

            if (lastNonEmptyLine >= 0) {
                if (originalIndent < currentIndent) {
                    var matched = false;
                    for (i in 0...blockStack.length) {
                        if (blockStack[i] == originalIndent) {
                            var levelsToClose = blockStack.length - i - 1;
                            for (_ in 0...levelsToClose) {
                                luaCode.add("end\n");
                                blockStack.pop();
                            }
                            matched = true;
                            break;
                        }
                    }
                    if (!matched) {
                        errors.push('Error at line $currentLine: Inconsistent indentation');
                        errors.push('  → "$trimmedLine"');
                        return null;
                    }
                } else if (originalIndent > currentIndent) {
                    if (!isStarter && !expectingBlockContent) {
                        errors.push('Error at line $currentLine: Unexpected indentation increase');
                        errors.push('  → "$trimmedLine"');
                        return null;
                    }
                }
            }

            currentIndent = originalIndent;
            if (isStarter) {
                blockStack.push(originalIndent);
                expectingBlockContent = true;
            }
            lastNonEmptyLine = currentLine;

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
        // Handle subtraction with numbers and noun variables
        // Pattern: number - number, <var> - number, number - <var>, <var> - <var>
        var subtractionRegex = ~/([0-9>][^ ]*) *- *([0-9<][^ ]*)/g;
        line = subtractionRegex.replace(line, "$1 − $2");

        // Also catch cases without spaces: 5-3, <x>-<y>, 5-<y>, <x>-3
        var subtractionNoSpaceRegex = ~/([0-9>][^ ]*)-([0-9<][^ ]*)/g;
        line = subtractionNoSpaceRegex.replace(line, "$1 − $2");

        // Pattern for negative sign: -number or -<var> at start or after operators
        var negativeRegex = ~/(^|[=\(\{,;+*\/÷−]) *- *([0-9<][^ ]*)/g;
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

    static function isBlockStarter(line:String):Bool {
        var l = StringTools.trim(line);
        if (l.endsWith(":")) return true;
        if (l.startsWith("if ") && (l.endsWith(":") || l.indexOf(" then") > -1)) return true;
        if (l.startsWith("else if ") && (l.endsWith(":") || l.indexOf(" then") > -1)) return true;
        if (l == "else" || l == "else:") return true;
        if (l.startsWith("for ") && (l.endsWith(":") || l.indexOf(" do") > -1)) return true;
        if (l.startsWith("while ") && (l.endsWith(":") || l.indexOf(" do") > -1)) return true;
        return false;
    }
}