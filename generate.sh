#!/bin/bash

# Exit on error
set -e

SKIP_BIBTEX=(00-Frontmatter 00-Frontmatter-Abs 01-Jones 02-Swirski 08-Alnaim 10-Kurz 05-Stamford)
FRONT_PAGE_OFFSET="0"

function usage()
{
  echo "$0: [directory]"
  echo ""
  echo "directory is a directory containing a main.tex and/or main_abs.tex file."
  echo "If not specified all top level directories containing a main.tex file will be traversed"
}

function main2abs()
{
  echo -e "\033[32mGenerating abstract from ${1}/main.tex\033[0m"
  local PNUM="$(echo $1 | grep -Eo '^[0-9]+')"
  local PNUM="$(echo $PNUM '+' $FRONT_PAGE_OFFSET | bc -l)"
  cat $1/main.tex | grep -B9999 '\end{abstract}' | sed -r 's/\{[0-9]+(\}\% starting page number)/\{'$PNUM'\1/' | sed -r 's/(\\begin\{document\})/\n% Page numbers in side margins\n\\usepackage[some]{background}\n\\usepackage{ifthen}\n\\SetBgContents{\\textcolor{gray}{\\LARGE \\bf \\hl \\thepage}}\n\\SetBgOpacity{1}\n\\SetBgScale{1}\n\\SetBgAngle{0}\n\\SetBgColor{black}\n\\makeatletter\n  \\AddEverypageHook{%\n    \\ifthenelse{\\isodd{\\thepage}}%\n      {\\SetBgPosition{\.9\\paperwidth,-.9\\paperheight}%\n	  \\thispagestyle{empty}%\n	}%\n      {\\SetBgPosition{\.1\\paperwidth,-.9\\paperheight}%\n	  \\thispagestyle{empty}%\n	}%\n    \\bg\@material}\n\\makeatother\n\1/' > $1/main_abs.tex
  echo '\end{document}' >> $1/main_abs.tex
}

function build()
{
  echo -e "\033[32mRunning on ${1}\033[0m"
  if [ -r $1/main.tex ]; then
    main2abs $1
    cd $1
    pdflatex -halt-on-error main
    pdflatex -halt-on-error main_abs
    SKIP=0
    for d in ${SKIP_BIBTEX[*]}; do
      if [ $(echo "$1" | grep -Ec "$d") -eq 1 ]; then
        SKIP=1
      fi
    done
    if [ $SKIP -eq 0 ]; then
      echo "Running BibTeX"
      bibtex main
    else
      echo -e "\033[31m*****Skipping BibTeX****\033[0m"
    fi
    pdflatex -halt-on-error main
    pdflatex -halt-on-error main
    pdflatex -halt-on-error main_abs
    pdflatex -halt-on-error main_abs
    cd ..
  fi
}

if [ $# -eq 1 ]; then
  if [ ! -d "$1" ]; then
    echo "$1 is not a directory"
    usage
    exit 1
  fi
  DIRS="$1"
else
  DIRS="$(find . -maxdepth 2 -iname 'main.tex' -exec dirname \{} \; | sort)"
fi

# Show run commands
set -x

for x in $DIRS; do
  if [ $(echo "$x" | grep -Ec "00-Frontmatter") -eq 1 -a $# -eq 0 ]; then
    echo "skipping front matter"
    continue
  elif [ $(echo "$x" | grep -Ec "00-Frontmatter-Abs") -eq 1 -a $# -eq 0 ]; then
    echo "skipping front matter"
    continue
  else
    build $x
  fi
done

if [ $# -eq 0 ]; then
  # Needs vtc files from all other papers
  build 00-Frontmatter-Abs/
  pdfjoin */main_abs.pdf --outfile iccsw.pdf
  build 00-Frontmatter/
  pdfjoin */main.pdf --outfile iccsw.pdf
fi
