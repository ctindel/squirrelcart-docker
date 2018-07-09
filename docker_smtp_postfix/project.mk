readme: README.html

README.html: README.md
	markdown $? > $@
