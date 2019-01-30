#!/bin/sh
# Custom build script


KERNEL_DIR=$PWD
ZIMAGE=$KERNEL_DIR/outdir/arch/arm64/boot/Image.gz-dtb
BUILD_START=$(date +"%s")
ORNG=$'\033[0;33m'
CYN=$'\033[0;36m'
PURP=$'\033[0;35m'
BLINK_RED=$'\033[05;31m'
BLUE=$'\033[01;34m'
BLD=$'\033[1m'
GRN=$'\033[01;32m'
RED=$'\033[01;31m'
RST=$'\033[0m'
YLW=$'\033[01;33m'

#make kernel compiling dir...
mkdir output
echo "${CYN}Cloning Anykernel2........."
git clone --depth=1 --no-single-branch https://github.com/raymondmiracle/anykernel2
echo "${ORNG}Cloning Anykernel2 Done........."
echo ""
echo "${RED}Cloning Toolchain............."
git clone --depth=1 --no-single-branch https://github.com/raymondmiracle/Toolchain toolchain
echo "${ORNG}Cloning Toolchain Done........."
echo ""
echo "${RST}Export Started......"
#exports ::
#toolchain , custom build_user , custom build_host , arch
export ARCH=arm64
export ARCH=arm64
export CROSS_COMPILE=$PWD/toolchain/bin/aarch64-linux-android-
export KBUILD_BUILD_USER="Ray-Miracle"
export KBUILD_BUILD_HOST="OmegaHOST"


compile_kernel ()
{
echo "${PURP}***********************************************"
echo "          Compiling Omega-Kernel...          "
echo "${PURP}***********************************************"
echo ""
make -C $(pwd) O=output k5fpr_defconfig 2>&1 | tee defconfiglog.txt
#
make -j32 -C $(pwd) O=output 2>&1 | tee logcat.txt
cp output/arch/arm64/boot/Image.gz-dtb anykernel2/zImage

if ! [ -f $ZIMAGE ];
then
echo -e "$red Kernel Compilation failed! Fix the errors! $nocol"
exit 1
fi
}

zip_zak ()
{
echo -e "$cyan***********************************************"
echo "          ZIpping Omega-Kernel...          "
echo -e "***********************************************$nocol"
echo ""
echo -e "$yellow Putting custom_kernel™ Kernel in Recovery Flashable Zip $nocol"
cd anykernel2
zip -r9 omegakernel-$BUILD_START * -x .git README.md
    echo "" "Done Making Recovery Flashable Zip"
    echo ""
    echo -e "$blue***********************************************"
    echo "          Uploading Omega-Kernel as zip...          "
    echo -e "***********************************************$nocol"
    echo ""
    curl --upload-file omegakernel-$BUILD_START * https://transfer.sh/omegakernel-$BUILD_START.zip
    echo ""
    echo " Uploading Done !!!"
    echo ""
    echo ""
    BUILD_END=$(date +"%s")
    DIFF=$(($BUILD_END - $BUILD_START))
    echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$n"
    exit 1
    fi
}
