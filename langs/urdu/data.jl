consonants = Dict(
    "ب" => "ba",
    "پ" => "pha",
    "ت" => "ta",
    "ٹ" => "Ta",
    "ث" => "sa",
    "ج" => "ja",
    "چ" => "cha",
    "ح" => "ha",
    "خ" => "kha",
    "د" => "da",
    "ڈ" => "Da",
    "ذ" => "za",
    "ر" => "ra",
    "ڑ" => "Ra",
    "ز" => "za",
    "ژ" => "zha",
    "س" => "sa",
    "ش" => "Sha",
    "ص" => "Sa",
    "ض" => "Za",
    "ط" => "Ta",
    "ظ" => "Za",
    "ع" => "'a",
    "غ" => "gha",
    "ف" => "fa",
    "ق" => "qa",
    "ک" => "ka",
    "گ" => "ga",
    "ل" => "la",
    "م" => "ma",
    "ن" => "na",
    "ں" => "~na",
    "و" => "va",
    "ہ" => "ha",
    "ھ" => "ha",
    "ء" => "'",
    "ی" => "ya",
    "ے" => "e"
)

vowels = Dict(
    "َ" => "a",    # zabar
    "ِ" => "i",    # zer
    "ُ" => "u",    # pesh
    "ً" => "am.",  # tanween (an)
    "ٍ" => "im.",  # tanween (in)
    "ٌ" => "um.",  # tanween (un)
    "ْ" => "",     # sukoon
    "ّ" => "",     # shadda (handled elsewhere)
)

vowels_sep = Dict(
    "ا" => "a",
    "آ" => "A",
    "ؤ" => "^O",   # consistent with your mapping of "ॉ" => "^O"
    "ئ" => "I",
    "و" => "O",
    "ی" => "I",
    "ے" => "E"
)

learning_path = ["vow", "cons", "vow+cons", "cons+cons"]

title = "اُردُو حُرُوفِ تَہَجِّی‌ (﷽)"