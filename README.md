# Logfmt

[![Build Status](https://github.com/jclem/logfmt-elixir/workflows/CI/badge.svg)](https://github.com/jclem/logfmt-elixir/actions?workflow=CI)
[![Module Version](https://img.shields.io/hexpm/v/logfmt.svg)](https://hex.pm/packages/logfmt)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/logfmt/)
[![Total Download](https://img.shields.io/hexpm/dt/logfmt.svg)](https://hex.pm/packages/logfmt)
[![License](https://img.shields.io/hexpm/l/logfmt.svg)](https://github.com/jclem/logfmt-elixir/blob/master/LICENSE.md)
[![Last Updated](https://img.shields.io/github/last-commit/jclem/logfmt-elixir.svg)](https://github.com/jclem/logfmt-elixir/commits/master)

Logfmt is a module for encoding and decoding logfmt-style log lines.

## Installation

The package can be installed by adding `:logfmt` to your list of dependencies in
`mix.exs`:

```elixir
def deps do
  [
    {:logfmt, "~> 3.2.0"}
  ]
end
```

## Usages

Decode log lines into maps:

```elixir
iex> Logfmt.decode "foo=bar"
%{"foo" => "bar"}
```

Encode Dict implementation values into log lines:

```elixir
iex> Logfmt.encode [foo: "bar"]
"foo=bar"

iex> Logfmt.encode %{foo: "bar"}
"foo=bar"
```

Custom types can encoded by implementing the ValueEncoder protocol for it.

For example to encode DateTime and NaiveDateTime and implementation could look like this:

```elixir
defimpl Logfmt.ValueEncoder, for: NaiveDateTime do
  def encode(naive_date_time), do: NaiveDateTime.to_iso8601(naive_date_time)
end

defimpl Logfmt.ValueEncoder, for: DateTime do
  def encode(date_time), do: DateTime.to_iso8601(date_time)
end
```

## Type Coercion

When decoding a log line, Logfmt will coerce some strings into booleans and
numbers:

```elixir
iex> Logfmt.decode "foo=true"
%{"foo" => true}

iex> Logfmt.decode "foo=-1.2e9"
%{"foo" => -1.2e9}
```

In the future, this may be optional, or more robust. For example, it might make
sense for `"foo=true"` to decode into `%{"foo" => true}`, but `~s(foo="true")`
to decode into `%{"foo" => "true"}`.

Another option might be to allow the user to provide a formatting map to the
`decode` function, which expects coercion functions as values:

```elixir
iex> "foo=1 bar=2" |> Logfmt.decode %{
...> foo: &Logfmt.TypeCoercion.parse_integer/1
...> }
%{"foo" => 1, "bar" => "2"}
```

## Why decode into maps?

Originally, this library both decoded and encoded maps. However, this was
problematic because key ordering in maps is not guaranteed. A developer wants to
be able to ensure that their log output will have identical ordering for
multiple calls for the sake of readability.

To solve this, the second version encoded and decoded Keyword lists only. Of
course, this is also problematic because decoding log lines into Keyword lists
involves converting user strings into non-garbage-collected atoms.

Now, this module decodes into maps only (with string keys) and encodes any Dict
implementation type. This is a fair compromise, because ordering upon decoding a
Logfmt line is not important, and keeping only the last value for a duplicate
key in a log line is fair, as well.

## Copyright and License

Copyright (c) 2015 Jonathan Clem

This library is released under the MIT License. See the [LICENSE.md](./LICENSE.md) file
for further details.
