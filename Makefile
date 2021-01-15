lib_linux = /usr/lib/libGL.so /usr/lib/libglut.so /usr/lib/libGLU.so
lib_mac = -framework GLUT -framework OpenGL
lib_win = 

NETLIST_COMPILER = ./compilateurNetlist_openGL
CPU = cpu

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

cpu.c: Build_C Build_Rom
	@if test -e _build/cpu.c; then echo ""; else _build/compilateurNetlist.exe cpu.net;mv cpu.c _build/cpu.c ;fi
	

Build_C:
	dune build compilateurNetlist_openGL.exe
	@cp _build/default/compilateurNetlist_openGL.exe _build/compilateurNetlist.exe

Build_A:
	dune build assembly.exe
	@cp _build/default/assembly.exe _build/assembly.exe

Build_Rom: Build_A
	@_build/assembly.exe ROMcode.s -o ROMcode.rom

cpu.exe: cpu.c
	@if test -e cpu.exe; then echo ""; else gcc _build/cpu.c -o cpu.exe $(lib) -Os; fi

help:
	@echo "make : compile everything"
	@echo "make netlist_compiler : compiles only the OCaml netlist -> C compiler"
	@echo "make simulator : compiles the simulator from netlest to a C file"
	@echo "make bin : compiles the C simulator into an executable version"
	@echo "make clean : cleans the directory from EVERYTHING that is compiled"
	@echo "Options:"
	@echo "	CPU : path to the netltlist CPU (without extension),"
	@echo "	NETLIST_COMPILER : path to the .ml compiler, without the extension"

clean:
	@rm -rf _build
	@rm ROMcode.rom
	@rm cpu.exe
	@echo "Directory cleaned!"

.PHONY: all clean
