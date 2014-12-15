LIBDIR = $(DESTDIR)/usr/lib/gamewake
BINDIR = files/bin/$(shell uname)/gamewake_$(shell uname -m)
ETCDIR = $(DESTDIR)/etc/gamewake

all:	build	install

clean:
	rm -f $(BINDIR)/usr/lib/gamewake/gamewake

build:
	lazbuild files/src/GameWake.lpr
	strip $(BINDIR)/gamewake

install:
	install -D --mode 755 $(BINDIR)/gamewake $(LIBDIR)/gamewake
	ln -s $(LIBDIR)/gamewake /usr/bin/gamewake
	install -D --mode 644 bin/beep.wav $(LIBDIR)/beep.wav
	install -D --mode 644 bin/bing.wav $(LIBDIR)/bing.wav
	install -D --mode 644 bin/bell.wav $(LIBDIR)/bell.wav
	install -D --mode 644 bin/horn.wav $(LIBDIR)/horn.wav
	install -D --mode 666 src/gamewake.conf $(ETCDIR)/gamewake.conf
	install -D --mode 644 src/lang $(ETCDIR)/lang
	install -D --mode 644 src/gamewake.ico $(DESTDIR)/usr/share/pixmaps/gamewake.ico
	install -D --mode 644 src/gamewake.png $(DESTDIR)/usr/share/pixmaps/gamewake.png
	install -D --mode 644 src/gamewake.desktop $(DESTDIR)/usr/share/applications/gamewake.desktop

uninstall:
	rm -rf $(LIBDIR)
	rm -f $(DESTDIR)/usr/bin/gamewake
	rm -rf $(ETCDIR)
	rm -f $(DESTDIR)/usr/share/pixmaps/gamewake.ico
	rm -f $(DESTDIR)/usr/share/pixmaps/gamewake.png
	rm -f $(DESTDIR)/usr/share/applications/gamewake.desktop
