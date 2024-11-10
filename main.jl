using Mousetrap
using TickTock

# TODO: Export these to separate language file
consonants = Dict(
    "க" => "ka",
    "ங" => "~Nga",
    "ச" => "ca",
    "ஞ" => "~na",
    "ட" => "Ta",
    "ண" => "Na",
    "த" => "ta",
    "ந" => "na",
    "ப" => "pa",
    "ம" => "ma",
    "ய" => "ya",
    "ர" => "ra",
    "ல" => "la",
    "வ" => "va",
    "ழ" => "zha",
    "ள" => "La",
    "ற" => "Ra",
    "ன" => "na",  # ^na

    "ஜ" => "ja",
    "ஶ" => "Sa",
    "ஷ" => "S.a",
    "ஸ" => "sa",
    "ஹ" => "ha",
    "க்ஷ" => "kS.a",
    "ஸ்ரீ" => "SrI",
    ":" => ":",
)

vowels = Dict(
    "்" => "",
    "ா" => "A",
    "ி" => "i",
    "ீ" => "I",
    "ு" => "u",
    "ூ" => "U",
    "ெ" => "e",
    "ே" => "E",
    "ை" => "ai",
    "ொ" => "o",
    "ோ" => "O",
    "ௌ" => "au",
)

vowels_sep = Dict(
    "அ" => "a",
    "ஆ" => "A",
    "இ" => "i",
    "ஈ" => "I",
    "உ" => "u",
    "ஊ" => "U",
    "எ" => "e",
    "ஏ" => "E",
    "ஐ" => "ai",
    "ஒ" => "o",
    "ஓ" => "O",
    "ஔ" => "au",
    "ஃ" => "::"
)


function transliterate(tamil)
    english = ""
    for char_i_ ∈ 1:length(tamil)
        char_i = nextind(tamil, 0, char_i_)
        char = string(tamil[char_i])
        if char ∈ keys(consonants)
            if char_i_ + 1 <= length(tamil) && string(tamil[nextind(tamil, char_i)]) ∈ keys(vowels)
                english *= chop(consonants[char])
            else
                english *= consonants[char]
            end
        elseif char ∈ keys(vowels)
            english *= vowels[char]
        elseif char ∈ keys(vowels_sep)
            english *= vowels_sep[char]
        else
            english *= char
        end
    end
    return english
end

function generate_random_word()
    len = rand(4:8)
    string_rand = ""
    prev_vowel = false
    for k ∈ 1:len
        if k == 1
            begins_with_vowel = rand([true, false])
            if begins_with_vowel
                string_rand *= collect(keys(vowels_sep))[rand(1:length(keys(vowels_sep)))]
                prev_vowel = true
            else
                string_rand *= collect(keys(consonants))[rand(1:length(keys(consonants)))]
                prev_vowel = false
            end
        else
            if prev_vowel == true
                string_rand *= collect(keys(consonants))[rand(1:length(keys(consonants)))]
                prev_vowel = false
            else
                vowel_now = rand([true, false, false, false, false])
                if vowel_now
                    # string_rand = chop(string_rand)
                    string_rand *= collect(keys(vowels))[rand(1:length(keys(vowels)))]
                    prev_vowel = true
                else
                    string_rand *= collect(keys(consonants))[rand(1:length(keys(consonants)))]
                    prev_vowel = false
                end
            end
        end
    end
    return string_rand
end

function random_word_from_src()
    file = open("src.txt", "r")
    lines = readlines(file)
    close(file)
    chosen_word = ""
    while chosen_word ∈ [" ", "", "-", " - ", ",", ", "]
        randline = rand(lines)
        words = split(randline, " ")
        chosen_word = rand(words)
    end
    return string(replace(chosen_word, "," => "", "." => "", "?" => "", " " => ""))
end


# define widget colors
const WidgetColor = String
const WIDGET_COLOR_DEFAULT = "default"
const WIDGET_COLOR_ACCENT = "accent"
const WIDGET_COLOR_SUCCESS = "success"
const WIDGET_COLOR_WARNING = "warning"
const WIDGET_COLOR_ERROR = "error"

# create CSS classes for all of the widget colors
for name ∈ [WIDGET_COLOR_DEFAULT, WIDGET_COLOR_ACCENT, WIDGET_COLOR_SUCCESS, WIDGET_COLOR_WARNING, WIDGET_COLOR_ERROR]
    # compile CSS and append it to the global CSS style provider state
    add_css!("""
    $name:not(.opaque) {
        background-color: @$(name)_fg_color;
    }
    .$name.opaque {
        background-color: @$(name)_bg_color;
        color: @$(name)_fg_color;
    }
    """)
