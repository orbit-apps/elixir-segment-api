# SegmentAPI

Basic HTTP wrapper for the Segment service.

## Installation

Package can be installed by adding `segment_api` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:segment_api, github: "pixelunion/elixir-segment-api", tag: "0.1.0"}
  ]
end
```

Add the following configuration to your config.ex

```elixir
config :segment_api, :api_key, "<your encoded basic auth keys>"
```

Use like

```elixir
app_slug = "USO"
shopify_domain = "example.myshopify.com"
type = :customer_data_request

SegmentAPI.track(
  SegmentAPI.event(app_slug, type),
  shopify_domain,
  %{data: %{foo: "bar"}}
)
```
