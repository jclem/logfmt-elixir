defmodule Logfmt do
  import String, only: [next_grapheme: 1]

  @spec parse(String.t) :: map
  def parse(string) do
    parse_char(next_grapheme(string), :garbage, %{})
  end

  @spec parse_char({String.t, String.t}, atom, map) :: map
  def parse_char({char, rest}, :garbage, map)
  when char > " " and char != "\"" and char != "=" do
    parse_char(next_grapheme(rest), :key, char, map)
  end

  @spec parse_char({String.t, String.t}, atom, map) :: map
  def parse_char({_char, rest}, :garbage, map) do
    parse_char(next_grapheme(rest), :garbage, map)
  end

  @spec parse_char(nil, atom, map) :: map
  def parse_char(nil, :garbage, map) do
    map
  end

  @spec parse_char({String.t, String.t}, atom, String.t, map) :: map
  def parse_char({char, rest}, :key, key, map)
  when char > " " and char != "\"" and char != "=" do
    parse_char(next_grapheme(rest), :key, key <> char, map)
  end

  @spec parse_char({String.t, String.t}, atom, String.t, map) :: map
  def parse_char({char, rest}, :key, key, map)
  when char == "=" do
    parse_char(next_grapheme(rest), :equals, key, map)
  end

  @spec parse_char({String.t, String.t}, atom, String.t, map) :: map
  def parse_char({char, rest}, :key, key, map)
  when char == "=" do
    parse_char(next_grapheme(rest), :equals, key, map |> Map.put(key, true))
  end

  @spec parse_char({String.t, String.t}, atom, String.t, map) :: map
  def parse_char({_char, rest}, :key, key, map) do
    parse_char(next_grapheme(rest), :garbage, map |> Map.put(key, true))
  end

  @spec parse_char(nil, atom, String.t, map) :: map
  def parse_char(nil, :key, key, map) do
    map |> Map.put(key, true)
  end

  @spec parse_char({String.t, String.t}, atom, String.t, map) :: map
  def parse_char({char, rest}, :equals, key, map)
  when char > " " and char != "\"" and char != "=" do
    parse_char(next_grapheme(rest), :ivalue, key, char, map)
  end

  @spec parse_char({String.t, String.t}, atom, String.t, map) :: map
  def parse_char({char, rest}, :equals, key, map) when char == "\"" do
    parse_char(next_grapheme(rest), :qvalue, false, key, "", map)
  end

  @spec parse_char({String.t, String.t}, atom, String.t, map) :: map
  def parse_char({_char, rest}, :equals, _key, map) do
    parse_char(next_grapheme(rest), :garbage, map)
  end

  @spec parse_char(nil, atom, String.t, map) :: map
  def parse_char(nil, :equals, key, map) do
    map |> Map.put(key, true)
  end

  @spec parse_char({String.t, String.t}, atom, String.t, String.t, map) :: map
  def parse_char({char, rest}, :ivalue, key, value, map)
  when char <= " " or char == "\"" or char == "=" do
    parse_char(next_grapheme(rest), :garbage, map |> Map.put(key, value))
  end

  @spec parse_char({String.t, String.t}, atom, String.t, String.t, map) :: map
  def parse_char({char, rest}, :ivalue, key, value, map) do
    parse_char(next_grapheme(rest), :ivalue, key, value <> char, map)
  end

  @spec parse_char(nil, atom, String.t, String.t, map) :: map
  def parse_char(nil, :ivalue, key, value, map) do
    map |> Map.put key, value
  end

  @spec parse_char({String.t, String.t}, atom, String.t, boolean, String.t, map) :: map
  def parse_char({char, rest}, :qvalue, false, key, value, map) when char == "\"" do
    parse_char(next_grapheme(rest), :garbage, map |> Map.put(key, value))
  end

  @spec parse_char({String.t, String.t}, atom, String.t, boolean, String.t, map) :: map
  def parse_char({char, rest}, :qvalue, false, key, value, map) do
    parse_char(next_grapheme(rest), :qvalue, false, key, value <> char, map)
  end

  @spec parse_char(nil, atom, String.t, boolean, String.t, map) :: map
  def parse_char(nil, :qvalue, false, key, value, map) do
    map |> Map.put key, value
  end
end
