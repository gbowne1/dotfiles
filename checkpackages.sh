#!/bin/bash

packages=("libc6" "libgcc1" "libmlt++3" "libmlt6" "libqt5core5a" "libqt5gui5" "libqt5multimedia5" "libqt5network5" "libqt5opengl5" "libqt5qml5" "libqt5quick5" "libqt5quickwidgets5" "libqt5sql5" "libqt5webkit5" "libqt5websockets5" "libqt5widgets5" "libqt5xml5" "libstdc++6" "melt" "qmelt" "shotcut-data")

for pkg in "${packages[@]}"; do
    echo "Checking $pkg"
    apt-cache policy "$pkg"
done
