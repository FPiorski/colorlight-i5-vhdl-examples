# UART

This example uses the UART-USB bridge built into the extension board programmer. Configure which sub-example you want by uncommenting the appropriate line in `Makefile`.

Then simply
```
make
make prog
```
`make prog` uses the programmer included on the extension board (the one with PMOD connectors and a USB-C port), which is pretty slow (almost 22s), I also included `make prog-blaster` in the Makefile because I had an external Altera USB Blaster clone lying around, with which I managed bring the upload time down to 4.5s. 

You can use picocom to open the serial port, the exact location may be different
```
picocom /dev/ttyACM0
```
