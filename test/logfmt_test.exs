defmodule LogfmtTest do
  use ExUnit.Case

  test "parses simple key=value" do
    assert Logfmt.parse("key=value") == %{"key" => "value"}
  end

  test "parses quoted value" do
    assert Logfmt.parse("key=\"value\"") == %{"key" => "value"}
  end

  test "parses single keys" do
    assert Logfmt.parse("key=\"value\" key2") == %{"key" => "value", "key2" => true}
  end

  test "parses unfinished pairs" do
    assert Logfmt.parse("key=\"value\" key2=") == %{"key" => "value", "key2" => true}
  end

  test "supports escaped quotes" do
    assert Logfmt.parse(~S(key="\"value\"")) == %{"key" => ~S("value")}
  end
end
