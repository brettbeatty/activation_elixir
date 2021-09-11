defmodule Mix.Tasks.Compile.Activate do
  use Mix.Task.Compiler

  @impl Mix.Task.Compiler
  def run(_args) do
    erlang_prefix = :code.lib_dir()

    activations =
      for dir <- :code.get_path(),
          not :lists.prefix(erlang_prefix, dir),
          file <- ls(dir),
          :lists.prefix('Elixir.', file) and :filename.extension(file) == '.beam',
          {Activate, activations} <- get_attrs(dir, file),
          {module, function_name, args} <- activations,
          uniq: true do
        quote do
          {{unquote(module), unquote(function_name), unquote(args)},
           apply(unquote(module), unquote(function_name), unquote(args))}
        end
      end

    ast =
      quote do
        def start do
          :persistent_term.put(Activate, %{unquote_splicing(activations)})
        end
      end

    :code.purge(Activate.Starter)
    :code.delete(Activate.Starter)
    Module.create(Activate.Starter, ast, __ENV__)

    :ok
  end

  defp ls(dir) do
    case :file.list_dir(dir) do
      {:ok, files} ->
        files

      {:error, _reason} ->
        []
    end
  end

  defp get_attrs(dir, file) do
    filename = :filename.join(dir, file)

    case :beam_lib.chunks(filename, [:attributes]) do
      {:ok, {_module, attributes: attrs}} ->
        attrs

      {:error, :beam_lib, _reason} ->
        []
    end
  end
end
