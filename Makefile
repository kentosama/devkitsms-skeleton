####################################
# Makefile for DevkitSMS
# Date: November 22, 2020
# Author: Jacques Belosoukinski <kentosama>
# Github: https://github.com/kentosama
###################################

# Recursive wildcard
rwildcard = $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))

# Fancy colors
GREEN:=$(shell tput setaf 2)
YELLOW:=$(shell tput setaf 3)
CLEAR:=$(shell tput setaf 7 && tput sgr0)
BOLD:=$(shell tput bold)

CPUS?= $(shell nproc)
MAKEFLAGS:= --jobs=$(CPUS)

LIB:=/opt/toolchains/sms/devkit
CC:=sdcc
CC_ARGS:=-c -mz80 --peep-file $(LIB)/peep-rules.txt
LD:=ihx2sms

SRC_DIR:=src
OUT_DIR:=out

PROGRAM:=$(SRC_DIR)/main.ihx

SRC:=$(wildcard $(SRC_DIR)/*.c)
SRC_EXTRA_C:= $(wildcard $(SRC_DIR)/**/*.c)
SRC+= $(SRC_EXTRA_C)

OBJ:=$(SRC:.c=.rel)
OBJS:=$(addprefix $(OUT_DIR)/, $(OBJ))

SRC_DIR_LIST:= $(addprefix -I ,$(sort $(dir $(call rwildcard,$(SRC_DIR),*))))
INC:=$(SRC_DIR_LIST) -I$(SRC_DIR) -I$(LIB)

BIN:=rom.sms
EMULATOR:=meka $(shell pwd)/out/$(BIN)

all: release

release: BUILDTYPE=release
release: prebuild $(OUT_DIR)/$(BIN) postbuild

run: release
	@cd /usr/local/games/meka && $(EMULATOR)

prebuild:
	@mkdir -p $(OUT_DIR)
	@mkdir -p $(OUT_DIR)/$(SRC_DIR)
	@echo -e $(info $(BOLD)$(YELLOW)-- Build $(BUILDTYPE) started$(CLEAR))

postbuild:
	@echo -e $(info $(BOLD)$(GREEN)-- Build finished!$(CLEAR))

.PHONY: clean

clean:
	@rm -R $(OUT_DIR)/*

$(OUT_DIR)/$(BIN): $(OBJS)
	$(CC) -o $(OUT_DIR)/$(PROGRAM) -mz80 --no-std-crt0 --data-loc 0xC000 $(LIB)/crt0_sms.rel $(OBJS) $(LIB)/SMSlib.lib
	$(LD) $(OUT_DIR)/$(PROGRAM) $(OUT_DIR)/${BIN}

$(OUT_DIR)/%.rel: %.c
	@mkdir -p $(@D)
	$(CC) $(CC_ARGS) $(INC) -o $@ $^