#!/bin/sh
# Build Wrapper Disk script
# it should have been smaller
CDIR=$(pwd)
FXBDIR=$(pwd)/3dfx/build
MSBDIR=$(pwd)/mesa/build
TXTDIR=$(pwd)/texts
ISO=$(pwd)/iso
KJISO=$(pwd)/vmaddons

# Function to install wrappers
function wrapinstall {
echo "Installing compiled wrappers"
rm -rf $ISO/wine $ISO/wrapfx $ISO/wrapgl $ISO/readme.txt $ISO/license.txt $ISO/commit\ id.txt
mkdir -p $ISO/wrapfx $ISO/wrapgl
cp -rf $FXBDIR/* $ISO/wrapfx/
rm -rf $ISO/wrapfx/lib* $ISO/wrapfx/Makefile
cp -f $MSBDIR/* $ISO/wrapgl/
rm -f $ISO/wrapgl/Makefile
cp -r $TXTDIR/readme.txt $ISO/readme.txt
cp -r $TXTDIR/LICENSE $ISO/license.txt
}

# Function to make menu
function wineinstall {
echo "Installing wine libraries!"
PS3='Please enter your choice: '
OPTION1="Install kjliew's libraries (vmaddons.iso required!)"
OPTION2="Skip"
options=( "$OPTION1"
                    "$OPTION2"
)
# Options
select opt in "${options[@]}"
do
    case $opt in
        "$OPTION1")
            if [ -f "/bin/bsdtar" ]; then
                if [ -f "$(pwd)/vmaddons.iso" ]; then
                    kjwine
                    break
                else
                     echo "vmaddons.iso not found"
                fi
            else
            echo  "bsdtar not found! Please install it"
            fi
            ;;
        "$OPTION2")
            echo "Skipping wine libraries"
            break
            ;;
        *) echo "$REPLY is not a valid option!";;
    esac
done

}
# Function to handle kjliew's wine libraries
function kjwine {
    echo "vmaddons.iso found! Extracting optional wrappers"
    mkdir $CDIR/vmaddons
    bsdtar xf vmaddons.iso --directory $CDIR/vmaddons

    echo "Installing optional wrappers"
    cp -rf $KJISO/win32/wine $ISO/
    cp -r $TXTDIR/readme_dx.txt $ISO/readme.txt
    rm -rf $ISO/wine/*/build-timestamp
    rm -rf $KJISO
    rm -f $ISO/wine/wine-get
}

# Function to download wglgears if there is no testing application
function gearinstall {
if [ -f "$MSBDIR/wglgears.exe" ] || [ -f "$MSBDIR/wgltest.exe" ] || [ -f "$ISO/wrapgl/wglgears.exe" ]; then
        echo "wglgears or wgltest found!"
    else
        echo "wglgears or wgltest not found! Downloading"
        curl -o "$ISO/wrapgl/wglgears.exe" http://www2.cs.uidaho.edu/~jeffery/win32/wglgears.exe
fi
}

# Function to add commit ID
function commit {
    echo "Adding commit ID"
    echo $(git rev-parse HEAD) > $ISO/commit\ id.txt

}
# Function to change text to CRLF
function encode {
	echo "encoding text files"
	unix2dos $ISO/readme.txt $ISO/commit\ id.txt $ISO/license.txt
}
# Function to create the ISO
function makeiso {
    echo "Making wrapper iso"
    mkisofs -JR -V 3DFX-WRAPPERS -o $CDIR/wrappers.iso $ISO/
}
## First step install
# Checking if its kharovtobi's repository or upstream repo
if [ -f "$ISO/qemu.ico" ] && [ -f "$ISO/autorun.inf" ] && [ -f "$ISO/open.bat" ] && [ -f "$TXTDIR/readme.txt" ] && [ -f "$TXTDIR/readme_dx.txt" ] ; then
    echo "folders found!"
    wrapinstall
else
    if [ -f "/bin/git" ] && [ -f "/bin/curl" ]; then
        echo "downloading folders"
        mkdir -p $ISO $TXTDIR
        curl -o $ISO/autorun.inf https://raw.githubusercontent.com/kharovtobi/qemu-3dfx/refs/heads/master/wrappers/iso/autorun.inf
        curl -o $ISO/open.bat https://raw.githubusercontent.com/kharovtobi/qemu-3dfx/refs/heads/master/wrappers/iso/open.bat
        curl -o $ISO/qemu.ico https://raw.githubusercontent.com/kharovtobi/qemu-3dfx/refs/heads/master/wrappers/iso/qemu.ico
		curl -o $TXTDIR/readme.txt https://raw.githubusercontent.com/kharovtobi/qemu-3dfx/refs/heads/master/wrappers/texts/readme.txt
		curl -o $TXTDIR/readme_dx.txt https://raw.githubusercontent.com/kharovtobi/qemu-3dfx/refs/heads/master/wrappers/texts/readme_dx.txt
        wrapinstall
    else
        echo "git or curl not found! Please install it. Exiting"
        exit
    fi
fi


## Second step install
# Check for required binaries and run corresponding functions
wineinstall
gearinstall

if [ -f "/bin/git" ]; then
    commit
else
    echo "git not found! Skipping adding commit id"
fi
if [ -f "bin/unix2dos" ]; then
	encode
else
	echo "dos2unix not found! Skipping changing control characters"
fi
if [ -f "/bin/mkisofs" ]; then
    makeiso
else
    echo "mkisofs (cdrtools) not found! Please install it or manually make iso disk of the folder"
fi

echo "Installation Finished!"
