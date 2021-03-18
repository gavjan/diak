AS=nasm
ASFLAGS= -f elf64 -w+all -w+error
LDFLAGS= --fatal-warnings

.PHONY: all clean

all: diakrytynizator

diakrytynizator: diakrytynizator.o
	ld $(LDFLAGS) -o diakrytynizator diakrytynizator.o

diakrytynizator.o: diakrytynizator.asm
	$(AS) $(ASFLAGS) -o diakrytynizator.o diakrytynizator.asm

run: diakrytynizator
	./$^
format:
	nasmfmt diakrytynizator.asm
clean:
	-@$(RM) diakrytynizator *.o
