# Makefile for Y Ddraig bootloader
CPU := 68000
TARGET := bootload

# boards: ddraig68k, ddraig030 or soundcard
BOARD ?= ddraig68k

# Build directory
BUILD_DIR := build

LINKER_FILE ?= "./$(BOARD).ld"

ifeq ($(OS),Windows_NT)
    CROSSDIR ?= C:/dev/lang/m68k-ddraig-elf
else
    CROSSDIR ?= /opt/m68k-ddraig-elf
endif

# Output files
ELF         = $(BUILD_DIR)/$(TARGET).elf
BINARY      = $(BUILD_DIR)/$(TARGET).bin
SRECORD     = $(BUILD_DIR)/$(TARGET).s68
MAP         = $(BUILD_DIR)/$(TARGET).map
BINARY_EVEN = $(BUILD_DIR)/$(TARGET)_even.bin
BINARY_ODD  = $(BUILD_DIR)/$(TARGET)_odd.bin

# Toolchain
PREFIX := m68k-elf-
CC      = $(CROSSDIR)/bin/$(PREFIX)gcc
LD      = $(CROSSDIR)/bin/$(PREFIX)ld
OBJCOPY = $(CROSSDIR)/bin/$(PREFIX)objcopy
SIZE    = $(CROSSDIR)/bin/$(PREFIX)size
AS      = $(CROSSDIR)/bin/$(PREFIX)as

# Board-specific settings
ifeq ($(BOARD),ddraig68k)
    $(info Building for board: ddraig68k)
    CDEFS := -DDDRAIG68K
    CPU   := 68010
else ifeq ($(BOARD),ddraig030)
    $(info Building for board: ddraig030)
    CDEFS := -DDDRAIG030
    CPU   := 68030
else
    $(info Building for board: soundcard)
    CDEFS := -DSOUNDCARD
    CPU   := 68000
endif

ARCH ?= $(CPU)
TUNE ?= $(CPU)
EXTRA_CFLAGS ?=

CFLAGS = -std=c11 -nostartfiles -Wall -Wpedantic -Werror -nostdlib \
         -I. -mcpu=$(CPU) -march=$(ARCH) -mtune=$(TUNE) -O2 -g -MMD -MP \
         -mstrict-align -fomit-frame-pointer -ffreestanding \
         -Wa,--register-prefix-optional $(DEFINES) $(CDEFS)

LDFLAGS = -T $(LINKER_FILE) -Map=$(MAP) -print-memory-usage

GCC_VERSION = $(shell $(CC) -dumpversion)
LIBS = -L$(CROSSDIR)/lib/gcc/m68k-elf/$(GCC_VERSION) -lgcc

# GCC-version-specific settings
ifneq ($(findstring GCC,$(shell $(CC) --version 2>/dev/null)),)
    CC_VERSION := $(shell $(CC) -dumpfullversion)
    CC_MAJOR   := $(firstword $(subst ., ,$(CC_VERSION)))
    ifeq ($(filter 12 13 14,$(CC_MAJOR)),$(CC_MAJOR))
        CFLAGS += --param=min-pagesize=0
    endif
endif

SRCS := startup.c monitor.c interrupts.c srec.c

OBJS := $(SRCS:%.c=$(BUILD_DIR)/%.o)
DEPS := $(OBJS:.o=.d)

.PHONY: all clean roms size makedirs

# --- Build Targets ---
all: makedirs $(BINARY) $(SRECORD) size

makedirs:
ifeq ($(OS),Windows_NT)
	@if not exist $(BUILD_DIR) mkdir $(BUILD_DIR)
else
	@mkdir -p $(BUILD_DIR)
endif


$(ELF): $(OBJS)
	$(LD) $(LDFLAGS) $^ -o $@ $(LIBS)

$(BINARY): $(ELF)
	$(OBJCOPY) -O binary $< $@

$(SRECORD): $(ELF)
	$(OBJCOPY) -O srec $< $@

roms: all
	@echo "Generating even/odd split binaries..."
	$(OBJCOPY) -b 0 -i 2 --interleave-width=1 -I binary -O binary $(BINARY) $(BINARY_EVEN)
	$(OBJCOPY) -b 1 -i 2 --interleave-width=1 -I binary -O binary $(BINARY) $(BINARY_ODD)

size: $(ELF)
	@echo ""
	@$(SIZE) -Ax $(ELF)

# --- Compilation Rules ---
$(BUILD_DIR)/%.o: %.c
#	@mkdir -p $(dir $@)
	$(CC) -c $(CFLAGS) $(EXTRA_CFLAGS) -o $@ $<

$(BUILD_DIR)/%.o: %.S
	$(CC) -c $(CFLAGS) $(EXTRA_CFLAGS) -o $@ $<

# Include dependency files
-include $(DEPS)

# --- Clean Target ---
clean:
ifeq ($(OS),Windows_NT)
	@cmd /c if exist "$(BUILD_DIR)" rd /s /q "$(BUILD_DIR)"
else
	@rm -rf $(BUILD_DIR)
endif
