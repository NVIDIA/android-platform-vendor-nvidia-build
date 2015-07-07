#
# Makefile for U-boot
#

ifeq ($(TARGET_UBOOT_BUILD), true)

# Android build is started from the $TOP/Makefile, therefore $(CURDIR)
# gives the absolute path to the TOP.
UBOOT_SRC ?= $(CURDIR)/3rdparty/u-boot

# Always use absolute path for NV_UBOOT_INTERMEDIATES_DIR
ifneq ($(filter /%, $(TARGET_OUT_INTERMEDIATES)),)
NV_UBOOT_INTERMEDIATES_DIR := $(TARGET_OUT_INTERMEDIATES)/UBOOT
else
NV_UBOOT_INTERMEDIATES_DIR := $(CURDIR)/$(TARGET_OUT_INTERMEDIATES)/UBOOT
endif

UBOOT_CONFIG ?= jetson-tk1_defconfig

ifeq ($(wildcard $(UBOOT_SRC)/configs/$(UBOOT_CONFIG)),)
    $(error Could not find u-boot defconfig for board)
endif

PRIVATE_UBOOT_TOOLCHAIN = $(ARM_EABI_TOOLCHAIN)/arm-eabi-

u-boot:
	@echo "==========Uboot build=========="
	$(MAKE) -C $(UBOOT_SRC) ARCH=arm O=$(NV_UBOOT_INTERMEDIATES_DIR) CROSS_COMPILE=$(PRIVATE_UBOOT_TOOLCHAIN) $(UBOOT_CONFIG) && \
	$(MAKE) -C $(UBOOT_SRC) ARCH=arm O=$(NV_UBOOT_INTERMEDIATES_DIR) CROSS_COMPILE=$(PRIVATE_UBOOT_TOOLCHAIN)
	cp $(NV_UBOOT_INTERMEDIATES_DIR)/u-boot-dtb-tegra.bin $(PRODUCT_OUT)/u-boot.bin

.PHONY: u-boot
else
u-boot:
	@echo "Please enable TARGET_UBOOT_BUILD for u-boot if needed"
.PHONY: u-boot
endif
