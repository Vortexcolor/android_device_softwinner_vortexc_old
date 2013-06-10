# Copyright (C) 2012 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Inherit from those products. Most specific first.
$(call inherit-product, build/target/product/full_base.mk)
$(call inherit-product, device/softwinner/vortexc/vortexc.mk)
$(call inherit-product, device/softwinner/vortexc/libraries/Android.mk)
$(call inherit-product, device/softwinner/vortexc/packages/Android.mk)
$(call inherit-product, frameworks/native/build/tablet-dalvik-heap.mk)
$(call inherit-product, vendor/cm/config/gsm.mk)
$(call inherit-product-if-exists, vendor/softwinner/vortexc/vortexc-vendor.mk)

# Set those variables here to overwrite the inherited values.
PRODUCT_NAME := full_vortexc
PRODUCT_DEVICE := vortexc
PRODUCT_BRAND := Allwinner
PRODUCT_MODEL := MPvortexcC
PRODUCT_MANUFACTURER := Allwinner

# MDPI / HDPI images
PRODUCT_AAPT_CONFIG := hdpi mdpi
PRODUCT_AAPT_PREF_CONFIG := mdpi

# Screen layout
TARGET_SCREEN_HEIGHT := 800
TARGET_SCREEN_WIDTH := 480
