using Mousetrap
using TickTock

include("utils.jl")
using .Utils: transliterate, generate_random_word, random_word_from_src, current_script, set_script

set_script("tamil")
include("langs/$(current_script())/data.jl")

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
    num_words_for_round = 10

    point_label = Label("$counter/$num_words_for_round | $(string(round(points, sigdigits=2)))")
    add_css_class!(point_label, "mono")
    tick()

    function submit_transliteration()
        if counter < num_words_for_round
            if get_text(english_label) == correct_english_transliteration
                time_elapsed = tok()
                points += time_elapsed < 0.75 ? 50 : (length(correct_english_transliteration) / √time_elapsed) * (1-tanh(time_elapsed - 10))
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
                points -= 3
                set_text!(point_label, "$counter/$num_words_for_round | $(string(round(points, sigdigits=2)))")
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
