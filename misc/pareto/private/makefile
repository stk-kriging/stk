EXE = wfg
OBJ = read.o 
OPT = -O3 


march_error = $(error please define an architecture, e.g., 'make march=pentium')
ifdef ARCH
OPT=$(ARCH) $(COPT)
else
ifndef march 
  $(march_error)
  endif
  OPT += -march=$(march)
endif


CC = gcc -std=c99 -Wall  $(OPT)

$(EXE): $(OBJ) wfg.c
	$(CC) -o wfg wfg.c $(OBJ)

%.o: %.c
	$(CC) -c $<

clean: 
	rm -f wfg *.o 
	rm -rf *.dSYM
