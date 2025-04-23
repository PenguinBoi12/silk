defmodule Silk.LiveView do
  @moduledoc """
  Provides macros for generating Phoenix LiveView compatible HTML tags.

  This module extends Silk's functionality by offering macros that create HTML tags
  which produce `Phoenix.LiveView.Rendered` structs that work seamlessly with 
  Phoenix LiveView's rendering system.

  ## Examples

  ```elixir
  # Paired tag without attributes or inner content:
  live_tag "div"

  # Paired tag with attributes:
  live_tag "button", class: "btn", phx_click: "save"

  # Paired tag with inner block:
  live_tag "span" do
    "Hello, " <> name
  end

  # Void tags
  live_tag(:img, src: "/images/logo.png", alt: "Logo")
  live_tag(:input, type: "text", name: "username")

  # Nested
  live_tag(:section, id: "main", class: "content") do
    live_tag(:h1) do
      "Welcome to Silk"
    end

    live_tag(:p) do
      "Build your LiveView templates with ease"
    end
  end
  ```
  """

  import Silk, only: [is_void: 1]

  @doc """
  Generates a tag. If the tag is a void tag (e.g. `<br>`, `<img>`, etc.), 
  it will be self-closing.

  ## Examples
  ```
  iex> live_tag("p", do: "Hello")
  %Phoenix.LiveView.Rendered{
    static: ["<p>", "</p>"],
    dynamic: fn _ -> [["Hello"]] end
  }

  iex> live_tag("br")
  %Phoenix.LiveView.Rendered{
    static: ["<br", "/>"],
    dynamic: fn _ -> [[]] end
  }
  ```
  """
  @spec live_tag(name :: String.t()) :: Phoenix.LiveView.Rendered.t()
  defmacro live_tag(name) when is_void(name),
    do: live_void_tag(name, [])

  @spec live_tag(name :: String.t()) :: Phoenix.LiveView.Rendered.t()
  defmacro live_tag(name),
    do: live_paired_tag(name, [], do: "")

  @spec live_tag(name :: String.t(), do: Macro.t()) :: Phoenix.LiveView.Rendered.t()
  defmacro live_tag(name, do: block),
    do: live_paired_tag(name, [], do: block)

  @spec live_tag(name :: String.t(), opts :: keyword()) :: Phoenix.LiveView.Rendered.t()
  defmacro live_tag(name, opts) when is_void(name),
    do: live_void_tag(name, opts)

  @spec live_tag(name :: String.t(), opts :: keyword()) :: Phoenix.LiveView.Rendered.t()
  defmacro live_tag(name, opts) do
    {block, opts} = Keyword.pop(opts, :do, [])
    live_paired_tag(name, opts, do: block)
  end

  @spec live_tag(name :: String.t(), opts :: keyword(), do: Macro.t()) ::
          Phoenix.LiveView.Rendered.t()
  defmacro live_tag(name, opts, do: block),
    do: live_paired_tag(name, opts, do: block)

  @spec live_paired_tag(name :: String.t(), opts :: keyword(), do: Macro.t()) :: 
          Phoenix.LiveView.Rendered.t()
  defp live_paired_tag(name, opts, do: block) do
    quote do
      content = unquote(format_content(block))

      attributes = unquote(opts)
      |> Enum.map(fn {attr, value} -> " #{attr}=\"#{value}\"" end)
      |> Enum.join("")

      %Phoenix.LiveView.Rendered{
        static: ["<#{unquote(name)}#{attributes}", ">", "</#{unquote(name)}>"],
        dynamic: fn _changed -> [[], [content]] end
      }
    end
  end

  @spec live_void_tag(name :: String.t(), opts :: keyword()) :: Phoenix.LiveView.Rendered.t()
  defp live_void_tag(name, opts) do
    quote do
      attributes = unquote(opts)
      |> Enum.map(fn {attr, value} -> " #{attr}=\"#{value}\"" end)
      |> Enum.join("")

      %Phoenix.LiveView.Rendered{
        static: ["<#{unquote(name)}#{attributes}", "/>"],
        dynamic: fn _changed -> [[]] end
      }
    end
  end

  @spec format_content(Macro.t()) :: Macro.t()
  def format_content({:__block__, _, elements}) do
    quote do
      unquote(elements)
      |> Enum.map(fn element -> Phoenix.HTML.Safe.to_iodata(element) end)
      |> Enum.filter(&(&1 != ""))
      |> IO.iodata_to_binary()
    end
  end

  @spec format_content(single_element :: term()) :: Macro.t()
  def format_content(single_element) do
    quote do
      Phoenix.HTML.Safe.to_iodata(unquote(single_element))
    end
  end
end