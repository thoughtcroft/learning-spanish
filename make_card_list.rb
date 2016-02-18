#!/usr/bin/env ruby
#encoding: UTF-8

# Simple script to take a saved list of words from
# http://www.studyspanish.com/vocab/ and turn it into
# a file suitable for importing as flashcards using
# http://www.cram.com/flashcards/create
#
# Original list is alternating lines of
#   spanish word
#   english equivalent
#
# and we want to produce each pair on a single line as
#   english term<tab>spanish term

old_file = ARGV.first
new_file = File.basename(old_file, '.*') + '.new'
cards = []

File.open(old_file, 'r') do |f|
  f.each_line.each_slice(2) do |definition, term|
    cards << "#{term.chomp}\t#{definition.chomp}\n"
  end
end

File.open(new_file,'w') do |f|
  f.puts(cards.sort)
end
