#!/usr/bin/env bash
############################################################################
# tools/ci/platforms/fedora.sh
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.  The
# ASF licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.
#
############################################################################

# Fedora

set -e
set -o xtrace

WD=$(cd "$(dirname "$0")" && pwd)
WORKSPACE=$(cd "${WD}"/../../../../ && pwd -P)
tools=${WORKSPACE}/tools
EXTRA_PATH=

function add_path {
  PATH=$1:${PATH}
  EXTRA_PATH=$1:${EXTRA_PATH}
}

function arm-clang-toolchain {
  add_path "${tools}"/clang-arm-none-eabi/bin

  if [ ! -f "${tools}/clang-arm-none-eabi/bin/clang" ]; then
    local basefile
    basefile=LLVMEmbeddedToolchainForArm-17.0.1-Linux-x86_64
    cd "${tools}"
    # Download the latest ARM clang toolchain prebuilt by ARM
    curl -O -L -s https://github.com/ARM-software/LLVM-embedded-toolchain-for-Arm/releases/download/release-17.0.1/${basefile}.tar.xz
    xz -d ${basefile}.tar.xz
    tar xf ${basefile}.tar
    mv ${basefile} clang-arm-none-eabi
    rm ${basefile}.tar
  fi

  command clang --version
}

function arm-gcc-toolchain {
  add_path "${tools}"/gcc-arm-none-eabi/bin

  if [ ! -f "${tools}/gcc-arm-none-eabi/bin/arm-none-eabi-gcc" ]; then
    local basefile
    basefile=arm-gnu-toolchain-13.2.Rel1-x86_64-arm-none-eabi
    cd "${tools}"
    # Download the latest ARM GCC toolchain prebuilt by ARM
    wget --quiet https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/binrel/${basefile}.tar.xz
    xz -d ${basefile}.tar.xz
    tar xf ${basefile}.tar
    mv ${basefile} gcc-arm-none-eabi
    rm ${basefile}.tar
  fi

  command arm-none-eabi-gcc --version
}

function arm64-gcc-toolchain {
  add_path "${tools}"/gcc-aarch64-none-elf/bin

  if [ ! -f "${tools}/gcc-aarch64-none-elf/bin/aarch64-none-elf-gcc" ]; then
    local basefile
    basefile=arm-gnu-toolchain-13.2.Rel1-x86_64-aarch64-none-elf
    cd "${tools}"
    # Download the latest ARM64 GCC toolchain prebuilt by ARM
    wget --quiet https://developer.arm.com/-/media/Files/downloads/gnu/13.2.Rel1/binrel/${basefile}.tar.xz
    xz -d ${basefile}.tar.xz
    tar xf ${basefile}.tar
    mv ${basefile} gcc-aarch64-none-elf
    rm ${basefile}.tar
  fi

  command aarch64-none-elf-gcc --version
}

function avr-gcc-toolchain {
  if ! type avr-gcc &> /dev/null; then
    # avr-gcc-c++ 
    dnf -y install avr-binutils avr-gcc avr-libc
  fi

  command avr-gcc --version
}

# function binutils {
  # if ! type objcopy &> /dev/null; then
    # sudo apt-get install -y binutils-dev
  # fi

  # command objcopy --version
# }

function bloaty {
# todo
  # if ! type bloaty &> /dev/null; then
    # dnf -y install bloaty
  # fi
  add_path "${NUTTXTOOLS}"/bloaty/bin
  if [ ! -f "${tools}/bloaty/bin/bloaty" ]; then
    git clone https://github.com/google/bloaty "${tools}"/bloaty-src
    mkdir -p "${tools}"/bloaty
    cd "${tools}"/bloaty-src
    cmake -B build -DCMAKE_INSTALL_PREFIX="${tools}"/bloaty
    cmake --build build
    cmake --build build --target install
    cd "${tools}"
    rm -rf bloaty-src
    ls -a "${tools}"/bloaty
  fi

  command bloaty --version
}

