#pragma once
#include <cstdint>

namespace IO {
  //Gets a byte from the specified port
  inline uint8_t byteIn(uint16_t port){
    uint8_t result;
    __asm__ __volatile__ ("in %%dx, %%al" : "=a" (result) : "d" (port));
    return result;
  }

  //Gets a word from the specified port
  inline uint16_t wordIn(uint16_t port){
    uint16_t result;
    __asm__ __volatile__ ("in %%dx, %%ax" : "=a" (result) : "d" (port));
    return result;
  }

  //Gets a double word from the specified port
  inline uint32_t dwordIn(uint16_t port){
    uint32_t result;
    __asm__ __volatile__ ("in %%dx, %%eax" : "=a" (result) : "d" (port));
    return result;
  }

  //Sends a byte to the specified port
  inline void byteOut(uint16_t port, uint8_t data){
    __asm__ __volatile__ ("out %%al, %%dx" : : "a" (data), "d" (port));
  }

  //Sends a word to the specified port
  inline void wordOut(uint16_t port, uint16_t data){
    __asm__ __volatile__ ("out %%ax, %%dx" : : "a" (data), "d" (port));
  }

  //Sends a double word to the specified port
  inline void dwordOut(uint16_t port, uint32_t data){
    __asm__ __volatile__ ("out %%eax, %%dx" : : "a" (data), "d" (port));
  }

  //Reads count bytes from port into buffer
  inline void byteStringIn(uint16_t port, void* buffer, uint32_t count){
    __asm__ __volatile__ (
      "rep insb"
      : "+D" (buffer), "+c" (count)
      : "d" (port)
      : "memory");
  }

  //Reads count words from port into buffer
  inline void wordStringIn(uint16_t port, void* buffer, uint32_t count){
    __asm__ __volatile__ (
      "rep insw"
      : "+D" (buffer), "+c" (count)
      : "d" (port)
      : "memory");
  }

  //Writes count bytes from buffer into port
  inline void byteStringOut(uint16_t port, const void* buffer, uint32_t count){
    __asm__ __volatile__ (
      "rep outsb"
      : "+S" (buffer), "+c" (count)
      : "d" (port));
  }

  //Writes count words from buffer into port
  inline void wordStringOut(uint16_t port, const void* buffer, uint32_t count){
    __asm__ __volatile__ (
      "rep outsw"
      : "+S" (buffer), "+c" (count)
      : "d" (port));
  }
}