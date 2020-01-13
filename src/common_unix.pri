# contains(TARGET_ARCH, arm64 ): QMAKE_CXXFLAGS += -msse3 -m64
#
# CUDA
#

contains(TARGET_ARCH, arm64 ) {
    CUDA_TOOLKIT_PATH = "/usr/local/cuda-10.0"
} else {
    CUDA_TOOLKIT_PATH = "/usr/local/cuda-10.1"
}

INCLUDEPATH += $${CUDA_TOOLKIT_PATH}/include
CUDA_LIB  = -L$${CUDA_TOOLKIT_PATH}/lib64
CUDA_LIB += -lnppicc
CUDA_LIB += -lnppig
CUDA_LIB += -lnppif
CUDA_LIB += -lnpps
CUDA_LIB += -lnppc
CUDA_LIB += -lcudart
#
contains( DEFINES, SUPPORT_XIMEA ){
    XI_API_PATH = /opt/XIMEA/
    INCLUDEPATH += $$XI_API_PATH/include
    LIBS += -lm3api
}

contains( DEFINES, SUPPORT_GENICAM ){
    DEFINES -= UNICODE
    DEFINES += GENICAM_NO_AUTO_IMPLIB
    #
    # Setup Ximea Transport Layer !!!!
    #
    DEFINES += GENTL_INSTALL_PATH=\'\"/opt/XIMEA/lib\"\'

    GANAPIPATH = $$OTHER_LIB_PATH/GenICam/library/CPP

contains(TARGET_ARCH, arm64 ) {
    GANAPI_LIB_PATH = $$GANAPIPATH/bin/Linux64_ARM
    GCC_VER = gcc49
}
else {
    GANAPI_LIB_PATH = $$GANAPIPATH/bin/Linux64_x64
    GCC_VER = gcc49
}

    FASTVIDEO_EXTRA_DLLS += $$GANAPI_LIB_PATH/libGCBase_$${GCC_VER}_v3_2.so
    FASTVIDEO_EXTRA_DLLS += $$GANAPI_LIB_PATH/libGenApi_$${GCC_VER}_v3_2.so
    FASTVIDEO_EXTRA_DLLS += $$GANAPI_LIB_PATH/libLog_$${GCC_VER}_v3_2.so
    FASTVIDEO_EXTRA_DLLS += $$GANAPI_LIB_PATH/libMathParser_$${GCC_VER}_v3_2.so
    FASTVIDEO_EXTRA_DLLS += $$GANAPI_LIB_PATH/libNodeMapData_$${GCC_VER}_v3_2.so
    FASTVIDEO_EXTRA_DLLS += $$GANAPI_LIB_PATH/libXmlParser_$${GCC_VER}_v3_2.so

#    FASTVIDEO_EXTRA_DLLS += $$GANAPI_LIB_PATH/libCLProtocol_$${GCC_VER}_v3_2.so
#    FASTVIDEO_EXTRA_DLLS += $$GANAPI_LIB_PATH/libFirmwareUpdate_$${GCC_VER}_v3_2.so
#    FASTVIDEO_EXTRA_DLLS += $$GANAPI_LIB_PATH/liblog4cpp_$${GCC_VER}_v3_2.so

    INCLUDEPATH += $$GANAPIPATH/include
    LIBS += -L$$GANAPI_LIB_PATH -lCLAllSerial_$${GCC_VER}_v3_2 -lGCBase_$${GCC_VER}_v3_2 -lGenApi_$${GCC_VER}_v3_2
    LIBS += -lLog_$${GCC_VER}_v3_2 -lMathParser_$${GCC_VER}_v3_2 -lNodeMapData_$${GCC_VER}_v3_2 -lXmlParser_$${GCC_VER}_v3_2
#    LIBS += -lFirmwareUpdate_$${GCC_VER}_v3_2 -llog4cpp_$${GCC_VER}_v3_2 -lCLProtocol_$${GCC_VER}_v3_2
}

#
# FASTVIDEO SDK
#
FASTVIDEOPATH  = $$OTHER_LIB_PATH/FastvideoSDK
FASTVIDEO_SDK  = $$FASTVIDEOPATH/fastvideo_sdk
FASTVIDEO_INC  = $$FASTVIDEO_SDK/inc
FASTVIDEO_INC += $$FASTVIDEOPATH/common
FASTVIDEO_INC += $$FASTVIDEOPATH/libs/OpenGL/inc
#
FASTVIDEO_LIB += -L$$FASTVIDEOPATH/fastvideo_sdk/lib
FASTVIDEO_LIB += -lfastvideo_sdk -lfastvideo_denoise
#
# -lfastvideo_mjpeg -lfastvideo_denoise -lfastvideo_nppFilter -lfastvideo_nppResize -lfastvideo_nppGeometry
#
FFMPEG_PATH = $$OTHER_LIB_PATH/FastvideoSDK/libs/ffmpeg
contains(TARGET_ARCH, arm64 ) {
    FFMPEG_LIB = -L$$FFMPEG_PATH/lib/linux/aarch64/
}
else {
    FFMPEG_LIB = -L$$FFMPEG_PATH/lib/linux/x86_64/
}
FFMPEG_LIB += -lavcodec -lavformat -lavutil -lswresample
#
INCLUDEPATH += $$FASTVIDEO_INC
INCLUDEPATH += $$FFMPEG_PATH/inc
#
LIBS += $$FASTVIDEO_LIB
LIBS += $$CUDA_LIB
LIBS += $$FFMPEG_LIB
LIBS += -ldl
#
contains(TARGET_ARCH, arm64 ): LIBS += -lGL
#
defineTest(copyQtIcuDllsToDestdir) {
    DLLS = $$1
    for(ifile, DLLS) {
            IFILE = $$ifile".1"
            OLINK = $$ifile
            QMAKE_POST_LINK += cd $${DESTDIR}; $$QMAKE_COPY $$[QT_INSTALL_LIBS]/$$IFILE .; ln -sf $$IFILE $$OLINK $$escape_expand(\\n\\t)
    }
    export(QMAKE_POST_LINK)
}
# Copies the plugins to the destination directory
defineTest(copySelectedPluginsToDestdir) {
    ifiles = $$1
    for(ifile, ifiles) {
        dname = $${DESTDIR}/$$dirname(ifile)
        makeDir($$dname)
        QMAKE_POST_LINK += $$QMAKE_COPY $$[QT_INSTALL_PLUGINS]/$$ifile $${DESTDIR}/$$ifile $$escape_expand(\\n\\t)
    }
    export(QMAKE_POST_LINK)
}
