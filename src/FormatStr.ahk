/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-FormatStr
    Author: Nich-Cebolla
    License: MIT
*/

; An AutoHotkey (AHK) library for creating customizable and extensible text formatting logic to suit any project's needs.

#include collections.ahk
#include lib.ahk
#include tokens.ahk

/**
 *
 * `FormatStr` makes it easy to create a unique, customizable, and extensible text formatting system
 * just like the standard printf-style format codes "%d", "%u", "%i", and the like. With a feature-rich
 * API based on caller-defined callback functions, there's no limit to the possibilities.
 *
 * will ultimately be replaced by some data when producing the output text. Along with the format
 * specifiers the caller must define one or more callback functions that facilitates the formatting
 * logic. Format specifiers can contain any character except the colon and are enclosed in percent
 * symbols to indicate that the text is a format specifier.
 *
 * Format specifiers can be grouped together along with plain text in a "conditional group". A conditional
 * group is a segment of the format string which will only be included in the output text if one
 * or more of the format specifiers are replaced with one or more characters (that is, if all format
 * specifiers are replaced with an empty string, none of the text is included in the output).
 *
 * For example, say we are logging error information to file and we pass an error object to our
 * logger, and it outputs the following text.
 *
 * <pre>
 * File: C:\users\me\documents\AutoHotkey\lib\Script.ahk
 * Line: 100
 * Message: The object of type "Object" has no property named "prop".
 * Extra:
 * </pre>
 *
 * That empty "Extra:" section is offputting and should be removed or handled in some way. `FormatStr`
 * makes this easy.
 *
 * ## Demo
 *
 * See file {@link Demo "test\demo-FormatStr.ahk"} for a demonstration of the library's functionality.
 *
 * ## How it works
 *
 * Your code provides a list of symbols that are used by your format string, and `FormatStrConstructor`
 * returns a function that can be called to produce `FormatStr` objects. We will call this function
 * "the constructor function".
 *
 * Your code calls the constructor function with a format string. The format string encapsulates
 * the formatting logic you want for your output text. The constructor function processes your format
 * string into a series of tokens and returns a `FormatStr` object, which is a function you can call
 * to produce the output text. We will call this function "the format function".
 *
 * The format string which you pass to the constructor function contains symbols that will later be
 * replaced by text when you call the format function. These symbols are enclosed in a pair of
 * percent symbols. These are called "format specifiers" and the name of the symbols is
 * "format specifier name".
 *
 * `FormatStr` essentially allows you to define your own text formatting system, like standard
 * printf-style format specifiers "%d", "%i", "%u", etc.
 *
 * ## Quick start
 *
 * This section gives a basic explanation for using the class. I recommend also reviewing the
 * {@link demo} file "test\demo-FormatStr.ahk".
 *
 * 1. Define format specifier names as an array of strings. These are the symbols that you or your
 *    users will enclose in percent symbols to specify a particular datum to include in the
 *    output text.
 * 2. Define a callback function that handles the format specifier strings.
 *   - Parameters:
 *     1. The format specifier name.
 *     2. The value passed to the `Params` parameter of `FormatStr.Prototype.Call`.
 *     3. The token object.
 *     4. If the token object is part of a conditional group, the conditional group token object. Else,
 *        an empty string.
 *   - Returns: The string that replaces the format specifier.
 * 3. Define a format string. The format string is what structures the output text.
 * 4. (Optional) Define specifier codes and associated functions (see section "Specifier codes").
 * 5. (Optional) Define format codes and associated functions (see section "Format codes").
 * 6. (Optional) Create an options object.
 * 7. Call the class constructors.
 * 8. Call the `FormatStr` instance with zero to two parameters:
 *   1. Any value to pass to the callback.
 *   2. A callback function, if you didn't specify a function in the options or if you want to
 *      use a different one. If you pass a value to the second parameter, that function is used
 *      instead of the function that was passed to the options (if any).
 *
 * @example
 *  ; Define format specifier names.
 *  names := [ "file", "line", "message", "extra", "what", "stack" ]
 *  ; Define a callback function
 *  FormatStr_Callback(SpecifierName, Params, Token, ConditionalGroupToken) {
 *      ; Expects an error object to be passed to `Params`.
 *      return Params.%SpecifierName%
 *  }
 *  ; Define a format string.
 *  _format := (
 *      'File: %file%::%line%`r`n'
 *      'Message: %message%`r`n'
 *      '{What: %what%`r`n}'    ; The text enclosed by the brackets will only be included if the
 *      '{Extra: %extra%`r`n}'  ; format specifier is replaced with one or more characters
 *  )
 *  ; Define an options object.
 *  options := { Callback: FormatStr_Callback }
 *  ; Call the class constructors.
 *  constructor := FormatStrConstructor(names, options)
 *  _formatStr := constructor(_format)
 *  ; Call the `FormatStr` instance.
 *  output := _formatStr(Error())
 *  ; Do something with the output.
 *  MsgBox(output)
 * @
 *
 * ## Glossary
 *
 * This documentation uses the following terms.
 *
 * - Conditional group: A group including one or more format specifiers, zero or more significant
 *   conditions, and zero or more literal strings.
 *
 * - Constructor function: The value returned by {@link FormatStrConstructor.Prototype.__New}. The
 *   function object that takes a format string and produces an instance of {@link FormatStr}.
 *
 * - Default format codes: The built-in format codes. Default format codes always begin with an
 *   exclamation point ( ! ).
 *
 * - Default specifier codes: The built-in specifier codes. Default specifier codes always begin with
 *   an exclamation point ( ! ).
 *
 * - Format code: A string enclosed in percent symbols ( % ) that is used as a flag to invoke some
 *   action defined by the caller.
 *
 * - Format code parameters: A string appended to a format code separated by a colon character.
 *   The string is passed to the function associated with the format code.
 *
 * - Format code type: A library-defined type system that is used to specify when the function
 *   associated with the format code should be called.
 *
 * - Format function: The value returned by {@link FormatStr.Prototype.Call}. The function object
 *   that processes the format string and produces the output text.
 *
 * - Format specifier: A keyword enclosed in percent symbols ( % ) that is intended to be
 *   replaced by data when the output text is being produced.
 *
 * - Format specifier name: The string that is between the percent symbols of a format specifier.
 *
 * - Format string: The string that defines the expected format of the output text, including
 *   conditional groups, format specifiers, and significant conditions.
 *
 * - Significant condition: A format specifier that is within a conditional group that is enclosed
 *   in a pair of curly braces, e.g. "{What: {%what%}`n%extra%}". When one or more significant
 *   conditions are included in a conditional group, only the significant condition format specifiers
 *   count toward satisfying the condition to include the segment in the output text. That is,
 *   at least one of the significant conditions must be replaced with one or more characters for the
 *   entire group to be included in the output text. The other format specifiers do not count
 *   toward this condition.
 *
 * - Specifier code: A string appended to a format specifier separated by a colon character.
 *   Specifier codes are used as a flag to invoke some action defined by the caller.
 *
 * ## Conditional groups
 *
 * The primary use case for this library is to expose a means of systematically including text
 * segments in the output as a function of whether or not some data was available at the time
 * the output was produced. This is done by defining conditional groups.
 *
 * You can include conditional text with one or more of the format specifiers by grouping
 * them in brackets.
 *
 * If a conditional group contains only one format specifier, and if that format specifier is replaced
 * with an empty string, none of the surrounding text get included in the output.
 *
 * If a conditional group contains multiple format specifiers, then at least one of the format
 * specifiers must be replaced with one or more characters for the group to be included in the
 * output.
 *
 * @example
 *  names := [ "message", "extra" ]
 *  FormatStr_Callback(FormatSpecifierName, Params, *) {
 *      return Params.%FormatSpecifierName%
 *  }
 *  constructor := FormatStrConstructor(names, { Callback: FormatStr_Callback })
 *  _formatStr := constructor( 'Message: %message%{; Extra: %extra%}')
 *
 *  err1 := Error('Error')
 *  ; Only the message is included because nothing was passed to the parameter `Extra`.
 *  MsgBox(_formatStr(err1)) ; Message: Error
 *
 *  err2 := Error('Error', , 'Extra info')
 *  ; Both values are included.
 *  MsgBox(_formatStr(err2)) ; Message: Error; Extra: Extra info
 * @
 *
 * ### Multiple format specifiers
 *
 * `FormatStr` supports multiple format specifiers within a single conditional group. Only one
 * of the format specifiers must be replaced with one or more characters to be included in the
 * output.
 * @example
 *  names := [ "message", "extra" ]
 *  FormatStr_Callback(FormatSpecifierName, Params, *) {
 *      return Params.%FormatSpecifierName%
 *  }
 *  constructor := FormatStrConstructor(names, { Callback: FormatStr_Callback })
 *  _formatStr := constructor( '{Message: %message%; Extra: %extra%}')
 *
 *  err1 := Error('')
 *  ; No output.
 *  MsgBox(_formatStr(err1))
 *
 *  err2 := Error('', , 'Extra info')
 *  ; Only one of the two are needed.
 *  MsgBox(_formatStr(err2)) ; Message: ; Extra: Extra info
 * @
 *
 * ### Significant conditions
 *
 * Format specifier strings can be marked as a significant condition by enclosing the format specifier
 * string in curly braces with no additional text. When a conditional group contains one or more
 * significant conditions, the condition for including the segment in the output text changes. Only
 * the format specifiers marked as significant conditions count toward the condition; at least one
 * of the significant conditions must be replaced by one or more characters for the segment to be
 * included in the output text. A single conditional group may have zero or more significant
 * conditions.
 * @example
 *  names := [ "message", "what", "extra" ]
 *  FormatStr_Callback(FormatSpecifierName, Params, *) {
 *  return Params.%FormatSpecifierName%
 *  }
 *  constructor := FormatStrConstructor(names, { Callback: FormatStr_Callback })
 *  _formatStr := constructor( '{Message: %message%; What: {%what%}; Extra: {%extra%}}')
 *
 *  err1 := Error('Error', '', '')
 *  ; No output.
 *  MsgBox(_formatStr(err1))
 *
 *  err2 := Error('Error', 'auto-execute', '')
 *  MsgBox(_formatStr(err2)) ; Message: Error; What: auto-execute; Extra:
 *
 *  err3 := Error('Error', 'auto-execute', 'Extra info')
 *  MsgBox(_formatStr(err2)) ; Message: Error; What: auto-execute; Extra: Extra info
 * @
 *
 * ## Specifier codes
 *
 * Specifier codes (and format codes) are a means for extending the library's functionality with
 * custom logic.
 *
 * A specifier code is a string that occurs after a format specifier separated by a colon,
 * e.g. "%extra:1%" or "%extra:code-identifier%". Specifier codes may contain any character
 * except a colon.
 *
 * The codes are associated with some function that is intended to make some changes to
 * the text. When the format function is called, if a token is associated with a specifier
 * code, the function associated with that code is called before adding that substring to
 * the output text.
 *
 * ### Default specifier codes
 *
 * There are currently no default specifier codes.
 *
 * ### Custom specifier codes
 *
 * When you define the functions which will be associated with the specifier codes, the
 * functions must accept one to four parameters:
 * 1. The string that is to be adjusted.
 * 2. The value passed to the "Params" parameter of `FormatStr.Prototype.Call`.
 * 3. The token that produced the value passed to the first parameter.
 * 4. If the token is part of a conditional group, the conditional group token. Else, an
 *    empty string.
 *
 * See the {@link demo} file for some examples.
 *
 * ## Format codes
 *
 * Format codes (and specifier codes) are a means for extending the library's functionality with
 * custom logic.
 *
 * A format code is a string that occurs between two percent symbols that is not one of
 * the format specifier names. For example, if my format specifier names are
 * [ "error", "what", "message" ]
 * and if my format string has "%myCode%" in it, "myCode" is interpreted as a format code.
 * Format codes may contain any character except a colon.
 *
 * Format codes are associated with some function that is intended to make some changes to
 * the text.
 *
 * Format codes are removed completely from the output text and are stored separately from
 * the other tokens.
 *
 * ### Format code scope
 *
 * Format codes can be global, which causes its associated function to be called after the
 * entire output string has been constructed. Place a format code outside of a conditional group
 * to make it global.
 *
 * Format codes can be local, which causes its associated function to be called
 * after the conditional group has been processed and only if the condition was satisfied.
 * Place a format code within a conditional group to make it local.
 *
 * ### Format code types
 *
 * Format codes can be typed or untyped. There are currently two types:
 *
 * - Early: Format codes of this type have their associated functions called within the body of
 *   {@link FormatStr.Prototype.__New} and are only called once. The values passed to the function
 *   are:
 *
 *   1. The format code.
 *   2. If parameters were included with the format code, the parameters. Else, an empty string.
 *   3. If the format code is placed within a conditional group, the conditional group token object.
 *      else, an empty string.
 *   4. The {@link FormatStr} instance object.
 *
 * - Standard: Format codes of this type have their associated functions called within the body of
 *   {@link FormatStr.Prototype.Call} when the output text is being generated. If the format code
 *   is placed within a conditional group (local scope), the associated functions are called after
 *   the group has finished processing, and only if the condition was satisfied. If the format code
 *   is not placed within a conditional group (global scope), the associated functions are called
 *   after the output text has been generated. The values passed to the function are:
 *
 *   1. The string that is to be adjusted. This must be a `VarRef`.
 *   2. The value passed to the "Params" parameter of `FormatStr.Prototype.Call`.
 *   3. If parameters were included with the format code, the parameters. Else, an empty string.
 *   4. If the format code was within a conditional group, the conditional group token. Else,
 *      an empty string.
 *
 * All untyped format codes are treated as standard.
 *
 * To refer to a specific type you will use one of the global variables which contains the type
 * index. Currently, the global variables are:
 * - FORMATSTR_FORMATCODE_TYPE_CALL_EARLY
 * - FORMATSTR_FORMATCODE_TYPE_CALL_STANDARD
 *
 * If your code throws an unset variable error, call {@link FormatStr_SetConstants} somewhere before
 * your code refers to one of the variables.
 *
 * To use typed format codes, you must get an instance of {@link FormatStr_FormatCodesCollection}
 * and use that as your container. {@link FormatStr_FormatCodesCollection} is a map object with
 * additional methods to facilitate using the types.
 *
 * @example
 *
 *  FormatStr_SetFlag(FormatCode, FormatCodeParams, ConditionalGroupToken, FormatStrObj) {
 *      global customFlag := 'flag_name'
 *      if ConditionalGroupToken {
 *          ConditionalGroupToken.Flags.Set(customFlag, 1)
 *      } else {
 *          throw Error('The format code may only be used within a conditional group.', -1, FormatCode)
 *      }
 *  }
 *  FormatStr_Process(&Str, Params, FormatCodeParams, ConditionalGroupToken) {
 *      if ConditionalGroupToken.Flags.Get(customFlag) {
 *          ; Do one thing
 *      } else {
 *          ; Do a different thing
 *      }
 *  }
 *  options := {
 *      FormatCodes: FormatStr_FormatCodesCollection(
 *          ; Format code name, function object, type index
 *          "flag", FormatStr_SetFlag, FORMATSTR_FORMATCODE_TYPE_CALL_EARLY
 *        , "proc", FormatStr_Process, FORMATSTR_FORMATCODE_TYPE_CALL_STANDARD
 *      )
 *   }
 *  constructor := FormatStrConstructor([ "message", "extra", "what" ], options)
 * @
 *
 * You can add all of the format codes to the collection object when creating the object. The
 * values passed to the constructor are processed in groups of three in the order of:
 * 1. The format code name. This is what you or the user writes between percent symbols to
 *    specify the format code.
 * 2. The function object to associate with the format code.
 * 3. The format type index.
 *
 * ### Untyped format codes
 *
 * To use untyped format codes you can fill any map object with the values. The keys are the format
 * code names and the values are the function objects.
 *
 * ### Format code parameters
 *
 * Format codes may have parameters, which are indicated by appending a colon character and any
 * string to the format code. This additional string is passed to the function associated with the
 * format code. See the {@link Demo} file for an example.
 *
 * ### Default format codes
 *
 * Default format codes are built-in format codes that provide standard functionality. Below is
 * a table of the default format codes.
 *
 * <pre>
 *
 * |  Name           |  Type          |  Description                                                |
 * |  ---------------|----------------|-----------------------------------------------------------  |
 * |  !a             |  Early         |  Directs the format function to require that all conditions |
 * |                 |                |  / significant conditions within a conditional group are    |
 * |                 |                |  satisfied to include the segment in the output text.       |
 *
 * </pre>
 *
 * ## Escape sequences
 *
 * There are three operators used by the format strings: % { }
 *
 * The escape character is the backslash: \
 *
 * For consistency, any time one or more backslash characters are followed by %, {, or }, the
 * backslash characters are treated as escape characters even if the escape sequence was not
 * required in that context.
 *
 * Consecutive backslashes which precede one of %, {, or } cancel out in pairs. For example,
 * two backslashes preceding a curly brace result in one literal backslash and the curly brace
 * may still be consumed as an operator. Three backslashes preceding a curly brace result in
 * one literal backslash and one literal curly brace.
 *
 * The operator characters can be included as literal characters without a backslash as long as the
 * position of the character does not cause the character to be consumed as an operator. If you are
 * unsure, it is safe to always escape the operator characters when intending to use them literally.
 *
 */
