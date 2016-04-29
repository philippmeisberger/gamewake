##
## Game Wake makefile for Unix
##

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

LIBDIR = $(DESTDIR)/usr/lib/gamewake
BINDIR = files/bin/$(shell uname)-$(ARCH)

all:	build

build:
	lazbuild files/src/GameWake.lpr

install: $(BINDIR)/gamewake
	install -D --mode 755 $(BINDIR)/gamewake $(LIBDIR)/gamewake
	mkdir -p $(DESTDIR)/usr/bin/
	ln -s /usr/lib/gamewake/gamewake $(DESTDIR)/usr/bin/gamewake
	install -D --mode 644 files/bin/beep.wav $(LIBDIR)/beep.wav
	install -D --mode 644 files/bin/bing.wav $(LIBDIR)/bing.wav
	install -D --mode 644 files/bin/bell.wav $(LIBDIR)/bell.wav
	install -D --mode 644 files/bin/horn.wav $(LIBDIR)/horn.wav
	install -D --mode 644 files/src/lang $(LIBDIR)/lang
	install -D --mode 644 files/src/gamewake.ico $(DESTDIR)/usr/share/pixmaps/gamewake.ico
	install -D --mode 644 gamewake.png $(DESTDIR)/usr/share/pixmaps/gamewake.png
	install -D --mode 644 files/src/gamewake.desktop $(DESTDIR)/usr/share/applications/gamewake.desktop

.PHONY: install

uninstall:
	rm -rf $(LIBDIR)
	rm -f $(DESTDIR)/usr/bin/gamewake
	rm -f $(DESTDIR)/usr/share/pixmaps/gamewake.ico
	rm -f $(DESTDIR)/usr/share/pixmaps/gamewake.png
	rm -f $(DESTDIR)/usr/share/applications/gamewake.desktop
