
#Compiler flags
NASM_FLAGS := -Ox -f elf64 -g
GPP_FLAGS := -g -c -fno-pic -O0 \
			-Wall -Wextra -pedantic -Wno-psabi \
			-Wno-missing-field-initializers \
			-nostartfiles -std=c++23 \
			-ffunction-sections \
			-fdata-sections \
			-ffreestanding \
			-fno-omit-frame-pointer \
			-fno-use-cxa-atexit \
			-fno-exceptions \
			-fno-rtti \
			-fno-lto \
			-fno-pic \
			-mcmodel=kernel \
			-march=x86-64 \
			-mabi=sysv \
			-mpopcnt \
			-mno-red-zone \
		    -mno-sse2 \
		    -mno-sse \
		    -mno-mmx \
			-MMD -MP

KERNEL_NAME := my_os

#Drive parameters
PARTITION_SIZE := 64
DRIVE_UUID := "QEMU boot drive"
PART_UUID := "EFI System Partition"

#Machine related configs
QEMU_SETUP :=  -cpu qemu64,+popcnt -bios bios/OVMF.fd -m 2G -smp 4
#Drive declarations
QEMU_DRIVES := -drive file=$(BOOT_DRIVE),if=ide,format=raw

REMOTE_TARGET := /dev/ttyUSB0
QEMU_FLAGS := $(QEMU_SETUP) $(QEMU_DRIVES) -msg timestamp=on -d int,guest_errors,cpu_reset -D qemu.log # -serial pty -serial pty
