----------------------------------------------------------------------------
Atari realtime clock driver(s)

Extendible driver system for real time clock upgrades.
Comes with a driver for Dallas DS1216, DS1315 or similar ROM based clocks.

These files are distributed under the GPL v2, or at your option any
later version.  See LICENSE.TXT for details.

(c)2020, Anders Granlund
Anders Granlund, 2019
----------------------------------------------------------------------------

How to use: Put driver in your AUTO folder.

These drivers are meant to work with TOS and the normal TOS applications
for setting the time such as XControl.

Using other clock drivers, fixes or 3rd party applications at the
same time may cause interference. Especially those that rely on the IKBD
and sets the year back and forth to compensate.

Tested with a FMC-II cartridge under TOS2.06 and EmuTOS1.0.
Your milage may vary.

----------------------------------------------------------------------------
Hardware drivers:
----------------------------------------------------------------------------
DALLAS1.PRG
  Supports various ROM based dallas chips such as 1216E, 1216F or 1315
  in ROM mode.
  It assumes A1 is used for data input and either A2 or A3 is used for /WE
  The Dallas can be located in cartridge port or any of the TOS ROM sockets.


----------------------------------------------------------------------------
Sources:
----------------------------------------------------------------------------
SRC/CORE.s        - hardware independent driver core
SRC/TEMPLATE.S    - dummy driver template
SRC/DALLAS1.S     - driver for DS1216 / DS1315
