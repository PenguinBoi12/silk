defmodule Silk do
  @moduledoc """
  Silk is a lightweight Elixir DSL for generating HTML in a clean, expressive,
  and composable way - using just Elixir syntax.

  ## Examples

  ```elixir
  tag :div, class: "items" do
    Enum.map 1..10, fn i ->
      tag :p, "data-item": "item-\#{i}" do
        "Item: \#{tag(:b, do: i)}"
      end
    end
  end

  <div class="items">
    <p data-item="item-1">Item: <b>1</b></p>
    <p data-item="item-2">Item: <b>2</b></p>
    ...
    <p data-item="item-10">Item: <b>10</b></p>
  </div>
  ```
  """
  @void_tags [
    :aread,
    :base,
    :br,
    :col,
    :embed,
    :hr,
    :img,
    :input,
    :keygen,
    :link,
    :meta,
    :source,
    :track,
    :wbr
  ]

  @typedoc """
  A valid HTML tag name represented as an atom.
  """
  @type tag_name :: atom()

  @typedoc """
  HTML attributes represented as keyword list.
  Keys are attribute names and values are attribute values.
  """
  @type attributes :: keyword()

  @typedoc """
  The inner content of an HTML tag.
  Can be any Elixir term that can be converted to a string.
  """
  @type content :: any()

  defguardp is_void(name) when name in @void_tags

  @doc """
  Generates an HTML tag. If the tag is a void tag (e.g. `<br>`, `<img>`, etc.), 
  it will be self-closing.

  If the tag is not a void tag, it wraps the given `do` block as inner content.

  ## Examples
  ```
  tag :p, class: "info" do
    "Hello"
  end

  <p class="info">Hello</p>

  tag :br

  <br />
  ```
  """
  @spec tag(tag_name()) :: binary()
  defmacro tag(name) when is_void(name),
    do: void_tag(name, [])

  @spec tag(tag_name()) :: binary()
  defmacro tag(name),
    do: paired_tag(name, [], do: "")

  @spec tag(tag_name(), do: content()) :: binary()
  defmacro tag(name, do: block),
    do: paired_tag(name, [], do: block)

  @spec tag(tag_name(), attributes()) :: binary()
  defmacro tag(name, opts) when is_void(name),
    do: void_tag(name, opts)

  @spec tag(tag_name(), attributes()) :: binary()
  defmacro tag(name, opts) do
    {block, opts} = Keyword.pop(opts, :do, "")
    paired_tag(name, opts, do: block)
  end

  @spec tag(tag_name(), attributes(), do: content()) :: binary()
  defmacro tag(name, opts, do: block),
    do: paired_tag(name, opts, do: block)

  @doc false
  @spec paired_tag(tag_name(), attributes(), do: content()) :: Macro.t()
  defp paired_tag(name, opts, do: block) do
    contents =
      case block do
        {:__block__, _, exprs} -> exprs
        expr -> [expr]
      end

    attributes = parse_attributes(opts)

    quote do
      inner_content =
        [unquote_splicing(Enum.map(contents, &quote(do: to_string(unquote(&1)))))]
        |> IO.iodata_to_binary()

      "<#{unquote(name)}#{unquote(attributes)}>#{inner_content}</#{unquote(name)}>"
    end
  end

  @doc false
  @spec void_tag(tag_name(), attributes()) :: Macro.t()
  defp void_tag(name, opts) do
    attributes = parse_attributes(opts)

    quote do
      "<#{unquote(name)}#{unquote(attributes)} />"
    end
  end

  @doc false
  @spec parse_attributes(attributes()) :: binary()
  defp parse_attributes(attributes) do
    attributes
    |> Enum.map(fn {attr, value} -> " #{attr}=\"#{value}\"" end)
    |> Enum.join("")
  end
end