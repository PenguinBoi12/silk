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

  @doc """
  Generates an HTML tag. If the tag is a void tag (e.g. `<br>`, `<img>`, etc.), 
  it will be self-closing.

  If the tag is not a void tag, it wraps the given `do` block as inner content.

  ## Examples
  ```
    iex> tag :p, class: "info" do
    ...>   "Hello"
    ...> end

    "<p class=\\"info\\">Hello</p>"

    iex> tag :br

    "<br />"
  ```
  """
  @spec macro tag(atom, keyword, Macro.t()) :: Macro.t()
  defmacro tag(name, opts \\ [], do: block) do
    if name in @void_tags do
      void_tag(name, opts)
    else
      paired_tag(name, opts, do: block)
    end
  end

  @doc false
  @spec paired_tag(atom, keyword, do: Macro.t()) :: Macro.t()
  defp paired_tag(name, opts \\ [], do: block) do
    contents =
      case block do
        {:__block__, _, exprs} -> exprs
        expr -> [expr]
      end

    quote do
      attributes =
        unquote(opts)
        |> Enum.map(fn {attr, value} -> " #{attr}=\"#{value}\"" end)
        |> Enum.join("")

      inner_content =
        [unquote_splicing(Enum.map(contents, &quote(do: to_string(unquote(&1)))))]
        |> IO.iodata_to_binary()

      "<#{unquote(name)}#{attributes}>#{inner_content}</#{unquote(name)}>"
    end
  end

  @doc false
  @spec void_tag(atom, keyword) :: Macro.t()
  defp void_tag(name, opts \\ []) do
    quote do
      attributes =
        unquote(opts)
        |> Enum.map(fn {attr, value} -> " #{attr}=\"#{value}\"" end)
        |> Enum.join("")

      "<#{unquote(name)}#{attributes} />"
    end
  end
end