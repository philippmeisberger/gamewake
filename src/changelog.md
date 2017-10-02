Game Wake
=========

An open-source project of PM Code Works

Version 3.5  [*??.10.17*]
-----------

* Usage of Delphi/FPC TTime
* Linux:
  * Game Wake is terminated if language file cannot be found
  * Added 48x48 PNG for better desktop icon quality
* Bug fixes:
  * Disabled alert after initiating a shutdown otherwise Game Wake was minimized and stayed active
  * Blinking stayed enabled (even if deselected) after alarm has occured and was set again
  * Exception when loading default time (00:00) at startup in counter mode
  * Automatic alarm termination after 1 minute did not work in counter mode
  * Portable Edition did not play bing sound
  * Loading primary language if requested locale could not be found in language file
  * Color could not be changed if nothing should be saved
* Updater v3.1
  * Removed dependency to "Indy" component suite
  * Executable up to 1MB smaller
  * Removed "Search for update" under Linux
* Usage of Delphi/FPC TIniFile

Version 3.4  [*18.05.16*]
-----------

* Linux:
  * Shutdown now also works on systemd
* Windows:
  * Added volume slider to "volume mixer" in Windows Vista and later
  * New setup
  * Improved report bug system
    * Added translations for german, english and french
    * In case no mail client is installed for sending the bug report the website will be shown
  * Program executable is now signed with SHA-256 under Windows
* Alert sounds have the same volume
* Closed small memory leak when changing the mode
* Usage of the new "About ..." dialog

Version 3.3  [*22.08.15*]
-----------

* Linux:
  * Moved configuration file to $HOME/.gamewake
* Windows:
  * Moved configuration file to %APPDATA%\Game Wake\gamewake.ini
  * Usage of specific Windows UI features (beginning with Vista)
  * 32/64-Bit binaries
  * Updater v3.0 with SSL support
* Language is now loaded by "Locale" in configuration file
* IniFileParser v1.1.1
* OSUtils v2.2

Version 3.2  [*10.01.15*]
-----------

* Fixed bug caused when "SaveClock"=False and "Counter Mode" was set
* Using custom INI-file parser for registry file export and import
* Updater v2.2
* OSUtils v2.0

Version 3.1  [*18.09.14*]
-----------

* New icon
  * Thanks to Rafi: http://www.graphicsfuel.com/2012/08/alarm-clock-icon-psd/
* Updater v2.1
* Moved sounds to /usr/lib/gamewake/ instead of /opt/gamewake/
* Several small improvements

Version 3.0  [*16.03.14*]
-----------

* Improved updater
* Improved platform independence

Version 2.1.2  [*02.11.13*]
-------------

* Now platform independent (Windows and Debian)
* New Beep sound
* Bug fix in counter mode
* Several bug fixes

Version 2.1.1  [*09.10.13*]
-------------

* Added balloon tip when clicking on tray icon
* Bug fixes
  * Time will be refreshed after standby
  * In shutdown function
* Cancel button in update form will not be disabled

Version 2.1  [*21.06.13*]
-----------

* Added new option: Hours and minutes can be combined
* Changed time format to HH:MM:SS
* Changes in form management

Version 2.0.1  [*03.12.12*]
-------------

* Added new option: automatically search for update on startup can be changed
* Improved update function
* GUI changes in option form
* Bug fix in save progress

Version 2.0  [*18.11.12*]
-----------

* Restructurement
  * Improved save progress
  * Alert is now threaded
* Added new mode: counter
* Improved GUI
  * Added buttons for easy setting up alert
  * Added "search for update" button
* Added translations for english and french
* Added "Install certificate"
* Added shutdown feature
* Several bug fixes

Version 1.3.1  [*09.11.11*]
-------------

* Added new sound: horn
* Several bug fixes

Version 1.3  [*24.08.11*]
-----------

* Added option form
  * Select settings that should be saved
* Several bug fixes

Version 1.2  [*17.08.11*]
-----------

* Blinking color can be chosen
  * Storing custom created colors
* Several bug fixes

Version 1.1  [*14.08.11*]
-----------

* Added main menu
* Added storing feature
* Added feature to show a short text during alert
* Added blinking feature

Version 1.0  [*10.08.11*]
-----------

Initial release

--------------------------------------------------------------------------------
Game Wake was released under the D-FSL license and is open-source. The source code can be downloaded from GitHub or from the website.

If Game Wake is going to be pressed onto a commercial CD-ROM (with magazine), it would be nice to send me an issue of this CD-ROM (with magazine). You can contact me under team@pm-codeworks.de and I will give you my address.
