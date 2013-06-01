// # Module Iota
//
// A packrat parser combinator for Io.
//
//
// :licence: MIT
//   Copyright (c) 2013 Quildreen Motta <quildreen@gmail.com>
//
//   Permission is hereby granted, free of charge, to any person
//   obtaining a copy of this software and associated documentation files
//   (the "Software"), to deal in the Software without restriction,
//   including without limitation the rights to use, copy, modify, merge,
//   publish, distribute, sublicense, and/or sell copies of the Software,
//   and to permit persons to whom the Software is furnished to do so,
//   subject to the following conditions:
//
//   The above copyright notice and this permission notice shall be
//   included in all copies or substantial portions of the Software.
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//   NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//   LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//   OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//   WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Iota := Object clone

// ## {} State
//
// Represents each state a parser's input can be in.
//
// :: { input  : String
//    , index  : Number
//    , length : Number
//    , cache  : { Parser -> Result }
//    }
Iota State := Object clone do(
  input  := ""
  index  := 0
  length := 0
  cache  := Map clone

  // ### with(input, index)
  //
  // Constructs a new parser state for the given input, starting at the
  // `index`.
  //
  // :: @Iota/State => Number, Number -> Iota/State
  with := method(newInput, newIndex,
    result := clone
    result input  = newInput
    result index  = newIndex
    result length = newInput size - newIndex
    result
  )

  // ### slice(start[, end])
  //
  // Returns the text in the parser state's input between [start, end)
  //
  // :: @Iota/State => Number -> String
  // :: @Iota/State => Number, Number -> String
  slice := method(startIndex, endIndex,
    if(call argCount == 2,
      input exclusiveSlice(index + startIndex, index + endIndex)
    ,
      input inclusiveSlice(index + startIndex)
    )
  )

  // ### asString()
  //
  // Returns a textual representation of the parser's state.
  //
  // :: @Iota/State => () -> String
  asString := method(
    "Iota State(#{slice(0)})" interpolate
  )
)

// ## {} Result
//
// Represents the result of parsing something.
//
// :: Match State AST | Error State String
Iota Result := Object clone do(
  state := nil

  isError := method(
    isKindOf(Error)
  )

  isSuccess := method(
    isKindOf(Match)
  )

  // ### {} Error
  Error := clone do(
    // #### with(state, message)
    //
    // Returns a parsing error.
    //
    // :: @Iota/Result/Error => State, String -> Error<State, String>
    with := method(state, exception,
      result := clone
      result state = state
      result error := exception
      result
    )
  )

  // ### {} Match AST
  Match := clone do(
    // #### with(state, ast)
    //
    // Puts a value inside the Match container.
    //
    // :: @Iota/Result/Match => AST -> Match AST
    with := method(ast,
      result      := clone
      result state = state
      result ast  := ast
      result
    )
  )
)

// ## {} Parser
//
// The base parser for all other stuff.

Iota Parser := Object clone do(

)
