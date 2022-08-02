
# Atari Realtime Clock Driver    [![Badge License]][License]

*Extensible driver system for real time clock upgrades.*

<br>
<br>

## Support

This driver works with the following types <br>
as well as similar **ROM** based clocks:

[<kbd>  DS1216E  </kbd>   <kbd>  DS1216F  </kbd>   <kbd>  DS1315  </kbd>][Driver Dallas]

<br>

It should also work seamlessly with any **TOS** and **Atari** <br>
applications for setting date / time, such as `XControl`.

<br>
<br>

## ⚠  Caution  ⚠

Using other clock drivers, y2k fixes or 3rd party **Dallas** <br>
applications for setting time may cause problems.

Most problematic are ones that rely on the **IKBD** <br>
which compensates by modifying the set year.

<br>
<br>

## Tested

This driver has been tested with a <br>
`Forget Me Clock II`  cartridge.

<br>

The following systems have been tested:

<kbd>  FreeMiNT  </kbd>   <kbd>  EmuTOS  </kbd>   <kbd>  MagiC  </kbd>   <kbd>  TOS  </kbd>

<br>

They have been tested with versions:

<kbd>  2.06  </kbd>   <kbd>  1.62  </kbd>   <kbd>  1.04  </kbd>

<br>
<br>

## Usage

<br>

1.  `A1`  must be used as data input.

    <br>

2.  `A2`  /  `A3`  must be used for  `/WE` .

    <br>

3.  The **Dallas** must occupy the cartridge <br>
    port or any of the **TOS ROM** sockets.
    
    <br>

4.  Place the driver in your  `AUTO`  folder.

<br>
<br>

## Files
    
-   [`Source/Template.s`][Template.s]

    *Dummy Driver Template*
    
-   [`Source/Dallas.s`][Dallas.s]

    `DS1216`  /  `DS1315`  Implementation
    
-   [`Source/Core.s`][Core.s]

    *Hardware Independent Driver Core*

<br>


<!----------------------------------------------------------------------------->

[Driver Dallas]: Drivers/DALLAS.PRG
[Template.s]: Source/Template.s
[Dallas.s]: Source/Dallas.s
[License]: LICENSE
[Core.s]: Source/Core.s

<!----------------------------------[ Badges ]--------------------------------->

[Badge License]: https://img.shields.io/badge/License-GPL2-015d93.svg?style=for-the-badge&labelColor=blue
