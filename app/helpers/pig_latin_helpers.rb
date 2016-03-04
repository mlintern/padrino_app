PadrinoApp::App.helpers do

  VOWELS = "AEIOUaeiou"     # Standard English vowels
  VOWELSY = "AEIOUaeiouYy"  # Sometimes "Y" and "W", but only "Y" here
  WAY = "way"               # Vowel word suffix
  AY = "ay"                 # Consonant word suffix
  LEARNMODE = true          # Learn Mode Default


  def word_to_pig_latin (word, learn_mode = false)

    word = word  # Move to local storage
    first_letter = word.first # First character of word
    cap = first_letter == first_letter.upcase ? true : false  # Capitalization flag
    suffix = ""

    if !VOWELS.index(first_letter).nil? # Word starts with a vowel?
      suffix = WAY  # Suffix is "way"
      last_letter = word.last  # Get last char of word

      if (last_letter == last_letter.upcase && word.length > 1)  # If last char of word is upcase (except "I")
        suffix = WAY.upcase  # Make suffix upcase to match
      end

      # At this point, the word is translated correctly

    else  # Word starts with consonant(s) -- more complex processing required

      # Move all consonants at front of word to the end and add "ay"

      if (word != word.upcase)  # If not all caps
        first_letter = first_letter.downcase  # Format for display
      end

      is = word.length;  # Only process n characters

      while ( is-=1 ) do # For typos and any possible all-consonant "words"

        suffix += first_letter  # Build suffix with leading consonants
        last_letter = first_letter  # Save last character (for "qu" testing)

        cap_flag = (first_letter == first_letter.upcase) ? true : false  # Capitalize flag

        word = word[1, word.length]  # Remove first/next char of word
        first_letter = word.first  # Get next/first char of new word

        if !VOWELS.index(first_letter).nil? # Vowel signals end
          if (!((last_letter == "q" || last_letter == "Q") && (first_letter == "u" || first_letter == "U")))  # Check for "qu"
            break  # Quit loop if we hit a vowel or "y" (unless "qu")
          end
        end

      end  # while

      if (cap_flag)  # If the first char of the new word is capitalized
        suffix += AY.upcase  # Append "AY"
      else
        suffix += AY  # Append "ay"
      end
    end

    word += (learn_mode ? "-" : "") + suffix  # Put final translated word together

    if (cap)  # If original word was capitalized…
      first_letter = word.first  # …ensure translated word is too
      word = first_letter.upcase + word[1, word.length]
    end

    return word

  end

  def pig_translate (text,learn_mode = LEARNMODE)

    sNewline = "\n"  # Other systems use this for New Line (Mac, etc.)
    pig_latin = ""  # End result stored here
    word = ""      # Clear word text
    real = true    # We start off working on a real word

    for i in 0..text.length

      # The null at the end of the text signals final end of text/word

      char = text[i]  # Get the next character

      if !char.nil? && ((char >= "A" && char <= "Z") || (char >= "a" && char <= "z") || (char == "'" && real && word != ""))  # If alphabetic character

        if (!real)  # If last not a word, then must be non-word/separator
          pig_latin += word  # Append punctuation & whitespace to line
          word = ""  # Clear word text
          real = true  # We're working on a real word
        end

        word += char  # Append alpha character to word

      else  # A non-alpha character
        if (real && word != "") # If word mode and a word was found
          word = word_to_pig_latin(word, learn_mode)  # Translate word to Pig Latin

          pig_latin += word  # Append translated word to line
          word = ""  # Clear word text
        end

        if !char.nil?
          word += char;  # Build punctuation, symbol & whitespace "word"
          real = false;  # Switch to non-word/separator mode
        end
      end

    end  # for

    return pig_latin += word;  # Append final line and word to result

  end

end
