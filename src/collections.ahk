

class FormatStr_FormatCodesCollection extends Map {
    /**
     * @param {...*} [Values] - A variadic series of values in this order: FormatCode, Value, FormatCodeType
     */
    __New(Values*) {
        types := this.Types := []
        types.Length := FormatStrConstructor.FormatCodeTypes.Length
        for formatCodeType in FormatStrConstructor.FormatCodeTypes {
            types[formatCodeType] := Map()
        }
        if Values.Length {
            this.Add(Values)
        }
    }
    /**
     * @param {*[]} [Values] - An array of values in this order: FormatCode, Value, FormatCodeType
     */
    Add(Values) {
        loop Values.Length / 3 {
            this.Types[Values[A_Index * 3]].Set(Values[A_Index * 3 - 2], Values[A_Index * 3 - 1])
            Values[A_Index * 3 - 1].DefineProp('FormatCodeType', { Value: Values[A_Index * 3] })
        }
    }
    Has(Key, &FormatCodeType?) {
        if IsSet(FormatCodeType) {
            return this.Types[FormatCodeType].Has(Key)
        } else {
            for m in this.Types {
                if m.Has(Key) {
                    FormatCodeType := A_Index
                    return 1
                }
            }
        }
    }
    Get(Key, &FormatCodeType?) {
        if IsSet(FormatCodeType) {
            return this.Types[FormatCodeType].Get(Key)
        } else {
            for m in this.Types {
                if m.Has(Key) {
                    FormatCodeType := A_Index
                    return m.Get(Key)
                }
            }
        }
        throw UnsetItemError('Item not found.', -1, Key)
    }
    __Enum(VarCount) {
        items := Map()
        for m in this.Types {
            for key, val in m {
                items.Set(key, val)
            }
        }
        return items.__Enum(VarCount)
    }
}
class FormatStr_FormatCodeParamsCollection extends Array {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        desc := Array.Prototype.GetOwnPropDesc('__Item')
        proto.DefineProp('GetItem', { Call: desc.Get })
        proto.DefineProp('SetItem', { Call: desc.Set })
    }
    __Item[Index] {
        Get {
            if Index {
                return this.GetItem(Index)
            } else {
                return ''
            }
        }
        Set => this.SetItem(Value, Index)
    }
}
class FormatStr_FormatCodeCollection extends Map {
}
class FormatStr_ConstructorCollection extends FormatStr_PrototypeCollection {
}
class FormatStr_PrototypeCollection extends Array {
    ConditionalGroup => this[FORMATSTR_TYPE_INDEX_CONDITIONALGROUP]
    FormatCode => this[FORMATSTR_TYPE_INDEX_FORMATCODE]
    FormatSpecifier => this[FORMATSTR_TYPE_INDEX_FORMATSPECIFIER]
    PlainText => this[FORMATSTR_TYPE_INDEX_PLAINTEXT]
    SignificantCondition => this[FORMATSTR_TYPE_INDEX_SIGNIFICANTCONDITION]
    SimpleCondition => this[FORMATSTR_TYPE_INDEX_SIMPLECONDITION]
    TokenBase => this[FORMATSTR_TYPE_INDEX_PLAINTEXT].Base
    FormatSpecifierBase => this[FORMATSTR_TYPE_INDEX_FORMATSPECIFIER].Base
}
class FormatStr_TokenCollection extends Array {
}
