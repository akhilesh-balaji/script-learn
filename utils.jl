module Utils
include("langs/tamil/data.jl")
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
    file = open("langs/tamil/src.txt", "r")
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
end