#include "log.h"
#include "early_com.h"

namespace Log {
  void init(){
    EarlyCom::init(COM1_PORT);
  }

  void write(const char* string){
    do{
      EarlyCom::write(COM1_PORT, *string);
    }while(++string);
  }
}