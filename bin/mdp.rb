#!/usr/bin/env ruby
#encoding: utf-8


# usage: mdpdf file
# kommt raus: file.pdf

full = ARGV[0]
baseless = File.basename(full, ".*")
base = File.basename(full)
#olddir = File.dirname(full) # without trailing /
#ext = File.extname(full)    # .md
dir = "/Users/marius/drop/mdp/bin"

`cp "#{full}" #{dir}`
Dir.chdir dir
# puts Dir.getwd
lines = File.readlines(base)
style = "" # necessary?
lines.each do |line|
  if style == "" && line.index("Vorlage: ") == 0 # change to use regexp
    style = line.chop.sub(/Vorlage: /, "").strip
  end
end
style = "nostyle" if style == ""
# puts "Found style: #{style}"

# determine if there are header fields.
unless lines[0] =~ /^[a-zA-Z]+:\s*\S+.*/
  lines = lines.insert(0, "\n")
end

lines = lines.insert(0, "LatexInput: tex/#{style}-packages\n")
# puts lines.index("\n")
lines = lines.insert(lines.index("\n"),
  "QuotesLanguage: german\n",
  "BaseHeaderLevel: 3\n",
  "LatexInput: tex/#{style}-begin\n",
  "LatexFooter: tex/#{style}-footer\n")

file = File.new(base, "w")
file.write(lines.join)
file.close
 
`mmd2tex "#{base}"`

lines = File.readlines(baseless + ".tex")

(0...lines.length).each do |i|
  # replace in lines that start with \def: \textbackslash{}, \{, \}
  if lines[i] =~ /\\def.*/
    lines[i] = lines[i].gsub(/\\textbackslash\{\}/, "\\").
                        gsub(/\\\{/, "{").
                        gsub(/\\\}/, "}")
  end

  # replace strange chars
  lines[i] = lines[i].gsub(" ", " ") # <A-Space>
  lines[i] = lines[i].gsub(" ", " ") # aus MacWord-PDF kopiert
  lines[i] = lines[i].gsub("ü", "ü")
  lines[i] = lines[i].gsub("ö", "ö")
  lines[i] = lines[i].gsub("ä", "ä")

  # workaround ?``: just replace all closing quotes.
  lines[i] = lines[i].gsub("``", "“")
end

file = File.new(baseless + ".tex", "w")
file.write(lines.join)
file.close
 

`/usr/texbin/pdflatex "#{baseless}"`
`open "#{baseless}.pdf"`


# TODO
# deutsches Datum
# structure: tex, build, pdf, bin
# Feld "HelperFiles: ", wo man dateinamen angibt, die im selben pfad liegen, die irgendwie strukturierte bibliographie-daten enthalten, die in eine .bib(?)-Datei geschrieben werden
# Überschriften in gleicher Schriftart.
