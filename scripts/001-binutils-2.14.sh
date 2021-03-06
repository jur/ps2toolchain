#!/bin/sh
# binutils-2.14.sh by Dan Peori (danpeori@oopo.net)

 ## Download the source code.
 SOURCE=https://cloud.github.com/downloads/ps2dev/ps2toolchain/binutils-2.14.tar.bz2
 NAME="`basename \"$SOURCE\"`"
 set -x
 wget --continue --no-check-certificate $SOURCE || curl -o "$NAME" "$SOURCE" || { exit 1; }

 BASENAME=binutils-2.24
 FILENAME="$BASENAME.tar.bz2"
 SOURCE="http://kernelloader.cvs.sourceforge.net/viewvc/kernelloader/linux/src/$FILENAME?revision=1.1"
 wget --continue --no-check-certificate -O "$FILENAME" "$SOURCE" || curl -o "$FILENAME" "$SOURCE" || { exit 1; }

 ## Unpack the source code.
 rm -Rf binutils-2.14 && tar xfvj binutils-2.14.tar.bz2 || { exit 1; }
 rm -Rf "$BASENAME" && tar xfvj "$FILENAME" || { exit 1; }

 ## Enter the source directory and patch the source code.
 cd "$BASENAME" || { exit 1; }
 if [ -e ../patches/$BASENAME-PS2.patch ]; then
 	cat ../../patches/$BASENAME-PS2.patch | patch -p1 || { exit 1; }
 fi

 ## For each target that supports new toolchain...
 for TARGET in "ee"; do

  ## Create and enter the build directory.
  mkdir "build-$TARGET" && cd "build-$TARGET" || { exit 1; }

  ## Configure the build.
  ../configure --prefix="$PS2DEV/$TARGET" --target="mips64r5900el-ps2-elf" --program-prefix="$EE_TOOL_PREFIX" || { exit 1; }

  ## Compile and install.
  make clean && make -j 8 && make install && make clean || { exit 1; }

  ## Exit the build directory.
  cd .. || { exit 1; }

 ## End target.
 done

 cd ..

 ## Enter the source directory and patch the source code.
 cd binutils-2.14 && cat ../../patches/binutils-2.14-PS2.patch | patch -p1 || { exit 1; }

 ## For each target that only supports old toolchain...
 for TARGET in "iop" "dvp"; do

  ## Create and enter the build directory.
  mkdir "build-$TARGET" && cd "build-$TARGET" || { exit 1; }

  ## Configure the build.
  CFLAGS="-O0" ../configure --prefix="$PS2DEV/$TARGET" --target="$TARGET" || { exit 1; }

  ## Compile and install.
  make clean && make -j 8 && make install && make clean || { exit 1; }

  ## Exit the build directory.
  cd .. || { exit 1; }

 ## End target.
 done

