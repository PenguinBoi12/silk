defmodule SilkTest do
  use ExUnit.Case
  import Silk

  describe "tag/1" do
    test "renders empty <p>…</p> around blank content" do
      assert tag(:p) == "<p></p>"
    end

    test "renders void tag without attributes" do
      assert tag(:br) == "<br />"
    end
  end

  describe "tag/2" do
    test "renders tag with content (inline block)" do
      assert  tag(:p, do: "Hello World!") == "<p>Hello World!</p>"
    end

    test "renders tag with content (block)" do
      result = tag(:p) do
        "Hello World!"
      end

      assert result == "<p>Hello World!</p>"
    end

    test "renders empty <div> with id main and class container" do
      result = tag(:div, id: "test", class: "container")

      assert result == "<div id=\"test\" class=\"container\"></div>"
    end

    test "renders void tag with attributes" do
      result = tag(:input, type: "checkbox", checked: true)

      assert result == "<input type=\"checkbox\" checked=\"true\" />"
    end

    test "renders nested tags without attributes" do
      result =
        tag(:div) do
          tag(:span, do: "Inner")
        end

      assert result == "<div><span>Inner</span></div>"
    end

  end

  describe "tag/3" do
    test "renders <button> with class and data-id" do
      result = tag(:button, class: "btn", "data-id": 5) do
        "Save!"
      end

      assert result == "<button class=\"btn\" data-id=\"5\">Save!</button>"
    end

    test "renders list of tags with class attributes on parent" do
      result = tag(:div, class: "container") do
        ["Hello ", tag(:span, class: "bold", do: "World")]
      end

      assert result == "<div class=\"container\">Hello <span class=\"bold\">World</span></div>"
    end

    test "renders multiple expressions in block" do
      result = tag(:div) do
        tag(:span, do: "Line 1\n")
        tag(:span, do: "Line 2\n")
      end

      assert result == "<div><span>Line 1\n</span><span>Line 2\n</span></div>"
    end
  end

  describe "format_content/1" do
    test "format 'basic' types to strings" do
      assert format_content(123) == "123"
      assert format_content(true) == "true"
      assert format_content(:atom) == "atom"
      assert format_content(nil) == ""
      assert format_content([1, 2, 3]) == ["1", "2", "3"]
      assert format_content([a: 1]) == [{:a, 1}]
      assert format_content({:a, 1}) == {:a, 1}
      assert format_content(%{a: 1}) == %{a: 1}
    end

    test "format block" do
      block = tag(:p, do: "Hello World!")
      result = format_content(block)

      assert result == "<p>Hello World!</p>"
    end
  end

  describe "is_void/1" do
    void_tags = [
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

    assert Enum.all?(void_tags, &is_void/1)
  end
end