#!/usr/bin/env ruby
#encoding: utf-8


# usage: mdpdf file
# kommt raus: file.pdf

full = ARGV[0]
baseless = File.basename(full, ".*")
base = File.basename(full)
#olddir = File.dirname(full) # without trailing /
#ext = File.extname(full)    # .md
dir = "/Users/marius/tmp" if File.exists? "/Users/marius/tmp"
dir = "/u/gawrisch/tmp" if File.exists? "/u/gawrisch/tmp"

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
  boring = seq.index("\\\\").nil?
  puts seq.index("\\\\").to_s + seq unless boring
  new_seq = " \\\\\\(" + seq.gsub("  ", "").gsub("\\\\", "\\\\\\\\\\\\\\\\") + "\\\\\\) " # hui.
  puts new_seq unless boring
  new_seq = new_seq. # TODO: Substitutions in extra file
             gsub("ZZ", "\\mathbb{Z}").
             gsub("RR", "\\mathbb{R}").
             gsub("NN", "\\mathbb{N}").
             gsub("QQ", "\\mathbb{Q}").
             gsub("CC", "\\mathbb{C}").
             gsub("FF", "\\mathbb{F}").
             gsub("KK", "\\mathbb{K}").
             gsub("PP", "\\mathcal{P}").
             gsub("ggT", "\\text{ggT}").
             gsub("ker", "\\text{ker}").
             gsub("sgn", "\\text{sgn}").
             gsub("Hom", "\\text{Hom}").
             gsub("sup ", "\\text{sup }").
             gsub("inf ", "\\text{inf }").
             gsub("min ", "\\min ").
             gsub("max ", "\\max ").
             gsub("Re ", "\\text{Re } ").
             gsub("Im ", "\\text{Im } ").
             gsub("ord", "\\text{ord}").
             gsub("sqrt", "\\sqrt").
             gsub("smatrix{", "\\smallsmatrix{"). # use as "matrix{...}"
             gsub("pmatrix{", "\\smallpmatrix{"). # use as "matrix{...}"
             gsub("cap", "\\cap").
             gsub("cup", "\\cup").
             gsub("big\\cup", "\\bigcup").
             gsub("big\\cap", "\\bigcap").
             gsub("sigma", "\\sigma").
             gsub("phi", "\\phi").
             gsub("alpha", "\\alpha").
             gsub("beta", "\\beta").
             gsub("delta", "\\delta").
             gsub("lam", "\\lambda").
             gsub("mü", "\\mu").
             gsub("eps", "\\varepsilon").
             gsub("φ", "\\phi").
             gsub("π", "\\pi").
             gsub("pi", "\\pi").
             gsub("theta", "\\theta").
             gsub("ε", "\\varepsilon").
             gsub("∂", "\\delta").
             gsub("µ", "\\mu").
             gsub("λ", "\\lambda").
             gsub("∞", "\\infty").
             gsub("ξ", "\\xi").
             gsub("<=>", " \\Leftrightarrow").
             gsub("=>", " \\Rightarrow").
             gsub("≤", "\\leq").
             gsub("<=", "\\leq").
             gsub("≥", "\\geq").
             gsub(">=", "\\geq").
             gsub(" not ", " \\not ").
             gsub("varnothing", "\\varnothing").
             gsub("+-", "\\pm").
             gsub("±", "\\pm").
             gsub("equiv", "\\equiv").
             gsub("neq", "\\neq").
             gsub(" mod ", " \\mod ").
             gsub(" in ", " \\in ").
             gsub(" mapsto ", " \\mapsto ").
             gsub(" to ", " \\to ").
             gsub(" up ", " \\uparrow ").
             gsub(" down ", " \\downarrow ").
             gsub(" times ", " \\times ").
             gsub(" setminus ", " \\setminus ").
             gsub("infty", "\\infty").
             gsub("forall", "\\forall").
             gsub("exists", "\\exists").
             gsub("overline", "\\overline").
             gsub("span", "\\text{span}").
             gsub("langle", "\\langle").
             gsub("rangle", "\\rangle").
             gsub("right|", "\\right|").
             gsub("left|", "\\left|").
             gsub("right)", "\\right)").
             gsub("left(", "\\left(").
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
             gsub("dim", "\\dim").
             gsub("exp", "\\exp").
             gsub("ln", "\\ln").
             gsub("char(", "\\text{char}(").
             gsub("Abb(", "\\text{Abb}(").
             gsub("triangle", "\\triangle").
             gsub("overset", "\\overset").
             gsub("checkmark", "\\checkmark").
             gsub(" sim", " \\sim").
             gsub("cong", "\\cong").
             gsub(" sse ", " \\subseteq ").
             gsub("supset", "\\supset").
             gsub("subset", "\\subset").
             gsub(" ssne ", " \\subsetneq ").
             gsub("qed", " \\hfill\\square").
             gsub("displaystyle", "\\displaystyle").
             gsub("lim_{", "\\displaystyle \\lim_{").
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

all_text = lines.join
# "Bla.. " ersetzen
#all_text = all_text.gsub /(?<!\.)\.\.\s/, ".\\quad " # muss Lösung ohne lookbehind finden. vll ... -> äöü, .. -> quad, äöü -> ...
# "$Bla..$ " ersetzen
#all_text = all_text.gsub /(?<!\.)\.\.\$\s/, ".$\\quad "
all_text = all_text.gsub("...", "#BLATEXT#").
                    gsub(".. ", ".\\quad ").
                    gsub("..$ ", "$.\\quad ").
                    gsub("#BLATEXT#", "...")
if style == "notiz"
  all_text = all_text.sub("begin}\n", "begin}\n\\noindent ")
end

file = File.new(baseless + ".tex", "w")
file.write(all_text)
file.close
 

`pdflatex "#{baseless}"`
#`open "#{baseless}.pdf"` if `which open` != "" # which ist noisy auf linux
`cp "#{baseless}.pdf" /u/gawrisch/public_html` if File.exists? "/u/gawrisch/public_html"


# TODO
# deutsches Datum
# structure: tex, build, pdf, bin
# Feld "HelperFiles: ", wo man dateinamen angibt, die im selben pfad liegen, die irgendwie strukturierte bibliographie-daten enthalten, die in eine .bib(?)-Datei geschrieben werden
# Überschriften in gleicher Schriftart.
