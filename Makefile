LIBDIR = $(DESTDIR)/usr/lib/gamewake
BINDIR = bin/$(shell uname)/gamewake_$(shell uname -m)
ETCDIR = $(DESTDIR)/etc/gamewake

all:
	build
	install

clean:
	rm -f $(BINDIR)/usr/lib/gamewake/gamewake

build:
	lazbuild src/GameWake.lpr
	strip $(BINDIR)/usr/lib/gamewake/gamewake

install:
	install -D --mode 755 $(BINDIR)/usr/lib/gamewake/gamewake $(LIBDIR)/gamewake
	ln -s $(LIBDIR)/gamewake /usr/bin/gamewake
	install -D --mode 644 bin/beep.wav $(LIBDIR)/beep.wav
	install -D --mode 644 bin/bing.wav $(LIBDIR)/bing.wav
	install -D --mode 644 bin/bell.wav $(LIBDIR)/bell.wav
	install -D --mode 644 bin/horn.wav $(LIBDIR)/horn.wav
	install -D --mode 666 src/gamewake.conf $(ETCDIR)/gamewake.conf
	install -D --mode 644 src/lang $(ETCDIR)/lang
	install -D --mode 644 src/gamewake.ico $(DESTDIR)/usr/share/pixmaps/gamewake.ico
	install -D --mode 644 src/gamewake.png $(DESTDIR)/usr/share/pixmaps/gamewake.png

uninstall:
	rm -rf $(LIBDIR)
	rm -f /usr/bin/gamewake
	rm -rf $(ETCDIR)
	rm -f /usr/share/pixmaps/gamewake.ico
	rm -f /usr/share/pixmaps/gamewake.png
