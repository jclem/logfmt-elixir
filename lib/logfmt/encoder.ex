defprotocol Logfmt.ValueEncoder do
  @spec encode(value :: term) :: String.t
  def encode(value)
end

defimpl Logfmt.ValueEncoder, for: BitString do
  def encode(str), do: str
end

defimpl Logfmt.ValueEncoder, for: Atom do
  def encode(atom), do: Atom.to_string(atom)
end

defimpl Logfmt.ValueEncoder, for: NaiveDateTime do
  def encode(naive_date_time), do: NaiveDateTime.to_string(naive_date_time)
end

defimpl Logfmt.ValueEncoder, for: DateTime do
  def encode(date_time), do: DateTime.to_string(date_time)
end

defimpl Logfmt.ValueEncoder, for: Integer do
  def encode(int), do: Integer.to_string(int)
end

defimpl Logfmt.ValueEncoder, for: Float do
  def encode(float), do: Float.to_string(float)
end

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
  @spec encode(Dict.t, options :: Keyword.t) :: String.t
  def encode(list, options \\ []) do
    result = Enum.reduce(list, [], &encode_pair/2)
    case options[:output] do
      # in case you wish to get back an iolist
      :iolist -> result
      # otherwise default to returning a binary
      _ -> Enum.join(List.flatten(result))
    end
  end

  @spec encode_value(value :: term) :: String.t
  defp encode_value(value) do
    str = Logfmt.ValueEncoder.encode(value)
    cond do
      # originally I wanted to check if the string contained both ' and "
      # the quoting would require escaping those characters first
      str =~ ~r/[\s\=]/ -> ["\"", str, "\""]
      true -> str
    end
  end

  defp encode_pair({key, value}, []) do
    # this is called for the first item in the list, since the accumulator
    # would be empty at that point.
    # in the second variant of the function, a spacer " " must be added between
    # the previous accumulator values and the current key value pair
    [[key, :=, encode_value(value)]]
  end

  defp encode_pair({key, value}, acc) do
    # if an options keyword list was passed in, the " " could be replaced
    # with a user configurable option, but for now we'll keep the space.
    [acc, " ", [key, :=, encode_value(value)]]
  end
end
