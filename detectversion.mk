ifneq (, $(filter 3.%, $(PLATFORM_VERSION)))
$(error Unsupported PLATFORM_VERSION = $(PLATFORM_VERSION))
endif
ifneq (, $(filter 4.2%, $(PLATFORM_VERSION)))
$(error Unsupported PLATFORM_VERSION = $(PLATFORM_VERSION))
endif
ifneq (, $(filter 4.3%, $(PLATFORM_VERSION)))
$(error Unsupported PLATFORM_VERSION = $(PLATFORM_VERSION))
endif

PLATFORM_IS_JELLYBEAN := 1
PLATFORM_IS_JELLYBEAN_MR1 := 1
PLATFORM_IS_JELLYBEAN_MR2 := 1
PLATFORM_IS_KITKAT := 1

ifeq (, $(filter 4.4%, $(PLATFORM_VERSION)))
PLATFORM_IS_NEXT := 1
endif
