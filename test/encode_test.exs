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

  test "encode an empty string" do
    assert encode(empty: "") == ~s(empty="")
  end

  test "quotes a value with =" do
    assert encode(foo: "bar=baz") == ~s(foo="bar=baz")
  end

  test ~s{escape a value with "} do
    assert encode(foo: ~s{hello "world"}) == ~s(foo="hello \\"world\\"")
  end

  test "escape a value with a new line" do
    assert encode(foo: ~s{a b\nc d\ne f\n}) == ~s(foo="a b\\nc d\\ne f\\n")
  end

  test "value with \\ but no spaces does not require quotes" do
    assert encode(foo: "t3st1\\t3st2") == "foo=t3st1\\t3st2"
  end

  test ~s{value with " but no spaces requires quotes and escapes anyway} do
    assert encode(foo: ~s{t3st1"t3st2}) == ~s{foo="t3st1\\"t3st2"}
  end

  test ~s{value with control character but no spaces requires quotes and escapes anyway} do
    assert encode(foo: ~s{t3st1\nt3st2}) == ~s{foo="t3st1\\nt3st2"}
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
