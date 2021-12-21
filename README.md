
[Core.s]: Source/Core.s
[Template.s]: Source/Template.s
[Dallas.s]: Source/Dallas.s

[Driver Dallas]: Drivers/DALLAS.PRG


# Atari Realtime Clock Driver

*Extensible driver system for real time clock upgrades.*

---

## Support

This driver works with the following configurations:

| Dallas |
|:------:|
| [`DS1216E`][Driver Dallas] |
| [`DS1216F`][Driver Dallas] |
| [`DS1315`][Driver Dallas] |

*Similar* ***ROM*** *based clocks should also work.*

It should also work seamlessly with any **TOS** and **Atari** <br>
applications for setting date / time, such as `XControl`.


---

## Caution

Using other clock drivers, y2k fixes or 3rd party **Dallas** <br>
applications for setting time may cause problems.

Most problematic are ones that rely on the **IKBD** <br>
which compensates by modifying the set year.


---

## Tested

This driver has been tested with a `Forget Me Clock II` cartridge.

The following systems have been tested:

| System |        Version       |
|:------:|:--------------------:|
| TOS    | `1.04` `1.62` `2.06` |
| EmuTOS               | **\*** |
| FreeMiNT             | **\*** |
| MagiC                | **\*** |

---

## Usage

1. `A1` must be used as data input.

2. `A2` / `A3` must be used for `/WE`.

3. The **Dallas** must occupy the cartridge <br>
   port or any of the **TOS ROM** sockets.

4. Place the driver in your `AUTO` folder.

---

## Files

| File | Description |
|:-----|:-----------:|
| [`Source/Core.s`][Core.s] | Hardware Independent Driver Core |
| [`Source/Template.s`][Template.s] | Dummy Driver Template |
| [`Source/Dallas.s`][Dallas.s] | `DS1216` / `DS1315` Implementation |
