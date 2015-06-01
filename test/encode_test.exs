defmodule LogfmtEncodeTest do
  use ExUnit.Case
  import Logfmt, only: [encode: 1]

  test "encodes an unquoted key=value pair" do
    assert encode(%{"foo" => "bar"}) == "foo=bar"
  end

  test "encodes an quoted value" do
    assert encode(%{"foo" => "bar baz"}) == ~s(foo="bar baz")
  end
end