class FormatStrConstructor {
    static __New() {
        this.DeleteProp('__New')
        this.__Initialize()
    }
    /**
     * The purpose of {@link FormatStrConstructor.Initialize} is to give external code a meaningful
     * entrypoint for invoking the initialization logic. The following information explains why
     * {@link FormatStrConstructor.Initialize} just deletes itself, and is intended for readers
     * who do not yet have a strong understanding of AutoHotkey's class system.
     *
     * When AutoHotkey processes the {@link https://www.autohotkey.com/docs/v2/Scripts.htm#auto auto-execute thread},
     * it proceeds in top-down order until reaching the end.
     *
     * Class objects are initialized when the auto-execute thread reaches the class definition, or
     * when the class is first referenced, whichever occurs first.
     *
     * In the case of {@link FormatStrConstructor}, the class initialization logic includes setting
     * a number of global variables. A subset of these global variables might be needed by external
     * code to prepare the functions and options it will use.
     *
     * If {@link FormatStrConstructor} has not yet been referenced or reached in the auto-execute
     * thread, using the global variables will throw an unset var error.
     *
     * To handle this, this library's documentation directs the user to call
     * {@link FormatStrConstructor.Initialize} to set the global variables with their values.
     *
     * In some cases, the call to {@link FormatStrConstructor.Initialize} will be the first time
     * {@link FormatStrConstructor} was referenced. When this is true, AutoHotkey will automatically
     * call {@link FormatStrConstructor.__New} BEFORE calling {@link FormatStrConstructor.Initialize}.
     * If both methods are defined to initialize the values, then the values will be initialized
     * twice consecutively, which is a waste of processing time and also can cause issues depending
     * on the initialization logic.
     *
     * In other cases, the call to {@link FormatStrConstructor.Initialize} will not be the first
     * time {@link FormatStrConstructor} was referenced, and so re-initializing the values might
     * incidentally overwrite the existing values depending on the initialization logic.
     *
     * Consequently, the optimal approach is to define {@link FormatStrConstructor.Initialize} to
     * do nothing. If the call to {@link FormatStrConstructor.Initialize} is also the first time
     * {@link FormatStrConstructor} is referenced, then {@link FormatStrConstructor.__New} is called
     * and the values are still initialized. If the call to {@link FormatStrConstructor.Initialize}
     * is not the first time {@link FormatStrConstructor} is referenced, then the values are
     * already initialized and we don't want to re-initialize them.
     *
     * Here is the actual sequence of execution that occurs when a call to
     * {@link FormatStrConstructor.Initialize} is the first time {@link FormatStrConstructor} is
     * referenced:
     *
     * 1. Code calls {@link FormatStrConstructor.Initialize}.
     * 2. AutoHotkey calls `FormatStrConstructor.__Init` (method defined by AutoHotkey not seen in our code).
     * 3. AutoHotkey calls `FormatStrConstructor.Options.__Init` (method defined by AutoHotkey not seen in our code).
     * 4. AutoHotkey calls {@link FormatStrConstructor.__New}.
     * 5. The body of {@link FormatStrConstructor.__New} calls {@link FormatStrConstructor.__Initialize}.
     * 6. The original call to {@link FormatStrConstructor.Initialize} is finally processed, which
     *    simply deletes itself so future calls will throw an error.
     *
     * This avoids the issue of double-consecutive-initialization while still providing a meaningful
     * method for callers to use to set the global variables.
     */
    static Initialize() {
        if this.HasOwnProp('Initialize') {
            this.DeleteProp('Initialize')
        }
    }
    ; Do not call "__Initialize"; call "Initialize" instead.
    static __Initialize() {
        global FORMATSTR_TYPE_INDEX_CONDITIONALGROUP
        , FORMATSTR_TYPE_INDEX_DEFAULTFORMATCODE
        , FORMATSTR_TYPE_INDEX_FORMATCODE
        , FORMATSTR_TYPE_INDEX_FORMATSPECIFIER
        , FORMATSTR_TYPE_INDEX_PLAINTEXT
        , FORMATSTR_TYPE_INDEX_SIGNIFICANTCONDITION
        , FORMATSTR_TYPE_INDEX_SIMPLECONDITION
        this.DeleteProp('__New')
        FormatStr_SetConstants()
        prototypes := this.Prototypes := FormatStr_PrototypeCollection()
        prototypes.Capacity := 8
        for name in [ 'ConditionalGroup', 'DefaultFormatCode', 'FormatCode', 'FormatSpecifier', 'PlainText', 'SignificantCondition', 'SimpleCondition' ] {
            proto := FormatStrToken_%name%.Prototype
            prototypes.Push(proto)
            FORMATSTR_TYPE_INDEX_%StrUpper(name)% := proto.TypeIndex := prototypes.Length
        }
        this.CompareStringsEx := DllCall('GetProcAddress', 'ptr', DllCall('GetModuleHandleW', 'wstr', 'kernel32', 'ptr'), 'astr', 'CompareStringEx', 'ptr')
        this.FormatCodeTypes := [
            FORMATSTR_FORMATCODE_TYPE_CALL_EARLY
          , FORMATSTR_FORMATCODE_TYPE_CALL_STANDARD
        ]
        this.DefaultFormatCodes := FormatStr_FormatCodesCollection(
            '!a', FormatStr_FormatCode_AllSpecifiers, FORMATSTR_FORMATCODE_TYPE_CALL_EARLY
        )
        defaultFormatCodeMap := this.defaultFormatCodeMap := Map()
        for name in this.DefaultFormatCodes {
            defaultFormatCodeMap.Set(name, String(A_Index), String(A_Index), name)
        }
        this.DefaultSpecifierCodes := Map(
        )
        this.DefaultFormatCodes.Default :=
        defaultFormatCodeMap.Default :=
        this.DefaultSpecifierCodes.Default := ''
    }
    static GetPrototypes(Base) {
        if not Base is Array {
            throw TypeError('``Base`` must inherit from ``Array``.', -1)
        }
        result := FormatStr_PrototypeCollection()
        prototypes := this.Prototypes
        result.Length := prototypes.Length
        _base := _GetBase(FormatStrTokenBase.Prototype)
        ObjSetBase(_base, Base)
        base_formatSpecifier := _GetBase(FormatStrToken_FormatSpecifierBase.Prototype)
        ObjSetBase(base_formatSpecifier, _base)
        _Proc([ FORMATSTR_TYPE_INDEX_CONDITIONALGROUP, FORMATSTR_TYPE_INDEX_PLAINTEXT ], _base)
        _Proc(
            [   FORMATSTR_TYPE_INDEX_FORMATCODE
              , FORMATSTR_TYPE_INDEX_FORMATSPECIFIER
              , FORMATSTR_TYPE_INDEX_SIGNIFICANTCONDITION
              , FORMATSTR_TYPE_INDEX_SIMPLECONDITION
            ]
          , base_formatSpecifier
        )
        _Proc([ FORMATSTR_TYPE_INDEX_DEFAULTFORMATCODE ], prototypes[FORMATSTR_TYPE_INDEX_FORMATCODE])

        return result

        _GetBase(proto) {
            local base := []
            for prop in proto.OwnProps() {
                base.DefineProp(prop, proto.GetOwnPropDesc(prop))
            }
            return base
        }
        _Proc(indices, base) {
            for i in indices {
                result[i] := _GetBase(prototypes[i])
                ObjSetBase(result[i], base)
            }
        }
    }

