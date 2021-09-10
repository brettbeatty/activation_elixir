defmodule ActivateTest do
  use ExUnit.Case
  doctest Activate

  test "greets the world" do
    assert Activate.hello() == :world
  end
end
