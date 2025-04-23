defmodule LiveViewTest do
  use ExUnit.Case
  import Silk.LiveView

  defp render_dynamic(rendered) do
    rendered.dynamic.(%{})
    |> IO.iodata_to_binary()
  end

  describe "live_tag/1" do
    test "renders empty <p>…</p> around blank content" do
      result = live_tag(:p)

      assert result.static == ["<p", ">", "</p>"]
      assert render_dynamic(result) == ""
    end

    test "renders void tag without attributes" do
      result = live_tag(:br)

      assert result.static == ["<br", "/>"]
      assert render_dynamic(result) == ""
    end
  end

  describe "live_tag/2" do
    test "renders tag with content (inline block)" do
      result = live_tag(:p, do: "Hello World!")

      assert result.static == ["<p", ">", "</p>"]
      assert render_dynamic(result) == "Hello World!"
    end

    test "renders tag with content (block)" do
      result = live_tag(:p) do
        "Hello World!"
      end

      assert result.static == ["<p", ">", "</p>"]
      assert render_dynamic(result) == "Hello World!"
    end

    test "renders empty <div> with id main and class container" do
      result = live_tag(:div, id: "test", class: "container")

      assert result.static == ["<div id=\"test\" class=\"container\"", ">", "</div>"]
      assert render_dynamic(result) == ""
    end

    test "renders void tag with attributes" do
      result = live_tag(:input, type: "checkbox", checked: true)


      assert result.static == ["<input type=\"checkbox\" checked=\"true\"", "/>"]
      assert render_dynamic(result) == ""
    end
  end

  describe "live_tag/3" do
    test "renders <button> with class and phx-click attrs" do
      result = live_tag(:button, class: "btn", "phx-click": "save") do
        "Save!"
      end

      assert result.static == ["<button class=\"btn\" phx-click=\"save\"", ">", "</button>"]
      assert render_dynamic(result) == "Save!"
    end
  end
end