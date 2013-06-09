#
# Copyright (C) 2011 The Android Open-Source Project
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
#

$(call inherit-product, device/softwinner/vortexc/full_vortexc.mk)

# Inherit some common CM10 stuff.
$(call inherit-product, vendor/cm/config/common_full_tablet_wifionly.mk)
$(call inherit-product, device/softwinner/vortexc/vortexc-blobs.mk)

## Device identifier. This must come after all inclusions
PRODUCT_NAME := cm_vortexc
PRODUCT_BRAND := Allwinner
PRODUCT_DEVICE := vortexc
PRODUCT_MODEL := vortexc
PRODUCT_MANUFACTURER := UNUSUAL
PRODUCT_RELEASE_NAME := vortexc
