# MakeupEEx


A [Makeup](https://github.com/elixir-makeup/makeup/) lexer for the EEx and HEEx languages.

## Installation

Add `makeup_eex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:makeup_eex, "~> 0.1.0"}
  ]
end
```

This package provides two lexers:

* `EExLexer` - this lexer is automatically registered for the `eex` and `html_eex` languages
* `HEExLexer` - this lexer is automatically registered for the `heex` language



