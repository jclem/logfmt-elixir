defmodule Logfmt.Decoder do
  import String, only: [next_grapheme: 1]

  @spec decode(String.t) :: map
  def decode(string) do
    parse_char(next_grapheme(string), :garbage, %{})
  end

  @spec parse_char({String.t, String.t}, atom, map) :: map
  defp parse_char({char, rest}, :garbage, map)
  when char > " " and char != "\"" and char != "=" do
    parse_char(next_grapheme(rest), :key, char, map)
  end

  @spec parse_char({String.t, String.t}, atom, map) :: map
  defp parse_char({_char, rest}, :garbage, map) do
    parse_char(next_grapheme(rest), :garbage, map)
  end

  @spec parse_char(nil, atom, map) :: map
  defp parse_char(nil, :garbage, map) do
    map
  end

  @spec parse_char({String.t, String.t}, atom, String.t, map) :: map
  defp parse_char({char, rest}, :key, key, map)
  when char > " " and char != "\"" and char != "=" do
    parse_char(next_grapheme(rest), :key, key <> char, map)
  end

  @spec parse_char({String.t, String.t}, atom, String.t, map) :: map
  defp parse_char({"=", rest}, :key, key, map) do
    parse_char(next_grapheme(rest), :equals, key, map)
  end

  @spec parse_char({String.t, String.t}, atom, String.t, map) :: map
  defp parse_char({_char, rest}, :key, key, map) do
    parse_char(next_grapheme(rest), :garbage, map |> put_value(key, true))
  end

  @spec parse_char(nil, atom, String.t, map) :: map
  defp parse_char(nil, :key, key, map) do
    map |> put_value(key, true)
  end

  @spec parse_char({String.t, String.t}, atom, String.t, map) :: map
  defp parse_char({char, rest}, :equals, key, map)
  when char > " " and char != "\"" and char != "=" do
    parse_char(next_grapheme(rest), :ivalue, key, char, map)
  end

  @spec parse_char({String.t, String.t}, atom, String.t, map) :: map
  defp parse_char({"\"", rest}, :equals, key, map) do
    parse_char(next_grapheme(rest), :qvalue, false, key, "", map)
  end

  @spec parse_char({String.t, String.t}, atom, String.t, map) :: map
  defp parse_char({_char, rest}, :equals, key, map) do
    parse_char(next_grapheme(rest), :garbage, map |> put_value(key, true))
  end

  @spec parse_char(nil, atom, String.t, map) :: map
  defp parse_char(nil, :equals, key, map) do
    map |> put_value(key, true)
  end

  @spec parse_char({String.t, String.t}, atom, String.t, String.t, map) :: map
  defp parse_char({char, rest}, :ivalue, key, value, map)
  when char <= " " or char == "\"" or char == "=" do
    parse_char(next_grapheme(rest), :garbage, map |> put_value(key, value))
  end

  @spec parse_char({String.t, String.t}, atom, String.t, String.t, map) :: map
  defp parse_char({char, rest}, :ivalue, key, value, map) do
    parse_char(next_grapheme(rest), :ivalue, key, value <> char, map)
  end

  @spec parse_char(nil, atom, String.t, String.t, map) :: map
  defp parse_char(nil, :ivalue, key, value, map) do
    map |> put_value(key, value)
  end

  @spec parse_char({String.t, String.t}, atom, boolean, String.t, String.t, map) :: map
  defp parse_char({"\\", rest}, :qvalue, false, key, value, map) do
    parse_char(next_grapheme(rest), :qvalue, true, key, value, map)
  end

  @spec parse_char({String.t, String.t}, atom, boolean, String.t, String.t, map) :: map
  defp parse_char({char, rest}, :qvalue, true, key, value, map) do
    parse_char(next_grapheme(rest), :qvalue, false, key, value <> char, map)
  end

  @spec parse_char({String.t, String.t}, atom, boolean, String.t, String.t, map) :: map
  defp parse_char({"\"", rest}, :qvalue, false, key, value, map) do
    parse_char(next_grapheme(rest), :garbage, map |> put_value(key, value))
  end

  @spec parse_char({String.t, String.t}, atom, boolean, String.t, String.t, map) :: map
  defp parse_char({char, rest}, :qvalue, false, key, value, map) do
    parse_char(next_grapheme(rest), :qvalue, false, key, value <> char, map)
  end

  @spec parse_char(nil, atom, boolean, String.t, String.t, map) :: map
  defp parse_char(nil, :qvalue, false, key, value, map) do
    map |> put_value(key, value)
  end

  @spec put_value(map, String.t, boolean) :: map
  defp put_value(map, key, value) when is_boolean(value) do
    map |> Map.put(key, value)
  end

  @spec put_value(map, String.t, String.t) :: map
  defp put_value(map, key, value) do
    map |> Map.put(key, value |> cast)
  end

  @spec cast(String.t) :: boolean
  defp cast("true"), do: true

  @spec cast(String.t) :: boolean
  defp cast("false"), do: false

  @spec cast(String.t) :: Float | Integer | String.t
  defp cast(value)  do
    integer = case Integer.parse(value) do
      {integer, ""} -> integer
      {_, _}        -> nil
      :error        -> nil
    end

    float = case Float.parse(value) do
      {float, ""} -> float
      {_, _}      -> nil
      :error      -> nil
    end

    integer || float || value
  end
end
