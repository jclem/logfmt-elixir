defmodule LogfmtDecodeTest do
  use ExUnit.Case
  import Logfmt, only: [decode: 1]

  test "decodes the empty string" do
    assert decode("") == %{}
  end

  test "decodes whitespace-only string" do
    assert decode("\t") == %{}
  end

  test "decodes keys followed by garbage" do
    assert decode(~s(key")) == %{"key" => true}
  end

  test "decodes equals followed by garbage" do
    assert decode(~s(key==)) == %{"key" => true}
  end

  test "decodes unclosed quoted values" do
    assert decode(~s(foo="bar)) == %{"foo" => "bar"}
  end

  test "decodes a single key/value pair" do
    assert decode("foo=bar") == %{"foo" => "bar"}
  end

  test "decodes multiple key-value pairs" do
    assert decode("foo=bar baz=qux") == %{"foo" => "bar", "baz" => "qux"}
  end

  test "decodes quoted values" do
    assert decode(~s(foo="bar")) == %{"foo" => "bar"}
  end

  test "decodes standalone keys" do
    assert decode("foo=bar baz") == %{"foo" => "bar", "baz" => true}
  end

  test "decodes standalone keys with equals signs" do
    assert decode("foo=bar baz=") == %{"foo" => "bar", "baz" => true}
  end

  test "decodes empty qutoed strings" do
    assert decode(~s(foo="")) == %{"foo" => ""}
  end

  test "decodes escaped quotes" do
    assert decode(~S(foo="escaped \" quote")) == %{"foo" => ~s(escaped " quote)}
  end

  test "decodes \"true\" as a boolean" do
    assert decode("foo=true") == %{"foo" => true}
  end

  test "decodes \"false\" as a boolean" do
    assert decode("foo=false") == %{"foo" => false}
  end

  test "decodes zero" do
    assert decode("foo=0") == %{"foo" => 0}
  end

  test "decodes positive integers" do
    assert decode("foo=1") == %{"foo" => 1}
  end

  test "decodes negative integers" do
    assert decode("foo=-1") == %{"foo" => -1}
  end

  test "decodes positive floats" do
    assert decode("foo=1.2") == %{"foo" => 1.2}
  end

  test "decodes negative floats" do
    assert decode("foo=-1.2") == %{"foo" => -1.2}
  end

  test "decodes exponential floats" do
    assert decode("foo=1.2e9") == %{"foo" => 1.2e9}
  end
end
