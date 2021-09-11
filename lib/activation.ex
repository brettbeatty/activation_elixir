defmodule Activation do
  defmacro activate(module, function_name, args) do
    unless Module.has_attribute?(__CALLER__.module, __MODULE__) do
      Module.register_attribute(__CALLER__.module, __MODULE__, accumulate: true, persist: true)
    end

    mfa = {
      Macro.expand(module, __CALLER__),
      function_name,
      Enum.map(args, &Macro.expand(&1, __CALLER__))
    }

    Module.put_attribute(__CALLER__.module, __MODULE__, mfa)

    quote do
      case :persistent_term.get(unquote(__MODULE__), %{}) do
        %{{unquote(module), unquote(function_name), unquote(args)} => value} ->
          value

        %{} ->
          raise "could not get value; did you call Activation.start/0?"
      end
    end
  end

  def start do
    apply(Activation.Consolidated, :start, [])
  end
end