function c-cache {
  if ! type ccache &> /dev/null; then
    dnf -y install ccache
  fi
  setup_links
  command ccache --version
}

function clang-tidy {
  if ! type clang &> /dev/null; then
    dnf -y install clang clang-tools-extra
  fi

  command clang --version
}

# function util-linux {
  # if ! type flock &> /dev/null; then
    # sudo apt-get install -y util-linux
  # fi

  # command flock --version
# }

# function gen-romfs {
  # if ! type genromfs &> /dev/null; then
    # sudo apt-get install -y genromfs
  # fi
# }

# function gperf {
 # if ! type gperf &> /dev/null; then
    # sudo apt-get install -y gperf
  # fi

# }

function kconfig-frontends {
  add_path "${tools}"/kconfig-frontends/bin

  if [ ! -f "${tools}/kconfig-frontends/bin/kconfig-conf" ]; then
    git clone https://bitbucket.org/nuttx/tools.git "${tools}"/nuttx-tools
    cd "${tools}"/nuttx-tools/kconfig-frontends
    ./configure --prefix="${tools}"/kconfig-frontends \
      --disable-kconfig --disable-nconf --disable-qconf \
      --disable-gconf --disable-mconf --disable-static \
      --disable-shared --disable-L10n
    # Avoid "aclocal/automake missing" errors
    touch aclocal.m4 Makefile.in
    make install
    cd "${tools}"
    rm -rf nuttx-tools
  fi
}

function mips-gcc-toolchain {
  add_path "${tools}"/pinguino-compilers/p32/bin

  if [ ! -d "${tools}/pinguino-compilers/p32/bin/p32-gcc" ]; then
    local basefile
    basefile=pinguino-linux64-p32
    mkdir -p "${tools}"/pinguino-compilers
    cd "${tools}"
    # Download the latest pinguino toolchain prebuilt by 32bit
    curl -O -L -s  https://github.com/PinguinoIDE/pinguino-compilers/releases/download/v20.10/${basefile}.zip
    unzip -qo ${basefile}.zip
    mv p32 "${tools}"/pinguino-compilers/p32
    rm ${basefile}.zip
  fi

  command p32-gcc --version
}

function python-tools {

  pip3 install \
    cxxfilt \
    esptool \
    imgtool \
    kconfiglib
}

function riscv-gcc-toolchain {
  add_path "${tools}"/riscv-none-elf-gcc/bin

  if [ ! -f "${tools}/riscv-none-elf-gcc/bin/riscv-none-elf-gcc" ]; then
    local basefile
    basefile=xpack-riscv-none-elf-gcc-13.2.0-2-linux-x64
    cd "${tools}"
    # Download the latest RISCV GCC toolchain prebuilt by xPack
    wget --quiet https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/download/v13.2.0-2/${basefile}.tar.gz
    tar zxf ${basefile}.tar.gz
    mv xpack-riscv-none-elf-gcc-13.2.0-2 riscv-none-elf-gcc
    rm ${basefile}.tar.gz
  fi
  command riscv-none-elf-gcc --version
}

function rust {
  add_path "${NUTTXTOOLS}"/rust/cargo/bin
  # Configuring the PATH environment variable
  export CARGO_HOME=${NUTTXTOOLS}/rust/cargo
  export RUSTUP_HOME=${NUTTXTOOLS}/rust/rustup
  echo "export CARGO_HOME=${NUTTXTOOLS}/rust/cargo" >> "${NUTTXTOOLS}"/env.sh
  echo "export RUSTUP_HOME=${NUTTXTOOLS}/rust/rustup" >> "${NUTTXTOOLS}"/env.sh
  if ! type rustc > /dev/null 2>&1; then
    # Install Rust target x86_64-unknown-linux-musl
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --no-modify-path -y
    # Install targets supported from NuttX
    "$CARGO_HOME"/bin/rustup target add thumbv6m-none-eabi
    "$CARGO_HOME"/bin/rustup target add thumbv7m-none-eabi
    
  fi

  command rustc --version
}

