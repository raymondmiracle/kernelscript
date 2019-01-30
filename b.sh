#!/bin/sh
# Custom build script
# Copyright (C) 2019 Raymond Miracle

function Declarations {
KERNEL_DIR=$PWD
ZIMAGE=$KERNEL_DIR/output/arch/arm64/boot/Image.gz-dtb
BUILD_START=$(date +"%s")
BUILD_END=$(date +"%s")
}

function colors {
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
}

function Making_compiling_dir {
mkdir output
}

function clone {
echo "${CYN}★★Cloning Anykernel2........."
git clone --depth=1 --no-single-branch https://github.com/raymondmiracle/anykernel2
echo "${ORNG}★★Cloning Anykernel2 Done........."
echo ""
echo "${RED}★★Cloning Toolchain............."
git clone --depth=1 --no-single-branch https://github.com/raymondmiracle/Toolchain toolchain
echo "${ORNG}★★Cloning Toolchain Done........."
echo ""
}

function exports {
echo "${RST}Export Started......"
export ARCH=arm64
export CROSS_COMPILE=$PWD/toolchain/bin/aarch64-linux-android-
export KBUILD_BUILD_USER="Ray-Miracle"
export KBUILD_BUILD_HOST="OmegaHOST"
}

function build_kernel {
#better checking defconfig at first
echo "${ORNG}Checking Defconfig"
	if [ -f $KERNEL_DIR/arch/arm64/configs/k5fpr_defconfig ]
	then 
		DEFCONFIG=k5fpr_defconfig
	elif [ -f $KERNEL_DIR/arch/arm64/configs/omega_defconfig ]
	then
		DEFCONFIG=omega_defconfig
	else
echo "${RED}Defconfig Mismatch"
echo "${RED}Exiting in 5 seconds"
		sleep 5
		exit
         fi
		 
echo "${PURP}***********************************************"
echo "          Compiling Omega-Kernel...          "
echo "${PURP}***********************************************"
echo ""
make -C $(pwd) O=output $DEFCONFIG 2>&1 | tee defconfiglog.txt
#
make -j32 -C $(pwd) O=output 2>&1 | tee logcat.txt

}

function check_img {
if ! [ -f $ZIMAGE ]
then
echo "${RED}Kernel Compilation failed! Fix the errors!"
     sleep 2
     exit
fi
}

function gen_zip {
   if [ -f $ZIMAGE ]
       then
	   echo "${YLW}Zipping Files........"
	   cp output/arch/arm64/boot/Image.gz-dtb anykernel2/Image.gz-dtb
	   cd anykernel2
	   mv Image.gz-dtb zImage
	   zip -r9 omegakernel-$BUILD_START * -x .git README.md
	   echo "${PURP}Done Zipping........."
}

function Upload {
    echo "${BLUE}***********************************************"
    echo "          Uploading Omega-Kernel as zip...          "
    echo "${BLUE}***********************************************"
	file=$1
	curl -f' file=@$1' http://0x0.st
    DIFF=$(($BUILD_END - $BUILD_START))
	echo "${YLW}Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
    exit 1
    fi
}

#Declarations
#colors
#clone
#exports
#build_kernel
#check_img
#gen_zip
#Upload
