
; The parameters are:
; 1. FormatCode
; 2. FormatCodeParams
; 3. ConditionalGroupToken
; 4. FormatStrObj


FormatStr_FormatCode_AllSpecifiers(DefaultFormatCode, FormatCodeParams, ConditionalGroupToken, *) {
    if ConditionalGroupToken {
        ConditionalGroupToken.SetFlag(FORMATSTR_FLAG_ALLCONDITIONS, 1)
    } else {
        throw Error('The "!a" format code may only be used within a conditional group.', -1)
    }
}


/*
Not implemented yet
FormatStr_FormatCode_Indent(DefaultFormatCode, FormatCodeParams, ConditionalGroupToken, FormatStrObj) {
    s := ''
    loop FormatStrObj.IndentLen {
        s .= ' '
    }
    loop FormatCodeParams - 1 {
        s .= s
    }
    return s
}
