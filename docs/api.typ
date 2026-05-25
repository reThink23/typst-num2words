#import "@preview/mantys:1.0.2": tidy-module

#let show-module(name, ..tidy-args) = tidy-module(
  name,
  read("../src/" + name + ".typ"),
  legacy-parser: true,
  ..tidy-args.named(),
)

#let show-lang-module(lang-code, ..tidy-args) = show-module(
  "langs/" + lang-code,
  module: lang-code,
  ..tidy-args.named(),
)

= API reference

== Main module

#show-module("lib")

== Error helpers

#show-module("errors")

== Languages

=== English (US)

#show-lang-module("en")

=== Spanish

#show-lang-module("es")

=== Catalan

#show-lang-module("ca")

=== German

#show-lang-module("de")