function rx-gcc-toolchain {
  add_path "${tools}"/renesas-toolchain/rx-elf-gcc/bin

  if [ ! -f "${tools}/renesas-toolchain/rx-elf-gcc/bin/rx-elf-gcc" ]; then
    # Download toolchain source code
    # RX toolchain is built from source code. Once prebuilt RX toolchain is made available, the below code snippet can be removed.
    local basefilebinutils
    local basefilegcc
    local basefilenewlib
    basefilebinutils=binutils-2.36.1
    basefilegcc=gcc-8.3.0
    basefilenewlib=newlib-4.1.0

    mkdir -p "${tools}"/renesas-tools/source
    curl -L -s "https://llvm-gcc-renesas.com/downloads/d.php?f=rx/binutils/8.3.0.202305-gnurx/binutils-2.36.1.tar.gz" -o ${basefilebinutils}.tar.gz
    tar zxf ${basefilebinutils}.tar.gz
    mv ${basefilebinutils} "${tools}"/renesas-tools/source/binutils
    rm ${basefilebinutils}.tar.gz

    curl -L -s "https://llvm-gcc-renesas.com/downloads/d.php?f=rx/gcc/8.3.0.202305-gnurx/gcc-8.3.0.tar.gz" -o ${basefilegcc}.tar.gz
    tar zxf ${basefilegcc}.tar.gz
    mv ${basefilegcc} "${tools}"/renesas-tools/source/gcc
    rm ${basefilegcc}.tar.gz

    curl -L -s "https://llvm-gcc-renesas.com/downloads/d.php?f=rx/newlib/8.3.0.202305-gnurx/newlib-4.1.0.tar.gz" -o ${basefilenewlib}.tar.gz
    tar zxf ${basefilenewlib}.tar.gz
    mv ${basefilenewlib} "${tools}"/renesas-tools/source/newlib
    rm ${basefilenewlib}.tar.gz

    # Install binutils
    cd "${tools}"/renesas-tools/source/binutils; chmod +x ./configure ./mkinstalldirs
    mkdir -p "${tools}"/renesas-tools/build/binutils; cd "${tools}"/renesas-tools/build/binutils
    "${tools}"/renesas-tools/source/binutils/configure --target=rx-elf --prefix="${tools}"/renesas-toolchain/rx-elf-gcc \
      --disable-werror
    make; make install

    # Install gcc
    cd "${tools}"/renesas-tools/source/gcc
    chmod +x ./contrib/download_prerequisites ./configure ./move-if-change ./libgcc/mkheader.sh
    ./contrib/download_prerequisites
    sed -i '1s/^/@documentencoding ISO-8859-1\n/' ./gcc/doc/gcc.texi
    sed -i 's/@tex/\n&/g' ./gcc/doc/gcc.texi && sed -i 's/@end tex/\n&/g' ./gcc/doc/gcc.texi
    mkdir -p "${tools}"/renesas-tools/build/gcc; cd "${tools}"/renesas-tools/build/gcc
    "${tools}"/renesas-tools/source/gcc/configure --target=rx-elf --prefix="${tools}"/renesas-toolchain/rx-elf-gcc \
      --disable-shared --disable-multilib --disable-libssp --disable-libstdcxx-pch --disable-werror --enable-lto \
      --enable-gold --with-pkgversion=GCC_Build_1.02 --with-newlib --enable-languages=c
    make; make install

    # Install newlib
    cd "${tools}"/renesas-tools/source/newlib; chmod +x ./configure
    mkdir -p "${tools}"/renesas-tools/build/newlib; cd "${tools}"/renesas-tools/build/newlib
    "${tools}"/renesas-tools/source/newlib/configure --target=rx-elf --prefix="${tools}"/renesas-toolchain/rx-elf-gcc
    make; make install
    rm -rf "${tools}"/renesas-tools/
  fi

  command rx-elf-gcc --version
}

