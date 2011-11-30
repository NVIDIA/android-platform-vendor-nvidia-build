
# Grab name of the makefile to depend on it
ifneq ($(PREV_LOCAL_PATH),$(LOCAL_PATH))
NVIDIA_MAKEFILE := $(lastword $(filter-out $(lastword $(MAKEFILE_LIST)),$(MAKEFILE_LIST)))
PREV_LOCAL_PATH := $(LOCAL_PATH)
endif
include $(CLEAR_VARS)

# Build variables common to all nvidia modules

LOCAL_C_INCLUDES += $(TEGRA_TOP)/core/include
LOCAL_C_INCLUDES += $(TEGRA_TOP)/core/drivers/hwinc

ifneq (,$(findstring core-private,$(LOCAL_PATH)))
LOCAL_C_INCLUDES += $(TEGRA_TOP)/core-private/include
LOCAL_C_INCLUDES += $(TEGRA_TOP)/core-private/drivers/hwinc
LOCAL_C_INCLUDES += $(TEGRA_TOP)/core-private/drivers/hwinc/$(TARGET_TEGRA_FAMILY)
endif

ifneq (,$(findstring tests,$(LOCAL_PATH)))
LOCAL_C_INCLUDES += $(TEGRA_TOP)/core-private/include
endif

-include $(NVIDIA_UBM_DEFAULTS)

TEGRA_CFLAGS :=

ifeq ($(TARGET_BUILD_TYPE),debug)
LOCAL_CFLAGS += -DNV_DEBUG=1
# TODO: fix source that relies on these
LOCAL_CFLAGS += -DDEBUG
LOCAL_CFLAGS += -D_DEBUG
# disable all optimizations and enable gdb debugging extensions
LOCAL_CFLAGS += -O0 -ggdb
else
LOCAL_CFLAGS += -DNV_DEBUG=0
endif
LOCAL_CFLAGS += -DNV_IS_AVP=0
LOCAL_CFLAGS += -DNV_BUILD_STUBS=1
ifneq ($(filter ap20,$(TARGET_TEGRA_VERSION)),)
TEGRA_CFLAGS += -DCONFIG_PLLP_BASE_AS_408MHZ=0
else
TEGRA_CFLAGS += -DCONFIG_PLLP_BASE_AS_408MHZ=1
endif


ifeq ($(PLATFORM_IS_GINGERBREAD),YES)
TEGRA_CFLAGS += -DPLATFORM_IS_GINGERBREAD=1
else ifeq ($(PLATFORM_IS_HONEYCOMB),YES)
TEGRA_CFLAGS += -DPLATFORM_IS_HONEYCOMB=1
endif

# Define Trusted Foundations
ifeq ($(SECURE_OS_BUILD),y)
TEGRA_CFLAGS += -DCONFIG_TRUSTED_FOUNDATIONS
ifeq (,$(findstring tf.enable=y,$(ADDITIONAL_BUILD_PROPERTIES)))
ADDITIONAL_BUILD_PROPERTIES += tf.enable=y
endif
endif

ifdef PLATFORM_IS_ICECREAMSANDWICH
LOCAL_CFLAGS += -DPLATFORM_IS_ICECREAMSANDWICH=1
endif

LOCAL_CFLAGS += $(TEGRA_CFLAGS)

LOCAL_PRELINK_MODULE := false

LOCAL_MODULE_TAGS := optional

# clear nvidia local variables to defaults
NVIDIA_CLEARED := true
LOCAL_IDL_INCLUDES := $(TEGRA_TOP)/core/include
LOCAL_IDLFLAGS :=
LOCAL_NVIDIA_CGOPTS :=
LOCAL_NVIDIA_INTERMEDIATES_DIR :=
LOCAL_NVIDIA_STUBS :=
LOCAL_NVIDIA_DISPATCHERS :=
LOCAL_NVIDIA_SHADERS :=
LOCAL_NVIDIA_GEN_SHADERS :=
LOCAL_NVIDIA_PKG :=
LOCAL_NVIDIA_PKG_DISPATCHER :=
LOCAL_NVIDIA_EXPORTS :=
LOCAL_NVIDIA_NO_COVERAGE :=
LOCAL_NVIDIA_NULL_COVERAGE :=
LOCAL_NVIDIA_NO_EXTRA_WARNINGS :=
LOCAL_NVIDIA_NO_WARNINGS_AS_ERRORS :=
LOCAL_NVIDIA_RM_WARNING_FLAGS :=
