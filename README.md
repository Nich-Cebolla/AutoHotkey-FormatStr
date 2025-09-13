# AutoHotkey-FormatStr

An AutoHotkey (AHK) library for creating customizable and extensible text formatting logic to suit any project's needs.

## Introduction

`FormatStr` makes it easy to create a unique, customizable, and extensible text formatting system just like the standard printf-style format codes "%d", "%u", "%i", and the like. With a feature-rich API based on caller-defined callback functions, there's no limit to the possibilities.

The core functionality involves defining a list of symbols, called "format specifiers", which will ultimately be replaced by some data when producing the output text. Along with the format specifiers the caller must define one or more callback functions that facilitates the formatting logic. Format specifiers can contain any character except the colon and are enclosed in percent symbols to indicate that the text is a format specifier.

Format specifiers can be grouped together along with plain text in a "conditional group". A conditional group is a segment of the format string which will only be included in the output text if one or more of the format specifiers are replaced with one or more characters (that is, if all format specifiers are replaced with an empty string, none of the text is included in the output).

For example, say we are logging error information to file and we pass an error object to our logger, and it outputs the following text.

<pre>
File: C:\users\me\documents\AutoHotkey\lib\Script.ahk
Line: 100
Message: The object of type "Object" has no property named "prop".
Extra:
</pre>

That empty "Extra:" section is offputting and should be removed or handled in some way. `FormatStr` makes this easy.

## Demo

