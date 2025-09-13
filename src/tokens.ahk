
class FormatStrToken_ConditionalGroup extends FormatStrTokenBase {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.__desc_SetFlag := proto.GetOwnPropDesc('__SetFlag')
        proto.__desc_AddDefaultFormatCode := proto.GetOwnPropDesc('__AddDefaultFormatCode')
        proto.Flags := Map() ; So it always returns 0
        proto.Flags.Default := 0
    }
    __New(IndexToken, Str) {
        this.Push(
            IndexToken
          , Str
          , InStr(Str, this.TOKEN_FORMAT_SPECIFIER)
          , InStr(Str, this.TOKEN_SIGNIFICANT_CONDITION)
          , 0 ; Flag to signal no default format codes have been added yet.
        )
        this.Tokens := FormatStr_TokenCollection()
        if !HasProp(this, 'FormatCodes') {
            this.FormatCodes := []
        }
    }
    AddDefaultFormatCode(IndexDefaultFormatCode) {
        if !this.HasOwnProp('DefaultFormatCodes') {
            this.DefineProp('DefaultFormatCodes', { Value: [] })
        }
        this.DefineProp('AddDefaultFormatCode', this.__desc_AddDefaultFormatCode)
        ; Flag to signal that a default format code was added.
        this[5] := 1
        return this.AddDefaultFormatCode(IndexDefaultFormatCode)
    }
    __AddDefaultFormatCode(Token) {
        this.DefaultFormatCodes.Push(Token)
    }
    SetFlag(Flag, Value) {
        if !this.HasOwnProp('Flags') {
            this.DefineProp('Flags', { Value: Map() })
            this.Flags.Default := 0
        }
        this.DefineProp('SetFlag', this.__desc_SetFlag)
        return this.SetFlag(Flag, Value)
    }
    __SetFlag(Flag, Value) {
        this.Flags.Set(Flag, Value)
    }
    HasDefaultFormatCode => this[5]
    HasFormatSpecifier => this[3]
    HasSignificantCondition => this[4]
    Str => this[2]
}
class FormatStrToken_DefaultFormatCode extends FormatStrToken_FormatCode {
}
class FormatStrToken_FormatCode extends FormatStrToken_FormatSpecifierBase {
    __New(IndexToken, IndexFormatCode, IndexFormatCodeParams) {
        this.Push(IndexToken, IndexFormatCode, IndexFormatCodeParams)
        if IndexFormatCode {
            this.DefineProp('FormatCodeFunction', { Value: this.FormatCodes.Get(this.FormatCode) })
        }
    }
    IndexFormatCode => this[2]
    IndexFormatCodeParams => this[3]
    FormatCode => this.FormatCodeMap.Get(this[2])
    Params => this.FormatCodeParams[this[3]]
}
class FormatStrToken_FormatSpecifier extends FormatStrToken_FormatSpecifierBase {
}
class FormatStrToken_PlainText extends FormatStrTokenBase {
    __New(IndexToken, Str) {
        this.Push(IndexToken, Str)
    }
    Str => this[2]
}
class FormatStrToken_SignificantCondition extends FormatStrToken_FormatSpecifierBase {
}
class FormatStrToken_SimpleCondition extends FormatStrToken_FormatSpecifierBase {
}
class FormatStrToken_FormatSpecifierBase extends FormatStrTokenBase {
    __New(IndexToken, IndexFormatSpecifier, IndexSpecifierCode) {
        this.Push(IndexToken, IndexFormatSpecifier, IndexSpecifierCode)
        if IndexSpecifierCode {
            this.DefineProp('SpecifierCodeFunction', { Value: this.SpecifierCodes.Get(this.SpecifierCodeMap.Get(this[3])) })
        }
    }
    SpecifierCode => this.SpecifierCodeMap.Get(this[3])
    IndexSpecifierCode => this[3]
    IndexFormatSpecifier => this[2]
    FormatSpecifierName => this.Names[this[2]]
}
class FormatStrTokenBase extends Array {
    IndexToken => this[1]
}
