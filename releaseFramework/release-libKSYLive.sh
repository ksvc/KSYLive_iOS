#! /bin/sh

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
echo "  $0 name format [dy]"
echo ""
echo "PARAM:"
echo "name  :   KSYMediaPlayer - build player framework"
echo "      libksygpulive  - build live framework"
echo "format  :     lite - only support common media format"
echo "      265  - contain 265 codec"
echo "      vod  - support most media format" 
echo "[dy]  :   if exist, build a dynamic framework, otherwise, build a static framework" 
echo ""
echo "FOR EXAMPLE:"
echo "$0 KSYMediaPlayer lite    : build a static player framework which name is "KSYMediaPlayer.framework", only support common media format"
echo "$0 KSYMediaPlayer vod     : build a static player framework which name is "KSYMediaPlayer.framework", support most media format"
echo "$0 KSYMediaPlayer lite dy  : build a dynamic player framework which name is "KSYMediaPlayer.framework", only support common media format"
echo "$0 KSYMediaPlayer vod dy  : build a dynamic player framework which name is "KSYMediaPlayer.framework", support most media format"
echo "$0 libksygpulive lite     : build a static live framework which name is "libksygpulive.framework", only support common media format"
echo "$0 libksygpulive 265  : build a static live framework which name is "libksygpulive.framework", contain 265 codec"
echo "$0 libksygpulive lite dy  : build a dynamic live framework which name is "libksygpulive.framework", only suport common media format"
echo "$0 libksygpulive 265 dy   : build a dynamic live framework which name is "libksygpulive.framework", contain 265 codec"
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

function xDownload() {
    FILE_NAME=$1
    SUB_DIR=$2

    DST_DIR=${FRAMEWORK_DIR}/${SUB_DIR}
    mkdir -p ${DST_DIR}

    IOS_URL=http://ks3-cn-beijing.ksyun.com/ksy.vcloud.sdk/Ios/${SUB_DIR}${FILE_NAME}.zip
    ZIP_FILE=${DST_DIR}/${SUB_DIR}${FILE_NAME}.zip

    if [ ! -d "${DST_DIR}/${FILE_NAME}.framework" ]; then
        echo "download ${FILE_NAME}.framework to ${DST_DIR}"
        curl ${IOS_URL} -o ${ZIP_FILE}
        unzip -q ${ZIP_FILE} -d ${DST_DIR}/
        rm ${ZIP_FILE}
    fi
}

if [ $FRAMEWORKNAME = "libksygpulive" ]; then
    FRAMEWORK_DIR=$PROJECT_BUILD_ROOT/../framework
    if [ ! -d $FRAMEWORK_DIR ]; then
        mkdir $FRAMEWORK_DIR
    fi
	
	xDownload GPUImage $TYPE
	xDownload Bugly    ""
fi

TARGET_NAME=$FRAMEWORKNAME
LOG_F=${TARGET_NAME}_build.log

PLAYER_DEPS="-lksybase -lksyplayer -lksymediacore_dec"
LIVE_DEPS="-lksybase  -lksyyuv -lksyplayer"
LIVE_DEPS="${LIVE_DEPS} -lksystreamerbase -lksystreamerengine -lksygpufilter"
LIVE_DEPS="${LIVE_DEPS} -lksymediacore_enc -lksymediacore_enc_base"
LIVE_DEPS_DEV="${LIVE_DEPS} -lksymediacodec"
LIVE_DEPS_SIM="${LIVE_DEPS}"

LD_FLAGS="-all_load -lstdc++.6 -lz"
LIB_FLAGS=""
if [ $FRAMEWORKNAME == "KSYMediaPlayer" ]; then
    LIB_FLAGS_DEV="${LIB_FLAGS} ${PLAYER_DEPS}"
    LD_FLAGS_DEV="${LD_FLAGS} ${PLAYER_DEPS} -lbz2 "
    LIB_FLAGS_SIM="${LIB_FLAGS} ${PLAYER_DEPS}"
    LD_FLAGS_SIM="${LD_FLAGS} ${PLAYER_DEPS} -lbz2 "
