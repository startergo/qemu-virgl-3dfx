#!/bin/bash

if [ -f ./glide2x.dll ]; then
    echo "Standalone Build"
    GLIDE_DLL=./
    QEMU=./qemu-system-i386.exe
    $QEMU --version
    echo "Host Glide DLL at Standalone build dir"
    LD_LIBRARY_PATH=$GLIDE_DLL $QEMU -display sdl $@ 2>&1 | tee ./qemu-3dfx.log

else
    if [ ! -f $GLIDE_DLL/glide2x.dll ]; then
        echo "System Build"
        GLIDE_DLL=/usr/lib
        echo "Missing Glide2x library at $GLIDE_DLL"
        exit 1
    else
        QEMU=./qemu-3dfx-system-i386.exe
        $QEMU --version
        echo "Host Glide DLL at LD_LIBRARY=$GLIDE_DLL"
        LD_LIBRARY_PATH=$GLIDE_DLL $QEMU -display sdl $@ 2>&1 | tee ./qemu-3dfx.log
    fi

fi

