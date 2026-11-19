#Core project directories
SOURCE_DIR := source
BUILD_DIR := build
TARGET_DIR := target

#Kernel sources paths
INCLUDE_DIR := $(SOURCE_DIR)/include

#Limine stuff
LIMINE_CONF := limine/limine.conf
LIMINE_BINARY := limine/limine-binary

#Target file names
KERNEL := target/kernel.elf
BOOT_DRIVE := target/drive_image

#Main recipes
.PHONY: all build debug run-qemu run-qemu-debug run-gdb clear close-qemu flash
all: build run-qemu
build: $(KERNEL) copy-files
debug: build run-qemu-debug run-gdb

#Runs qemu normally
run-qemu: $(BOOT_DRIVE)
	-qemu-system-x86_64 $(QEMU_FLAGS) -no-reboot -serial stdio
	@echo

#Runs qemu and waits for gdb attach
run-qemu-debug: $(BOOT_DRIVE)
	qemu-system-x86_64 $(QEMU_FLAGS) -s -S -daemonize

#Runs gdb with kernel.elf symbols
run-gdb: $(KERNEL)
	-gdb -q -ex "target remote localhost:1234" $< && $(MAKE) close-qemu

listen-remote: $(REMOTE_TARGET)
	@sudo stty -F $(REMOTE_TARGET) 115200
	@sudo cat $(REMOTE_TARGET)

debug-remote: $(KERNEL) $(REMOTE_TARGET)
	@sudo stty -F $(REMOTE_TARGET) 115200
	-sudo gdb -q -iex "file $<" -iex "target remote $(REMOTE_TARGET)" && $(MAKE) close-qemu

get-address_line: $(KERNEL)
	@objdump --dwarf=decodedline $< | fzf

#Deletes everything that this makefile has built
clear:
	@rm -rf $(BOOT_PARTITION)
	@rm -rf $(BOOT_DRIVE)
	@rm -rf $(BUILD_DIR) $(TARGET_DIR)
	@rm -rf *.map
	@rm -rf *.log

close-qemu:
	@-pkill -f "qemu-system-x86_64.*$(BOOT_DRIVE)"

#Flashes to a external drive
flash: $(FLASH_TARGET) $(BOOT_DRIVE) copy-files
	@echo "Flash target $<"
	@sudo echo "Flashing drive" #Uses sudo to get a nicer terminal output, asking for password beforehand
	@sudo dd if=$(BOOT_DRIVE) of=$(FLASH_TARGET) status=progress
	@sync

#Builds the drive image, partition table, installs limine-bios and formats as fat32
$(BOOT_DRIVE):
	@mkdir -p $(dir $@)

	@echo -e "Creating boot drive image"
	@dd if=/dev/zero of=$@ bs=512 count=2048 status=none
	@dd if=/dev/zero of=$@ bs=1M count=$(PARTITION_SIZE) oflag=append conv=notrunc status=progress

	@echo -e "\nWriting partition table"
	sgdisk $@ -n 1:2048:0 -t 1:ef00 -c 1:"EFI System Partition" -U R -m 1 >/dev/null 2>&1
	
	@echo -e "\nInstalling limine BIOS stage"
	$(LIMINE_BINARY)/limine bios-install $@ >/dev/null 2>&1

	@echo -e "\nFormating partition"
	mkfs.vfat -F 32 --offset=2048 $@
	@echo

#Copies all needed files into the efi boot partition
copy-files: .copy-files
.copy-files: $(KERNEL) $(LIMINE_CONF) $(BOOT_DRIVE)
	@#Build required directories
	@mmd -D s -i $(BOOT_DRIVE)@@1M ::/EFI ::/EFI/BOOT ::/boot ::/boot/$(KERNEL_NAME) ::/boot/limine >/dev/null 2>&1 || true

	@#Copy files
	@echo -e "Copying files"
	mcopy -D o -i $(BOOT_DRIVE)@@1M $(KERNEL) ::/boot/$(KERNEL_NAME)
	mcopy -D o -i $(BOOT_DRIVE)@@1M $(LIMINE_CONF) $(LIMINE_BINARY)/limine-bios.sys ::/boot/limine
	mcopy -D o -i $(BOOT_DRIVE)@@1M $(LIMINE_BINARY)/BOOTX64.EFI ::/EFI/BOOT

	@touch $@
	@echo

include kernel.mk
include config.mk
