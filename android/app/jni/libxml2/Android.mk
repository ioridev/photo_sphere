ifeq ($(ANDROID_BUILD_TOP),)

LOCAL_PATH:= $(call my-dir)

common_SRC_FILES := \
	SAX.c \
	entities.c \
	encoding.c \
	buf.c \
	error.c \
	parserInternals.c \
	parser.c \
	tree.c \
	hash.c \
	list.c \
	xmlIO.c \
	xmlmemory.c \
	uri.c \
	valid.c \
	xlink.c \
	HTMLparser.c \
	HTMLtree.c \
	debugXML.c \
	xpath.c \
	xpointer.c \
	xinclude.c \
	nanohttp.c \
	nanoftp.c \
	DOCBparser.c \
	catalog.c \
	globals.c \
	threads.c \
	c14n.c \
	xmlstring.c \
	xmlregexp.c \
	xmlschemas.c \
	xmlschemastypes.c \
	xmlunicode.c \
	xmlreader.c \
	relaxng.c \
	dict.c \
	SAX2.c \
	legacy.c \
	chvalid.c \
	pattern.c \
	xmlsave.c \
	xmlmodule.c \
	xmlwriter.c \
	schematron.c

common_C_INCLUDES += \
	$(LOCAL_PATH)/../libiconv \
	$(LOCAL_PATH)/include \
	$(LOCAL_PATH)/../libiconv/include

include $(CLEAR_VARS)

LOCAL_SRC_FILES := $(common_SRC_FILES)

LOCAL_C_INCLUDES += $(common_C_INCLUDES) external/icu4c/common
LOCAL_SHARED_LIBRARIES += $(common_SHARED_LIBRARIES)
LOCAL_CFLAGS += -fvisibility=hidden
LOCAL_ARM_MODE := arm

LOCAL_MODULE:= libxml2

include $(BUILD_STATIC_LIBRARY)

endif
