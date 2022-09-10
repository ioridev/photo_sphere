LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
	gthread-impl.c

LOCAL_MODULE := libgthread-2.0

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH) \
	$(GLIB_TOP)/android-internal \
	$(GLIB_C_INCLUDES)

LOCAL_CFLAGS := \
	-DHAVE_CONFIG_H \
	-DG_LOG_DOMAIN=\"GThread\" \
	-D_POSIX4_DRAFT_SOURCE \
	-D_POSIX4A_DRAFT10_SOURCE \
	-U_OSF_SOURCE \
	-DG_DISABLE_DEPRECATED

LOCAL_NDK_STL_VARIANT := gnustl_static
LOCAL_ARM_MODE := arm

ifeq ($(GLIB_BUILD_STATIC),true)
-include external/Focal/gnustl.mk
include $(BUILD_STATIC_LIBRARY)
else
LOCAL_SHARED_LIBRARIES := libglib-2.0
-include external/Focal/gnustl.mk
include $(BUILD_SHARED_LIBRARY)
endif
