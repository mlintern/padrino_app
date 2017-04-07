#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

PadrinoApp::App.helpers do
  ####
  # Name: translate_piglatin
  # Description: takes a body text and lanugage and returns new body text in pig latin
  # Arguments: title - string
  #            language - string
  # Response: string
  ####
  def translate_piglatin(body)
    word_array = body.gsub(%r{<\/?[^>]+>}, '').gsub(/[!@#`$%^&*()-=_+|;:",.<>?]/, '').gsub('\'s', '').split(' ').uniq
    new_html = body
    safe_words = %w[alt src style as a s]
    good_array = word_array - safe_words
    good_array.each do |word|
      new_word = Nretnil::Translate.pig_latin(word)
      new_html = new_html.gsub(' ' + word + ' ', ' ' + new_word + ' ')
      new_html = new_html.gsub(word + ' ', new_word + ' ')
      new_html = new_html.gsub(' ' + word, ' ' + new_word)
    end

    new_html
  end

  ####
  # Name: translate_piglatin_title
  # Description: takes a title and lanugage and returns new title in pig latin
  # Arguments: title - string
  #            language - string
  # Response: string
  ####
  def translate_piglatin_title(title, language = pig_latin)
    title_words = title.split(' ')
    new_title = title
    title_words.each do |w|
      new_title = new_title.gsub(w, Nretnil::Translate.pig_latin(w))
    end

    '[' + language + '] ' + new_title
  end
end
