# Logfmt [![Build Status](https://travis-ci.org/jclem/logfmt-elixir.svg?branch=master)](https://travis-ci.org/jclem/logfmt-elixir)

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