elif [ $FRAMEWORKNAME == "libksygpulive" ]; then
    LIB_FLAGS_DEV="${LIB_FLAGS} ${LIVE_DEPS_DEV}"
    LD_FLAGS_DEV="${LD_FLAGS} -framework GPUImage ${LIVE_DEPS_DEV}"
    LIB_FLAGS_SIM="${LIB_FLAGS} ${LIVE_DEPS_SIM}"
    LD_FLAGS_SIM="${LD_FLAGS} -framework GPUImage ${LIVE_DEPS_SIM}"
fi

XCODE_CONFIG=${FRAMEWORKNAME}.xcconfig
function xGenConfig() {
    echo "// ${XCODE_CONFIG} ${TYPE}"        > $1
    if [ $TYPE == "static" ]; then
        echo "MACH_O_TYPE=staticlib"        >> $1
        echo "OTHER_LIBTOOLFLAGS[sdk=iphoneos*]=${LIB_FLAGS_DEV}"  >> $1
        echo "OTHER_LIBTOOLFLAGS[sdk=iphonesimulator*]=${LIB_FLAGS_SIM}"  >> $1
    elif [ $TYPE == "dynamic" ]; then
        echo "OTHER_LDFLAGS[sdk=iphoneos*]=${LD_FLAGS_DEV}"        >> $1
        echo "OTHER_LDFLAGS[sdk=iphonesimulator*]=${LD_FLAGS_SIM}" >> $1
        echo "IPHONEOS_DEPLOYMENT_TARGET=8.0" >> $1
    fi
    echo "FRAMEWORK_SEARCH_PATHS=../../framework/${TYPE}"   >> $1
}

function xBuild() {
PROJ=$1
TARG=$2
SDK=$3

XCODE_BUILD="xcrun xcodebuild"
XCODE_BUILD="$XCODE_BUILD  -configuration Release"
XCODE_BUILD="$XCODE_BUILD  -project ${PROJ}.xcodeproj"
XCODE_BUILD="$XCODE_BUILD  -target  ${TARG}"
XCODE_BUILD="$XCODE_BUILD  -sdk     ${SDK}"

echo "=====  building ${PROJ} - ${TARG} - ${SDK} @ `date` " | tee -a $LOG_F
xGenConfig ${XCODE_CONFIG}
$XCODE_BUILD clean build -xcconfig ${XCODE_CONFIG}  >> $LOG_F
}

function xUniversal() {
TARG=$1
CTYPE=$2
echo "=====  strip & universal - $1 @ `date` " | tee -a $LOG_F
DEV_F=${BUILD_DIR}/${CONFIGURATION}-iphoneos/${TARG}.framework
SIM_F=${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${TARG}.framework
OUT_D=../../framework/$CTYPE
if [ ! -d $OUT_D ]; then
    mkdir -p $OUT_D
fi
OUT_F=${OUT_D}/${TARG}.framework

cp -R ${DEV_F} ${OUT_D}
$XCODE_STRIP -S "${DEV_F}/${TARG}" 2> /dev/null
file "${DEV_F}/${TARG}"
$XCODE_STRIP -S "${SIM_F}/${TARG}" 2> /dev/null
file "${SIM_F}/${TARG}"
xcrun lipo -create -output "${OUT_F}/${TARG}" \
                           "${DEV_F}/${TARG}" \
                           "${SIM_F}/${TARG}"
xcrun lipo -info "${OUT_F}/${TARG}"
file "${OUT_F}/${TARG}"
}

cd $PROJECT_NAME
echo "======================"
echo "== build framework ==="
echo "======================"

xBuild  libKSYLive  $TARGET_NAME iphoneos
xBuild  libKSYLive  $TARGET_NAME iphonesimulator
xUniversal $TARGET_NAME $TYPE 
