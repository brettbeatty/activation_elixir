# Activation

Activation is a project I hacked together to play with cross-module aggregation at compile-time in
Elixir. It allows you to easily declare values that are only calculated once, on app startup. It
looks to strike a balance between compile-time and runtime calculation, front-loading work to app
startup for reduced work later (I came up with the idea when I had a plug where I wanted an
`:init_mode` of `:compile` for performance but needed some data from runtime).

I wasn't sure what to call things. I used the name activation because the concept reminded me of the
activation energy for a reaction, but I wasn't sure what to name my functions, so if you have any
ideas let me know.

## Using Activation

Start by adding Activation to your deps.

```elixir
  defp deps do
    [
      # ...
      {:activation, github: "brettbeatty/activation_elixir"},
      # ...
    ]
  end
```

While you're in `mix.exs` you'll need to add a compiler. This allows Activation to collect
module-function-attributes trios to call them all at startup.

```elixir
  def project do
    [
      # ...
      compilers: Mix.compilers() ++ [:activation],
      # ...
    ]
  end
```

Activation leaves it to your app to "start" calculating values (again, name ideas welcome), so
you'll want to add that to your application startup logic.

```elixir
defmodule MyApp.Application do
  # ...

  def start(_type, _args) do
    Activation.start()

    # ...
  end

  # ...
end
```

You can now start using Activation. While I intended it for more expensive calculations, our example
will be pretty simple.

```elixir
defmodule MyApp do
  # ...
  import Activation, only: [activate: 3]

  # ...

  def hello do
    activate(IO, :inspect, [:world, [label: "hello"]])
  end
end
```

If you start up your app, you can see that `:world` gets inspected with the label `"hello"`.

```
$ iex -S mix
Erlang/OTP 24 [erts-12.0.4] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:1] [jit]

Compiling 1 file (.ex)
hello: :world
Interactive Elixir (1.12.3) - press Ctrl+C to exit (type h() ENTER for help)
```

Now you can make calls to `MyApp.hello/0` and see that it returns `:world` with no additional
inspection.

```elixir
iex(1)> MyApp.hello
:world
iex(2)> MyApp.hello
:world
```

If you use an MFA trio more than one place in your code, it will only get run once.

## To Do If I Feel Like It

- [ ] Support for more deeply-nested args. Right now if you pass nested terms that need expanded (a module inside a keyword list, for
  example) it won't consolidate them correctly.
- [ ] Add manifest and .beam files. For now it does all consolidation work every time your app compiles.
- [ ] Code organization and docs and all that fun stuff
