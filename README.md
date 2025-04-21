# Silk

Silk is a lightweight Elixir DSL for generating HTML in a clean, expressive, 
and composable way - using just Elixir syntax.

It gives you a tag macro that feels native to the language, making it easy to build dynamic HTML 
structures without templates, markup files, or string concatenation.

## Features

- Elixir-style HTML generation with blocks.
- Supports standard and void HTML tags.
- Compile-time HTML construction using macros.

Silk is a great fit for:
- Generating dynamic HTML fragments in scripts or apps
- Writing small UI components without reaching for a full template engine
- Keeping everything in Elixir, especially in tooling, testing, or LiveView helper contexts

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `silk` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:silk, "~> 0.1.0"}
  ]
end
```

## Usage
Start by importing the Silk module and using the tag macro:
```elixir
import Silk

tag :section, class: "content" do
  tag :h1, do: "Welcome"
end
```

Dynamic content? No problem:
```elixir
import Silk

tag :ul do
  Enum.map ["one", "two", "three"], fn item ->
    tag :li, do: item
  end
end
```

Void tags like img, br, or input:
```elixir
tag :img, src: "/logo.png", alt: "Logo"
````

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/silk>.

