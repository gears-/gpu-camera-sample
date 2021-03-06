/*
 Copyright 2011-2019 Fastvideo, LLC.
 All rights reserved.

 This file is a part of the GPUCameraSample project
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3. Any third-party SDKs from that project (XIMEA SDK, Fastvideo SDK, etc.) are licensed on different terms. Please see their corresponding license terms.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 The views and conclusions contained in the software and documentation are those
 of the authors and should not be interpreted as representing official policies,
 either expressed or implied, of the FreeBSD Project.
*/

#include "FrameBuffer.h"
#include "SurfaceTraits.hpp"

CircularBuffer::CircularBuffer(QObject *parent) : QObject(parent)
{

}

bool CircularBuffer::allocate(int width, int height, fastSurfaceFormat_t format)
{
    QMutexLocker lock(&mMutex);
    FastAllocator alloc;

    int pitch = GetPitchFromSurface(format, width);
    int bpc = GetBitsPerChannelFromSurface(format);

    //Sometimes XI API returns Not enough memory
    //if we allocate exact number of bytes
    //so we double buffer size just in case
    int bytesAlloc = height * pitch * 2;

    mImages.resize(numBuffers);

    mAllocated = 0;
    mCurrent = 0;
    mLast = -1;

    for(int i = 0; i < numBuffers; i++)
    {
        mImages[i].w = width;
        mImages[i].h = height;
        mImages[i].surfaceFmt = format;
        mImages[i].wPitch = pitch;
        mImages[i].bitsPerChannel = bpc;
        try
        {
            mImages[i].data.reset(static_cast<unsigned char *>(alloc.allocate(bytesAlloc)));
        }
        catch(...)
        {
            mImages.clear();
            return false;
        }
    }

    mAllocated = bytesAlloc;

    return true;
}

int CircularBuffer::width()
{
    return mImages.isEmpty() ? 0 : mImages.at(0).w;
}

int CircularBuffer::height()
{
    return  mImages.isEmpty() ? 0 : mImages.at(0).h;
}
int CircularBuffer::pitch()
{
    return  mImages.isEmpty() ? 0 : mImages.at(0).wPitch;
}

int CircularBuffer::size()
{
    return mAllocated;
}
fastSurfaceFormat_t CircularBuffer::surfaceFmt()
{
    return  mImages.isEmpty() ? FAST_I8 : mImages.at(0).surfaceFmt;
}

unsigned char* CircularBuffer::getBuffer()
{
    if(mImages.isEmpty())
        return nullptr;

    int num = (mCurrent + 1) % numBuffers;
    if(num == mLast)
        num = (mCurrent + 2) % numBuffers;
    mCurrent = num;
    return mImages[mCurrent].data.get();
}

ImageT* CircularBuffer::getLastImage()
{
    if(mImages.isEmpty() || mLast < 0)
        return nullptr;

    return &(mImages[mLast]);
}

void CircularBuffer::release()
{
    mLast = mCurrent;
}
