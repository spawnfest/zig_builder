defmodule ZigBuilder.Compiler do
  def compile(args) do
    config = Mix.Project.config()
    Mix.shell().print_app()
    priv? = File.dir?("priv")
    Mix.Project.ensure_structure()
    build(config, args)

    # IF there was no priv before and now there is one, we assume
    # the user wants to copy it. If priv already existed and was
    # written to it, then it won't be copied if build_embedded is
    # set to true.
    if not priv? and File.dir?("priv") do
      Mix.Project.build_structure()
    end

    {:ok, []}
  end

  def build(config, task_args) do
    exec = "zig"
    env = default_env(config, %{})

    cwd = ZigBuilder.Zig.directory()
    build_file_arg = ["--build-file", Path.join([File.cwd!(), "build.zig"])]
    cache_dir_arg = ["--cache-dir", Path.join(cwd, "zig-cache")]
    base = exec |> Path.basename() |> Path.rootname()
    args = ["build", build_file_arg, cache_dir_arg] |> List.flatten()

    case cmd(exec, args, cwd, env, "--verbose" in task_args) do
      0 ->
        :ok

      exit_status ->
        raise_build_error(exec, exit_status, "compile error")
    end
  end

  # Runs `exec [args]` in `cwd` and prints the stdout and stderr in real time,
  # as soon as `exec` prints them (using `IO.Stream`).
  defp cmd(exec, args, cwd, env, verbose?) do
    opts = [
      into: IO.stream(:stdio, :line),
      stderr_to_stdout: true,
      cd: cwd,
      env: env
    ]

    if verbose? do
      print_verbose_info(exec, args)
    end

    {%IO.Stream{}, status} = System.cmd(find_executable(exec), args, opts)
    status
  end

  defp find_executable(exec) do
    System.find_executable(exec) ||
      Mix.raise("""
      "#{exec}" not found, fatal error, jump from the plane.
      """)
  end

  defp raise_build_error(exec, exit_status, error_msg) do
    Mix.raise(~s{Could not compile with "#{exec}" (exit status: #{exit_status}).\n} <> error_msg)
  end

  defp print_verbose_info(exec, args) do
    args =
      Enum.map_join(args, " ", fn arg ->
        if String.contains?(arg, " "), do: inspect(arg), else: arg
      end)

    Mix.shell().info("Compiling with zig: #{exec} #{args}")
  end

  # Returns a map of default environment variables
  # Defaults may be overwritten.
  defp default_env(config, default_env) do
    root_dir = :code.root_dir()
    erl_interface_dir = Path.join(root_dir, "usr")
    erts_dir = Path.join(root_dir, "erts-#{:erlang.system_info(:version)}")
    erts_include_dir = Path.join(erts_dir, "include")
    erl_ei_lib_dir = Path.join(erl_interface_dir, "lib")
    erl_ei_include_dir = Path.join(erl_interface_dir, "include")

    Map.merge(
      %{
        # Don't use Mix.target/0 here for backwards compatibility
        "MIX_TARGET" => env("MIX_TARGET", "host"),
        "MIX_ENV" => to_string(Mix.env()),
        "MIX_BUILD_PATH" => Mix.Project.build_path(config),
        "MIX_APP_PATH" => Mix.Project.app_path(config),
        "MIX_COMPILE_PATH" => Mix.Project.compile_path(config),
        "MIX_CONSOLIDATION_PATH" => Mix.Project.consolidation_path(config),
        "MIX_DEPS_PATH" => Mix.Project.deps_path(config),
        "MIX_MANIFEST_PATH" => Mix.Project.manifest_path(config),

        # Rebar naming
        "ERL_EI_LIBDIR" => env("ERL_EI_LIBDIR", erl_ei_lib_dir),
        "ERL_EI_INCLUDE_DIR" => env("ERL_EI_INCLUDE_DIR", erl_ei_include_dir),

        # erlang.mk naming
        "ERTS_INCLUDE_DIR" => env("ERTS_INCLUDE_DIR", erts_include_dir),
        "ERL_INTERFACE_LIB_DIR" => env("ERL_INTERFACE_LIB_DIR", erl_ei_lib_dir),
        "ERL_INTERFACE_INCLUDE_DIR" => env("ERL_INTERFACE_INCLUDE_DIR", erl_ei_include_dir),

        # Disable default erlang values
        "BINDIR" => nil,
        "ROOTDIR" => nil,
        "PROGNAME" => nil,
        "EMU" => nil
      },
      default_env
    )
  end

  defp env(var, default) do
    System.get_env(var) || default
  end
end
