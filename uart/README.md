# UART

This example uses the UART-USB bridge built into the expansion board programmer. Configure which sub-example you want by uncommenting the appropriate line in `Makefile`. You can change the UART baud rate there as well.

Then simply
```
make
make prog
```

You can use picocom to open the serial port, the exact location may be different
```
picocom /dev/ttyACM0
```
