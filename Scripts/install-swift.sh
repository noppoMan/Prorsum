#!/usr/bin/env bash

VERSION="5.0.3"

# Determine OS
UNAME=`uname`;
if [[ $UNAME == "Darwin" ]];
then
    OS="macos";
else
    if [[ $UNAME == "Linux" ]];
    then
        UBUNTU_RELEASE=`lsb_release -a 2>/dev/null`;
        if [[ $UBUNTU_RELEASE == *"16.04"* ]];
        then
            OS="ubuntu1604";
        else
            OS="ubuntu1404";
        fi
    fi
fi

if [[ $OS != "macos" ]];
then
    sudo apt-get install -y clang libicu-dev uuid-dev

    if [[ $OS == "ubuntu1604" ]];
    then
        SWIFTFILE="swift-$VERSION-RELEASE-ubuntu16.04";
    else
        SWIFTFILE="swift-$VERSION-RELEASE-ubuntu14.04";
    fi
    wget https://swift.org/builds/swift-$VERSION-release/$OS/swift-$VERSION-RELEASE/$SWIFTFILE.tar.gz
    tar -zxf $SWIFTFILE.tar.gz
    export PATH=$PWD/$SWIFTFILE/usr/bin:"${PATH}"
fi
