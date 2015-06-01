defmodule Logfmt.Encoder do
  @spec encode(Dict.t) :: String.t
  def encode(list) do
    Enum.reduce list, "", &encode_pair/2
  end

  @spec encode_pair({Dict.key, String.t | boolean | number}, String.t) :: String.t
  defp encode_pair({key, value}, "") do
    "#{key}=#{value |> encode_value}"
  end

  @spec encode_pair({Dict.key, String.t | boolean | number}, String.t) :: String.t
  defp encode_pair({key, value}, line) do
    "#{line} #{key}=#{value |> encode_value}"
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
end
