defmodule ZigBuilder.GenerateUtils do
  # Runs `exec [args]` in `cwd` and prints the stdout and stderr in real time,
  # as soon as `exec` prints them (using `IO.Stream`).
  def cmd(exec, args, cwd, env, verbose?) do
    opts = [
      # into: IO.stream(:stdio, :line),
      stderr_to_stdout: true,
      cd: cwd,
      env: env
    ]

    if verbose? do
      print_verbose_info(exec, args)
    end

    {_message, status} = System.cmd(find_executable(exec), args, opts)
    status
  end

  defp find_executable(exec) do
    System.find_executable(exec) ||
      Mix.raise("""
      "#{exec}" not found, fatal error, jump from the plane.
      """)
  end

  defp print_verbose_info(exec, args) do
    args =
      Enum.map_join(args, " ", fn arg ->
        if String.contains?(arg, " "), do: inspect(arg), else: arg
      end)

    Mix.shell().info("Compiling with zig: #{exec} #{args}")
  end

  def raise_build_error(exec, exit_status, error_msg) do
    Mix.raise(~s{Could not compile with "#{exec}" (exit status: #{exit_status}).\n} <> error_msg)
  end

  def copy_or_override_build_file(build_file_path, location) do
    if(File.exists?(location)) do
      data =
        IO.gets(
          "File #{Path.basename(location)} already exists, do you want to override it? [Y/n]: "
        )
        |> String.trim()

      if data == String.downcase("y") do
        File.cp!(build_file_path, location)
        IO.puts("File overriden successfully.")
      else
        IO.puts("Operation canceled.")
      end
    else
      File.cp!(build_file_path, location)
    end
  end
end
