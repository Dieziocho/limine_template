#pragma once
#include <cstdint>

#define COM1_PORT 0x3F8
#define COM2_PORT 0x2F8

namespace EarlyCom {
  bool init(uint16_t port);

  char read(uint16_t port);
  void write(uint16_t port, char character);
}