# QEMU MESA GL/3Dfx Glide Pass-Through Wrapper Disk
This folder contains the source codes for wrappers that make pass-through possible and how to make one.

## Content
    3dfx          - Glide wrappers for supported guest OS/environment (DOS/Windows/DJGPP/Linux)
    mesa          - MESA GL wrapper for supported guest OS/environment (Windows)
    iso           - Wrapper Disk folder
    texts         - Some texts and readme
    
## Building Guest Wrappers
**Requirements:**
 - `base-devel` (make, sed, xxd etc.)
 - `gendef, shasum`
 - `mingw32` cross toolchain (`binutils, gcc, windres, dlltool`) for WIN32 DLL wrappers
 - `Open-Watcom-1.9/v2.0` or `Watcom C/C++ 11.0` for DOS32 OVL wrapper
 - `{i586,i686}-pc-msdosdjgpp` cross toolchain (`binutils, gcc, dxe3gen`) for DJGPP DXE wrappers

If you have Watcom installed, run command first

    $ source /opt/watcom/owsetenv.sh
    
**Building**

    $ cd ~/myqemu/qemu-3dfx/wrappers/3dfx
    $ mkdir build && cd build
    $ bash ../../../scripts/conf_wrapper
    $ make && make clean

    $ cd ~/myqemu/qemu-3dfx/wrappers/mesa
    $ mkdir build && cd build
    $ bash ../../../scripts/conf_wrapper
    $ make && make clean

## Packaging Guest Wrappers
**Requirements**
- `git` for stamping commit ID to text
- `mkisofs` for making iso
- `dos2unix` for changing control characters to Windows CRLF (important)
- `bsdtar, vmaddons.iso` for copying DirectX wrappers (optional)

**Packaging**

This instructions are based in Arch Linux btw, in Bash Shell. Its simple because of different Linux distributions or your using Windows.

    $ cd ~/myqemu/qemu-3dfx/wrappers/iso
    $ mkdir wrapfx && cd wrapfx
    $ cp -r ../../3dfx/build/* ./
    $ rm -r lib* Makefile     

    $ cd ~/myqemu/qemu-3dfx/wrappers/iso
    $ mkdir wrapgl && cd wrapgl
    $ cp -r ../../mesa/build/* ./
    $ rm Makefile
    
    $ cd ~/myqemu/qemu-3dfx/wrappers/iso
    $ cp ../texts/readme.txt ./readme.txt
    $ echo $(git rev-parse HEAD) > ./commit\ id.txt
    $ unix2dos readme.txt commit\ id.txt 
    $ cd ..
    $ mkisofs -o wrappers.iso ./iso
    
- Feel free to add anything to iso
- mkisofs is not available on MSYS2. You may have to use [WinCDEmu](https://wincdemu.sysprogs.org/download/)
- dos2unix is recommended as texts encoded in LF while on Windows (until 1809) have text errors.

**Wine Support**

Since kjliew did not provide source code for Wine binaries that work in QEMU-3dfx. You may donate to him for the Binaries or seek alternatives. (his binaries are better than mine anyway)

1. Install [SoftGPU](https://github.com/JHRobotics/softgpu) (Works like a charm)
2. Compile [Wine9x Libraries](https://github.com/JHRobotics/wine9x) (Works if followed instructions correctly, but runs terrible)
3. Compile WineD3D Libraries directly on wine. I've tried that and it does not work, especially later versions of wine. ([kjliew to me](https://www.youtube.com/watch?v=FGtzsy8Uptw))
4. Try compiling ReactOS Wine (might work. [Reference](https://github.com/adolfintel/wined3d4win/issues/13))
5. [Donate to him](https://github.com/kjliew/qemu-3dfx?tab=readme-ov-file#donation).
6. c̶h̶e̶c̶k̶ ̶a̶r̶c̶h̶i̶v̶e̶.̶o̶r̶g̶.


## Notes
 - If you got some problems with the wrappers (i.e wrappers compiled without 3dfx patches). you should download it on actions tab via "Build Wrappers" and choose the latest build. (you need a github account)
 - Using NVIDIA driver on Linux may crash QEMU-3dfx when running a game. try using nouveau (or not)
 - ICD support is included via JHRobotics forked repo but disabled by default (im sorry)
 - Making mesa wrappers only compile opengl32.dll and wgltest.exe only. If you want all of them to compile including ICD support, run command in `wrappers/mesa/build` with Makefile
        
        $ make all+ && make clean
