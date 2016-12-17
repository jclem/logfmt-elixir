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
  See [`Logfmt.encode`](/logfmt/Logfmt.html#encode/1).
  """
  @spec encode(Dict.t) :: String.t
  def encode(list) do
    Enum.reduce list, "", &encode_pair/2
  end

  @spec encode_pair({Dict.key, String.t | boolean | number}, String.t) :: String.t
  defp encode_pair({key, value}, "") when is_binary(value) do
    if String.contains?(value, "=") do
      ~s(#{key}="#{encode_value(value)}")
    else
      ~s(#{key}=#{encode_value(value)})
    end
  end

  defp encode_pair({key, value}, "") do
    ~s(#{key}=#{encode_value(value)})
  end

  @spec encode_pair({Dict.key, String.t | boolean | number}, String.t) :: String.t
  defp encode_pair({key, value}, line) do
    "#{line} #{encode_pair({key, value}, "")}"
  end

  @spec encode_value(String.t) :: String.t
  defp encode_value(value) when is_binary(value) do
    case String.match? value, ~r/\s/ do
      true  -> ~s("#{value}")
      false -> value
    end
  end

  @spec encode_value(boolean | number) :: boolean | number
  defp encode_value(value) when is_boolean(value) or is_number(value), do: value

  @spec encode_value(nil) :: String.t
  defp encode_value(value) when is_nil(value), do: "nil"
end
