$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)
$(call inherit-product, frameworks/native/build/tablet-7in-hdpi-1024-dalvik-heap.mk)

PRODUCT_CHARACTERISTICS := tablet

PRODUCT_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay

include $(LOCAL_PATH)/product/*.mk

$(call inherit-product, vendor/asus/me176c/proprietary.mk)
