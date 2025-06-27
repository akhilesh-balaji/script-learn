module Utils
using DataStructures
CURRENT_SCRIPT = "tamil"
DIFFICULTY = 3 # 0 1 2 3
@enum MODE practice=1 learning=2
CURRENT_MODE = :practice

function current_script()
    return CURRENT_SCRIPT
end

function set_script(script)
    global CURRENT_SCRIPT = script
    include("langs/$(current_script())/data.jl")
end

function get_window_title()
    include("langs/$(current_script())/data.jl")
    return title
end

function get_difficulty()
    return DIFFICULTY
end

function set_difficulty(n)
    global DIFFICULTY = n
end

function get_mode()
    return CURRENT_MODE
end

function set_mode()
    global CURRENT_MODE = (CURRENT_MODE == :practice) ? :learning : :practice
end

include("langs/$(current_script())/data.jl")

function transliterate(original)
    english = ""
    for char_i_ ∈ 1:length(original)
        char_i = nextind(original, 0, char_i_)
        char = string(original[char_i])
        if char ∈ keys(consonants)
            if char_i_ + 1 <= length(original) && string(original[nextind(original, char_i)]) ∈ keys(vowels)
                english *= chop(consonants[char])
            else
                english *= consonants[char]
            end
        elseif char ∈ keys(vowels)
            english *= vowels[char]
        elseif char ∈ keys(vowels_sep)
            english *= vowels_sep[char]
        else
            english *= "-"
        end
    end
    return english
end

function generate_random_word(len)
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
    return lowercase(string_rand)
end

function random_word_from_src()
    file = open("langs/$(current_script())/src.txt", "r")
    lines = readlines(file)
    close(file)
    chosen_word = ""
    println(get_difficulty())
    while chosen_word ∈ [" ", "", "-", " - ", ",", ", "] || (get_difficulty() == 0 ? false : (get_difficulty() == 1 ? false : get_difficulty == 2 ? length(chosen_word) >= 5 : false))
        randline = rand(lines)
        words = split(randline, " ")
        chosen_word = rand(words)
    end
    chosen_word = string(replace(chosen_word, "," => "", "." => "", "?" => "", " " => "", "'" => "", "\"" => ""))
    if get_difficulty() == 0
        return string(generate_random_word(1))
        # return string(rand(chosen_word))
    end
    if get_difficulty() == 1
        return string(generate_random_word(2))
        # return string(rand(chosen_word))
    end
    return chosen_word
end

function get_learning_path_length()
    return length(learning_path)
end

function get_current_learning_stage()
    file = open("langs/$(current_script())/learning_progress.log", "r")
    lines = readlines(file)
    close(file)
    current_stage = parse(Float64, lines[length(lines)])
    return current_stage
end

function next_learning_word()
    file = open("langs/$(current_script())/learning_progress.log", "r")
    lines = readlines(file)
    close(file)
    current_stage = 1
    stage_name = "vow"
    vowels_sep_length = length(vowels_sep)
    vowels_length = length(vowels)
    consonants_length = length(consonants)
    chosen_word = ""
    if lines == []
        stage_name = learning_path[floor(Int, current_stage-0.1)]
        open("langs/$(current_script())/learning_progress.log","a") do io
            print(io,"\n1")
        end
    else
        current_stage = parse(Float64, lines[length(lines)])
        try
            stage_name = learning_path[floor(Int, current_stage-0.1)]
        catch
            current_stage = 1
            stage_name = learning_path[current_stage]
        end
    end
    if stage_name == "vow"
        if current_stage <= 1.5
            chosen_word = collect(keys(vowels_sep))[rand(1:floor(Int, length(keys(vowels_sep))/2))]
        elseif 1.5 < current_stage <= 2
            chosen_word = collect(keys(vowels_sep))[rand(1:length(keys(vowels_sep)))]
        end
    elseif stage_name == "cons"
        if 2 <= current_stage < 2.25
            println("yes!!")
            chosen_word = collect(keys(consonants))[rand(1:floor(Int, length(keys(consonants))/4))]
        elseif 2.25 <= current_stage < 2.5
            chosen_word = collect(keys(consonants))[rand(1:floor(Int, length(keys(consonants))/2))]
        elseif 2.5 <= current_stage < 2.75
            chosen_word = collect(keys(consonants))[rand(1:floor(Int, 3*length(keys(consonants))/4))]
        else
            chosen_word = collect(keys(consonants))[rand(1:length(keys(consonants)))]
        end
    elseif stage_name == "vow+cons"
        chosen_word = collect(keys(consonants))[rand(1:length(keys(consonants)))]
        chosen_word *= collect(keys(vowels))[rand(1:length(keys(vowels)))]
    elseif stage_name == "cons+cons"
        chosen_word = collect(keys(consonants))[rand(1:length(keys(consonants)))]
        chosen_word *= [s for (s,v) in vowels if v == ""][1]
        chosen_word *= collect(keys(consonants))[rand(1:length(keys(consonants)))]
    end
    return chosen_word
    end
end