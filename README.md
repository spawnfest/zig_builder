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
    {:zig_builder, git: "https://github.com/spawnfest/zig_builder.git"}
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
$ mix zig_builder.get
```
The executable is kept at `_build/zig-TARGET`.
Where `TARGET` is your system target architecture.

## ZigBuilder Mix Tasks

The `ZigBuilder` offers two key Mix tasks to enhance the integration between Zig and Elixir. These tasks help you set up Zig build configurations optimized for your project.

### `mix zig_builder.get`

This task is a dedicated Mix task designed to fetch the Zig compiler from its online sources. It utilizes functionalities provided by the `ZigBuilder.Zig` module to determine the correct Zig version and system architecture, ensuring that you have the correct binary for your platform. 

The Zig programming language offers excellent facilities for systems programming, and by integrating it within your Elixir environment, you can harness the power of both worlds. The `mix zig_builder.get` task ensures that you have the necessary Zig compiler binaries ready to use without manual intervention.

#### Usage

```bash
mix mix zig_builder.get
```

On invocation, the task will:

1. Check if Zig is already downloaded.
2. If not, it identifies the system's operating system and architecture.
3. Fetches the appropriate Zig binary and its standard library for the configured or latest known version.
4. Stores the Zig binary in a dedicated directory within your project's build path.

#### Requirements
- Internet connection: The task fetches Zig from its official website, so ensure you have a stable internet connection.
- Supported platform: Currently, this task supports Linux, FreeBSD, macOS, and has limited support for Windows.

#### Notes

- If Zig is already present, the task will log an informational message and won't re-download it.
- Ensure you invoke this task before generating Zig build files or invoking other Zig-related operations to ensure the compiler's availability.

### `mix zig_builder.generate.exe`

This task produces a sample `build.zig` tailored for creating executables.

#### Usage

```bash
mix zig_builder.generate.exe
```
#### Parameters:

* `name`: Optional. Name of the Zig build file (defaults to `build.zig`).

#### Behavior:

1. If Zig is not already downloaded, the task will fetch it.
2. Generates a Zig configuration file for libraries.
3. If a `build.zig` file already exists in the project directory, you will be prompted to override it.

### `mix zig_builder.generate.lib`

This task curates a sample build.zig for library development.

#### Usage

```bash
mix zig_builder.generate.lib
```
#### Parameters:

* `name`: Optional. Name of the Zig build file (defaults to `build.zig`).

#### Behavior:

1. If Zig is not already downloaded, the task will fetch it.
2. It will set up a Zig configuration designed for libraries.
3. Should there already be a build.zig in your project directory, you will receive a prompt regarding its override.


### Tips
- Ensure Zig is set up correctly in your environment to maximize the potential of these Mix tasks.
- Stay updated with Zig and ZigBuilder releases for enhanced capabilities and compatibility.


## Getting Started with ZigBuilder

For a practical demonstration of the `ZigBuilder` library in action, check out our demo project at [ZigBuilder Demo Project](https://github.com/D4no0/zig_builder_demo). This will provide insights into how to set up and use `ZigBuilder` effectively in a real-world scenario.

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

**Thank you for supporting ZigBuilder!**