defmodule Mix.Tasks.ZigBuilder.Get do
  use Mix.Task

  @shortdoc "Get the zig from online"

  @moduledoc """
  Get zig from online
  """

  def run(_) do
    ZigBuilder.Zig.fetch!()
  end
end
