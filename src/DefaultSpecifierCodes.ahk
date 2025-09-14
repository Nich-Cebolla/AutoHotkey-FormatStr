

/*
Not implemented yet

FormatStr_SpecifierCode_EscapeJson(Str) {
    return StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(Str, '\', '\\'), '`n', '\n'), '`r', '\r'), '"', '\"'), '`t', '\t')
}
FormatStr_SpecifierCode_UnEscapeJson(Str) {
        n := 0xFFFD
        while InStr(Str, Chr(n)) {
            n++
        }
        return StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(Str, '\\', Chr(n)), '\n', '`n'), '\r', '`r'), '\"', '"'), '\t', '`t'), Chr(n), '\')
}
