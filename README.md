# Silk
[![Tests](https://github.com/PenguinBoi12/silk/actions/workflows/test.yml/badge.svg)](https://github.com/PenguinBoi12/silk/actions/workflows/test.yml)
[![Silk version](https://img.shields.io/hexpm/v/silk_html.svg)](https://hex.pm/packages/silk_html)

Silk is a lightweight Elixir DSL for generating HTML in a clean, expressive, 
and composable way - using just Elixir syntax.

## Features

- Elixir-style HTML generation with blocks.
- Supports standard and void HTML tags.
- Compile-time HTML construction using macros.
- Supports Pheonix LiveView Component 

Silk is a great fit for:
- Generating dynamic HTML fragments in scripts or apps
- Writing small UI components without reaching for a full template engine
- Keeping everything in Elixir, especially in tooling, testing, or LiveView helper contexts

## Installation

```elixir
def deps do
  [
    {:silk_html, "~> 0.1.0"}
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

### Phoenix LivewView and Live Component
Simple usage:
```elixir
import Silk.LiveView

live_tag(:button, "phx-click: "save") do
  "Save!"
end
```

With rendering:
```elixir
attr :for, :string, default: nil
slot :inner_block, required: true

def label(assigns) do
  live_tag(:label, for: assigns.for, class: "block text-sm font-semibold leading-6 text-zinc-800") do
    ~H[{render_slot(@inner_block)}]
  end
end
```

Note: Currently it is not possible to call a live component (i.e. `.label`) from `live_tag`.

# License

Silk is released under GPL-3.0 - See the [LICENCE](LICENSE).
