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
#
#   english term<tab>spanish term
#
# and in another file as
#
#   spanish term<tab>english term
#

require 'optparse'

def write_cards_to_file(file, cards=[], sort=true)
  File.open(file,'w') do |f|
    f.puts sort ? cards.sort { |x,y| noise_free(x) <=> noise_free(y) } : cards
  end
end

def file_name(part_a, part_b, part_c)
  part_a + '_to_' + part_b + '_' + part_c + '.fc'
end

def noise_free(term)
  noise = %w(la el las los de del a)
  term.split.delete_if { |w| noise.include?(w) }.first
end

options = {
  list: %w(spanish english),
  sort: true
}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: make_card_list.rb [options]"

  opts.separator ""
  opts.separator "Specific options:"

  opts.on("-f", "--file FILE", "Input file to be converted", "=MANDATORY")  { |f| options[:file] = f }
  opts.on("-s", "--[no-]sort", "Sort output files by terms")                { |s| options[:sort] = s }
  opts.on("-l", "--list a,b", Array, "Language terms order in file")        { |l| options[:list] = l }

  opts.separator ""
  opts.separator "Common options:"

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end

begin
  optparse.parse!
  mandatory = [:file]
  missing = mandatory.select { |o| options[o].nil? }
  unless missing.empty?
    puts "Missing options: #{missing.join(', ')}"
    puts optparse
    exit 1
  end
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts $!.to_s
  puts optparse
  exit 1
end

a_cards = []
z_cards = []

File.open(options[:file], 'r') do |f|
  f.each_line.each_slice(2) do |term, definition|
    a_cards << "#{term.chomp}\t#{definition.chomp}\n"
    z_cards << "#{definition.chomp}\t#{term.chomp}\n"
  end
end

write_cards_to_file file_name(options[:list].first,
                              options[:list].last,
                              File.basename(options[:file], '.*')
                             ), a_cards, options[:sort]

write_cards_to_file file_name(options[:list].last,
                              options[:list].first,
                              File.basename(options[:file], '.*')
                             ), z_cards, options[:sort]
