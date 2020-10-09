----------------------------------------------------------------------------
Atari realtime clock driver(s)

Extendible driver system for real time clock upgrades.
Comes with a driver for Dallas DS1216, DS1315 or similar ROM based clocks.

These files are distributed under the GPL v2, or at your option any
later version.  See LICENSE.TXT for details.

(c)2020, Anders Granlund
----------------------------------------------------------------------------

How to use: Put driver in your AUTO folder.

These drivers are meant to work seamlessly with any TOS and the
Atari applications for setting time and date, for example XControl.

Note: Using other clock drivers, y2k type fixes or 3rd party Dallas
applications for setting time may cause interference. Especially those
that rely on the IKBD and sets the year back and forth to compensate.


It has been tested with a "Forget Me Clock II" cartridge under
TOS 1.04, 1.62, 2.06 and EmuTOS, as well as FreeMiNT and MagiC.
Your milage may vary.

----------------------------------------------------------------------------
Hardware drivers:
----------------------------------------------------------------------------
DALLAS1.PRG
  Supports various ROM based dallas chips such as DS1216E, DS1216F,
  DS1315 in ROM mode or similar chips.
  It assumes A1 is used as data input and either A2 or A3 as /WE
  The Dallas can be located in cartridge port or any of the TOS ROM sockets.


----------------------------------------------------------------------------
Sources:
----------------------------------------------------------------------------
SRC/CORE.s        - hardware independent driver core
SRC/TEMPLATE.S    - dummy driver template
SRC/DALLAS1.S     - driver for DS1216 / DS1315
