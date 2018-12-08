FROM i386/debian:latest

# Update packages
RUN apt-get update && apt-get -y upgrade

# Install build dependencies
RUN apt-get install -y git devscripts lcl-utils fpc
#RUN mk-build-deps -i -r -t 'apt-get -y'
RUN apt-get autoremove -y
RUN apt-get clean

# Package will be moved into this folder
VOLUME /build

# Clone repository
RUN git clone https://github.com/philippmeisberger/gamewake.git
WORKDIR gamewake

# Create the debian package on run
ENTRYPOINT ["debuild", "--post-dpkg-buildpackage-hook=mv *.deb *.dsc *.tar.xz *.changes *.build* /build"]
CMD ["-us", "-uc"]
