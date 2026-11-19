#include "early_com.h"
#include "port_io.h"

#define RECEIVE_BUFFER 0
#define TRANSMIT_BUFFER 0
#define LOW_DIVISOR 0
#define HIGH_DIVISOR 1
#define INTERRUPT_ENABLE 1
#define INTERRUPT_IDENTIFY 2
#define FIFO_CONTROL 2
#define LINE_CONTROL 3
#define MODEM_CONTROL 4
#define LINE_STATUS 5
#define MODEM_STATUS 6
#define SCRATCH_REGISTER 7


namespace EarlyCom {
  bool init(uint16_t port){
    IO::byteOut(port + INTERRUPT_ENABLE, 0x00);  //Disable all interrupts
    IO::byteOut(port + LINE_CONTROL,     0x80);  //Enable DLAB (set baud rate divisor)
    IO::byteOut(port + LOW_DIVISOR,      0x01);  //Set divisor to 12 (lo byte) 115200 baud
    IO::byteOut(port + HIGH_DIVISOR,     0x00);  //                  (hi byte)
    IO::byteOut(port + LINE_CONTROL,     0x03);  //8 bits, no parity, one stop bit
    IO::byteOut(port + FIFO_CONTROL,     0x07);  //Enable FIFO, clear buffers, set 1-byte threshold
    IO::byteOut(port + MODEM_CONTROL,    0x0B);  //IRQs enabled, RTS/DSR set
    IO::byteOut(port + MODEM_CONTROL,    0x1E);  //Set in loopback mode, test the serial chip

    IO::byteOut(port + 0, 0xAE);        //Test serial chip (send byte 0xAE and check if serial returns same byte)
    for(uint32_t i = 0; i < 0x1000000; ++i) ;
    if(IO::byteIn(port) != 0xAE) return false;

    IO::byteOut(port + MODEM_CONTROL, 0x0F);
    return true;
  }

  bool serialReceived(uint16_t port){
    return IO::byteIn(port + LINE_STATUS) & 1;
  }

  bool isTransmitEmpty(uint16_t port){
    return IO::byteIn(port + LINE_STATUS) & 0x20;
  }

  char read(uint16_t port){
    while(!serialReceived(port)) ;
    return IO::byteIn(port);
  }

  void write(uint16_t port, char character){
    while(!isTransmitEmpty(port)) ;
    IO::byteOut(port, character);
  }
}