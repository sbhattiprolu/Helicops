# test/Makefile

#topdir:=..
#include $(topdir)/config.mk
INCLUDES=/usr/local/include/libcwiimote-0.4.0/libcwiimote/
CFLAGS:=$(CFLAGS) #-static -g
LIBS:=  -lcwiimote -lbluetooth -lm -lncurses

all: main

main: main.c
	$(CC) $(CFLAGS) -I $(INCLUDES) -o $@ $< $(LIBS)

clean:
	@rm -f *.o *~ $(BINDIR)/*
