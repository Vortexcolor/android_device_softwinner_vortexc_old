/*
 * Copyright (C) 2011 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 * Contains implementation of an abstract class V4L2Camera that defines
 * functionality expected from an emulated physical camera device:
 *  - Obtaining and setting camera parameters
 *  - Capturing frames
 *  - Streaming video
 *  - etc.
 */
#define LOG_TAG "V4L2Camera"
#include "CameraDebug.h"

#include <sys/select.h>
#include "V4L2Camera.h"
#include "Converters.h"

namespace android {

V4L2Camera::V4L2Camera(CameraHardware* camera_hal)
    : mObjectLock(),
      mCurFrameTimestamp(0),
      mCameraHAL(camera_hal),
      mCurrentFrame(NULL),
      mState(ECDS_CONSTRUCTED),
      mTakingPicture(false),
      mInPictureThread(false),
      mThreadRunning(false)
{
	F_LOG;
	
	pthread_mutex_init(&mMutexTakePhotoEnd, NULL);
	pthread_cond_init(&mCondTakePhotoEnd, NULL);
	
	pthread_mutex_init(&mMutexThreadRunning, NULL);
	pthread_cond_init(&mCondThreadRunning, NULL);
}

V4L2Camera::~V4L2Camera()
{
	F_LOG;

    if (mCurrentFrame != NULL) {
        delete[] mCurrentFrame;
    }
}

/****************************************************************************
 * V4L2Camera device public API
 ***************************************************************************/

status_t V4L2Camera::Initialize()
{
	F_LOG;
    if (isInitialized()) {
        ALOGW("%s: V4L2Camera device is already initialized: mState = %d",
             __FUNCTION__, mState);
        return NO_ERROR;
    }

    /* Instantiate worker thread object. */
    mWorkerThread = new WorkerThread(this);
    if (getWorkerThread() == NULL) {
        ALOGE("%s: Unable to instantiate worker thread object", __FUNCTION__);
        return ENOMEM;
    }

    mState = ECDS_INITIALIZED;

    return NO_ERROR;
}

status_t V4L2Camera::startDeliveringFrames(bool one_burst)
{
    ALOGV("%s", __FUNCTION__);

	mThreadRunning = false;

    if (!isStarted()) {
        ALOGE("%s: Device is not started", __FUNCTION__);
        return EINVAL;
    }

    /* Frames will be delivered from the thread routine. */
    const status_t res = startWorkerThread(one_burst);
    ALOGE_IF(res != NO_ERROR, "%s: startWorkerThread failed", __FUNCTION__);
    return res;
}

status_t V4L2Camera::stopDeliveringFrames()
{
    ALOGV("%s", __FUNCTION__);
	
	pthread_mutex_lock(&mMutexTakePhotoEnd);
	if (mTakingPicture)
	{
		ALOGW("wait until take picture end before stop thread ......");		
		pthread_cond_wait(&mCondTakePhotoEnd, &mMutexTakePhotoEnd);
		ALOGW("wait take picture ok");
	}
	pthread_mutex_unlock(&mMutexTakePhotoEnd);

	// for CTS, V4L2Camera::WorkerThread::readyToRun must be called before stopDeliveringFrames
	pthread_mutex_lock(&mMutexThreadRunning);
	if (!mThreadRunning)
	{
		ALOGW("should not stop preview so quickly, wait thread running first ......");
		pthread_cond_wait(&mCondThreadRunning, &mMutexThreadRunning);
		ALOGW("wait thread running ok");
	}
	pthread_mutex_unlock(&mMutexThreadRunning);
	
    if (!isStarted()) {
        ALOGW("%s: Device is not started", __FUNCTION__);
        return NO_ERROR;
    }

    const status_t res = stopWorkerThread();
    ALOGE_IF(res != NO_ERROR, "%s: startWorkerThread failed", __FUNCTION__);
    return res;
}

static void NV12ToNV21(const void* nv12, void* nv21, int width, int height)
{	
	char * src_uv = (char *)nv12 + width * height;
	char * dst_uv = (char *)nv21 + width * height;

	memcpy(nv21, nv12, width * height);

	for(int i = 0; i < width * height / 2; i += 2)
	{
		*(dst_uv + i) = *(src_uv + i + 1);
		*(dst_uv + i + 1) = *(src_uv + i);
	}
}

status_t V4L2Camera::getCurrentPreviewFrame(void* buffer)
{
    if (!isStarted()) {
        ALOGE("%s: Device is not started", __FUNCTION__);
        return EINVAL;
    }
    if (mCurrentFrame == NULL || buffer == NULL) {
        ALOGE("%s: No framebuffer", __FUNCTION__);
        return EINVAL;
    }

#if PREVIEW_FMT_RGBA32
    /* In emulation the framebuffer is never RGB. */
    switch (mPixelFormat) {
        case V4L2_PIX_FMT_YVU420:
            YV12ToRGB32(mCurrentFrame, buffer, mFrameWidth, mFrameHeight);
            return NO_ERROR;
        case V4L2_PIX_FMT_YUV420:
            YU12ToRGB32(mCurrentFrame, buffer, mFrameWidth, mFrameHeight);
            return NO_ERROR;
        case V4L2_PIX_FMT_NV21:
            NV21ToRGB32(mCurrentFrame, buffer, mFrameWidth, mFrameHeight);
            return NO_ERROR;
        case V4L2_PIX_FMT_NV12:
            NV12ToRGB32(mCurrentFrame, buffer, mFrameWidth, mFrameHeight);
            return NO_ERROR;

        default:
            ALOGE("%s: Unknown pixel format %.4s",
                 __FUNCTION__, reinterpret_cast<const char*>(&mPixelFormat));
            return EINVAL;
    }
#else
	if (mPixelFormat == V4L2_PIX_FMT_NV21)
	{
		// NV21
		memcpy(buffer, mCurrentFrame, mFrameWidth * mFrameHeight * 3 / 2);
	}
	else if (mPixelFormat == V4L2_PIX_FMT_NV12)
	{
		// NV12 to NV21
		NV12ToNV21(mCurrentFrame, buffer, mFrameWidth, mFrameHeight);
	}
	
	return OK;
#endif
}

/****************************************************************************
 * V4L2Camera device private API
 ***************************************************************************/

status_t V4L2Camera::commonStartDevice(int width,
                                       int height,
                                       uint32_t pix_fmt)
{
	F_LOG;
	
    /* Validate pixel format, and calculate framebuffer size at the same time. */
    switch (pix_fmt) {
        case V4L2_PIX_FMT_YVU420:
        case V4L2_PIX_FMT_YUV420:
        case V4L2_PIX_FMT_NV21:
        case V4L2_PIX_FMT_NV12:
            mFrameBufferSize = (width * height * 12) / 8;
            break;

        default:
            ALOGE("%s: Unknown pixel format %.4s",
                 __FUNCTION__, reinterpret_cast<const char*>(&pix_fmt));
            return EINVAL;
    }

    /* Cache framebuffer info. */
    mFrameWidth = width;
    mFrameHeight = height;
    mPixelFormat = pix_fmt;
    mTotalPixels = width * height;

    /* Allocate framebuffer. */
    mCurrentFrame = new uint8_t[mFrameBufferSize];
    if (mCurrentFrame == NULL) {
        ALOGE("%s: Unable to allocate framebuffer", __FUNCTION__);
        return ENOMEM;
    }
    ALOGV("%s: Allocated %p %d bytes for %d pixels in %.4s[%dx%d] frame",
         __FUNCTION__, mCurrentFrame, mFrameBufferSize, mTotalPixels,
         reinterpret_cast<const char*>(&mPixelFormat), mFrameWidth, mFrameHeight);

    return NO_ERROR;
}

void V4L2Camera::commonStopDevice()
{
	F_LOG;
    mFrameWidth = mFrameHeight = mTotalPixels = 0;
    mPixelFormat = 0;
	
    if (mCurrentFrame != NULL) {
        delete[] mCurrentFrame;
        mCurrentFrame = NULL;
    }
}

/****************************************************************************
 * Worker thread management.
 ***************************************************************************/

status_t V4L2Camera::startWorkerThread(bool one_burst)
{
    ALOGV("%s", __FUNCTION__);

    if (!isInitialized()) {
        ALOGE("%s: V4L2Camera device is not initialized", __FUNCTION__);
        return EINVAL;
    }

    const status_t res = getWorkerThread()->startThread(one_burst);
    ALOGE_IF(res != NO_ERROR, "%s: Unable to start worker thread", __FUNCTION__);
    return res;
}

status_t V4L2Camera::stopWorkerThread()
{
    ALOGV("%s", __FUNCTION__);

    if (!isInitialized()) {
        ALOGE("%s: V4L2Camera device is not initialized", __FUNCTION__);
        return EINVAL;
    }

    const status_t res = getWorkerThread()->stopThread();
    ALOGE_IF(res != NO_ERROR, "%s: Unable to stop worker thread", __FUNCTION__);
    return res;
}

bool V4L2Camera::inWorkerThread()
{
	F_LOG;
    /* This will end the thread loop, and will terminate the thread. Derived
     * classes must override this method. */
    return false;
}

/****************************************************************************
 * Worker thread implementation.
 ***************************************************************************/

status_t V4L2Camera::WorkerThread::readyToRun()
{
    ALOGV("V4L2Camera::WorkerThread::readyToRun");

    ALOGW_IF(mThreadControl >= 0 || mControlFD >= 0,
            "%s: Thread control FDs are opened", __FUNCTION__);
    /* Create a pair of FDs that would be used to control the thread. */
    int thread_fds[2];
    if (pipe(thread_fds) == 0) {
        mThreadControl = thread_fds[1];
        mControlFD = thread_fds[0];
        ALOGV("V4L2Camera's worker thread has been started.");

        return NO_ERROR;
    } else {
        ALOGE("%s: Unable to create thread control FDs: %d -> %s",
             __FUNCTION__, errno, strerror(errno));
        return errno;
    }
}

status_t V4L2Camera::WorkerThread::stopThread()
{
    ALOGV("Stopping V4L2Camera device's worker thread...");

    status_t res = EINVAL;
    if (mThreadControl >= 0) {
        /* Send "stop" message to the thread loop. */
        const ControlMessage msg = THREAD_STOP;
        const int wres =
            TEMP_FAILURE_RETRY(write(mThreadControl, &msg, sizeof(msg)));
        if (wres == sizeof(msg)) {
            /* Stop the thread, and wait till it's terminated. */
            res = requestExitAndWait();
            if (res == NO_ERROR) {
                /* Close control FDs. */
                if (mThreadControl >= 0) {
                    close(mThreadControl);
                    mThreadControl = -1;
                }
                if (mControlFD >= 0) {
                    close(mControlFD);
                    mControlFD = -1;
                }
                ALOGV("V4L2Camera device's worker thread has been stopped.");
            } else {
                ALOGE("%s: requestExitAndWait failed: %d -> %s",
                     __FUNCTION__, res, strerror(-res));
            }
        } else {
            ALOGE("%s: Unable to send THREAD_STOP message: %d -> %s",
                 __FUNCTION__, errno, strerror(errno));
            res = errno ? errno : EINVAL;
        }
    } else {
        ALOGE("%s: Thread control FDs are not opened", __FUNCTION__);
    }
	
	ALOGV("Stopping V4L2Camera device's worker thread... OK");

    return res;
}

V4L2Camera::WorkerThread::SelectRes
V4L2Camera::WorkerThread::Select(int fd, int timeout)
{
	// F_LOG;
    fd_set fds[1];
    struct timeval tv, *tvp = NULL;

    const int fd_num = (fd >= 0) ? max(fd, mControlFD) + 1 :
                                   mControlFD + 1;
    FD_ZERO(fds);
    FD_SET(mControlFD, fds);
    if (fd >= 0) {
        FD_SET(fd, fds);
    }
    if (timeout) {
        tv.tv_sec = timeout / 1000000;
        tv.tv_usec = timeout % 1000000;
        tvp = &tv;
    }
    int res = TEMP_FAILURE_RETRY(select(fd_num, fds, NULL, NULL, tvp));
    if (res < 0) {
        ALOGE("%s: select returned %d and failed: %d -> %s",
             __FUNCTION__, res, errno, strerror(errno));
        return ERROR;
    } else if (res == 0) {
        /* Timeout. */
        return TIMEOUT;
    } else if (FD_ISSET(mControlFD, fds)) {
        /* A control event. Lets read the message. */
        ControlMessage msg;
        res = TEMP_FAILURE_RETRY(read(mControlFD, &msg, sizeof(msg)));
        if (res != sizeof(msg)) {
            ALOGE("%s: Unexpected message size %d, or an error %d -> %s",
                 __FUNCTION__, res, errno, strerror(errno));
            return ERROR;
        }
        /* THREAD_STOP is the only message expected here. */
        if (msg == THREAD_STOP) {
            ALOGV("%s: THREAD_STOP message is received", __FUNCTION__);
            return EXIT_THREAD;
        } else {
            ALOGE("Unknown worker thread message %d", msg);
            return ERROR;
        }
    } else {
        /* Must be an FD. */
        ALOGW_IF(fd < 0 || !FD_ISSET(fd, fds), "%s: Undefined 'select' result",
                __FUNCTION__);
        return READY;
    }
}

};  /* namespace android */
