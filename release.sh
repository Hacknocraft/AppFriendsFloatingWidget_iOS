#!/bin/sh

# by default, just increase the version number by 1
PROJECT_DIR="./"
INFOPLIST_FILE="AppFriendsFloatingWidget/Info.plist"
VERSIONNUM=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "${PROJECT_DIR}/${INFOPLIST_FILE}")
NEWSUBVERSION=`echo $VERSIONNUM | awk -F "." '{print $3}'`
NEWSUBVERSION=$(($NEWSUBVERSION + 1))
NEWVERSIONSTRING=`echo $VERSIONNUM | awk -F "." '{print $1 "." $2 ".'$NEWSUBVERSION'" }'`
# see if the we want to customize the release version
inputVersionString=""
echo -n "Enter the release version (skip to auto-version) > "
read inputVersionString
size=${#inputVersionString}
if test $size -gt 0;
then
NEWVERSIONSTRING=${inputVersionString}
fi
echo "releasing version: ${NEWVERSIONSTRING}"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $NEWVERSIONSTRING" "${PROJECT_DIR}/${INFOPLIST_FILE}"

commit to github
git commit -a -m "commit release ${NEWVERSIONSTRING}"
git push
git tag -a ${NEWVERSIONSTRING} -m "release ${NEWVERSIONSTRING}"
git push --tag
echo "released version: ${NEWVERSIONSTRING}, don't forget to update the https://github.com/Hacknocraft/hacknocraft-cocoapods-spec"
