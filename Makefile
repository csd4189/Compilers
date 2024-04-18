CFILES = symtable.c quads.c

all: clean bison

bison:
	bison --defines --output=parser.c parser.y
	flex --outfile=scanner.c scanner.l
	gcc -o alpha scanner.c parser.c $(CFILES)
	rm parser.c scanner.c parser.h 

clean:
	@rm -f alpha scanner.c parser.c parser.h parser.output parser.tab.c parser.tab.h

