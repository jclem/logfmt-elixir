defmodule LogfmtEncodeTest do
  use ExUnit.Case
  doctest Logfmt.Encoder
  import Logfmt, only: [encode: 1, encode: 2]

  test "encodes an unquoted key=value pair" do
    assert encode(foo: "bar") == "foo=bar"
  end

  test "encodes a map" do
    assert encode(%{foo: "bar"}) == "foo=bar"
  end

  test "encodes multiple pairs" do
    assert encode(foo: "bar", baz: "qux") == "foo=bar baz=qux"
  end

  test "encodes an quoted value" do
    assert encode(foo: "bar baz") == ~s(foo="bar baz")
  end

  test "quotes a value with =" do
    assert encode(foo: "bar=baz") == ~s(foo="bar=baz")
  end

  test "encodes a boolean" do
    assert encode(foo: true) == "foo=true"
  end

  test "encodes a number" do
    assert encode(foo: 1) == "foo=1"
  end

  test "encodes a duplicate key" do
    assert encode(foo: 1, foo: 2) == "foo=1 foo=2"
  end

  test "encodes nil" do
    assert encode(foo: nil) == "foo=nil"
  end

  test "encodes a PID value" do
    p = self()
    value = inspect(p)
    assert "foo=" <> ^value = encode(foo: p)
  end

  test "encodes a Reference value" do
    ref = make_ref()
    value = inspect(ref)
    assert "foo=" <> ^value = encode(foo: ref)
  end

  test "encodes to an iolist" do
    assert [["foo", "=", ["\"", "bar baz", "\""]], " ", ["bar", "=", "foobar"]] ==
             encode([foo: "bar baz", bar: :foobar], output: :iolist)
  end
end
