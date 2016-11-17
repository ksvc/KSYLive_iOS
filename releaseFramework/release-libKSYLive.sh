#! /bin/bash

#######################
## default opt
#######################
if [ $XCODE_STRIP ]; then
	echo "XCODE_STRIP=$XCODE_STRIP"
else
	XCODE_STRIP="xcrun strip"
fi
#######################
## cmd line
#######################
PROJECT_BUILD_ROOT=`pwd`

CONFIGURATION=Release
PROJECT_NAME=libKSYLive
BUILD_DIR=build

function print_usage() {
echo "USAGE:"
echo "	$0 name format [dy]"
echo ""
echo "PARAM:"
echo "name 	: 	KSYMediaPlayer - build player framework"
echo "		libksygpulive  - build live framework"
echo "format  : 	lite - only support common media format"
echo "		265  - contain 265 codec"
echo "	 	vod  - support most media format" 
echo "[dy] 	: 	if exist, build a dynamic framework, otherwise, build a static framework" 
echo ""
echo "FOR EXAMPLE:"
echo "$0 KSYMediaPlayer lite 	: build a static player framework which name is "KSYMediaPlayer.framework", only support common media format"
echo "$0 KSYMediaPlayer vod 	: build a static player framework which name is "KSYMediaPlayer.framework", support most media format"
echo "$0 KSYMediaPlayer lite dy  : build a dynamic player framework which name is "KSYMediaPlayerDy.framework", only support common media format"
echo "$0 KSYMediaPlayer vod dy 	: build a dynamic player framework which name is "KSYMediaPlayerDy.framework", support most media format"
echo "$0 libksygpulive lite 	: build a static live framework which name is "libksygpulive.framework", only support common media format"
echo "$0 libksygpulive 265	: build a static live framework which name is "libksygpulive.framework", contain 265 codec"
echo "$0 libksygpulive lite dy 	: build a dynamic live framework which name is "libksygpuliveDy.framework", only suport common media format"
echo "$0 libksygpulive 265 dy 	: build a dynamic live framework which name is "libksygpuliveDy.framework", contain 265 codec"
}

if [ $# -lt 2 ]; then
print_usage
exit
fi

FRAMEWORKNAME=$1
FORMAT=$2
TYPE="static"
if [ -n "$3" ]; then
	TYPE="dynamic"
fi

LIBDECNAME=ksymediacore_dec
LIBENCNAME=ksymediacore_enc

cd $PROJECT_BUILD_ROOT/../prebuilt/libs/
ln -s -f lib"$LIBDECNAME"_lite.a lib"$LIBDECNAME".a
ln -s -f lib"$LIBENCNAME"_lite.a lib"$LIBENCNAME".a

if [ $FRAMEWORKNAME = "KSYMediaPlayer" ]; then
	if [ $FORMAT = "vod" ]; then
		ln -s -f lib"$LIBDECNAME"_vod.a lib"$LIBDECNAME".a
	fi
elif [ $FRAMEWORKNAME = "libksygpulive" ]; then
	if [ $FORMAT = "265" ]; then
		ln -s -f lib"$LIBENCNAME"_265.a lib"$LIBENCNAME".a
	fi
else
	print_usage
	exit
fi

cd $PROJECT_BUILD_ROOT

if [ $FRAMEWORKNAME = "libksygpulive" ]; then
	GPUIMAGE_DIR=$PROJECT_BUILD_ROOT/../framework
	if [ ! -d $GPUIMAGE_DIR ]; then
		mkdir $GPUIMAGE_DIR
	fi
	IOS_URL=http://ks3-cn-beijing.ksyun.com/ksy.vcloud.sdk/Ios
	GPUPACK=GPUImage.zip
	if [ ! -d "$GPUIMAGE_DIR/GPUImage.framework" ]; then
		echo "download GPUImage.framework"	
		curl ${IOS_URL}/${GPUPACK} -o $GPUIMAGE_DIR/$GPUPACK
		unzip -q $GPUIMAGE_DIR/$GPUPACK -d $GPUIMAGE_DIR
		rm $GPUIMAGE_DIR/$GPUPACK
	fi
	if [ ! -d "$GPUIMAGE_DIR/Bugly.framework" ]; then
		echo "download Bugly.framework for demo"
		curl ${IOS_URL}/Bugly.framework.zip -o $GPUIMAGE_DIR/Bugly.framework.zip
		unzip -q $GPUIMAGE_DIR/Bugly.framework.zip -d $GPUIMAGE_DIR
		rm $GPUIMAGE_DIR/Bugly.framework.zip
	fi
fi

TARGET_NAME=$FRAMEWORKNAME
if [ $TYPE = "dynamic" ]; then
	TARGET_NAME="$TARGET_NAME"Dy
fi
LOG_F=${TARGET_NAME}_build.log

function xBuild() {
PROJ=$1
TARG=$2
SDK=$3

XCODE_BUILD="xcrun xcodebuild"
XCODE_BUILD="$XCODE_BUILD  -configuration Release"
XCODE_BUILD="$XCODE_BUILD  -project ${PROJ}.xcodeproj"
XCODE_BUILD="$XCODE_BUILD  -target  ${TARG}"

echo "=====  building ${PROJ} - ${TARG} @ `date` " | tee -a $LOG_F
$XCODE_BUILD -sdk $SDK clean build  >> $LOG_F
}

function xUniversal() {
TARG=$1
echo "=====  strip & universal - $1 @ `date` " | tee -a $LOG_F
DEV_F=${BUILD_DIR}/${CONFIGURATION}-iphoneos/${TARG}.framework
SIM_F=${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${TARG}.framework
OUT_D=../../framework
if [ ! -d $OUT_D ]; then
	mkdir $OUT_D
fi
OUT_F=${OUT_D}/${TARG}.framework

cp -R ${DEV_F} ${OUT_D}
$XCODE_STRIP -S "${DEV_F}/${TARG}" 2> /dev/null
$XCODE_STRIP -S "${SIM_F}/${TARG}" 2> /dev/null
xcrun lipo -create -output "${OUT_F}/${TARG}" \
                           "${DEV_F}/${TARG}" \
                           "${SIM_F}/${TARG}"
$XCODE_STRIP -S "${OUT_F}/${TARG}"  >> $LOG_F 2>&1
if [ $2 == "dynamic" ]; then
	lipo ${OUT_F}/${TARG} -remove i386 -output ${OUT_F}/${TARG}	
	lipo ${OUT_F}/${TARG} -remove x86_64 -output ${OUT_F}/${TARG}	
fi
xcrun lipo -info "${OUT_F}/${TARG}"
}

cd $PROJECT_NAME
echo "======================"
echo "== build framework ==="
echo "======================"

xBuild  libKSYLive  $TARGET_NAME iphoneos
xBuild  libKSYLive  $TARGET_NAME iphonesimulator
xUniversal $TARGET_NAME $TYPE 