function sparc-gcc-toolchain {
  add_path "${tools}"/sparc-gaisler-elf-gcc/bin

  if [ ! -f "${tools}/sparc-gaisler-elf-gcc/bin/sparc-gaisler-elf-gcc" ]; then
    local basefile
    basefile=bcc-2.1.0-gcc-linux64
    cd "${tools}"
    # Download the SPARC GCC toolchain prebuilt by Gaisler
    wget --quiet https://www.gaisler.com/anonftp/bcc2/bin/${basefile}.tar.xz
    xz -d ${basefile}.tar.xz
    tar xf ${basefile}.tar
    mv bcc-2.1.0-gcc sparc-gaisler-elf-gcc
    rm ${basefile}.tar
  fi

  command sparc-gaisler-elf-gcc --version
}

function xtensa-esp32-gcc-toolchain {
  add_path "${tools}"/xtensa-esp32-elf/bin

  if [ ! -f "${tools}/xtensa-esp32-elf/bin/xtensa-esp32-elf-gcc" ]; then
    local basefile
    basefile=xtensa-esp32-elf-12.2.0_20230208-x86_64-linux-gnu
    cd "${tools}"
    # Download the latest ESP32 GCC toolchain prebuilt by Espressif
    wget --quiet https://github.com/espressif/crosstool-NG/releases/download/esp-12.2.0_20230208/${basefile}.tar.xz
    xz -d ${basefile}.tar.xz
    tar xf ${basefile}.tar
    rm ${basefile}.tar
  fi

  command xtensa-esp32-elf-gcc --version
}

function xtensa-esp32s2-gcc-toolchain {
  add_path "${tools}"/xtensa-esp32s2-elf/bin

  if [ ! -f "${tools}/xtensa-esp32s2-elf/bin/xtensa-esp32s2-elf-gcc" ]; then
    local basefile
    basefile=xtensa-esp32s2-elf-12.2.0_20230208-x86_64-linux-gnu
    cd "${tools}"
    # Download the latest ESP32 S2 GCC toolchain prebuilt by Espressif
    wget --quiet https://github.com/espressif/crosstool-NG/releases/download/esp-12.2.0_20230208/${basefile}.tar.xz
    xz -d ${basefile}.tar.xz
    tar xf ${basefile}.tar
    rm ${basefile}.tar
  fi

  command xtensa-esp32s2-elf-gcc --version
}

function xtensa-esp32s3-gcc-toolchain {
  add_path "${tools}"/xtensa-esp32s3-elf/bin

  if [ ! -f "${tools}/xtensa-esp32s3-elf/bin/xtensa-esp32s3-elf-gcc" ]; then
    local basefile
    basefile=xtensa-esp32s3-elf-12.2.0_20230208-x86_64-linux-gnu
    cd "${tools}"
    # Download the latest ESP32 S3 GCC toolchain prebuilt by Espressif
    wget --quiet https://github.com/espressif/crosstool-NG/releases/download/esp-12.2.0_20230208/${basefile}.tar.xz
    xz -d ${basefile}.tar.xz
    tar xf ${basefile}.tar
    rm ${basefile}.tar
  fi

  command xtensa-esp32s3-elf-gcc --version
}

# function u-boot-tools {
  # if ! type mkimage &> /dev/null; then
    # sudo apt-get install -y u-boot-tools
  # fi
# }

function wasi-sdk {
  add_path "${tools}"/wamrc

  if [ ! -f "${tools}/wasi-sdk/bin/clang" ]; then
    local wasibasefile
    local wasmbasefile
    wasibasefile=wasi-sdk-19.0-linux
    wasmbasefile=wamrc-1.1.2-x86_64-ubuntu-20.04
    cd "${tools}"
    mkdir -p wamrc

    # Download the latest WASI-enabled WebAssembly C/C++ toolchain prebuilt by WASM
    wget --quiet https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-19/${wasibasefile}.tar.gz
    tar xzf ${wasibasefile}.tar.gz
    mv wasi-sdk-19.0 wasi-sdk
    rm ${wasibasefile}.tar.gz
    cd wamrc
    # Download the latest "wamrc" AOT compiler prebuilt by WAMR
    wget --quiet https://github.com/bytecodealliance/wasm-micro-runtime/releases/download/WAMR-1.1.2/${wasmbasefile}.tar.gz
    tar xzf ${wasmbasefile}.tar.gz
    rm ${wasmbasefile}.tar.gz

  fi

  export WASI_SDK_PATH="${tools}/wasi-sdk"
  echo "export WASI_SDK_PATH=${tools}/wasi-sdk" >> "${tools}"/env.sh

  command "${WASI_SDK_PATH}"/bin/clang --version
  command wamrc --version
}

