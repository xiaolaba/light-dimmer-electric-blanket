:: --
:: Copyright, xiaolaba, 2020-OCT-20, xiao_laba_cn@yahoo.com
:: --


@echo off

del *.elf
del *.hex
del *.lst
del *.o
del *.s

::avr-gcc -mmcu=attiny2313 -Wall -Os -o main.elf main.c -w
::avr-objcopy -j .text -j .data -O ihex main.elf main.hex

::pause
::avrdude -c usbtiny -p t2313 -U flash:w:"main.hex":a



@echo on

set mcu=attiny85
::set lfuse=0x7a
::set hfuse=0xff
::set mcu=atmega328p
::set mcu=atmega324p
::set mcu=atmega168p
::set mcu=attiny2313

:::: // no PRR register
:: set mcu=attiny13 

:::: // PRR register, Power Reduction Register
::set mcu=attiny13a   

mkdir firmware
set dir=firmware

set F_CPU=8000000L

set main=AVR211_arduino
set lib=pid
set target=%dir%\pid
::set ac=C:\WinAVR-20100110
:: 2020-09-07, download avr-gcc 3.6 from Microchip
set ac=C:\avr8-gnu-toolchain-win32_x86

path %ac%\bin;%ac%\utils\bin;%path%;

:: REF : https://www.nongnu.org/avr-libc/user-manual/using_tools.html


:: ref: https://www.nongnu.org/avr-libc/user-manual/group__demo__project.html

avr-gcc.exe -dumpversion

:: to include the C source code into the assembler listing in file
::avr-gcc -c -O2 -Wall -mmcu=%mcu% -Wa,-acdhlmns=%main%.lst -Wl,-Ttiny13flash.x -nostdlib -g %main%.c -o %main%.o

::avr-gcc -c -mmcu=%mcu% -x assembler-with-cpp -o %main%.o %main%.S -Wa,--gstabs

:::: -Os optinize for Size, debug -g is not working, must turn off as -g0
::avr-gcc.exe -xc -Os -mmcu=%mcu% -Wall -g0 -o %main%.out %main%.c -w

:::: -Os optinize for Size, debug -g is ok
::avr-gcc.exe -xc -Os -DF_CPU=%F_CPU% -mmcu=%mcu% -Wall -g -o %target%.out %main%.ino -w

::Compiling
:: avr-gcc did not reconise *.ino, error 
:: avr-gcc: warning: AVR211_arduino.ino: linker input file unused because linking not done
:: solution, copy main.ino to main.c first, once compile done, delete main.c
cp %main%.ino %main%.c 
avr-gcc -Os -DF_CPU=%F_CPU% -mmcu=%mcu% -c %main%.c %lib%.c


::linking
avr-gcc -mmcu=%mcu% %main%.o %lib%.o -o %main%.elf

:::: // output asm
avr-gcc.exe -S -fverbose-asm -xc -Os -DF_CPU=%F_CPU% -gdwarf-2 -mmcu=%mcu% -Wall -g0 -S -o %target%.out %main%.c

:: git gui push did not process *.hex, why ? change firmware buid with *_hex

:: build listing
cmd /c avr-objdump.exe -h -S %main%.elf >%target%.lst

:: build hex
cmd /c avr-objcopy.exe -O ihex  %main%.elf %target%_%mcu%_hex

avr-size.exe  %main%.elf
del  %main%.elf

:: avr-gcc: warning: AVR211_arduino.ino: linker input file unused because linking not done
:: solution, copy main.ino to main.c first, once compile done, delete main.c
del %main%.c

::pause
:::: burn hex

::avrdude -c usbtiny -p %mcu% -U flash:w:"%target%_%mcu%.hex":a -U lfuse:w:%lfuse%:m  -U hfuse:w:%hfuse%:m

avrdude -c usbtiny -p %mcu% -U flash:w:%target%_%mcu%.hex:a

:::: avrdude terminal only
::avrdude -c usbtiny -p %mcu% -t

pause
:end