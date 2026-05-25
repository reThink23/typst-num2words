#import "@preview/mantys:1.0.2": arg

== German

Language code: `"de"`.

=== Options

/ #arg("form"): The output form. One of `"cardinal"` (default), `"ordinal"`.
/ #arg("negative"): The prefix used for negative numbers. Defaults to `"minus"`.

=== Forms

==== Cardinal

The default form. Converts numbers to their cardinal word representation.

```example
#num2words(42, lang: "de")
```

```example
#num2words(1000, lang: "de")
```

Negative numbers are prefixed with the value of #arg("negative"):

```example
#num2words(-7, lang: "de")
```

```example
#num2words(-7, lang: "de", negative: "negative")
```

==== Ordinal

Converts numbers to their ordinal word form.

```example
#num2words(1, lang: "de", form: "ordinal")
```

```example
#num2words(42, lang: "de", form: "ordinal")
```
