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

LIB_DIR:=/opt/toolchains/sms/devkit/lib
SMSLIB_DIR:= $(LIB_DIR)/SMSlib
SMSLIB:=$(SMSLIB_DIR)/SMSlib.lib
PSGLIB_DIR:=$(LIB_DIR)/PSGlib
PSGLIB:=$(PSGLIB_DIR)/PSGlib.rel
CC:=sdcc
CC_ARGS:=-c -mz80 --peep-file $(SMSLIB_DIR)/peep-rules.txt
LD:=ihx2sms

SRC_DIR:=src
INC_DIR:=inc
RES_DIR:=res
OUT_DIR:=out


PROGRAM:=$(SRC_DIR)/main.ihx

SRC:=$(wildcard $(SRC_DIR)/*.c)
SRC_EXTRA_C:= $(wildcard $(SRC_DIR)/**/*.c)
SRC+= $(SRC_EXTRA_C)

# Ressources
SRC+=$(wildcard $(RES_DIR)/*.c)

OBJ:=$(SRC:.c=.rel)
OBJS:=$(addprefix $(OUT_DIR)/, $(OBJ))

SRC_DIR_LIST:= $(addprefix -I ,$(sort $(dir $(call rwildcard,$(SRC_DIR),*))))
INC:=$(SRC_DIR_LIST) -I$(SRC_DIR) -I$(RES_DIR) -I$(INC_DIR) -I$(PSGLIB_DIR) -I$(SMSLIB_DIR)

BIN:=rom.sms
EMULATOR_DIR:=/usr/local/games/meka
EMULATOR:=meka $(shell pwd)/out/$(BIN)

all: release

release: BUILDTYPE=release
release: prebuild $(OUT_DIR)/$(BIN) postbuild

run: release
	@cd $(EMULATOR_DIR) && $(EMULATOR)

prebuild:
	@mkdir -p $(OUT_DIR)
	@echo -e "$(info $(BOLD)$(YELLOW)-- Build $(BUILDTYPE) started$(CLEAR))"

postbuild:
	@echo -e "$(BOLD)$(GREEN)-- Build finished!$(CLEAR)"

.PHONY: clean

clean:
	@rm -R $(OUT_DIR)/*

$(OUT_DIR)/$(BIN): $(OBJS)
	$(CC) -o $(OUT_DIR)/$(PROGRAM) -mz80 --no-std-crt0 --data-loc 0xC000 $(SMSLIB_DIR)/crt0_sms.rel $(OBJS) $(PSGLIB) $(SMSLIB)
	$(LD) $(OUT_DIR)/$(PROGRAM) $(OUT_DIR)/${BIN}

$(OUT_DIR)/%.rel: %.c
	@mkdir -p $(@D)
	$(CC) $(CC_ARGS) -o $@ $^