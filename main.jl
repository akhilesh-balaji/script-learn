using Mousetrap
using TickTock
using Printf
using DataStructures

include("utils.jl")
using .Utils: transliterate, generate_random_word, random_word_from_src, next_learning_word, current_script, set_script, get_window_title, get_difficulty, set_difficulty, get_mode, set_mode, get_learning_path_length, get_current_learning_stage, MODE

set_script("tamil")
include("langs/$(current_script())/data.jl")

# set_mode()

set_difficulty(0)
num_words_for_round = 10

include("styles.jl")

main() do app::Application
    window = Window(app)
    header_bar = get_header_bar(window)
    set_title_widget!(header_bar, Label(get_window_title()))
    add_css_class!(header_bar, "headerbar_vary")
    set_layout!(header_bar, ":minimize,close")

    rand_word_to_show = get_mode() == :practice ? random_word_from_src() : next_learning_word()
    correct_english_transliteration = string(transliterate(rand_word_to_show))

    script_label = Label(string(rand_word_to_show))
    add_css_class!(script_label, "scripttext")

    english_label = Entry()
    add_css_class!(english_label, "mono")

    randomize_button = Button()
    set_child!(randomize_button, Label(string("Verify")))
    set_accent_color!(randomize_button, "accent", true)

    result = Label("")
    add_css_class!(result, "result_scrpt")

    learning_or_practice = Label("$(string(get_mode()))$(get_mode() == :learning ? " L($(get_current_learning_stage()))" : "")")
    add_css_class!(learning_or_practice, "modetxt")

    # Learning mode
    prev_level = Button()
    set_is_circular!(prev_level, true)
    set_child!(prev_level, Label("◀"))
    add_css_class!(prev_level, "mono")
    next_level = Button()
    set_is_circular!(next_level, true)
    set_child!(next_level, Label("▶"))
    add_css_class!(next_level, "mono")
    toggler = Switch()
    set_is_active!(toggler, false)
    add_css_class!(toggler, "togglebutton")
    learning_box = hbox(prev_level, toggler, next_level)
    set_spacing!(learning_box, 10)
    set_horizontal_alignment!(learning_box, ALIGNMENT_CENTER)
    if get_mode() == :practice
        add_css_class!(next_level, "invisible")
        add_css_class!(prev_level, "invisible")
    end

    # Practice mode
    difficulty_scale = Scale(0.0, 0.3, 0.1, ORIENTATION_HORIZONTAL)
    set_value!(difficulty_scale, 0)
    set_should_draw_value!(difficulty_scale, true)
    set_size_request!(difficulty_scale, Vector2f(200, 0))
    if get_mode() == :learning
        add_css_class!(difficulty_scale, "invisible")
    end

    points = 0
    counter = 1
    global num_words_for_round

    point_label = Label("$counter/$num_words_for_round | $(string(round(points, sigdigits=2)))")
    add_css_class!(point_label, "mono")

    tick()
    act_tick = false

    function submit_transliteration()
        if counter == 1
            act_tick = false
        end
        if counter < num_words_for_round
            if get_text(english_label) == correct_english_transliteration
                time_elapsed = tok()
                points += time_elapsed < 0.75 ? 50 : (length(correct_english_transliteration) / √time_elapsed) * (1-tanh(time_elapsed - 10))
                counter += 1
                set_text!(point_label, "$counter/$num_words_for_round | $(string(round(points, sigdigits=2)))")
                set_text!(result, "✓ Correct!")

                set_text!(result, "")
                set_text!(english_label, "")
                # rand_word_to_show = random_word_from_src()
                rand_word_to_show = get_mode() == :practice ? random_word_from_src() : next_learning_word()
                correct_english_transliteration = string(transliterate(rand_word_to_show))
                set_text!(script_label, string(rand_word_to_show))
                tick()
            else
                points -= 3
                set_text!(point_label, "$counter/$num_words_for_round | $(string(round(points, sigdigits=2)))")
                set_text!(result, "× $correct_english_transliteration")
            end
        elseif counter == num_words_for_round
            tock()
            file = open("langs/$(current_script())/points.log", "r")
            lines = readlines(file)
            close(file)
            max_points = try max(parse.(Float64, lines)...) catch; 0 end
            println(max_points)
            println(points)
            println(points > max_points)
            if get_mode() == :practice
                open("langs/$(current_script())/points.log","a") do io
                    print(io,"\n$points")
                end
            end
            set_text!(result, "◯ Completed!")

            set_child!(randomize_button, Label(string("New Round")))
            set_accent_color!(randomize_button, "success", false)
            counter += 1

            set_text!(script_label, get_mode() == :practice ? (points > max_points ? "■ New Best Score!" : "—") : "Learning; no scores saved")
            points = 0
            set_text!(english_label, "")
        elseif counter == num_words_for_round + 1
            counter = 1
            global act_tick = false
            points = 0
            set_text!(point_label, "$counter/$num_words_for_round | $(string(round(points, sigdigits=2)))")

            set_child!(randomize_button, Label(string("Verify")))
            set_accent_color!(randomize_button, "accent", true)

            set_text!(result, "")
            set_text!(english_label, "")

            # rand_word_to_show = random_word_from_src()
            rand_word_to_show = get_mode() == :practice ? random_word_from_src() : next_learning_word()
            correct_english_transliteration = string(transliterate(rand_word_to_show))
            set_text!(script_label, string(rand_word_to_show))
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
        if counter == 1 && length(get_text(english_label)) == 1
            act_tick = true
            tick()
        end
    end

    scripts = readdir("langs")
    actions = [Action("change.script.$i", app) do x
        set_script(scripts[i])
        set_child!(view, Label(uppercasefirst("$(current_script())")))
        act_tick = false
        set_title_widget!(header_bar, Label(get_window_title()))
        if counter != num_words_for_round + 1
            counter = num_words_for_round + 1
            submit_transliteration()
        end
    end for i in 1:length(scripts)]

    end_action = Action("end.round", app) do x
        counter = num_words_for_round
        submit_transliteration()
    end

    connect_signal_value_changed!(difficulty_scale) do self::Scale
        set_difficulty(floor(Int, get_value(self) * 10))
        activate!(actions[findall(sc -> sc == current_script(), scripts)[1]])
    end

    connect_signal_switched!(toggler) do self::Switch
        set_mode()
        if get_mode() == :practice
            add_css_class!(next_level, "invisible")
            add_css_class!(prev_level, "invisible")
            remove_css_class!(difficulty_scale, "invisible")
        end
        if get_mode() == :learning
            add_css_class!(difficulty_scale, "invisible")
            remove_css_class!(next_level, "invisible")
            remove_css_class!(prev_level, "invisible")
        end
        set_text!(learning_or_practice, string(get_mode()))
        if get_mode() == :learning
            set_text!(learning_or_practice, "$(string(get_mode())) (L$(get_current_learning_stage()))")
        end
        activate!(actions[findall(sc -> sc == current_script(), scripts)[1]])
    end

    connect_signal_clicked!(prev_level) do self::Button
        current_stage = get_current_learning_stage()
        open("langs/$(current_script())/learning_progress.log","a") do io
            if current_stage == 1
                print(io, "\n1")
            else
                if 1 < current_stage <= 2
                    print(io, "\n$(current_stage-0.5)")
                elseif 2 < current_stage <= 3
                    print(io, "\n$(current_stage-0.25)")
                elseif 3 < current_stage <= 5
                    print(io, "\n$(current_stage-1)")
                end
            end
        end
        set_text!(learning_or_practice, "$(string(get_mode())) (L$(get_current_learning_stage()))")
    end

    connect_signal_clicked!(next_level) do self::Button
        current_stage = get_current_learning_stage()
        open("langs/$(current_script())/learning_progress.log","a") do io
            if current_stage == get_learning_path_length() + 0.5
                print(io, "")
            else
                if 1 <= current_stage < 2
                    print(io, "\n$(current_stage+0.5)")
                elseif 2 <= current_stage < 3
                    print(io, "\n$(current_stage+0.25)")
                elseif 3 <= current_stage <= get_learning_path_length()
                    print(io, "\n$(current_stage+1)")
                end
            end
        end
        set_text!(learning_or_practice, "$(string(get_mode())) (L$(get_current_learning_stage()))")
    end

    root = MenuModel()
    for script ∈ scripts
        add_action!(root, uppercasefirst(script), actions[findfirst(item -> item == script, scripts)])
    end
    add_action!(root, "END ROUND", end_action)
    view = PopoverButton(PopoverMenu(root))
    set_child!(view, Label(uppercasefirst("$(current_script())")))
    timer = Label("$(round(peektimer(), sigdigits=4))")
    add_css_class!(timer, "mono")
    top_box = hbox(view, timer)
    set_tick_callback!(window) do clock::FrameClock
        if counter <= num_words_for_round
            set_text!(timer, "$(@sprintf("%0.3f", act_tick == false ? 0 : peektimer()))")
        end
        return TICK_CALLBACK_RESULT_CONTINUE
    end

    set_spacing!(top_box, 10)
    set_horizontal_alignment!(top_box, ALIGNMENT_CENTER)

    box = vbox(top_box, point_label, script_label, english_label, randomize_button, result, learning_or_practice, learning_box, difficulty_scale)
    set_spacing!(box, 10)
    set_margin_horizontal!(box, 75)
    set_margin_vertical!(box, 40)

    set_child!(window, box)

    set_current_theme!(app, THEME_DEFAULT_DARK)
    present!(window)
end