end

# function to set the accent color of a widget
function set_accent_color!(widget::Widget, color, opaque = true)
    if !(color ∈ [WIDGET_COLOR_DEFAULT, WIDGET_COLOR_ACCENT, WIDGET_COLOR_SUCCESS, WIDGET_COLOR_WARNING, WIDGET_COLOR_ERROR])
        log_critical("In set_color!: Color ID `" * color * "` is not supported")
    end
    for color_type ∈ [WIDGET_COLOR_DEFAULT, WIDGET_COLOR_ACCENT, WIDGET_COLOR_SUCCESS, WIDGET_COLOR_WARNING, WIDGET_COLOR_ERROR]
        remove_css_class!(widget, color_type)
    end
    add_css_class!(widget, color)
    if opaque
        add_css_class!(widget, "opaque")
    else
        remove_css_class!(widget, "opaque")
    end
end

add_css!("""
.mono, .tamiltext, .accent, .success {
    font-size: 1.5em;
}
.mono {
    font-family: monospace;
}
""")

main() do app::Application
    window = Window(app)
    header_bar = get_header_bar(window)
    set_title_widget!(header_bar, Label("(ஃ) தமிழ் எழுத்து முறை"))
    set_layout!(header_bar, ":minimize,close")

    rand_word_to_show = random_word_from_src()
    correct_english_transliteration = string(transliterate(rand_word_to_show))

    tamil_label = Label(string(rand_word_to_show))
    add_css_class!(tamil_label, "tamiltext")

    english_label = Entry()
    add_css_class!(english_label, "mono")

    randomize_button = Button()
    set_child!(randomize_button, Label(string("Verify")))
    set_accent_color!(randomize_button, "accent", true)

    result = Label("")

    points = 0
    counter = 1
    num_words_for_round = 2

    point_label = Label("$counter/$num_words_for_round | $(string(round(points, sigdigits=2)))")  # TODO: Add score record system
    add_css_class!(point_label, "mono")
    tick()

    function submit_transliteration()
        println(counter)
        if counter < num_words_for_round
            if get_text(english_label) == correct_english_transliteration
                time_elapsed = tok()
                points += time_elapsed < 0.75 ? 10 : (length(correct_english_transliteration) / √time_elapsed) * (1-tanh(time_elapsed - 10))
                counter += 1
                set_text!(point_label, "$counter/$num_words_for_round | $(string(round(points, sigdigits=2)))")
                set_text!(result, "✓ Correct!")

                set_text!(result, "")
                set_text!(english_label, "")
                rand_word_to_show = random_word_from_src()
                correct_english_transliteration = string(transliterate(rand_word_to_show))
                set_text!(tamil_label, string(rand_word_to_show))
                tick()
            else
                set_text!(result, "× $correct_english_transliteration")
            end
        elseif counter == num_words_for_round
            tock()
            file = open("points.log", "r")
            lines = readlines(file)
            close(file)
            max_points = max(parse.(Float64, lines)...)
            println(max_points)
            println(points)
            println(points > max_points)
            open("points.log","a") do io
                print(io,"\n$points")
            end
            set_text!(result, "◯ Completed!")

            set_child!(randomize_button, Label(string("New Round")))
            set_accent_color!(randomize_button, "success", false)
            counter += 1

            set_text!(tamil_label, points > max_points ? "■ New Best Score!" : "—")
            points = 0
            set_text!(english_label, "")
        elseif counter == num_words_for_round + 1
            counter = 1
            set_text!(point_label, "$counter/$num_words_for_round | $(string(round(points, sigdigits=2)))")

            set_child!(randomize_button, Label(string("Verify")))
            set_accent_color!(randomize_button, "accent", true)

            set_text!(result, "")
            set_text!(english_label, "")

            rand_word_to_show = random_word_from_src()
            correct_english_transliteration = string(transliterate(rand_word_to_show))
            set_text!(tamil_label, string(rand_word_to_show))
            tick()
        end
    end

    connect_signal_clicked!(randomize_button) do self::Button
        submit_transliteration()
    end

    connect_signal_activate!(english_label) do self::Entry
        submit_transliteration()
    end

    connect_signal_text_changed!(english_label) do self::Entry
        if occursin(" ", get_text(english_label))
            set_text!(english_label, string(chop(get_text(english_label))))
            submit_transliteration()
        end
    end

    box = vbox(point_label, tamil_label, english_label, randomize_button, result)
    set_spacing!(box, 10)
    set_margin_horizontal!(box, 75)
    set_margin_vertical!(box, 40)

    set_child!(window, box)

    set_current_theme!(app, THEME_DEFAULT_DARK)
    present!(window)
end