    __New(FormatSpecifierNames, Options?) {
        options := FormatStrConstructor.Options(Options ?? unset)
        names := FormatStr_QuickSort(
            FormatSpecifierNames
          , FormatStr_SortCompare.Bind(
                FormatStrConstructor.CompareStringsEx
              , options.SortLocaleName
              , options.SortFlags
              , options.SortNLSVersionInfo
            )
        )
        namesMap := Map()
        namesMap.CaseSense := options.CaseSense
        namesMap.Default := ''
        for s in FormatSpecifierNames {
            namesMap.Set(s, String(A_Index))
        }
        this.Constructor := Class()
        this.Constructor.Base := FormatStr
        proto := this.Constructor.Prototype := {
            Callback: options.Callback
          , CaseSense: options.CaseSense
          , DefaultOperators: options.DefaultOperators
          , DefaultOperatorsLowerCode: options.DefaultOperatorsLowerCode
          , FormatCodes: options.FormatCodes
          , SpecifierCodes: options.SpecifierCodes
          , StrCapacity: options.StrCapacity
          , SubstringPattern: _ProcNames(FormatSpecifierNames, options.CaseSense)
          , NamesMap: namesMap
          , Names: FormatSpecifierNames
          , __Class: FormatStr.Prototype.__Class
        }
        ObjSetBase(proto, FormatStr.Prototype)
        index := 0
        if options.FormatCodes {
            proto.FormatCodeMap := Map()
            _ProcCodes(&index, proto.FormatCodeMap, options.FormatCodes)
        }
        index := 0
        proto.SpecifierCodeMap := Map()
        ; Add the defaults first so the keys can be overridden if the user is using a same key.
        _ProcCodes(&index, proto.SpecifierCodeMap, FormatStrConstructor.DefaultSpecifierCodes)
        if options.SpecifierCodes {
            _ProcCodes(&index, proto.SpecifierCodeMap, options.SpecifierCodes)
        }

        _ProcCodes(&index, mapObj, codes) {
            if !mapObj.Count {
                mapObj.CaseSense := options.CaseSense
                mapObj.Default := ''
            }
            for name in codes {
                mapObj.Set(name, String(++index), String(index), name)
            }
        }

        _ProcNames(FormatSpecifierNames, CaseSense) {
            first := ''
            remainder := ''
            VarSetStrCapacity(&first, FormatSpecifierNames.Length)
            VarSetStrCapacity(&remainder, FormatSpecifierNames.Length * 16)
            for s in FormatSpecifierNames {
                c := SubStr(s, 1, 1)
                if !InStr(first, c, CaseSense) {
                    first .= c
                }
                remainder .= SubStr(s, 2) '|'
            }
            return (
                '(?<open>\{)'
                '?%'
                '(?<specifier>'
                    '(?:'
                        '(?<name>'
                            '[' first ']'
                            '(?:'
                                remainder
                            ')'
                        ')'
                        '(?::(?<code>\w+))?'
                    ')'
                '|'
                    '.+?'
                ')'
                '%(?<close>\})?'
            )
        }
    }
    Call(FormatStr) {
        return this.Constructor.Call(FormatStr)
    }

