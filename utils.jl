module Utils
CURRENT_SCRIPT = "tamil"
DIFFICULTY = 3 # 0 1 2 3

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
            english *= char
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
    while chosen_word ∈ [" ", "", "-", " - ", ",", ", "] || (get_difficulty() == 0 ? false : (get_difficulty() == 1 ? length(chosen_word) >= 5 : get_difficulty == 2 ? length(chosen_word) >= 10 : false))
        randline = rand(lines)
        words = split(randline, " ")
        chosen_word = rand(words)
    end
    chosen_word = string(replace(chosen_word, "," => "", "." => "", "?" => "", " " => "", "'" => "", "\"" => ""))
    if get_difficulty() == 0
        return string(generate_random_word(2))
        # return string(rand(chosen_word))
    end
    return chosen_word
end
end