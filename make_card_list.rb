#!/usr/bin/env ruby
#encoding: UTF-8

# Simple script to take a saved list of words from
# http://www.studyspanish.com/vocab/ and turn it into
# a file suitable for importing as flashcards using
# http://www.cram.com/flashcards/create
#
# Original list is alternating lines of
#
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
# Where there are two terms listed (separation by a ',')
# we produce combinations for each referencing the original.
#
# Note: language that comes first is set by `list` option which defaults
# to spanish but depending on word source can be anything

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
  noise = %w(a al de del el la las los the)
  term.split.delete_if { |w| noise.include?(w) }.first
end

options = {
  div:  ',',
  list: %w(spanish english),
  sort: false
}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: make_card_list.rb [options]"

  opts.separator ""
  opts.separator "Specific options:"

  opts.on("-d", "--div STRING", "Divider for separating terms")            { |d| options[:div] = d }
  opts.on("-f", "--file FILE", "Input file to be converted", "=MANDATORY") { |f| options[:file] = f }
  opts.on("-l", "--list a,b", Array, "Language terms order in file")       { |l| options[:list] = l }
  opts.on("-s", "--[no-]sort", "Sort output files by terms")               { |s| options[:sort] = s }

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
  f.each_line.each_slice(2) do |terms, definitions|
    terms.split(options[:div]).each do |term|
      a_cards << "#{term.strip}\t#{definitions.strip}\n"
    end
    definitions.split(options[:div]).each do |definition|
      z_cards << "#{definition.strip}\t#{terms.strip}\n"
    end
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
