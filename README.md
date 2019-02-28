Game Wake
=========

[![Build Status](https://travis-ci.org/philippmeisberger/gamewake.svg?branch=master)](https://travis-ci.org/philippmeisberger/gamewake)

Game Wake is a simple to configure virtual alarm clock application. It provides multiple types of alerts and features both a timer and counter mode.

Installation for Linux
----------------------

There are two ways of installing Game Wake: Installation of the stable or latest version. The stable version is distributed through the PM Code Works APT repository and is fully tested but does not contain the latest changes.

### Installation of the stable version

Add PM Code Works repository

* Debian 8:

    `~# echo "deb http://apt.pm-codeworks.de jessie main" | tee /etc/apt/sources.list.d/pm-codeworks.list`

* Debian 9:

    `~# echo "deb http://apt.pm-codeworks.de stretch main" | tee /etc/apt/sources.list.d/pm-codeworks.list`

Add PM Code Works key

    ~# wget -qO - http://apt.pm-codeworks.de/pm-codeworks.de.gpg | apt-key add -
    ~# apt-get update

Install the package

    ~# apt-get install gamewake

### Installation of the latest version

The latest version contains the latest changes that may not have been fully tested and should therefore not be used productively. It is recommended to install the stable version.

Install required packages for building

    ~# apt-get install git devscripts

Clone this repository

    ~$ git clone https://github.com/philippmeisberger/gamewake.git

Build the package

    ~$ cd ./gamewake/
    ~$ sudo mk-build-deps -i debian/control
    ~$ dpkg-buildpackage -uc -us

Install the package

    ~# dpkg -i ../gamewake*.deb

### Building for i386 using Docker

Build Docker image

    ~# docker build -t gamewake-i386:latest .

Build Debian package inside Docker container

    ~# docker run --rm -d -v ${PWD}/build:/build gamewake-i386:latest

Installation for Windows
------------------------

Visit <http://www.pm-codeworks.de/gamewake.html>.

Questions and suggestions
-------------------------

If you have any questions to this project just ask me via email:

<team@pm-codeworks.de>
