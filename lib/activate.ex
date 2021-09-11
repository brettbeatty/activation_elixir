defmodule Activate do
  defmacro activate(module, function_name, args) do
    unless Module.has_attribute?(__CALLER__.module, __MODULE__) do
      Module.register_attribute(__CALLER__.module, __MODULE__, accumulate: true, persist: true)
    end

    Module.put_attribute(__CALLER__.module, __MODULE__, {module, function_name, args})

    quote do
      case :persistent_term.get(unquote(__MODULE__), %{}) do
        %{{unquote(module), unquote(function_name), unquote(args)} => value} ->
          value

        %{} ->
          raise "could not get value; did you call Activate.start/0?"
      end
    end
  end

  def start do
    apply(Activate.Starter, :start, [])
  end
end
