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

<<<<<<< HEAD
=======
PRODUCT_CHARACTERISTICS := tablet

PRODUCT_TAGS += dalvik.gc.type-precise

PRODUCT_PROPERTY_OVERRIDES += \
	ro.opengles.version = 131072 \
	debug.egl.hw=1 \
	ro.display.switch=1 \
	ro.sf.lcd_density=120 \
	hwui.render_dirty_regions=false \
	wifi.interface = wlan0 \
	wifi.supplicant_scan_interval = 150 \
	persist.sys.strictmode.visual=0 \
	persist.sys.strictmode.disable=1 \
	persist.sys.usb.config=mass_storage,adb \
	dalvik.vm.verify-bytecode=false \
	dalvik.vm.dexopt-flags=v=n,o=v \
	dalvik.vm.execution-mode=int:jit \
	persist.sys.timezone=Europe/Rome \
	persist.sys.language=es \
	persist.sys.country=ES \
	ro.com.google.locationfeatures=1 \
	dalvik.vm.lockprof.threshold=500 \
	ro.kernel.android.checkjni=0 \
	dalvik.vm.checkjni=false \
	dalvik.vm.dexopt-data-only=1 \
	ro.vold.umsdirtyratio=20 \
	persist.sys.use_dithering=0 \
	persist.sys.purgeable_assets=0 \
	windowsmgr.max_events_per_sec=240 \
	view.touch_slop=2 \
	view.minimum_fling_velocity=25 \
	ro.additionalmounts=/storage/sdcard1 \
	ro.vold.switchablepair=/storage/sdcard0,/storage/sdcard1 \
	persist.sys.vold.switchexternal=0 \
	ro.disable_phablet_ui=1

DEVICE_PACKAGE_OVERLAYS := device/softwinner/vortexc/overlay

>>>>>>> 6cb79b76db4cfdbf62aa0484915036e393640257
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
