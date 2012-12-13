#!/usr/bin/env ruby
#encoding: utf-8


# usage: mdpdf file
# kommt raus: file.pdf

full = ARGV[0]
baseless = File.basename(full, ".*")
base = File.basename(full)
#olddir = File.dirname(full) # without trailing /
#ext = File.extname(full)    # .md
dir = "/u/gawrisch/tmp"

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

# TODO: nicht in header-fields ersetzen
# TODO: schöner machen.
all_text = lines.join
#re = /´.*?´/
#re = / .*? /
re = /  .*?  /m
code_seqs = all_text.scan re
code_seqs = code_seqs.map do |seq|
  #new_seq = "\\\\\\(" + seq.gsub("´", "") + "\\\\\\)"
  new_seq = " \\\\\\(" + seq.gsub("  ", "") + "\\\\\\) "
  new_seq = new_seq. # TODO: Substitutions in extra file
             gsub("ZZ", "\\mathbb{Z}").
             gsub("RR", "\\mathbb{R}").
             gsub("NN", "\\mathbb{N}").
             gsub("QQ", "\\mathbb{Q}").
             gsub("CC", "\\mathbb{C}").
             gsub("FF", "\\mathbb{F}").
             gsub("PP", "\\mathcal{P}").
             gsub("ggT", "\\text{ggT}").
             gsub("ker", "\\text{ker}").
             gsub("sgn", "\\text{sgn}").
             gsub("sup ", "\\text{sup }").
             gsub("inf ", "\\text{inf }").
             gsub("min ", "\\min ").
             gsub("max ", "\\max ").
             gsub("Re ", "\\text{Re } ").
             gsub("Im ", "\\text{Im } ").
             gsub("ord", "\\text{ord}").
             gsub("sqrt", "\\sqrt").
             gsub("cap", "\\cap").
             gsub("cup", "\\cup").
             gsub("sigma", "\\sigma").
             gsub("phi", "\\phi").
             gsub("alpha", "\\alpha").
             gsub("beta", "\\beta").
             gsub("lam", "\\lambda").
             gsub("mü", "\\mu").
             gsub("eps", "\\epsilon").
             gsub("φ", "\\phi").
             gsub("π", "\\pi").
             gsub("pi", "\\pi").
             gsub("theta", "\\theta").
             gsub("≤", "\\leq").
             gsub("≥", "\\geq").
             gsub(" not ", " \\not ").
             gsub("varnothing", "\\varnothing").
             gsub("+-", "\\pm").
             gsub("equiv", "\\equiv").
             gsub("neq", "\\neq").
             gsub(" mod ", " \\mod ").
             gsub(" in ", " \\in ").
             gsub(" mapsto ", " \\mapsto ").
             gsub(" to ", " \\to ").
             gsub(" times ", " \\times ").
             gsub(" setminus ", " \\setminus ").
             gsub("infty", "\\infty").
             gsub("forall", "\\forall").
             gsub("exists", "\\exists").
             gsub("overline", "\\overline").
             gsub("right", "\\right").
             gsub("left", "\\left").
             gsub("widetilde", "\\widetilxxxde").
             gsub("tilde", "\\tilde").
             gsub("widetilxxxde", "\\widetilde").
             gsub("unlhd", "\\unlhd").
             gsub(" quad ", " \\quad ").
             gsub("cdot", "\\cdot").
             gsub("circ", "\\circ").
             gsub("oplus", "\\oplus").
             gsub("odot", "\\odot").
             gsub("mapsto", "\\mapsto").
             gsub("frac", "\\frac").
             gsub("sum", "\\sum").
             gsub("sin", "\\sin").
             gsub("cos", "\\cos").
             gsub("deg", "\\deg").
             gsub("char(", "\\text{char}(").
             gsub("Abb(", "\\text{Abb}(").
             gsub("triangle", "\\triangle").
             gsub("overset", "\\overset").
             gsub("checkmark", "\\checkmark").
             gsub(" sim", " \\sim").
             gsub(" sse ", " \\subseteq ").
             gsub("<=>", " \\Leftrightarrow").
             gsub("=>", " \\Rightarrow").
             gsub("qed", " \\hfill\\square").
             gsub("limn ", "{\\displaystyle \\lim_{n \\to \\infty}} ").
             gsub("limx ", "{\\displaystyle \\lim_{x \\to \\infty}} ")
  all_text = all_text.gsub(seq, new_seq)
end

# ugly workaround.
all_text = lines.join unless style == "math" or style == "zettel"

all_text = all_text.gsub(" [^", "[^")

file = File.new(base, "w")
file.write(all_text)
file.close
 
`multimarkdown --to=latex --output="#{baseless}.tex" "#{baseless}.md"`

lines = File.readlines(baseless + ".tex")

(0...lines.length).each do |i|
  # replace in lines that start with \def: \textbackslash{}, \{, \}
  if lines[i] =~ /\\def.*/
    lines[i] = lines[i].gsub(/\\textbackslash\{\}/, "\\").
                        gsub(/\\\{/, "{").
                        gsub(/\\\}/, "}")
  end

  # pagebreaks
  if lines[i] == "pagebreak\n" or lines[i] == "header\n"
    lines[i] = "\\" + lines[i]
  end

  # replace strange chars
  lines[i] = lines[i].gsub(" ", " ") # <A-Space>
  lines[i] = lines[i].gsub(" ", " ") # aus MacWord-PDF kopiert
  lines[i] = lines[i].gsub("ü", "ü")
  lines[i] = lines[i].gsub("ö", "ö")
  lines[i] = lines[i].gsub("ä", "ä")

  # workaround ?``: just replace all closing quotes.
  lines[i] = lines[i].gsub("``", "“")
  # nach den doppelten auch die einfachen
  lines[i] = lines[i].gsub("`", "{‘}")
end

file = File.new(baseless + ".tex", "w")
file.write(lines.join)
file.close
 

#`/usr/texbin/pdflatex "#{baseless}"`
`pdflatex "#{baseless}"`
#`open "#{baseless}.pdf"`
`cp "#{baseless}.pdf" ~/public_html`


# TODO
# deutsches Datum
# structure: tex, build, pdf, bin
# Feld "HelperFiles: ", wo man dateinamen angibt, die im selben pfad liegen, die irgendwie strukturierte bibliographie-daten enthalten, die in eine .bib(?)-Datei geschrieben werden
# Überschriften in gleicher Schriftart.
