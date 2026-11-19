#Include directory flag
GPP_INCLUDE := -I $(INCLUDE_DIR) -I $(INCLUDE_DIR)/common

#Collection of all source files
ASM_FILES := $(shell find $(SOURCE_DIR) -name "*.asm")
CPP_FILES := $(shell find $(SOURCE_DIR) -name "*.cpp")
#All source .o files
OBJ_FILES := $(ASM_FILES:$(SOURCE_DIR)/%.asm=$(BUILD_DIR)/%_ASM.o) \
			 $(CPP_FILES:$(SOURCE_DIR)/%.cpp=$(BUILD_DIR)/%_CPP.o)

#Include .d files to rebuild on header change
DEP_FILES = $(OBJ_FILES:.o=.d)
-include $(DEP_FILES)

#Kernel elf file
$(KERNEL): $(OBJ_FILES) linker.ld
	@mkdir -p $(dir $@)
	ld -o $@ $(OBJ_FILES) -T linker.ld
	@echo

#Generic for compiling asm files
$(BUILD_DIR)/%_ASM.o: $(SOURCE_DIR)/%.asm
	@mkdir -p $(dir $@)
	nasm -o $@ $< $(NASM_FLAGS)

#Generic for compiling cpp files
$(BUILD_DIR)/%_CPP.o: $(SOURCE_DIR)/%.cpp
	@mkdir -p $(dir $@)
	gcc -o $@ $< $(GPP_FLAGS) $(GPP_INCLUDE)
