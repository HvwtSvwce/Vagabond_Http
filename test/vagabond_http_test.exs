defmodule VagabondHttpTest do
  use ExUnit.Case
  doctest VagabondHttp

  test "greets the world" do
    assert VagabondHttp.hello() == :world
  end
end
