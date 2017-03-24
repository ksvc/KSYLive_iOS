#! /bin/bash

USER_KEY=$1
API_KEY=$2
alias sed='sed -i "" -E '
echo "=================== prepare demo (with 265 enabled) @ `date`==================="
cd demo
sed "s@(live\')@live_265\'@"  Podfile
pod install

echo "=================== archive demo @ `date`==================="
sed "s@(CODE_SIGN_ID.*iPhone) Developer@\1 Distribution@" \
	KSYLiveDemo.xcodeproj/project.pbxproj
sed "s@(PROVISIONING_PROFILE)(.*);@\1 = \"64ac3c36-4e3c-4446-b519-fec904348a3b\";@" \
	KSYLiveDemo.xcodeproj/project.pbxproj

xcodebuild -workspace *.xcwork*  -quiet  \
		   -scheme KSYLiveDemo archive   \
		   -archivePath `pwd`/archiveDir \
		   -configuration Release        \
		   DEVELOPMENT_TEAM=36PUU93BJ2

echo "=================== create plist  @ `date`==================="
cat <<EOF >export.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>teamID</key>
        <string>36PUU93BJ2</string>
        <key>method</key>
        <string>enterprise</string>
</dict>
</plist>
EOF

echo "=================== exportArchive demo @ `date`==================="
if which xcbuilds > /dev/null 2>&1; then
    # rvm issue https://openradar.appspot.com/28726736
    # [xcbuilds](https://github.com/fastlane/fastlane/blob/master/gym/lib/assets/wrap_xcodebuild/xcbuild-safe.sh)
    XCB=xcbuilds
else
	XCB=xcodebuild
fi
${XCB} -exportArchive -exportPath . \
		   -archivePath archiveDir.xcarchive  \
		   -exportOptionsPlist  export.plist

echo "=================== upload ipa  @ `date`==================="
curl -F "file=@`pwd`/KSYLiveDemo.ipa" \
	 -F "uKey=${USER_KEY}" \
	 -F "_api_key=${API_KEY}" \
	 https://qiniu-storage.pgyer.com/apiv1/app/upload 

echo "=================== done  @ `date` ==================="
