defmodule Logfmt.Decoder do
  import String, only: [next_grapheme: 1]

  @spec decode(String.t) :: Keyword.t
  def decode(string) do
    parse_char(next_grapheme(string), :garbage, Keyword.new)
  end

  @spec parse_char({String.t, String.t}, :garbage, Keyword.t) :: Keyword.t
  defp parse_char({char, rest}, :garbage, list)
  when char > " " and char != "\"" and char != "=" do
    parse_char(next_grapheme(rest), :key, char, list)
  end

  @spec parse_char({String.t, String.t}, :garbage, Keyword.t) :: Keyword.t
  defp parse_char({_char, rest}, :garbage, list) do
    parse_char(next_grapheme(rest), :garbage, list)
  end

  @spec parse_char(nil, :garbage, Keyword.t) :: Keyword.t
  defp parse_char(nil, :garbage, list) do
    list
  end

  @spec parse_char({String.t, String.t}, :key, String.t, Keyword.t) :: Keyword.t
  defp parse_char({char, rest}, :key, key, list)
  when char > " " and char != "\"" and char != "=" do
    parse_char(next_grapheme(rest), :key, key <> char, list)
  end

  @spec parse_char({String.t, String.t}, :key, String.t, Keyword.t) :: Keyword.t
  defp parse_char({"=", rest}, :key, key, list) do
    parse_char(next_grapheme(rest), :equals, key, list)
  end

  @spec parse_char({String.t, String.t}, :key, String.t, Keyword.t) :: Keyword.t
  defp parse_char({_char, rest}, :key, key, list) do
    parse_char(next_grapheme(rest), :garbage, list |> put_value(key, true))
  end

  @spec parse_char(nil, :key, String.t, Keyword.t) :: Keyword.t
  defp parse_char(nil, :key, key, list) do
    list |> put_value(key, true)
  end

  @spec parse_char({String.t, String.t}, :equals, String.t, Keyword.t) :: Keyword.t
  defp parse_char({char, rest}, :equals, key, list)
  when char > " " and char != "\"" and char != "=" do
    parse_char(next_grapheme(rest), :ivalue, key, char, list)
  end

  @spec parse_char({String.t, String.t}, :equals, String.t, Keyword.t) :: Keyword.t
  defp parse_char({"\"", rest}, :equals, key, list) do
    parse_char(next_grapheme(rest), :qvalue, false, key, "", list)
  end

  @spec parse_char({String.t, String.t}, :equals, String.t, Keyword.t) :: Keyword.t
  defp parse_char({_char, rest}, :equals, key, list) do
    parse_char(next_grapheme(rest), :garbage, list |> put_value(key, true))
  end

  @spec parse_char(nil, :equals, String.t, Keyword.t) :: Keyword.t
  defp parse_char(nil, :equals, key, list) do
    list |> put_value(key, true)
  end

  @spec parse_char({String.t, String.t}, :ivalue, String.t, String.t, Keyword.t) :: Keyword.t
  defp parse_char({char, rest}, :ivalue, key, value, list)
  when char <= " " or char == "\"" or char == "=" do
    parse_char(next_grapheme(rest), :garbage, list |> put_value(key, value))
  end

  @spec parse_char({String.t, String.t}, :ivalue, String.t, String.t, Keyword.t) :: Keyword.t
  defp parse_char({char, rest}, :ivalue, key, value, list) do
    parse_char(next_grapheme(rest), :ivalue, key, value <> char, list)
  end

  @spec parse_char(nil, :ivalue, String.t, String.t, Keyword.t) :: Keyword.t
  defp parse_char(nil, :ivalue, key, value, list) do
    list |> put_value(key, value)
  end

  @spec parse_char({String.t, String.t}, :qvalue, false, String.t, String.t, Keyword.t) :: Keyword.t
  defp parse_char({"\\", rest}, :qvalue, false, key, value, list) do
    parse_char(next_grapheme(rest), :qvalue, true, key, value, list)
  end

  @spec parse_char({String.t, String.t}, :qvalue, true, String.t, String.t, Keyword.t) :: Keyword.t
  defp parse_char({char, rest}, :qvalue, true, key, value, list) do
    parse_char(next_grapheme(rest), :qvalue, false, key, value <> char, list)
  end

  @spec parse_char({String.t, String.t}, :qvalue, false, String.t, String.t, Keyword.t) :: Keyword.t
  defp parse_char({"\"", rest}, :qvalue, false, key, value, list) do
    parse_char(next_grapheme(rest), :garbage, list |> put_value(key, value))
  end

  @spec parse_char({String.t, String.t}, :qvalue, false, String.t, String.t, Keyword.t) :: Keyword.t
  defp parse_char({char, rest}, :qvalue, false, key, value, list) do
    parse_char(next_grapheme(rest), :qvalue, false, key, value <> char, list)
  end

  @spec parse_char(nil, :qvalue, false, String.t, String.t, Keyword.t) :: Keyword.t
  defp parse_char(nil, :qvalue, false, key, value, list) do
    list |> put_value(key, value)
  end

  @spec put_value(Keyword.t, String.t, boolean) :: Keyword.t
  defp put_value(list, key, value) when is_boolean(value) do
    list ++ Keyword.new([{key |> String.to_atom, value}])
  end

  @spec put_value(Keyword.t, String.t, String.t) :: Keyword.t
  defp put_value(list, key, value) do
    list ++ Keyword.new([{key |> String.to_atom, value |> cast}])
  end

  @spec cast(String.t) :: true
  defp cast("true"), do: true

  @spec cast(String.t) :: false
  defp cast("false"), do: false

  @spec cast(String.t) :: number | String.t
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
