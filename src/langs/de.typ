/// German number-to-words conversion.
#import "../errors.typ"

/// The language code for this module.
#let _lang-code = "de"

// Data tables.

/// Words for numbers 0–19.
#let _units = (
  "null",
  "ein",
  "zwei",
  "drei",
  "vier",
  "fünf",
  "sechs",
  "sieben",
  "acht",
  "neun",
  "zehn",
  "elf",
  "zwölf",
  "dreizehn",
  "vierzehn",
  "fünfzehn",
  "sechzehn",
  "siebzehn",
  "achtzehn",
  "neunzehn",
)

/// Words for multiples of ten from 20–90.
#let _tens = (
  "zwanzig",
  "dreißig",
  "vierzig",
  "fünfzig",
  "sechzig",
  "siebzig",
  "achtzig",
  "neunzig",
)

/// Scale words for groups of three digits (short scale).
#let _scales = (
  "",
  "tausend",
  "Million",
  "Milliarde",
  "Billion",
  "Billiarde",
  "Trillion",
  "Trilliarde",
  "Quadrillion",
  "Quadrilliarde",
  "Quintillion",
  "Quintilliarde",
  "Sextillion",
  "Sextilliarde",
  "Septillion",
  "Septilliarde",
  "Oktillion",
  "Oktilliarde",
  "Nonillion",
  "Nonilliarde",
  "Dezillion",
  "Dezilliarde",
)

/// Cardinal words whose ordinal form is irregular.
#let _ordinal-irregulars = (
  eins: "erste",
  zwei: "zweite",
  drei: "dritte",
  vier: "vierte",
  fünf: "fünfte",
  sechs: "sechste",
  sieben: "siebte",
  acht: "achte",
  neun: "neunte",
  zehn: "zehnte",
  elf: "elfte",
  zwölf: "zwölfte",
)

/// Supported forms for this language module.
#let _supported-forms = ("cardinal", "ordinal", "year")


// Cardinal helpers.


/// Helper function to handle the "eins" to "ein" conversion used in compounds.
///
/// - word (str): The word to process.
/// -> str
#let _handle-eins(word) = {
  if word == "eins" {
    "ein"
  } else {
    word
  }
}

/// Pluralize the scale
///
/// - word (str): The word from scales to be pluralized
/// -> str
#let _pluralize-scale(word) = {
  return if word.last() == "n" {
    word + "en"
  } else if word.last() == "e" {
    word + "n"
  } else {
    word
  }
}


/// Converts a number in the range 1–99 to its cardinal word form.
/// order: units + "und" + tens
///
/// - number (int): The number to convert (1–99).
/// -> str
#let _convert-below-100(number) = {
  if number == 1 {
    return "eins"
  } else if number < 20 {
    return _units.at(number)
  }

  let tens-digit = calc.quo(number, 10)
  let units-digit = calc.rem(number, 10)

  if units-digit == 0 {
    return _tens.at(tens-digit - 2)
  } else if tens-digit == 0 {
    return _handle-eins(_units.at(units-digit))
  } else {
    return _handle-eins(_units.at(units-digit)) + "und" + _tens.at(tens-digit - 2)
  }
}

/// Converts a number in the range 1–999 to its cardinal word form.
///
/// - number (int): The number to convert (1–999).
/// -> str
#let _convert-below-1000(number) = {
  if number < 100 {
    return _convert-below-100(number)
  } else {
    let hundreds-digit = calc.quo(number, 100)
    let remainder = calc.rem(number, 100)
    if remainder == 0 {
      if hundreds-digit == 1 {
        "einhundert"
      } else {
        _handle-eins(_units.at(hundreds-digit)) + "hundert"
      }
    } else {
      _handle-eins(_units.at(hundreds-digit)) + "hundert" + _convert-below-100(remainder)
    }
  }
}

/// Converts a number in the range 1–999,999 to its cardinal word form.
///
/// - number (int): The number to convert (1–999,999).
/// -> str
#let _convert-below-million(number) = {
  let thousands = calc.quo(number, 1000)
  let below-thousands = calc.rem(number, 1000)
  return if (thousands == 0) {
    _convert-below-1000(below-thousands)
  } else {
    if below-thousands == 0 {
      _handle-eins(_convert-below-1000(thousands)) + "tausend"
    } else {
      _handle-eins(_convert-below-1000(thousands)) + "tausend" + _convert-below-1000(below-thousands)
    }
  }
}

