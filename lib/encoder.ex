defmodule Logfmt.Encoder do
  @spec encode(map) :: String.t
  def encode(map) do
    Enum.reduce map, "", &encode_pair/2
  end

  @spec encode_pair({String.t | atom, String.t | atom}, String.t) :: String.t
  defp encode_pair({key, value}, "") do
    "#{key}=#{value |> encode_value}"
  end

  @spec encode_pair({String.t | atom, String.t | atom}, String.t) :: String.t
  defp encode_pair({key, value}, line) do
    "#{line} #{key}=#{value |> encode_value}"
  end

  @spec encode_value(String.t) :: String.t
  defp encode_value(value) do
    case String.match? value, ~r/\s/ do
      true  -> ~s("#{value}")
      false -> value
    end
  end
end