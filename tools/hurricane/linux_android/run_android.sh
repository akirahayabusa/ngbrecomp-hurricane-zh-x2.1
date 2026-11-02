#!/bin/bash
export PATH=/usr/local/bin:$PATH ANDROID_HOME=$HOME/Android/Sdk JOBS=10
cd $HOME/ngb && bash packaging/android/build.sh > $HOME/android_build.log 2>&1
echo "rc=$?" > $HOME/android_build.done
