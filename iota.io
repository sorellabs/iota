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
    result := self clone
    result input  = newInput
    result index  = newIndex
    result length = newInput size - newIndex
    result
  )

  // ### consume(size)
  //
  // Advances size, returns the matched string.
  //
  // :: @Iota/State => Number -> Maybe String
  consume := method(size,
    if(size <= length,
      slice(0, size)
    ,
      nil
    )
  )

  // ### skip(size)
  //
  // Skips the amount of characters.
  //
  // :: @Iota/State => Number -> State
  skip := method(size,
    self with(input, index + size)
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
// :: Match<State, AST> | Error<State, String>
Iota Result := Object clone do(
  state := nil

  isError := method(
    isKindOf(Error)
  )

  isSuccess := method(
    isKindOf(Match)
  )

  isEmpty := method(
    state == nil
  )

  union := method(result,
    self chain(block(previous,
      result chain(block(new,
        self with(state, list(previous, new))
      ))
    ))
  )

  replace := method(value,
    self with(state, value)
  )

  // ### {} Error<A, B>
  Error := clone do(
    // #### with(state, message)
    //
    // Returns a parsing error.
    //
    // :: @Iota/Result/Error => A, B -> Error<A, B>
    with := method(state, exception,
      result       := self clone
      result state  = state
      result error := exception
      result
    )

    chain := method(f,
      f call(error)
    )
  )

  // ### {} Match<A, B>
  Match := clone do(
    // #### with(state, ast)
    //
    // Puts a value inside the Match container.
    //
    // :: @Iota/Result/Match => A, B -> Match<A, B>
    with := method(state, ast,
      result      := self clone
      result state = state
      result ast  := ast
      result
    )

    chain := method(f,
      f call(ast)
    )
  )
)

// ## {} Parser
//
// The base parser for all other stuff.

Iota Parser := Object clone do(
  state  := nil
  result := nil

  with := method(state, result,
    new       := self clone
    new state  = state
    new result = result
    new
  )

  fail := method(errorMessage,
    with(state, Iota Result Error with(state, errorMessage))
  )

  match := method(result, newState,
    with(newState, Iota Result Match with(state, result))
  )

  failed := method(
    result isKindOf(Iota Result Error)
  )

  parse := method(text,
    with(Iota State with(text, 0), nil)
  )

  map := method(consequent, alternate,
    if(result isNil,
      self
    ,
      if(self failed,
        self with(state, alternate call(result))
      ,
        self with(state, consequent call(result))
      )
    )
  )

  | := method(/* parser, */
    if(failed,
      call argAt(0) doInContext(self)
    ,
      self
    )
  )

  + := method(/* parser, */
    if(failed,
      self
    ,
      previous := result
      call argAt(0) doInContext(self) map(block(new, previous union(new))
                                         ,identity)
    )
  )

  flatten := method(
    map(block(xs,
      xs chain(block(value,
        xs replace(value flatten)
      ))
    ), identity)
  )

  identity := block(a, a)

  char := method(c,
    r := state consume(1)
    if(r != c,
      fail("Expected #{c}, got #{r}" interpolate)
    ,
      match(r, state skip(1))
    )
  )
)
