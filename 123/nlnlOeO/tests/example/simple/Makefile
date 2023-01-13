RISCV_ARCH := rv32im
RISCV_ABI := ilp32
RISCV_MCMODEL := medlow


TARGET = C_test


CFLAGS += -DSIMULATION
CFLAGS += -Os
#ASM_SRCS +=
#LDFLAGS +=
#INCLUDES += -I.

C_SRCS := \
	C_test.c \


COMMON_DIR = ..
TOOLCHAIN_DIR = ../../..
include ../common.mk
