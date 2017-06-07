Game Wake
=========

Game Wake is a simple to configure virtual alarm clock application. It provides multiple types of alerts and features both a timer and counter mode.

Installation for Linux
----------------------

There are two ways of installing Game Wake: Installation of the stable or latest version. The stable version is distributed through the PM Code Works APT repository and is fully tested but does not contain the latest changes.

### Installation of the stable version

Add PM Codeworks repository

    ~# wget http://apt.pm-codeworks.de/pm-codeworks.list -P /etc/apt/sources.d/

Add PM Codeworks key

    ~# wget -O - http://apt.pm-codeworks.de/pm-codeworks.de.gpg | apt-key add -
    ~# apt-get update

Install the package

    ~# apt-get install gamewake

### Installation of the latest version

The latest version contains the latest changes that may not have been fully tested and should therefore not be used productively. It is recommended to install the stable version.

Install required packages for building

    ~# apt-get install git lcl-utils fpc devscripts

Clone this repository

    ~$ git clone https://github.com/philippmeisberger/gamewake.git

Build the package

    ~$ cd ./gamewake/
    ~$ dpkg-buildpackage -uc -us

Install the package

    ~# dpkg -i ../gamewake*.deb

Installation for Windows
------------------------

Visit <http://www.pm-codeworks.de/gamewake.html>.

Questions and suggestions
-------------------------

If you have any questions to this project just ask me via email:

<team@pm-codeworks.de>
