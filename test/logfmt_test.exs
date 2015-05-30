defmodule LogfmtTest do
  use ExUnit.Case

  test "parses simple key=value" do
    assert Logfmt.parse("key=value") == %{"key" => "value"}
  end

  test "parses quoted value" do
    assert Logfmt.parse("key=\"value\"") == %{"key" => "value"}
  end
end
