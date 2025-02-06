# SegmentAPI

Basic HTTP wrapper for the Segment service.

## Installation

Package can be installed by adding `segment_api` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:segment_api, github: "Beam-Maintenance/elixir-segment-api", tag: "v0.5.0"}
  ]
end
```

Add the following configuration to your config.ex

```elixir
config :segment_api, :api_key, "<your encoded basic auth keys>"
```

Use like

```elixir
SegmentAPI.track(
  "Customer Data Request",
  "Customer:111",
  %{data: %{foo: "bar"}},
  %{integrations: %{All: true, Salesforce: false}}
)
```