function setup_links {
  # Configure ccache
  mkdir -p "${tools}"/ccache/bin/
  ln -sf "$(which ccache)" "${tools}"/ccache/bin/aarch64-none-elf-gcc
  ln -sf "$(which ccache)" "${tools}"/ccache/bin/aarch64-none-elf-g++
  ln -sf "$(which ccache)" "${tools}"/ccache/bin/arm-none-eabi-gcc
  ln -sf "$(which ccache)" "${tools}"/ccache/bin/arm-none-eabi-g++
  ln -sf "$(which ccache)" "${tools}"/ccache/bin/avr-gcc
  ln -sf "$(which ccache)" "${tools}"/ccache/bin/avr-g++
  ln -sf "$(which ccache)" "${tools}"/ccache/bin/cc
  ln -sf "$(which ccache)" "${tools}"/ccache/bin/c++
  ln -sf "$(which ccache)" "${tools}"/ccache/bin/clang
  ln -sf "$(which ccache)" "${tools}"/ccache/bin/clang++
  ln -sf "$(which ccache)" "${tools}"/ccache/bin/gcc
  ln -sf "$(which ccache)" "${tools}"/ccache/bin/g++
  ln -sf "$(which ccache)" "${tools}"/ccache/bin/p32-gcc
  ln -sf "$(which ccache)" "${tools}"/ccache/bin/rx-elf-gcc
  ln -sf "$(which ccache)" "${tools}"/ccache/bin/riscv-none-elf-gcc
  ln -sf "$(which ccache)" "${tools}"/ccache/bin/riscv-none-elf-g++
  ln -sf "$(which ccache)" "${tools}"/ccache/bin/sparc-gaisler-elf-gcc
  ln -sf "$(which ccache)" "${tools}"/ccache/bin/sparc-gaisler-elf-g++
  ln -sf "$(which ccache)" "${tools}"/ccache/bin/x86_64-elf-gcc
  ln -sf "$(which ccache)" "${tools}"/ccache/bin/x86_64-elf-g++
  ln -sf "$(which ccache)" "${tools}"/ccache/bin/xtensa-esp32-elf-gcc
  ln -sf "$(which ccache)" "${tools}"/ccache/bin/xtensa-esp32-elf-g++
  ln -sf "$(which ccache)" "${tools}"/ccache/bin/xtensa-esp32s2-elf-gcc
  ln -sf "$(which ccache)" "${tools}"/ccache/bin/xtensa-esp32s2-elf-g++
  ln -sf "$(which ccache)" "${tools}"/ccache/bin/xtensa-esp32s3-elf-gcc
  ln -sf "$(which ccache)" "${tools}"/ccache/bin/xtensa-esp32s3-elf-g++
}

function install_build_tools {
  mkdir -p "${tools}"
  echo "#!/usr/bin/env bash" > "${tools}"/env.sh

  install="arm-clang-toolchain arm-gcc-toolchain arm64-gcc-toolchain avr-gcc-toolchain bloaty clang-tidy kconfig-frontends mips-gcc-toolchain python-tools riscv-gcc-toolchain rust sparc-gcc-toolchain xtensa-esp32-gcc-toolchain wasi-sdk c-cache"

  pushd .
  for func in ${install}; do
    ${func}
  done
  popd

  # echo "#!/usr/bin/env bash" > "${tools}"/env.sh
  echo "PATH=${PATH}" >> "${tools}"/env.sh
  echo "export PATH" >> "${tools}"/env.sh
}

install_build_tools
