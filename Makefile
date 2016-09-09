#!/usr/bin/make -f

ARCH = $(shell uname -m)

ifeq ($(ARCH),i686)
	ARCH = i386
endif
ifeq ($(ARCH),i586)
	ARCH = i386
endif
ifeq ($(ARCH),i486)
	ARCH = i386
endif

BINDIR = bin/$(shell uname)-$(ARCH)

all: src/GameWake.lpr
	lazbuild src/GameWake.lpr

install: $(BINDIR)/gamewake
	install -D --mode 755 $(BINDIR)/gamewake $(DESTDIR)/usr/lib/gamewake/
