defmodule PipeHelpersTest do
  use ExUnit.Case
  doctest PipeHelpers

  test "greets the world" do
    assert PipeHelpers.hello() == :world
  end
end
