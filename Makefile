DIR_FRONT = 00-Frontmatter/
DIR_FRONT_ABS = 00-Frontmatter-Abs/

#~ find . -maxdepth 2 -iname 'main.tex' -exec dirname \{} \; | sort | tail -n +2 | cut -b3-
DIRS = $(addsuffix /,01-Dibona 02-Mueller 03-Belikov 04-El-Abbasy 05-Gulo 06-Hadjisoteriou 07-Hasmik 08-Satthar 09-Schoening 10-Silva 11-Spanring 12-Zbrzezny 13-Zhang)

# Requires `main.tex` in all directories
FRONT = $(addsuffix main.pdf, $(DIR_FRONT))
PAPERS = $(addsuffix main.pdf, $(DIRS))

# Abstracts
FRONT_ABS = $(addsuffix main_abs.pdf, $(DIR_FRONT_ABS))
ABS = $(addsuffix main_abs.pdf, $(DIRS))


.PHONY : all clean

both : iccsw2015.pdf iccsw2015-abstracts.pdf

iccsw2015.pdf : $(FRONT)
	pdfjoin $(FRONT) $(PAPERS) --outfile $@

iccsw2015-abstracts.pdf : $(FRONT_ABS)
	pdfjoin $(FRONT_ABS) $(ABS) --outfile $@

all : $(FRONT) $(FRONT_ABS)

clean :
	rm -f $(PAPERS) $(PAPERS:%.pdf=%.aux) $(PAPERS:%.pdf=%.bbl) $(PAPERS:%.pdf=%.blg) $(PAPERS:%.pdf=%.log) $(PAPERS:%.pdf=%.out)
	rm -f $(FRONT) $(FRONT:%.pdf=%.aux) $(FRONT:%.pdf=%.bbl) $(FRONT:%.pdf=%.blg) $(FRONT:%.pdf=%.log) $(FRONT:%.pdf=%.out)
	rm -f $(ABS) $(ABS:%.pdf=%.tex) $(ABS:%.pdf=%.aux) $(ABS:%.pdf=%.bbl) $(ABS:%.pdf=%.blg) $(ABS:%.pdf=%.log) $(ABS:%.pdf=%.out)
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
