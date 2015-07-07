#
# Nvidia specific targets
#

.PHONY: dev nv-blob sim-image list-non-nv-modules

dev: droidcore u-boot target-files-package
ifeq ($(BOARD_SUPPORT_SIMULATION),true)
	device/nvidia/common/generate_nvtest_ramdisk.sh $(TARGET_DEVICE)
	device/nvidia/common/generate_full_filesystem.sh $(TARGET_DEVICE)
	device/nvidia/common/generate_asim_bootimg.sh $(TARGET_DEVICE)
	device/nvidia/common/generate_qt_ramdisk.sh $(TARGET_DEVICE)
	$(BOOT_WRAPPER_CMD)
endif

#
# bootloader blob target and macros
#

# macro: checks file existence and returns list of existing file
# $(1) list of file paths
define _dynamic_blob_dependencies
$(foreach f,$(1), $(eval \
 ifneq ($(wildcard $(f)),)
  _dep += $(f)
 endif))\
 $(_dep)
 $(eval _dep :=)
endef

# macro: construct command line for nvblob based on type of input file
# $(1) list of file paths
define _blob_command_line
$(foreach f,$(1), $(eval \
 ifneq ($(filter %microboot.bin,$(f)),)
  _cmd += $(f) NVC 1
  _cmd += $(f) RMB 1
 else ifneq ($(filter %nvtboot.bin,$(f)),)
  _cmd += $(f) NVC 1
 else ifneq ($(filter %bootloader.bin,$(f)),)
  _cmd += $(f) EBT 1
  _cmd += $(f) RBL 1
 else ifneq ($(filter %cboot.bin,$(f)),)
  _cmd += $(f) EBT 1
  _cmd += $(f) RBL 1
 else ifneq ($(filter %.dtb,$(f)),)
  _cmd += $(f) DTB 1
 else ifneq ($(filter %.bct,$(f)),)
  _cmd += $(f) BCT 1
 else ifneq ($(filter %bootsplash.bmp,$(f)),)
  _cmd += $(f) BMP 1
 else ifneq ($(filter %nvidia.bmp,$(f)),)
  _cmd += $(f) BMP 1
 else ifneq ($(filter %charged.bmp,$(f)),)
  _cmd += $(f) FBP 1
 else ifneq ($(filter %charging.bmp,$(f)),)
  _cmd += $(f) CHG 1
 else ifneq ($(filter %fullycharged.bmp,$(f)),)
  _cmd += $(f) FCG 1
 else ifneq ($(filter %lowbat.bmp,$(f)),)
  _cmd += $(f) LBP 1
 else ifneq ($(filter %mts_si,$(f)),)
  _cmd += $(f) MBP 1
  _cmd += $(f) RBP 1
 else ifneq ($(filter %mts_prod,$(f)),)
  _cmd += $(f) MBP 1
  _cmd += $(f) RBP 1
 else ifneq ($(filter %mts_slow_stable_prod,$(f)),)
  _cmd += $(f) MBP 1
  _cmd += $(f) RBP 1
 else ifneq ($(filter %mts_preboot_si,$(f)),)
  _cmd += $(f) MPB 1
  _cmd += $(f) RPB 1
 else ifneq ($(filter %mts_preboot_prod,$(f)),)
  _cmd += $(f) MPB 1
  _cmd += $(f) RPB 1
 else ifneq ($(filter %mts_preboot_slow_stable_prod,$(f)),)
  _cmd += $(f) MPB 1
  _cmd += $(f) RPB 1
 else ifneq ($(filter %xusb_sil_rel_fw,$(f)),)
  _cmd += $(f) DFI 1
 else ifneq ($(filter %tos.img,$(f)),)
  _cmd += $(f) TOS 1
 else ifneq ($(filter %nvtbootwb0.bin,$(f)),)
  _cmd += $(f) WB0 1
 else ifneq ($(filter %bootsplash_land.bmp,$(f)),)
  _cmd += $(f) RP4 1
 endif))\
 $(_cmd)
 $(eval _cmd :=)
endef

# These are additional files for which we generate blobs only if they exists
_blob_deps := \
      $(HOST_OUT_EXECUTABLES)/nvsignblob \
      $(PRODUCT_OUT)/microboot.bin \
      $(wildcard $(PRODUCT_OUT)/$(TARGET_KERNEL_DT_NAME)*.dtb) \
      $(wildcard $(PRODUCT_OUT)/*.bmp) \
      $(PRODUCT_OUT)/flash.bct \
      $(PRODUCT_OUT)/nvtboot.bin \
      $(PRODUCT_OUT)/bootloader.bin \
      $(PRODUCT_OUT)/cboot.bin \
      $(wildcard $(PRODUCT_OUT)/mts_*) \
      $(PRODUCT_OUT)/xusb_sil_rel_fw \
      $(PRODUCT_OUT)/tos.img \
      $(PRODUCT_OUT)/nvtbootwb0.bin

# target to generate blob
nv-blob: \
      $(HOST_OUT_EXECUTABLES)/nvblob \
      $(TOP)/device/nvidia/common/security/signkey.pk8 \
      $(call _dynamic_blob_dependencies, $(_blob_deps))
	$(hide) python $(filter %nvblob,$^) \
		 $(call _blob_command_line, $^)

#
# Generate ramdisk images for simulation
#
sim-image:
	device/nvidia/common/copy_simtools.sh
	device/nvidia/common/generate_full_filesystem.sh $(TARGET_DEVICE)
	@echo "Generating sdmmc image w/ full filesystem ..."
	device/nvidia/common/sdmmc_util.sh \
	    -s 2048 -z \
	    -o $(PRODUCT_OUT)/sdmmc_full_fs.img \
	    -c device/nvidia/common/sdmmc_full_fs.cfg
	$(BOOT_WRAPPER_CMD)

# This macro lists all modules filtering those which
# 1. Are in a path which contains 'nvidia'
# 2. Have dependencies which are in a path which contains 'nvidia'
# TODO: This doesn't work well if a dependency have same name but different
# class. Eg. libexpat which is defined in multiple makefiles as host shared
# lib, shared lib and static lib
define list_nv_independent_modules
$(foreach _m,$(call module-names-for-tag-list,$(ALL_MODULE_TAGS)), \
    $(if $(findstring nvidia,$(ALL_MODULES.$(_m).PATH)), \
        $(info Skipping $(_m) location : $(ALL_MODULES.$(_m).PATH)), \
        $(if $(strip $(ALL_MODULES.$(_m).REQUIRED)), \
	    $(foreach _d,$(ALL_MODULES.$(_m).REQUIRED), \
	        $(if $(findstring nvidia,$(ALL_MODULES.$(_d).PATH)), \
	            $(info Skipping $(_m) location : $(ALL_MODULES.$(_m).PATH) dependency : $(_d) dependency location : $(ALL_MODULES.$(_d).PATH)), \
	            $(_m) \
	        ) \
	    ), \
	    $(_m) \
        ) \
    ) \
)
endef

# List all nvidia independent modules as well as modules skipped with reason
list-non-nv-modules:
	@echo "Nvidia independent modules analysis:"
	@for m in $(call list_nv_independent_modules); do echo $$m; done | sort -u

# Clear local variable
_blob_deps :=