    class Options {
        static Default := {
            Callback: ''
          , CaseSense: false
          , DefaultOperators: '[\x{2000}-\x{2009}]'
          , DefaultOperatorsLowerCode: 0x2000
          , FormatCodes: ''
          , SortLocaleName: 0
          , SortFlags: 0
          , SortNLSVersionInfo: 0
          , SpecifierCodes: ''
          , StrCapacity: 1024
        }
        static Call(Options?) {
            if IsSet(Options) {
                o := {}
                d := this.Default
                for prop in d.OwnProps() {
                    o.%prop% := HasProp(Options, prop) ? Options.%prop% : d.%prop%
                }
                return o
            } else {
                return this.Default.Clone()
            }
        }
    }
}
class FormatStr {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.FormatCodes := proto.FormatCodeMap := proto.SpecifierCodes := proto.SpecifierCodeMap := proto.GlobalFormatCodes := ''
    }
    __New(FormatStr) {
        _formatStr := ''
        VarSetStrCapacity(&_formatStr, StrLen(FormatStr))

        ; The purpose of this block is to shave off a few milliseconds of processing.

        ; The block opens by checking `this.DefaultOperators`, which is a value specified by
        ; option `Options.DefaultOperators` when calling `FormatStrConstructor.Prototype.__New`.
        ; The default value is a regex pattern that spans a unicode code point range. These
        ; are semi-arbitrary, chosen because they are 2-byte characters that are very unlikely to be
        ; used.

        ; If `this.DefaultOperators` matches with `FormatStr`, then the values assigned to each
        ; of the below variables are checked one at a time against `FormatStr` until all variables
        ; have been assigned a character that does not exist in `FormatStr`.

        ; If `this.DefaultOptions` does not match with `FormatStr`, then we know none of the characters
        ; exist in `FormatStr`, and can assign each without checking. The idea is that since it is
        ; unlikely that anyone will use one of these characters while also using this library,
        ; this will almost always result in a net performance gain, albeit a minor one.

        ; To similarly minded folk, if you know your input strings will contain a character in
        ; the default range, you can assign a new pattern to `Options.DefaultOperators`. Don't
        ; forget to set `Options.DefaultOperatorsLowerCode` to the correct number.

        n := this.DefaultOperatorsLowerCode - 1
        if RegExMatch(FormatStr, this.DefaultOperators, &match) {
            ++n
            LITERAL_BACKSLASH := this.LITERAL_BACKSLASH := _GetChar()
            ++n
            LITERAL_CLOSE := this.LITERAL_CLOSE := _GetChar()
            ++n
            LITERAL_PERCENT := this.LITERAL_PERCENT := _GetChar()
            ++n
            LITERAL_OPEN := this.LITERAL_OPEN := _GetChar()
            ++n
            TOKEN_FORMAT_CODE := this.TOKEN_FORMAT_CODE := _GetChar()
            ++n
            TOKEN_FORMAT_CODE_DEFAULT := this.TOKEN_FORMAT_CODE_DEFAULT := _GetChar()
            ++n
            TOKEN_FORMAT_SPECIFIER := this.TOKEN_FORMAT_SPECIFIER := _GetChar()
            ++n
            TOKEN_SIGNIFICANT_CONDITION := this.TOKEN_SIGNIFICANT_CONDITION := _GetChar()
        } else {
            LITERAL_BACKSLASH := this.LITERAL_BACKSLASH := Chr(++n)
            LITERAL_CLOSE := this.LITERAL_CLOSE := Chr(++n)
            LITERAL_PERCENT := this.LITERAL_PERCENT := Chr(++n)
            LITERAL_OPEN := this.LITERAL_OPEN := Chr(++n)
            TOKEN_FORMAT_CODE := this.TOKEN_FORMAT_CODE := Chr(++n)
            TOKEN_FORMAT_CODE_DEFAULT := this.TOKEN_FORMAT_CODE_DEFAULT := Chr(++n)
            TOKEN_FORMAT_SPECIFIER := this.TOKEN_FORMAT_SPECIFIER := Chr(++n)
            TOKEN_SIGNIFICANT_CONDITION := this.TOKEN_SIGNIFICANT_CONDITION := Chr(++n)
        }

        ; The token objects require references to various values. To accommodate this, this block
        ; creates prototype objects and constructor class objects for each of the token classes
        ; and assigns properties with the needed values.
        prototype := []
        prototype.TOKEN_FORMAT_SPECIFIER := TOKEN_FORMAT_SPECIFIER
        prototype.TOKEN_SIGNIFICANT_CONDITION := TOKEN_SIGNIFICANT_CONDITION
        prototype.Names := this.Names
        prototypes := FormatStrConstructor.GetPrototypes(prototype)
        constructors := this.Constructors := FormatStr_ConstructorCollection()
        constructors.Capacity := prototypes.Length
        for prototype in prototypes {
            constructors.Push(Class())
            constructors[A_Index].Base := %prototype.__Class%
            constructors[A_Index].Prototype := prototype
        }
        ; Handles the format codes.
        prototypes[FORMATSTR_TYPE_INDEX_FORMATCODE].FormatCodes := this.FormatCodes
        formatCodeMap := prototypes[FORMATSTR_TYPE_INDEX_FORMATCODE].FormatCodeMap := this.FormatCodeMap
        if this.FormatCodes {
            globalFormatCodes := this.GlobalFormatCodes := []
        } else {
            prototypes[FORMATSTR_TYPE_INDEX_FORMATCODE].DefineProp('FormatCodeFunction', { Value: '' })
            globalFormatCodes := prototypes[FORMATSTR_TYPE_INDEX_CONDITIONALGROUP].FormatCodes := ''
        }
        ; Handles the specifier codes.
        prototypes[FORMATSTR_TYPE_INDEX_FORMATSPECIFIER].Base.SpecifierCodes :=
        prototypes[FORMATSTR_TYPE_INDEX_FORMATCODE].SpecifierCodes := this.SpecifierCodes
        specifierCodeMap := prototypes[FORMATSTR_TYPE_INDEX_FORMATSPECIFIER].Base.SpecifierCodeMap :=
        prototypes[FORMATSTR_TYPE_INDEX_FORMATCODE].SpecifierCodeMap := this.SpecifierCodeMap
        if !this.SpecifierCodes {
            prototypes[FORMATSTR_TYPE_INDEX_FORMATSPECIFIER].Base.DefineProp('SpecifierCodeFunction', { Value: '' })
        }
        defaultFormatCodes :=
        prototypes[FORMATSTR_TYPE_INDEX_CONDITIONALGROUP].DefaultFormatCodes :=
        prototypes[FORMATSTR_TYPE_INDEX_DEFAULTFORMATCODE].FormatCodes :=
        FormatStrConstructor.DefaultFormatCodes
        defaultFormatCodeMap :=
        prototypes[FORMATSTR_TYPE_INDEX_CONDITIONALGROUP].DefaultFormatCodeMap :=
        prototypes[FORMATSTR_TYPE_INDEX_DEFAULTFORMATCODE].FormatCodeMap :=
        FormatStrConstructor.DefaultFormatCodeMap
        globalDefaultFormatCodes := this.GlobalDefaultFormatCodes := []
        formatCodeParams := prototypes[FORMATSTR_TYPE_INDEX_FORMATCODE].FormatCodeParams := FormatStr_FormatCodeParamsCollection()

        pos := 1
        ; The tokenizer makes three passes over `FormatStr`. The first pass handles any escape
        ; sequences. For consistency, all backslashes that precede a curly brace ( }{ ) or percent ( % )
        ; are treated as escape characters, whether or not the escape sequence was necessary in that
        ; context. Here we process escape sequences and replace with tokens indicating literal
        ; characters, which will later be re-replaced with the correct character.
        while RegExMatch(FormatStr, '(.*)(\\+)([{}%])', &match, pos) {
            pos := match.Pos + match.Len
            _formatStr .= match[1]
            if match.Len[2] == 1 {
                switch match[3] {
                    case '{': _formatStr .= LITERAL_OPEN
                    case '}': _formatStr .= LITERAL_CLOSE
                    case '%': _formatStr .= LITERAL_PERCENT
                }
            } else {
                loop Floor(match.Len[2] / 2) {
                    _formatStr .= LITERAL_BACKSLASH
                }
                if Mod(match.Len[2], 2) {
                    switch match[3] {
                        case '{': _formatStr .= LITERAL_OPEN
                        case '}': _formatStr .= LITERAL_CLOSE
                        case '%': _formatStr .= LITERAL_PERCENT
                    }
                }
            }
        }
        _formatStr .= SubStr(FormatStr, pos)
        pos := 1
        if this.CaseSense {
            pattern := this.SubstringPattern
        } else {
            pattern := 'i)' this.SubstringPattern
        }
        namesMap := this.NamesMap
        ; The second pass is over `_formatStr` which now has all literal backslashes, curly braces
        ; and percents removed and replaced with tokens. `this.SubstringPattern` is the output from
        ; processing the names into a regex pattern. If the format specifier is directly enclosed in
        ; brackets, e.g. "{%line%}", then the token used is TOKEN_SIGNIFICANT_CONDITION. This is
        ; because that is the syntax for specifying a significant condition. If the format
        ; specifier is not enclosed directly in brackets, e.g. "{Extra: %extra%`n}", then the token
        ; used is TOKEN_FORMAT_SPECIFIER. Following the token is the index of the format specifier, which
        ; are arbitrary integers assigned in `FormatStrConstructor.Prototype.__New`. When the format
        ; string is processed later, the index is used to get the name of the format specifier at that
        ; location.
        while RegExMatch(_formatStr, pattern, &match, pos) {
            pos := match.Pos
            ; If the text between percent symbols matches with a format specifier name
            name := _ReplaceLiteralTokens(match['name'])
            if index := namesMap.Get(name) {
                ; If the format specifier is encompassed by curly braces
                if match['open'] && match['close'] {
                    ; If there is a specifier code
                    if match['code'] {
                        ; If specifier codes were provided
                        if specifierCodeMap {
                            code := _ReplaceLiteralTokens(match['code'])
                            ; If the specifier code matches with one of the provided specifier codes
                            if _index := specifierCodeMap.Get(code) {
                                _formatStr := StrReplace(_formatStr, match[0], TOKEN_SIGNIFICANT_CONDITION index ':' _index)
                            } else {
                                _ThrowMissingSpecifierCode(code)
                            }
                        } else {
                            _ThrowNoSpecifierCodes(code)
                        }
                    } else {
                        _formatStr := StrReplace(_formatStr, match[0], TOKEN_SIGNIFICANT_CONDITION index)
                    }
                } else {
                    if match['code'] {
                        if specifierCodeMap {
                            code := _ReplaceLiteralTokens(match['code'])
                            if _index := specifierCodeMap.Get(code) {
                                _formatStr := StrReplace(_formatStr, '%' match['specifier'] '%', TOKEN_FORMAT_SPECIFIER index ':' _index)
                            } else {
                                _ThrowMissingSpecifierCode(code)
                            }
                        } else {
                            _ThrowNoSpecifierCodes(code)
                        }
                    } else {
                        _formatStr := StrReplace(_formatStr, '%' match['specifier'] '%', TOKEN_FORMAT_SPECIFIER index)
                    }
                }
            } else {
                code := _ReplaceLiteralTokens(match['specifier'])
                if posColon := InStr(code, ':') {
                    formatCode := SubStr(code, 1, posColon - 1)
                    formatCodeParams.Push(SubStr(code, posColon + 1))
                    _index := ':' formatCodeParams.Length
                } else {
                    formatCode := code
                    _index := ''
                }
                ; If the text does not match and if format codes have been supplied, treat it as a format code
                if formatCodeMap {
                    if index := formatCodeMap.Get(formatCode) {
                        _formatStr := StrReplace(_formatStr, '%' match['specifier'] '%', TOKEN_FORMAT_CODE index _index)
                    } else if defaultFormatCodeMap.Has(formatCode) {
                        _formatStr := StrReplace(_formatStr, '%' match['specifier'] '%', TOKEN_FORMAT_CODE_DEFAULT defaultFormatCodeMap.Get(formatCode) _index)
                    } else {
                        ; If you get this error it means you provided a set of format codes but this
                        ; specific code was not found in the set. Check the spelling and case sense
                        ; option (default is off).
                        throw UnsetItemError('Missing format code.', -1, code)
                    }
                } else if defaultFormatCodeMap.Has(formatCode) {
                    _formatStr := StrReplace(_formatStr, '%' match['specifier'] '%', TOKEN_FORMAT_CODE_DEFAULT defaultFormatCodeMap.Get(formatCode) _index)
                } else {
                    ; If you get this error, it means that, in your format string, there is text enclosed
                    ; by percent symbols that was not found in the list of format specifier names.
                    ; If you aren't using format specifier codes, check the spelling and case sense
                    ; option (default is off).
                    throw Error('A format code was included in the format string, but no format codes have been supplied.', -1, code)
                }
            }
        }
        tokens := this.Tokens := FormatStr_TokenCollection()
        pos := 1
        pattern := '([' TOKEN_FORMAT_CODE TOKEN_FORMAT_CODE_DEFAULT TOKEN_FORMAT_SPECIFIER TOKEN_SIGNIFICANT_CONDITION '])(\d+)(?::(\d+))?'
        ; The third pass generates the token objects in the order in which the substrings appear
        ; in the format string, separating out the conditional groups to be handled separately
        ; from the other text.
        while RegExMatch(_formatStr, 's)([^{]*)\{(.+?)\}', &match, pos) {
            pos := match.Pos + match.Len
            ; If there is preceding text, process it separately.
            if match.Len[1] {
                _Proc(1, tokens, globalFormatCodes, FORMATSTR_TYPE_INDEX_SIMPLECONDITION)
            }
            ; If the text between the brackets contains one or more of TOKEN_FORMAT_SPECIFIER or TOKEN_SIGNIFICANT_CONDITION,
            ; process the text as a conditional group.
            if RegExMatch(match[2], pattern) {
                tokens.Push(constructors[FORMATSTR_TYPE_INDEX_CONDITIONALGROUP].Call(tokens.Length + 1, match[2]))
                _Proc(2, tokens[-1].Tokens, tokens[-1].FormatCodes, FORMATSTR_TYPE_INDEX_SIGNIFICANTCONDITION, tokens[-1])
                ; If the conditional group has one or more significant conditions
                if tokens[-1][4] {
                    ; This separates the significant condition tokens from the others so we can check those
                    ; first and fail early to avoid wasting processing time.
                    significantConditions := tokens[-1].SignificantConditions := FormatStr_TokenCollection()
                    for _token in tokens[-1].Tokens {
                        if _token.TypeIndex == FORMATSTR_TYPE_INDEX_SIGNIFICANTCONDITION {
                            significantConditions.Push(_token)
                        }
                    }
                } else {
                    ; Similarly, this separates the format specifier tokens from the others so we
                    ; can check those first and fail early to avoid wasting processing time.
                    replacmentStrings := tokens[-1].FormatSpecifiers := FormatStr_TokenCollection()
                    for _token in tokens[-1].Tokens {
                        if _token.TypeIndex == FORMATSTR_TYPE_INDEX_FORMATSPECIFIER {
                            replacmentStrings.Push(_token)
                        }
                    }
                }
            ; If the text does not have either token, process the text as plain text.
            } else {
                tokens.Push(constructors[FORMATSTR_TYPE_INDEX_PLAINTEXT].Call(tokens.Length + 1, '{' match[2] '}'))
            }
        }
        ; Process any trailing text.
        if pos !== StrLen(_formatStr) {
            match := [SubStr(_formatStr, pos)]
            _Proc(1, tokens, globalFormatCodes, FORMATSTR_TYPE_INDEX_SIMPLECONDITION)
        }

        ; Delete any empty format code arrays
        for token in this.Tokens {
            if token.TypeIndex == FORMATSTR_TYPE_INDEX_CONDITIONALGROUP {
                if IsObject(token.FormatCodes) && !token.FormatCodes.Length {
                    token.DefineProp('FormatCodes', { Value: '' })
                }
            }
        }

        return

        _GetChar() {
            while InStr(FormatStr, Chr(n)) {
                n++
            }
            return Chr(n)
        }
        ; Parameter `significantConditionIndex` specifies what type index should be used when
        ; encountering TOKEN_SIGNIFICANT_CONDITION. If we find a TOKEN_SIGNIFICANT_CONDITION outside
        ; of a conditional group, then it is actually just a conditional group with one condition
        ; and no extra text. I included class `FormatStrToken_SimpleCondition` to identify
        ; these cases so later our code can make quick work of the format specifier and avoid all
        ; the extra logic needed to handle the other types.
        _Proc(index, tokens, formatCodes, significantConditionIndex, token := '') {
            local pos, _match
            pos := 1
            while RegExMatch(match[index], pattern, &_match, pos) {
                ; Treat leading text as plain text.
                if _match.Pos !== pos {
                    tokens.Push(constructors[FORMATSTR_TYPE_INDEX_PLAINTEXT].Call(tokens.Length + 1, SubStr(_ReplaceLiteralTokens(match[index]), pos, _match.Pos - pos)))
                }
                switch _match[1] {
                    case TOKEN_FORMAT_CODE:
                        if formatCodes is FormatStr_FormatCodesCollection {
                            formatCode := formatCodeMap.Get(_match[2])
                            formatCodeFunction := formatCodes.Get(defaultFormatCode, &formatCodeType)
                            switch formatCodeType {
                                case FORMATSTR_FORMATCODE_TYPE_CALL_EARLY:
                                    formatCodeFunction(formatCode, _match[3], token, this)
                                case FORMATSTR_FORMATCODE_TYPE_CALL_STANDARD:
                                    if token {
                                        formatCodes.Push(constructors[FORMATSTR_TYPE_INDEX_FORMATCODE].Call(tokens.Length + 1, _match[2], _match[3]))
                                    } else {
                                        globalFormatCodes.Push(constructors[FORMATSTR_TYPE_INDEX_FORMATCODE].Call(tokens.Length + 1, _match[2], _match[3]))
                                    }
                            }
                        } else {
                            formatCodes.Push(constructors[FORMATSTR_TYPE_INDEX_FORMATCODE].Call(tokens.Length + 1, _match[2], _match[3]))
                        }
                    case TOKEN_FORMAT_CODE_DEFAULT:
                        defaultFormatCode := defaultFormatCodeMap.Get(_match[2])
                        formatCodeFunction := defaultFormatCodes.Get(defaultFormatCode, &formatCodeType)
                        switch formatCodeType {
                            case FORMATSTR_FORMATCODE_TYPE_CALL_EARLY:
                                formatCodeFunction(defaultFormatCode, _match[3], token, this)
                            case FORMATSTR_FORMATCODE_TYPE_CALL_STANDARD:
                                if token {
                                    token.AddDefaultFormatCode(constructors[FORMATSTR_TYPE_INDEX_DEFAULTFORMATCODE].Call(tokens.Length + 1, _match[2], _match[3]))
                                } else {
                                    globalDefaultFormatCodes.Push(constructors[FORMATSTR_TYPE_INDEX_DEFAULTFORMATCODE].Call(tokens.Length + 1, _match[2], _match[3]))
                                }
                        }
                    case TOKEN_FORMAT_SPECIFIER:
                        tokens.Push(constructors[FORMATSTR_TYPE_INDEX_FORMATSPECIFIER].Call(tokens.Length + 1, _match[2], _match[3]))
                    case TOKEN_SIGNIFICANT_CONDITION:
                        tokens.Push(constructors[significantConditionIndex].Call(tokens.Length + 1, _match[2], _match[3]))
                }
                pos := _match.Pos + _match.Len
            }
            if pos !== StrLen(match[index]) {
                ; Treat trailing text as plaintext.
                tokens.Push(constructors[FORMATSTR_TYPE_INDEX_PLAINTEXT].Call(tokens.Length + 1, _ReplaceLiteralTokens(SubStr(match[index], pos, StrLen(match[index]) - pos + 1))))
            }
        }
        _ReplaceLiteralTokens(str) => StrReplace(StrReplace(StrReplace(StrReplace(str, LITERAL_BACKSLASH, '\'), LITERAL_CLOSE, '}'), LITERAL_PERCENT, '%'), LITERAL_OPEN, '{')
        _ThrowMissingSpecifierCode(code) {
            ; If you get this error it means that your format string contains a format specifier that
            ; is followed by a colon character and some text, and also you provided a set of specifier
            ; codes, but that particular code is absent from the set. Check the spelling and case sense
            ; option (default is off).
            throw UnsetItemError('Missing specifier code.', -1, code)
        }
        _ThrowNoSpecifierCodes(code) {
            ; If you get this error it means that your format string contains a format specifier that
            ; is followed by a colon character and some text, but you did not provide any specifier
            ; codes (which are passed as an option to `FormatStrConstructor`.
            throw Error('A specifier code was included in a format specifier, but no specifer codes have been supplied.', -1, code)
        }
    }

    Call(Params := '', Callback?) {
        if !IsSet(Callback) {
            Callback := this.Callback
        }
        LITERAL_BACKSLASH := this.LITERAL_BACKSLASH
        LITERAL_CLOSE := this.LITERAL_CLOSE
        LITERAL_PERCENT := this.LITERAL_PERCENT
        LITERAL_OPEN := this.LITERAL_OPEN
        TOKEN_SIGNIFICANT_CONDITION := this.TOKEN_SIGNIFICANT_CONDITION
        TOKEN_FORMAT_SPECIFIER := this.TOKEN_FORMAT_SPECIFIER
        formatCodes := this.FormatCodes
        specifierCodes := this.SpecifierCodes
        tokens := this.Tokens
        str := ''
        VarSetStrCapacity(&str, this.StrCapacity)

        for token in tokens {
            switch token.TypeIndex {
                case FORMATSTR_TYPE_INDEX_CONDITIONALGROUP:
                    ; If the conditional group has one or more significant conditions
                    if token[4] {
                        ; One or more format specifiers specified as a significant condition
                        ; must be replaced by one or more characters for the text to be included
                        ; in the output.
                        replacementResults := []
                        replacementResults.Capacity := token.SignificantConditions.Length
                        ; Flag to indicate all format specifiers must be replaced with one or more
                        ; characters to satisfy the condition.
                        if token.Flags.Get(FORMATSTR_FLAG_ALLCONDITIONS) {
                            flag_replace := true
                            for _token in token.SignificantConditions {
                                replacementResults.Push(Callback(_token.FormatSpecifierName, Params, _token, token))
                                if !replacementResults[-1] {
                                    continue 2
                                }
                            }
                        } else {
                            flag_replace := false
                            for _token in token.SignificantConditions {
                                replacementResults.Push(Callback(_token.FormatSpecifierName, Params, _token, token))
                                if replacementResults[-1] {
                                    flag_replace := true
                                    break
                                }
                            }
                        }
                        if !flag_replace {
                            continue
                        }
                        _str := ''
                        VarSetStrCapacity(&_str, this.StrCapacity / 2)
                        for _token in token.Tokens {
                            switch _token.TypeIndex {
                                case FORMATSTR_TYPE_INDEX_PLAINTEXT:
                                    _str .= _token[2]
                                case FORMATSTR_TYPE_INDEX_FORMATSPECIFIER:
                                    if _token[3] {
                                        _str .= _token.SpecifierCodeFunction.Call(Callback(_token.FormatSpecifierName, Params, _token, token), Params, _token, token)
                                    } else {
                                        _str .= Callback(_token.FormatSpecifierName, Params, _token, token)
                                    }
                                case FORMATSTR_TYPE_INDEX_SIGNIFICANTCONDITION:
                                    if _token[3] {
                                        if replacementResults.Length {
                                            _str .= _token.SpecifierCodeFunction.Call(replacementResults.RemoveAt(1), Params, _token, token)
                                        } else {
                                            _str .= _token.SpecifierCodeFunction.Call(Callback(_token.FormatSpecifierName, Params, _token, token), Params, _token, token)
                                        }
                                    } else {
                                        if replacementResults.Length {
                                            _str .= replacementResults.RemoveAt(1)
                                        } else {
                                            _str .= Callback(_token.FormatSpecifierName, Params, _token, token)
                                        }
                                    }
                            }
                        }
                    } else {
                        ; One or more format specifiers must be replaced by one or more characters
                        ; for the text to be included in the output.
                        replacementResults := []
                        replacementResults.Capacity := token.FormatSpecifiers.Length
                        ; Flag to indicate all format specifiers must be replaced with one or more
                        ; characters to satisfy the condition.
                        if token.Flags.Get(FORMATSTR_FLAG_ALLCONDITIONS) {
                            flag_replace := true
                            for _token in token.FormatSpecifiers {
                                replacementResults.Push(Callback(_token.FormatSpecifierName, Params, _token, token))
                                if !replacementResults[-1] {
                                    continue 2
                                }
                            }
                        } else {
                            flag_replace := false
                            for _token in token.FormatSpecifiers {
                                replacementResults.Push(Callback(_token.FormatSpecifierName, Params, _token, token))
                                if replacementResults[-1] {
                                    flag_replace := true
                                    break
                                }
                            }
                        }
                        if !flag_replace {
                            continue
                        }
                        _str := ''
                        VarSetStrCapacity(&_str, this.StrCapacity / 2)
                        for _token in token.Tokens {
                            switch _token.TypeIndex {
                                case FORMATSTR_TYPE_INDEX_PLAINTEXT:
                                    _str .= _token[2]
                                case FORMATSTR_TYPE_INDEX_FORMATSPECIFIER:
                                    if _token[3] {
                                        if replacementResults.Length {
                                            _str .= _token.SpecifierCodeFunction.Call(replacementResults.RemoveAt(1), Params, _token, token)
                                        } else {
                                            _str .= _token.SpecifierCodeFunction.Call(Callback(_token.FormatSpecifierName, Params, _token, token), Params, _token, token)
                                        }
                                    } else {
                                        if replacementResults.Length {
                                            _str .= replacementResults.RemoveAt(1)
                                        } else {
                                            _str .= Callback(_token.FormatSpecifierName, Params, _token, token)
                                        }
                                    }
                            }
                        }
                    }
                    if token.FormatCodes {
                        for formatCode in token.FormatCodes {
                            formatCode.FormatCodeFunction.Call(&_str, Params, formatCode.Params, token)
                        }
                    }
                    if token[5] {
                        for defaultFormatCode in token.DefaultFormatCodes {
                            defaultFormatCode.FormatCodeFunction.Call(&_str, Params, formatCode.Params, token)
                        }
                    }
                    str .= _str
                case FORMATSTR_TYPE_INDEX_FORMATSPECIFIER:
                    if token[3] {
                        str .= token.SpecifierCodeFunction.Call(Callback(token.FormatSpecifierName, Params, token, ''), Params, token, '')
                    } else {
                        str .= Callback(token.FormatSpecifierName, Params, token, '')
                    }
                case FORMATSTR_TYPE_INDEX_PLAINTEXT:
                    str .= token[2]
                case FORMATSTR_TYPE_INDEX_SIMPLECONDITION:
                    if result := Callback(token.FormatSpecifierName, Params, token, '') {
                        if token[3] {
                            str .= token.SpecifierCodeFunction.Call(result, Params, token, '')
                        } else {
                            str .= result
                        }
                    }
            }
        }
        if this.GlobalFormatCodes {
            for formatCode in this.GlobalFormatCodes {
                formatCode.FormatCodeFunction.Call(&str, Params, formatCode.Params, '')
            }
        }
        for defaultFormatCode in this.GlobalDefaultFormatCodes {
            defaultFormatCode.FormatCodeFunction.Call(&str, Params, defaultFormatCode.Params, '')
        }

        return str
    }
}
