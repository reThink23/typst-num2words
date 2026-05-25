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
  "Quntillion",
  "Quintilliarde",
  "Sextillion",
  "Sextilliarde",
  "Heptillion",
  "Heptilliarde",
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

#let _hundred-irregulars = (
  eins: "einhundert",
)

/// Supported forms for this language module.
#let _supported-forms = ("cardinal", "ordinal")


// Cardinal helpers.


/// Helper function to handle "eins" to "ein" conversion based on position.
///
/// - word (str): The word to process.
/// - is-first (bool): Whether this is the first part of a compound number.
/// -> str
#let _handle-eins(word, is-first: true) = {
  if word == "eins" and is-first {
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
  let num-groups = calc.quo(len-digits, 3)
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

  groups = groups.rev()

  errors.out-of-range(groups.len() - 1, max: _scales.len() - 1, lang: _lang-code)

  groups = groups.rev()
  let parts = ()

  for (idx, val) in groups.enumerate() {
    if val == 0 { continue }

    if idx == 0 {
      parts.push(_convert-below-1000(val))
    } else if idx == 1 {
      parts.push(_convert-below-1000(val) + "tausend")
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

  // for i in range(start,num-groups) {
  //   // start from last group
  //   let crt-thousands = int(str-number.slice(-3 * i, count: 3))
  //   let crt-scale = _scales.at(i+1) // if crt-thousands == 1 {_scales.at(i)} else {_pluralize-scale(_scales.at(i))}
  //   let d = _convert-below-1000(crt-thousands)
  //   if crt-thousands != 0 {
  //     parts.push(d)
  //   }
  //   parts.push(crt-scale)
  // }
  // parts.push(_convert-below-1000(int(str-number.slice(0,highest-group-len))).replace("eins", "eine"))
  // // // calculates length correctly by log10 and considering power of 10 has one more digit than detected
  // // let lg = calc.log(calc.abs(number))
  // // let len-digits = calc.ceil(lg) + if calc.rem(lg, 1) == 0 {1} else {0}
  // return parts.rev().join(" ")
}

/// Recursively splits a number into 3-digit chunks and converts each chunk,
/// appending the appropriate scale word.
///
/// - number (int): The remaining number to convert.
/// - scale-index (int): The current scale index (0 = units, 1 = thousands, etc.).
/// -> array
#let _chunk-and-convert(number, scale-index) = {
  if number == 0 {
    ()
  } else {
    errors.out-of-range(scale-index, max: _scales.len() - 1, lang: _lang-code)
    let chunk = calc.rem(number, 1000)
    let rest = calc.quo(number, 1000)
    let higher = _chunk-and-convert(rest, scale-index + 1)
    if chunk == 0 {
      higher
    } else {
      let words = _convert-below-1000(chunk)
      if scale-index > 0 {
        words = words + " " + _scales.at(scale-index)
      }
      higher + (words,)
    }
  }
}

/// Converts a positive integer to its cardinal word form.
///
/// - number (int): The number to convert (>= 1).
/// -> str
#let _convert-cardinal(number) = {
  return _convert-above-million(number)
  // return _chunk-and-convert(number, 0).join(" ")
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
/// only the last word (handling hyphenated compounds like "forty-two").
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
  if number < 1000 {
    return _convert-cardinal(number)
  } else if number < 10000 {
    let high = calc.quo(number, 100)
    let low = calc.rem(number, 100)
    if calc.rem(number, 1000) == 0 {
      _convert-cardinal(number)
    } else if low == 0 {
      _convert-below-100(high) + " hundred"
    } else if high == 20 and low < 10 {
      "two thousand " + _convert-below-100(low)
    } else if low < 10 {
      _convert-below-100(high) + " oh " + _units.at(low)
    } else {
      _convert-below-100(high) + " " + _convert-below-100(low)
    }
  } else {
    _convert-cardinal(number)
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
