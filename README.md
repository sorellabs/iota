Iota
====

A packrat parser combinator for Io.


## Example

```io

CSVParser := Iota clone do(
    file := endBy(line) eol
    line := sepBy(cell) char(',')
    cell := many(noneOf(',\n'))
    eol  := char('\n')
)

CSVParser file parse("a,b\nfoo,bar")
// => list(list("a", "b"), list("foo", "bar"))
```

## Installation

Drop `iota.io` somewhere your script can find, evaluate it.


## Tests

    $ make test
    
## Licence

MIT/X11.
