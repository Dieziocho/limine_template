#include "log.h"

int main(){
  Log::init();

  Log::write("Hello, world!");

  return 0;
}