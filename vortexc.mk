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

# Inherit overlay
DEVICE_PACKAGE_OVERLAYS := device/softwinner/vortexc/overlay

# Tablet configuration
PRODUCT_CHARACTERISTICS := tablet

PRODUCT_TAGS += dalvik.gc.type-precise

# Ramdisk
PRODUCT_COPY_FILES := \
	device/softwinner/vortexc/prebuilt/ramdisk/kernel:kernel \
	device/softwinner/vortexc/prebuilt/ramdisk/init.rc:root/init.rc \
	device/softwinner/vortexc/prebuilt/ramdisk/initlogo.rle:root/initlogo.rle \
	device/softwinner/vortexc/prebuilt/ramdisk/init.sun5i.rc:root/init.sun5i.rc \
	device/softwinner/vortexc/prebuilt/ramdisk/init.sun5i.usb.rc:root/init.sun5i.usb.rc \
	device/softwinner/vortexc/prebuilt/ramdisk/init.trace.rc:root/init.trace.rc \
	device/softwinner/vortexc/prebuilt/ramdisk/init.usb.rc:root/init.usb.rc \
	device/softwinner/vortexc/prebuilt/ramdisk/ueventd.sun5i.rc:root/ueventd.sun5i.rc \
	device/softwinner/vortexc/prebuilt/ramdisk/nand.ko:root/nand.ko


# Permissions
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/tablet_core_hardware.xml:system/etc/permissions/tablet_core_hardware.xml \
	frameworks/native/data/etc/android.hardware.camera.flash-autofocus.xml:system/etc/permissions/android.hardware.camera.flash-autofocus.xml \
	frameworks/native/data/etc/android.hardware.camera.front.xml:system/etc/permissions/android.hardware.camera.front.xml \
	frameworks/native/data/etc/android.hardware.telephony.gsm.xml:system/etc/permissions/android.hardware.telephony.gsm.xml \
	frameworks/native/data/etc/android.hardware.location.gps.xml:system/etc/permissions/android.hardware.location.gps.xml \
	frameworks/native/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
	frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:system/etc/permissions/android.hardware.sensor.accelerometer.xml \
	frameworks/native/data/etc/android.hardware.sensor.light.xml:system/etc/permissions/android.hardware.sensor.light.xml \
	frameworks/native/data/etc/android.hardware.sensor.proximity.xml:system/etc/permissions/android.hardware.sensor.proximity.xml \
	frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:system/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
	frameworks/native/data/etc/android.hardware.usb.host.xml:system/etc/permissions/android.hardware.usb.host.xml \
	frameworks/native/data/etc/android.hardware.usb.accessory.xml:system/etc/permissions/android.hardware.usb.accessory.xml \
	packages/wallpapers/LivePicker/android.software.live_wallpaper.xml:/system/etc/permissions/android.software.live_wallpaper.xml

# Live Wallapapers
PRODUCT_PACKAGES += \
	LiveWallpapers \
	LiveWallpapersPicker \
	MagicSmokeWallpapers \
	HoloSpiralWallpaper \
	VisualizationWallpapers

# Hardware libs
PRODUCT_PACKAGES += \
	gralloc.sun5i \
	hwcomposer.exDroid \
	lights.sun5i \
	display.sun5i \
        libcedarxbase \
        libcedarxosal \
	libcedarv \
	libcedarv_adapter \
        libcedarv_base \
	libCedarA \
	libCedarX \
	libstagefright_soft_cedar_h264dec \
        libswdrm \
	libaw_audio \
	libaw_audioa \
	libfacedetection \
	librtmp \
	libve \
	audio.primary.exDroid \
	audio.a2dp.default \
	audio.usb.default \
	libaudioutils \
	chat \
	u3gmonitor \
	devlistener \
	librs_jni

# EXT4 Support
PRODUCT_PACKAGES += \
	make_ext4fs \
	e2fsck

# CM9 apps
PRODUCT_PACKAGES += \
	com.android.future.usb.accessory