/// Converts a number upwards of 1,000,000
// (until scale has no more entries)
///
/// - number (int): The number to convert (1,000,000–10^63)
/// -> str
#let _convert-above-million(number) = {
  let str-number = str(number)
  let len-digits = str-number.len()
  let highest-group-len = calc.rem(len-digits, 3)

  if len-digits < 7 {
    return _convert-below-million(number)
  }

  if highest-group-len != 0 {
    str-number = "0" * (3 - highest-group-len) + str-number
  }

  let groups = ()
  for i in range(0, str-number.len(), step: 3) {
    groups.push(int(str-number.slice(i, count: 3)))
  }

  errors.out-of-range(groups.len() - 1, max: _scales.len() - 1, lang: _lang-code)

  groups = groups.rev()
  let parts = ()

  for (idx, val) in groups.enumerate() {
    if val == 0 { continue }

    if idx == 0 {
      parts.push(_convert-below-1000(val))
    } else if idx == 1 {
      parts.push(_handle-eins(_convert-below-1000(val)) + "tausend")
    } else {
      let scale = _scales.at(idx)
      let words = _convert-below-1000(val)

      if words == "eins" {
        words = "eine"
      }

      if val != 1 {
        scale = _pluralize-scale(scale)
      }

      parts.push(words + " " + scale + " ")
    }
  }

  return parts.rev().join("").trim()
}

/// Converts a positive integer to its cardinal word form.
///
/// - number (int): The number to convert (>= 1).
/// -> str
#let _convert-cardinal(number) = {
  return _convert-above-million(number)
}

// Ordinal helpers.

/// Converts a single cardinal word to its ordinal form.
///
/// - word (str): The cardinal word to ordinalize.
/// -> str
#let _ordinalize(word) = {
  return if word in _ordinal-irregulars {
    _ordinal-irregulars.at(word)
  } else if (
    word.ends-with("ig")
      or word.ends-with("hundert")
      or word.ends-with("tausend")
      or word.ends-with("ion")
      or word.ends-with("ard")
  ) {
    word + "ste"
  } else {
    word + "te"
  }
}

/// Transforms a full cardinal string into its ordinal form by ordinalizing
/// only the last word, accounting for cardinal endings that are irregular.
///
/// - cardinal (str): The cardinal string to transform.
/// -> str
#let _cardinal-to-ordinal(cardinal) = {
  let tokens = cardinal.split(" ")
  let last = tokens.last()
  let new-last = ""

  if last in _ordinal-irregulars {
    new-last = _ordinal-irregulars.at(last)
  } else {
    let found-irregular = false
    for (card, ord) in _ordinal-irregulars {
      if last.ends-with(card) {
        let base = last.slice(0, last.len() - card.len())
        new-last = base + ord
        found-irregular = true
        break
      }
    }

    if not found-irregular {
      new-last = _ordinalize(last)
    }
  }

  return (tokens.slice(0, -1) + (new-last,)).join(" ")
}

/// Converts a positive integer to its ordinal word form.
///
/// - number (int): The number to convert (>= 1).
/// -> str
#let _convert-ordinal(number) = {
  let cardinal = _convert-cardinal(number)
  return _cardinal-to-ordinal(cardinal)
}

// Year helpers.

/// Converts a positive integer to its year reading form.
///
/// - number (int): The number to convert (>= 1).
/// -> str
#let _convert-year(number) = {
  let high = calc.quo(number, 100)
  let low = calc.rem(number, 100)
  return if high >= 20 or high < 11 {
    _convert-below-million(number)
  } else {
    if low == 0 {
      _convert-below-100(high) + "hundert"
    } else {
      _convert-below-100(high) + "hundert" + _convert-below-100(low)
    }
  }
}

// Public entry point.

/// Converts a number to its German word form.
///
/// - number (int): The number to convert.
/// - form (str): The form: `"cardinal"`, `"ordinal"`, or `"year"` (default: `"cardinal"`).
/// - negative (str): The prefix for negative numbers (default: `"negative"`).
/// -> str
#let convert(number, form: "cardinal", negative: "minus") = {
  errors.assert-type("form", str, form, lang: _lang-code)
  errors.assert-option("form", form, _supported-forms, lang: _lang-code)
  errors.assert-type("negative", str, negative, lang: _lang-code)

  if number == 0 {
    if form == "ordinal" {
      "nullte"
    } else {
      "null"
    }
  } else {
    let prefix = if number < 0 { negative + " " } else { "" }
    let abs-number = calc.abs(number)
    let result = if form == "cardinal" {
      _convert-cardinal(abs-number)
    } else if form == "ordinal" {
      _convert-ordinal(abs-number)
    } else {
      _convert-year(abs-number)
    }
    prefix + result
  }
}
