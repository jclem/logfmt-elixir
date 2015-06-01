# Logfmt [![Build Status](https://travis-ci.org/jclem/logfmt-elixir.svg?branch=master)](https://travis-ci.org/jclem/logfmt-elixir)

Decode log lines into keyword lists:

```elixir
iex> Logfmt.decode "foo=bar"
[foo: "bar"]
```

Encode keyword lists into log lines:

```elixir
iex> Logfmt.encode [foo: "bar"]
"foo=bar"
```
