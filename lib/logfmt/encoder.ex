defmodule Logfmt.Encoder do
  @moduledoc ~S"""
  Encode a `Dict` into a logfmt-style log line.

  ## Examples

      iex> Logfmt.encode [foo: "bar"]
      "foo=bar"

      iex> Logfmt.encode [foo: "bar baz", qux: true]
      "foo=\"bar baz\" qux=true"
  """

  @doc """
  See [`Logfmt.encode`](/logfmt/Logfmt.html#encode/2).
  """
  @spec encode(Dict.t(), options :: Keyword.t()) :: String.t()
  def encode(list, options \\ []) do
    result =
      list
      |> Enum.map(&encode_pair/1)
      |> Enum.intersperse(" ")

    case options[:output] do
      # in case you wish to get back an iolist
      :iolist -> result
      # otherwise default to returning a binary
      _ -> Enum.join(result)
    end
  end

  @spec encode_value(value :: term) :: String.t()
  defp encode_value(value)

  defp encode_value(""),
    do: ~s("")

  defp encode_value(value) do
    str = Logfmt.ValueEncoder.encode(value)

    case deduce_string_style(str) do
      :unquoted ->
        str

      :quoted ->
        ["\"", str, "\""]

      :quoted_and_escaped ->
        ["\"", escape(str), "\""]
    end
  end

  defp encode_pair({key, value}) do
    # if an options keyword list was passed in, the " " could be replaced
    # with a user configurable option, but for now we'll keep the space.
    [encode_value(key), "=", encode_value(value)]
  end

  defp deduce_string_style(string),
    do: deduce_string_style(string, :unquoted)

  defp deduce_string_style(<<>>, acc),
    do: acc

  defp deduce_string_style(<<c, _rest::binary>>, _acc) when c <= 0x1F,
    do: :quoted_and_escaped

  defp deduce_string_style(<<" ", rest::binary>>, _acc),
    do: deduce_string_style(rest, :quoted)

  defp deduce_string_style(<<"\"", _rest::binary>>, _acc),
    do: :quoted_and_escaped

  defp deduce_string_style(<<"=", rest::binary>>, _acc),
    do: deduce_string_style(rest, :quoted)

  defp deduce_string_style(<<"\\", rest::binary>>, acc) do
    case acc do
      :unquoted ->
        deduce_string_style(rest, :unquoted)

      :quoted ->
        deduce_string_style(rest, :quoted_and_escaped)
    end
  end

  defp deduce_string_style(<<_c, rest::binary>>, acc),
    do: deduce_string_style(rest, acc)

  defp escape(string),
    do: escape(string, "")

  defp escape("", acc),
    do: acc

  defp escape(<<0x0, rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\u0000">>)

  defp escape(<<0x1, rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\u0001">>)

  defp escape(<<0x2, rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\u0002">>)

  defp escape(<<0x3, rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\u0003">>)

  defp escape(<<0x4, rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\u0004">>)

  defp escape(<<0x5, rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\u0005">>)

  defp escape(<<0x6, rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\u0006">>)

  defp escape(<<0x7, rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\u0007">>)

  defp escape(<<0x8, rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\u0008">>)

  defp escape(<<"\t", rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\t">>)

  defp escape(<<"\n", rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\n">>)

  defp escape(<<0xB, rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\u000b">>)

  defp escape(<<0xC, rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\u000c">>)

  defp escape(<<"\r", rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\r">>)

  defp escape(<<0xE, rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\u000e">>)

  defp escape(<<0xF, rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\u000f">>)

  defp escape(<<0x10, rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\u0010">>)

  defp escape(<<0x11, rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\u0011">>)

  defp escape(<<0x12, rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\u0012">>)

  defp escape(<<0x13, rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\u0013">>)

  defp escape(<<0x14, rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\u0014">>)

  defp escape(<<0x15, rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\u0015">>)

  defp escape(<<0x16, rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\u0016">>)

  defp escape(<<0x17, rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\u0017">>)

  defp escape(<<0x18, rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\u0018">>)

  defp escape(<<0x19, rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\u0019">>)

  defp escape(<<0x1A, rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\u001a">>)

  defp escape(<<0x1B, rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\u001b">>)

  defp escape(<<0x1C, rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\u001c">>)

  defp escape(<<0x1D, rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\u001d">>)

  defp escape(<<0x1E, rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\u001e">>)

  defp escape(<<0x1F, rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\u001f">>)

  defp escape(<<"\"", rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\\"">>)

  defp escape(<<"\\", rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\\\">>)

  defp escape(<<c, rest::binary>>, acc),
    do: escape(rest, <<acc::binary, c>>)
end
