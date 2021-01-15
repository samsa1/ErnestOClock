lib_linux = /usr/lib/libGL.so /usr/lib/libglut.so /usr/lib/libGLU.so
lib_mac = -framework GLUT -framework OpenGL
lib_win = 

CPU = cpu
ROM = code
CODE = clock.s

ifeq ($(OS),Windows_NT)
	lib = $(lib_win)
else
	UNAME = $(shell uname)
	ifeq ($(UNAME),Linux)
		lib = $(lib_linux)
	else ifeq ($(UNAME),Darwin)
		lib = $(lib_mac)
	endif
endif

all:cpu.exe
	@echo "Compilation done !"
run:
	@if test -e cpu.exe; then ./cpu.exe; else make; ./cpu.exe;fi

speed:
	@if test -e cpu.exe; then ./cpu.exe -hs; else make; ./cpu.exe -hs;fi

cpu.c: Build_C Build_Rom
	@if test -e _build/cpu.c; then echo ""; else _build/compilateurNetlist.exe $(CPU).net;mv $(CPU).c _build/cpu.c ;fi
	

Build_C:
	dune build compilateurNetlist_openGL.exe
	@cp _build/default/compilateurNetlist_openGL.exe _build/compilateurNetlist.exe

Build_A:
	dune build assembly.exe
	@cp _build/default/assembly.exe _build/assembly.exe

Build_Rom: Build_A
	@_build/assembly.exe $(CODE) -o ROM$(ROM).rom

cpu.exe: cpu.c
	@if test -e cpu.exe; then echo ""; else gcc _build/cpu.c -o cpu.exe $(lib) -Os; fi

help:
	@echo "make : compile everything"
	@echo "make clean : cleans the directory from EVERYTHING that is compiled"
	@echo "make run : run the clock in real time mode"
	@echo "make speed : run the clock at maximum speed"
	@echo "Options:"
	@echo "	CPU : path to the netlist CPU (without extension!),"
	@echo "	ROM : name of the rom in the CPU,"
	@echo "	CODE: name of the code to execute (extension .s)"

clean:
	@rm -rf _build
	@rm -f ROMcode.rom
	@rm -f cpu.exe
	@echo "Directory cleaned!"

.PHONY: all clean
