defmodule SilkTest do
  use ExUnit.Case
  doctest Silk

  test "greets the world" do
    assert Silk.hello() == :world
  end
end
