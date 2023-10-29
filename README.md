# ZigBuilder

Mix tasks for installing and invoking [zig](https://ziglang.org/) 

ZigBuilder is a library providing seamless integration between Elixir and the Zig compiler, allowing developers to replace `cmake` with `zig_builder`.

## Features

- **Seamless Zig Integration**: Directly use Zig within your Elixir projects.
- **cmake Replacement**: Say goodbye to `cmake` and hello to a streamlined build process.
- **Performance**: Capitalize on the efficiency of Zig while staying in the Elixir ecosystem.


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `zig_builder` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:zig_builder, "~> 0.1.0"}
  ]
end
```

Once installed, change your `config/config.exs` to pick your
zig version of choice:

```elixir
config :zig_builder, version: "0.11.0"
```

Now you can install zig_builder by running:

```bash
$ mix deps.get
```

or

```bash
$ mix zig.get
```
The executable is kept at `_build/zig-TARGET`.
Where `TARGET` is your system target architecture.


## Contribution

We welcome contributions from the community!

1. **Fork** the repository on GitHub.
2. **Clone** the forked repository to your machine.
3. Create a new **branch** for your feature or fix.
4. Make your changes and **commit** them to your branch.
5. Submit a **pull request** and describe the changes you've made.

## Support & Feedback

Your feedback helps make ZigBuilder even better! If you run into issues or have suggestions, please:

Open an issue on our GitHub repository.

**Thank you for supporting ElixirZigBuilder!**