See file ["test\demo-FormatStr.ahk"](https://github.com/Nich-Cebolla/AutoHotkey-FormatStr/test/demo-FormatStr.ahk) for a demonstration of the library's functionality.

## How it works

Your code provides a list of symbols that are used by your format string, and `FormatStrConstructor`
returns a function that can be called to produce `FormatStr` objects. This documentation refers to
this function as "the constructor function".

Your code calls the constructor function with a format string. The format string encapsulates
the formatting logic you want for your output text. The constructor function processes your format
string into a series of tokens and returns a `FormatStr` object, which is a function you can call
to produce the output text. This documentation refers to this function as "the format function".

The format string which you pass to the constructor function contains symbols, "format specifiers", that will later be
replaced by text when you call the format function. Format specifiers are enclosed in a pair of percent symbols.

Your code calls the format function with zero to two parameters, and the format function returns the formatted text.

## Quick start

This section gives a basic explanation for using the class. I recommend also reviewing the
[demo](https://github.com/Nich-Cebolla/AutoHotkey-FormatStr/test/demo-FormatStr.ahk). The demo file can be run as-is.

1. Define format specifier names as an array of strings. These are the symbols that you or your
   users will enclose in percent symbols to specify a particular datum to include in the
   output text.
2. Define a callback function that handles the format specifier strings.
  - Parameters:
    1. The format specifier name.
    2. The value passed to the "Params" parameter of `FormatStr.Prototype.Call`.
    3. The token object.
    4. If the token object is part of a conditional group, the conditional group token object. Else,
       an empty string.
  - Returns: The string that replaces the format specifier.
3. Define a format string. The format string is what structures the output text.
4. (Optional) Define specifier codes and associated functions (see section "Specifier codes").
5. (Optional) Define format codes and associated functions (see section "Format codes").
6. (Optional) Create an options object.
7. Call the class constructors.
8. Call the `FormatStr` instance with zero to two parameters:
  1. Any value to pass to the callback.
  2. A callback function, if you didn't specify a function in the options or if you want to
     use a different one. If you pass a value to the second parameter, that function is used
     instead of the function that was passed to the options (if any).

```ahk
 ; Define format specifier names.
 names := [ "file", "line", "message", "extra", "what", "stack" ]
 ; Define a callback function
 FormatStr_Callback(SpecifierName, Params, Token, ConditionalGroupToken) {
     ; Expects an error object to be passed to `Params`.
     return Params.%SpecifierName%
 }
 ; Define a format string.
 _format := (
     'File: %file%::%line%`r`n'
     'Message: %message%`r`n'
     '{What: %what%`r`n}'    ; The text enclosed by the brackets will only be included if the
     '{Extra: %extra%`r`n}'  ; format specifier is replaced with one or more characters
 )
 ; Define an options object.
 options := { Callback: FormatStr_Callback }
 ; Call the class constructors.
 constructor := FormatStrConstructor(names, options)
 _formatStr := constructor(_format)
 ; Call the `FormatStr` instance.
 output := _formatStr(Error())
 ; Do something with the output.
 MsgBox(output)
```

## Glossary

This documentation uses the following terms.

- **Conditional group**: A group including one or more format specifiers, zero or more significant
  conditions, and zero or more literal strings.

- **Constructor function**: The value returned by `FormatStrConstructor.Prototype.__New`. The
  function object that takes a format string and produces an instance of `FormatStr`.

- **Default format codes**: The built-in format codes. Default format codes always begin with an
  exclamation point ( ! ).

- **Default specifier codes**: The built-in specifier codes. Default specifier codes always begin with
  an exclamation point ( ! ).

- **Format code**: A string enclosed in percent symbols ( % ) that is used as a flag to invoke some
  action defined by the caller.

- **Format code parameters**: A string appended to a format code separated by a colon character.
  The string is passed to the function associated with the format code.

- **Format code type**: A library-defined type system that is used to specify when the function
  associated with the format code should be called.

- **Format function**: The value returned by `FormatStr.Prototype.Call`. The function object
  that processes the format string and produces the output text.

- **Format specifier**: A keyword enclosed in percent symbols ( % ) that is intended to be
  replaced by data when the output text is being produced.

- **Format specifier name**: The string that is between the percent symbols of a format specifier.

- **Format string**: The string that defines the expected format of the output text, including
  conditional groups, format specifiers, and significant conditions.

- **Significant condition**: A format specifier that is within a conditional group that is enclosed
  in a pair of curly braces, e.g. "{What: {%what%}`n%extra%}". When one or more significant
  conditions are included in a conditional group, only the significant condition format specifiers
  count toward satisfying the condition to include the segment in the output text. That is,
  at least one of the significant conditions must be replaced with one or more characters for the
  entire group to be included in the output text. The other format specifiers do not count
  toward this condition.

- **Specifier code**: A string appended to a format specifier separated by a colon character.
  Specifier codes are used as a flag to invoke some action defined by the caller.

## Conditional groups

The primary use case for this library is to expose a means of systematically including text
segments in the output as a function of whether or not some data was available at the time
the output was produced. This is done by defining conditional groups.

You can include conditional text with one or more of the format specifiers by grouping
them in brackets.

If a conditional group contains only one format specifier, and if that format specifier is replaced
with an empty string, none of the surrounding text get included in the output.

If a conditional group contains multiple format specifiers, then at least one of the format
specifiers must be replaced with one or more characters for the group to be included in the
output.

```ahk
 names := [ "message", "extra" ]
 FormatStr_Callback(FormatSpecifierName, Params,) {
     return Params.%FormatSpecifierName%
 }
 constructor := FormatStrConstructor(names, { Callback: FormatStr_Callback })
 _formatStr := constructor( 'Message: %message%{; Extra: %extra%}')

 err1 := Error('Error')
 ; Only the message is included because nothing was passed to the parameter `Extra`.
 MsgBox(_formatStr(err1)) ; Message: Error

 err2 := Error('Error', , 'Extra info')
 ; Both values are included.
 MsgBox(_formatStr(err2)) ; Message: Error; Extra: Extra info
```

### Multiple format specifiers

`FormatStr` supports multiple format specifiers within a single conditional group. Only one
of the format specifiers must be replaced with one or more characters to be included in the
output.

```ahk
 names := [ "message", "extra" ]
 FormatStr_Callback(FormatSpecifierName, Params,) {
     return Params.%FormatSpecifierName%
 }
 constructor := FormatStrConstructor(names, { Callback: FormatStr_Callback })
 _formatStr := constructor( '{Message: %message%; Extra: %extra%}')

 err1 := Error('')
 ; No output.
 MsgBox(_formatStr(err1))

 err2 := Error('', , 'Extra info')
 ; Only one of the two are needed.
 MsgBox(_formatStr(err2)) ; Message: ; Extra: Extra info
```

### Significant conditions

Format specifier strings can be marked as a significant condition by enclosing the format specifier
string in curly braces with no additional text. When a conditional group contains one or more
significant conditions, the condition for including the segment in the output text changes. Only
the format specifiers marked as significant conditions count toward the condition; at least one
of the significant conditions must be replaced by one or more characters for the segment to be
included in the output text. A single conditional group may have zero or more significant
conditions.

```ahk
 names := [ "message", "what", "extra" ]
 FormatStr_Callback(FormatSpecifierName, Params,) {
 return Params.%FormatSpecifierName%
 }
 constructor := FormatStrConstructor(names, { Callback: FormatStr_Callback })
 _formatStr := constructor( '{Message: %message%; What: {%what%}; Extra: {%extra%}}')

 err1 := Error('Error', '', '')
 ; No output.
 MsgBox(_formatStr(err1))

 err2 := Error('Error', 'auto-execute', '')
 MsgBox(_formatStr(err2)) ; Message: Error; What: auto-execute; Extra:

 err3 := Error('Error', 'auto-execute', 'Extra info')
 MsgBox(_formatStr(err2)) ; Message: Error; What: auto-execute; Extra: Extra info
```

## Specifier codes

Specifier codes (and format codes) are a means for extending the library's functionality with
custom logic.

A specifier code is a string that occurs after a format specifier separated by a colon,
e.g. "%extra:1%" or "%extra:code-identifier%". Specifier codes may contain any character
except a colon.

The codes are associated with some function that is intended to make some changes to
the text. When the format function is called, if a token is associated with a specifier
code, the function associated with that code is called before adding that substring to
the output text.

### Default specifier codes

There are currently no default specifier codes.

### Custom specifier codes

When you define the functions which will be associated with the specifier codes, the
functions must accept one to four parameters:
1. The string that is to be adjusted.
2. The value passed to the "Params" parameter of `FormatStr.Prototype.Call`.
3. The token that produced the value passed to the first parameter.
4. If the token is part of a conditional group, the conditional group token. Else, an
   empty string.

See the [demo](https://github.com/Nich-Cebolla/AutoHotkey-FormatStr/test/demo-FormatStr.ahk) file for some examples.

## Format codes

Format codes (and specifier codes) are a means for extending the library's functionality with
custom logic.

A format code is a string that occurs between two percent symbols that is not one of
the format specifier names. For example, if my format specifier names are
[ "error", "what", "message" ]
and if my format string has "%myCode%" in it, "myCode" is interpreted as a format code.
Format codes may contain any character except a colon.

Format codes are associated with some function that is intended to make some changes to
the text.

Format codes are removed completely from the output text and are stored separately from
the other tokens.

### Format code scope

Format codes can be global, which causes its associated function to be called after the
entire output string has been constructed. Place a format code outside of a conditional group
to make it global.

Format codes can be conditional, which causes its associated function to be called
after the conditional group has been processed and only if the condition was satisfied.
Place a format code within a conditional group to make it local.

### Format code types

Format codes can be typed or untyped. There are currently two types:

- Early: Format codes of this type have their associated functions called within the body of
  `FormatStr.Prototype.__New` and are only called once. The values passed to the function
  are:

  1. The format code.
  2. If parameters were included with the format code, the parameters. Else, an empty string.
  3. If the format code is placed within a conditional group, the conditional group token object.
     else, an empty string.
  4. The `FormatStr` instance object.

- Standard: Format codes of this type have their associated functions called within the body of
  `FormatStr.Prototype.Call` when the output text is being generated. If the format code
  is placed within a conditional group (local scope), the associated functions are called after
  the group has finished processing, and only if the condition was satisfied. If the format code
  is not placed within a conditional group (global scope), the associated functions are called
  after the output text has been generated. The values passed to the function are:

  1. The string that is to be adjusted. This must be a `VarRef`.
  2. The value passed to the `Params` parameter of `FormatStr.Prototype.Call`.
  3. If parameters were included with the format code, the parameters. Else, an empty string.
  4. If the format code was within a conditional group, the conditional group token. Else,
     an empty string.

To refer to a specific type you will use one of the global variables which contains the type
index. Currently, the global variables are:
- FORMATSTR_FORMATCODE_TYPE_CALL_EARLY
- FORMATSTR_FORMATCODE_TYPE_CALL_STANDARD

If your code throws an unset variable error, call `FormatStr_SetConstants` somewhere before
your code refers to one of the variables.

To use typed format codes, you must get an instance of `FormatStr_FormatCodesCollection`
and use that as your container. `FormatStr_FormatCodesCollection` is a map object with
additional methods to facilitate using the types.

```ahk
 FormatStr_SetFlag(FormatCode, FormatCodeParams, ConditionalGroupToken, FormatStrObj) {
     global customFlag := 'flag_name'
     if ConditionalGroupToken {
         ConditionalGroupToken.Flags.Set(customFlag, 1)
     } else {
         throw Error('The format code may only be used within a conditional group.', -1, FormatCode)
     }
 }
 FormatStr_Process(&Str, Params, FormatCodeParams, ConditionalGroupToken) {
     if ConditionalGroupToken.Flags.Get(customFlag) {
         ; Do one thing
     } else {
         ; Do a different thing
     }
 }
 options := {
     FormatCodes: FormatStr_FormatCodesCollection(
         ; Format code name, function object, type index
         "flag", FormatStr_SetFlag, FORMATSTR_FORMATCODE_TYPE_CALL_EARLY
       , "proc", FormatStr_Process, FORMATSTR_FORMATCODE_TYPE_CALL_STANDARD
     )
  }
 constructor := FormatStrConstructor([ "message", "extra", "what" ], options)
```

You can add all of the format codes to the collection object when creating the object. The
values passed to the constructor are processed in groups of three in the order of:
1. The format code name. This is what you or the user writes between percent symbols to
   specify the format code.
2. The function object to associate with the format code.
3. The format type index, passed using one of the global variablse.

### Format code parameters

Format codes may have parameters, which are indicated by appending a colon character and any
string to the format code. This additional string is passed to the function associated with the
format code. See the [demo](https://github.com/Nich-Cebolla/AutoHotkey-FormatStr/test/demo-FormatStr.ahk) file for an example.

### Default format codes

Default format codes are built-in format codes that provide standard functionality. Below is
a table of the default format codes.

<pre>

|  Name           |  Type          |  Description                                                         |
|  ---------------|----------------|--------------------------------------------------------------------  |
|  !a             |  Early         |  Directs the format function to require that all conditions /        |
|                 |                |  significant conditions within a conditional group are satisfied to  |
|                 |                |  include the segment in the output text.                             |

</pre>


## Escape sequences

There are three operators used by the format strings: % { }

The escape character is the backslash: \

For consistency, any time one or more backslash characters are followed by %, {, or }, the
backslash characters are treated as escape characters even if the escape sequence was not
required in that context.

Consecutive backslashes which precede one of %, {, or } cancel out in pairs. For example,
two backslashes preceding a curly brace result in one literal backslash and the curly brace
may still be consumed as an operator. Three backslashes preceding a curly brace result in
one literal backslash and one literal curly brace.

The operator characters can be included as literal characters without a backslash as long as the
position of the character does not cause the character to be consumed as an operator. If you are
unsure, it is safe to always escape the operator characters when intending to use them literally.
