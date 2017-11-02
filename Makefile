DIR_FRONT = 00-Frontmatter/
DIR_FRONT_ABS = 00-Frontmatter-Abs/

#~ find . -maxdepth 2 -iname 'main.tex' -exec dirname \{} \; | sort | tail -n +2 | cut -b3-
DIRS = $(addsuffix /,01-Jones 02-Swirski 03-Cauli 04-El-Sanosi 05-Kurz 06-Stamford 07-Tozzo 08-Winblad 09-Alnaim 10-Capuccini)

# Requires `main.tex` in all directories
FRONT = $(addsuffix main.pdf, $(DIR_FRONT))
PAPERS = $(addsuffix main.pdf, $(DIRS))

# Abstracts
FRONT_ABS = $(addsuffix main_abs.pdf, $(DIR_FRONT_ABS))
ABS = $(addsuffix main_abs.pdf, $(DIRS))


.PHONY : all clean

both : iccsw.pdf iccsw-abstracts.pdf

iccsw.pdf : $(FRONT)
	pdfjoin $(FRONT) $(PAPERS) --outfile $@

iccsw-abstracts.pdf : $(FRONT_ABS)
	pdfjoin $(FRONT_ABS) $(ABS) --outfile $@

all : $(FRONT) $(FRONT_ABS)

clean :
	rm -f $(PAPERS) $(PAPERS:%.pdf=%.aux) $(PAPERS:%.pdf=%.bbl) $(PAPERS:%.pdf=%.blg) $(PAPERS:%.pdf=%.log) $(PAPERS:%.pdf=%.out) $(PAPERS:%.pdf=%.vtc)
	rm -f $(FRONT) $(FRONT:%.pdf=%.aux) $(FRONT:%.pdf=%.bbl) $(FRONT:%.pdf=%.blg) $(FRONT:%.pdf=%.log) $(FRONT:%.pdf=%.out)
	rm -f $(ABS) $(ABS:%.pdf=%.tex) $(ABS:%.pdf=%.aux) $(ABS:%.pdf=%.bbl) $(ABS:%.pdf=%.blg) $(ABS:%.pdf=%.log) $(ABS:%.pdf=%.out) $(ABS:%.pdf=%.vtc)
	rm -f $(FRONT_ABS) $(FRONT_ABS:%.pdf=%.aux) $(FRONT_ABS:%.pdf=%.bbl) $(FRONT_ABS:%.pdf=%.blg) $(FRONT_ABS:%.pdf=%.log) $(FRONT_ABS:%.pdf=%.out) 

# Frontmatter
$(FRONT) : $(DIR_FRONT)main.tex $(PAPERS)
	# Needs vtc files from all other papers
	cd $(DIR_FRONT); pdflatex -halt-on-error main >> /dev/null 2>&1
	cd $(DIR_FRONT); pdflatex -halt-on-error main >> /dev/null
	cd $(DIR_FRONT); pdflatex -halt-on-error main >> /dev/null

$(FRONT_ABS) : $(DIR_FRONT_ABS)main_abs.tex $(FRONT) $(ABS)
	cd $(DIR_FRONT_ABS); pdflatex -halt-on-error main_abs >> /dev/null 2>&1
	cd $(DIR_FRONT_ABS); pdflatex -halt-on-error main_abs >> /dev/null
	cd $(DIR_FRONT_ABS); pdflatex -halt-on-error main_abs >> /dev/null

# All other PDFs (papers)
%.pdf : %.tex
	./generate.sh `dirname $@`
