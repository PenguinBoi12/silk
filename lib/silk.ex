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
  A valid HTML tag name represented as an atom or binary.
  """
  @type tag_name :: atom() | binary()

  @typedoc """
  HTML attributes represented as keyword list.
  Keys are attribute names and values are attribute values.
  """
  @type attributes :: keyword()

  @typedoc """
  The inner content of an HTML tag.
  Can be any Elixir term that can be converted to a string.
  """
  @type content :: String.t() | number() | atom() | [content()] | tuple() | map() | nil

  defguardp is_void(name) when name in @void_tags

  @doc """
  Generates an HTML tag. If the tag is a void tag (e.g. `<br>`, `<img>`, etc.), 
  it will be self-closing.

  If the tag is not a void tag, it wraps the given `do` block as inner content.

  ## Examples
  ```
  iex> tag :p, class: "info" do
    "Hello"
  end
  "<p class=\"info\">Hello</p>"

  iex> tag :br
  "<br />"
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
    content =
      quote do
        format_content(unquote(block))
      end

    quote do
      inner_content = unquote(content)

      attributes = Enum.map unquote(opts), fn {attr, value} -> 
        " #{attr}=\"#{value}\""
      end

      "<#{unquote(name)}#{attributes}>#{inner_content}</#{unquote(name)}>"
    end
  end

  @doc false
  @spec void_tag(tag_name(), attributes()) :: Macro.t()
  defp void_tag(name, opts) do
    quote do
      attributes = Enum.map unquote(opts), fn {attr, value} -> 
        " #{attr}=\"#{value}\""
      end

      "<#{unquote(name)}#{attributes} />"
    end
  end

  @doc """
  Formats content based on its type for optimal HTML rendering.

  ## Type-specific formatting:
  - Lists are processed recursively, formatting each element
  - Maps are converted to their string representation via inspect
  - Tuples are converted to their string representation via inspect
  - Other types are simply converted to strings

  ## Examples

  ```
  iex> format_content(["Hello", 123])
  ["Hello", "123"]

  iex> format_content(%{name: "John"})
  "%{name: \"John\"}"

  iex> format_content({:ok, 42})
  "{:ok, 42}"

  iex> format_content("Hello")
  "Hello"

  iex> format_content(123)
  "123"
  ```
  """
  @spec format_content(list()) :: [String.t()]
  def format_content(content) when is_list(content),
    do: Enum.map(content, &format_content/1)

  @spec format_content(map()) :: String.t()
  def format_content(content) when is_map(content),
    do: inspect(content)

  @spec format_content(tuple()) :: String.t()
  def format_content(content) when is_tuple(content),
    do: inspect(content)

  @spec format_content(any()) :: String.t()
  def format_content(content),
    do: to_string(content)
end