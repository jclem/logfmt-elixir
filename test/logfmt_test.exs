defmodule LogfmtTest do
  use ExUnit.Case

  doctest Logfmt

  test "roundtrip key unquoted value pair" do
    assert roundtrip("foo=bar") == "foo=bar"
  end

  test "roundtrip key quoted value pair" do
    assert roundtrip(~s(foo="bar baz")) == ~s(foo="bar baz")
  end

  defp roundtrip(string) do
    string |> Logfmt.decode() |> Logfmt.encode()
  end
end
