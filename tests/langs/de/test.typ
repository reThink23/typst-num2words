/// Tests for German number-to-words conversion.
#import "/src/lib.typ": converters
#import "/tests/utils.typ": check

#let convert = converters.de

// Cardinals.
#check(
  convert,
  (
    // Basic.
    (0, "null"),
    (1, "eins"),
    (2, "zwei"),
    (3, "drei"),
    (4, "vier"),
    (5, "fünf"),
    (9, "neun"),
    (10, "zehn"),
    (11, "elf"),
    (12, "zwölf"),
    (13, "dreizehn"),
    (15, "fünfzehn"),
    (19, "neunzehn"),
    // Tens.
    (20, "zwanzig"),
    (21, "einundzwanzig"),
    (30, "dreißig"),
    (42, "zweiundvierzig"),
    (50, "fünfzig"),
    (69, "neunundsechzig"),
    (80, "achtzig"),
    (99, "neunundneunzig"),
    // Hundreds.
    (100, "einhundert"),
    (101, "einhunderteins"),
    (110, "einhundertzehn"),
    (111, "einhundertelf"),
    (199, "einhundertneunundneunzig"),
    (200, "zweihundert"),
    (999, "neunhundertneunundneunzig"),
    // Thousands and beyond.
    (1000, "eintausend"),
    (1001, "eintausendeins"),
    (1010, "eintausendzehn"),
    (1100, "eintausendeinhundert"),
    (1234, "eintausendzweihundertvierunddreißig"),
    (10000, "zehntausend"),
    (12345, "zwölftausenddreihundertfünfundvierzig"),
    (100000, "einhunderttausend"),
    (1000000, "eine Million"),
    (1000001, "eine Million eins"),
    (1234567, "eine Million zweihundertvierunddreißigtausendfünfhundertsiebenundsechzig"),
    (1000000000, "eine Milliarde"),
    (1000000000000, "eine Billion"),
    // Negative numbers.
    (-1, "minus eins"),
    (-42, "minus zweiundvierzig"),
    (-1000, "minus eintausend"),
    (-5, "negative fünf", arguments(negative: "negative")),
  ),
  form: "cardinal",
)

// Ordinals.
#check(
  convert,
  (
    // Irregulars.
    (0, "nullte"),
    (1, "erste"),
    (2, "zweite"),
    (3, "dritte"),
    (4, "vierte"),
    (5, "fünfte"),
    (6, "sechste"),
    (7, "siebte"),
    (8, "achte"),
    (9, "neunte"),
    (10, "zehnte"),
    (11, "elfte"),
    (12, "zwölfte"),
    // Regular.
    (20, "zwanzigste"),
    (22, "zweiundzwanzigste"),
    (30, "dreißigste"),
    (31, "einunddreißigste"),
    (40, "vierzigste"),
    (100, "einhundertste"),
    (101, "einhunderterste"),
    (800, "achthundertste"),
    (1000, "eintausendste"),

    // Compound.
    (8528321, "acht Millionen fünfhundertachtundzwanzigtausenddreihunderteinundzwanzigste"),
    (1000000, "eine Millionste"),
    (1000001, "eine Million erste"),
  ),
  form: "ordinal",
)
