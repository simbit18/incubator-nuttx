#!/usr/bin/env sh
############################################################################
# tools/ci/platforms/alpine.sh
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

# Alpine

set -e
set -o xtrace

add_path() {
  PATH=$1:${PATH}
}

arm_clang_toolchain() {
  if ! type clang > /dev/null 2>&1; then
    apk --no-cache --update add clang
  fi
  
  which clang
  clang --version
}

arm_gcc_toolchain() {
  if ! type arm-none-eabi-gcc > /dev/null 2>&1; then
    apk --no-cache --update add clang gcc-arm-none-eabi \
          newlib-arm-none-eabi \
          g++-arm-none-eabi
  fi

  which arm-none-eabi-gcc
  arm-none-eabi-gcc --version
}

arm64_gcc_toolchain() {
  if ! type aarch64-none-elf-gcc > /dev/null 2>&1; then
    apk --no-cache --update add gcc-aarch64-none-elf
  fi
  
  aarch64-none-elf-gcc --version
}

avr_gcc_toolchain() {
  if ! type avr-gcc > /dev/null 2>&1; then
    apk --no-cache --update add gcc-avr
  fi

  avr-gcc --version
}

# function binutils {
  # if ! type objcopy &> /dev/null; then
    # sudo apt-get install -y binutils-dev
  # fi

  # command objcopy --version
# }

bloaty() {
  add_path "${NUTTXTOOLS}"/bloaty/bin

  if [ ! -f "${NUTTXTOOLS}/bloaty/bin/bloaty" ]; then
    git clone --depth 1 --branch v1.1 https://github.com/google/bloaty "${NUTTXTOOLS}"/bloaty-src
    mkdir -p "${NUTTXTOOLS}"/bloaty
    cd "${NUTTXTOOLS}"/bloaty-src
    cmake -B build -DCMAKE_INSTALL_PREFIX="${NUTTXTOOLS}"/bloaty
    cmake --build build
    cmake --build build --target install
    cd "${NUTTXTOOLS}"
    rm -rf bloaty-src
    ls -a "${NUTTXTOOLS}"/bloaty
  fi

  command bloaty --version
}

c_cache() {
  if ! type ccache > /dev/null 2>&1; then
    apk --no-cache --update add ccache
  fi
  setup_links
  command ccache --version
}

# function clang-tidy {
  # to-do
  # clang-tidy binary is available in the package clang-extra-tools in edge/main.
  # clang17-extra-tools
  # if ! type clang-tidy &> /dev/null; then
    # apk --no-cache --update add clang17-extra-tools
  # fi

  # command clang-tidy --version
# }

# function util-linux {
  # if ! type flock &> /dev/null; then
    # sudo apt-get install -y util-linux
  # fi

  # command flock --version
# }

gen_romfs() {
  add_path "${NUTTXTOOLS}"/genromfs/usr/bin

  if ! type genromfs > /dev/null 2>&1; then
    git clone https://bitbucket.org/nuttx/tools.git "${NUTTXTOOLS}"/nuttx-tools
    cd "${NUTTXTOOLS}"/nuttx-tools
    tar zxf genromfs-0.5.2.tar.gz
    cd genromfs-0.5.2
    make install PREFIX="${NUTTXTOOLS}"/genromfs
    cd "${NUTTXTOOLS}"
    rm -rf nuttx-tools
  fi
}

# function gperf {
 # if ! type gperf &> /dev/null; then
    # sudo apt-get install -y gperf
  # fi

# }

kconfig_frontends() {
  add_path "${NUTTXTOOLS}"/kconfig-frontends/bin

  if [ ! -f "${NUTTXTOOLS}/kconfig-frontends/bin/kconfig-conf" ]; then
    git clone https://bitbucket.org/nuttx/tools.git "${NUTTXTOOLS}"/nuttx-tools
    cd "${NUTTXTOOLS}"/nuttx-tools/kconfig-frontends
    ./configure --prefix="${NUTTXTOOLS}"/kconfig-frontends \
      --enable-mconf --disable-nconf --disable-gconf --disable-qconf
    ln -s /usr/bin/aclocal /usr/local/bin/aclocal-1.15
    ln -s /usr/bin/automake /usr/local/bin/automake-1.15
    make install
    cd "${NUTTXTOOLS}"
    rm -rf nuttx-tools
  fi
}

# function mips-gcc-toolchain {
  # add_path "${NUTTXTOOLS}"/pinguino-compilers/p32/bin

  # if [ ! -d "${NUTTXTOOLS}/pinguino-compilers/p32/bin/p32-gcc" ]; then
    # local basefile
    # basefile=pinguino-linux64-p32
    # mkdir -p "${NUTTXTOOLS}"/pinguino-compilers
    # cd "${NUTTXTOOLS}"
    # # Download the latest pinguino toolchain prebuilt by 32bit
    # curl -O -L -s  https://github.com/PinguinoIDE/pinguino-compilers/releases/download/v20.10/${basefile}.zip
    # unzip -qo ${basefile}.zip
    # mv p32 "${NUTTXTOOLS}"/pinguino-compilers/p32
    # rm ${basefile}.zip
  # fi

  # command p32-gcc --version
# }

# function riscv-gcc-toolchain {
  # add_path "${NUTTXTOOLS}"/riscv-none-elf-gcc/bin

  # if [ ! -f "${NUTTXTOOLS}/riscv-none-elf-gcc/bin/riscv-none-elf-gcc" ]; then
    # ## Add glibc-to-musl compatibility, because xPack GCC was compiled for glibc
    # ## From https://github.com/sgerrand/alpine-pkg-glibc
    # wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
    # wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r1/glibc-2.35-r1.apk
    # apk add glibc-2.35-r1.apk

    # local basefile
    # basefile=xpack-riscv-none-elf-gcc-13.2.0-2-linux-x64
    # cd "${NUTTXTOOLS}"
    # # Download the latest RISCV GCC toolchain prebuilt by xPack
    # wget --quiet https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/download/v13.2.0-2/${basefile}.tar.gz
    # tar zxf ${basefile}.tar.gz
    # mv xpack-riscv-none-elf-gcc-13.2.0-2 riscv-none-elf-gcc
    # rm ${basefile}.tar.gz
  # fi
  # command riscv-none-elf-gcc --version
# }

rust() {
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

# function sparc-gcc-toolchain {
  # add_path "${NUTTXTOOLS}"/sparc-gaisler-elf-gcc/bin

  # if [ ! -f "${NUTTXTOOLS}/sparc-gaisler-elf-gcc/bin/sparc-gaisler-elf-gcc" ]; then
    # local basefile
    # basefile=bcc-2.1.0-gcc-linux64
    # cd "${NUTTXTOOLS}"
    # # Download the SPARC GCC toolchain prebuilt by Gaisler
    # wget --quiet https://www.gaisler.com/anonftp/bcc2/bin/${basefile}.tar.xz
    # xz -d ${basefile}.tar.xz
    # tar xf ${basefile}.tar
    # mv bcc-2.1.0-gcc sparc-gaisler-elf-gcc
    # rm ${basefile}.tar
  # fi

  # command sparc-gaisler-elf-gcc --version
# }

# function xtensa-esp32-gcc-toolchain {
  # add_path "${NUTTXTOOLS}"/xtensa-esp32-elf/bin

  # if [ ! -f "${NUTTXTOOLS}/xtensa-esp32-elf/bin/xtensa-esp32-elf-gcc" ]; then
    # local basefile
    # basefile=xtensa-esp32-elf-12.2.0_20230208-x86_64-linux-gnu
    # cd "${NUTTXTOOLS}"
    # # Download the latest ESP32 GCC toolchain prebuilt by Espressif
    # wget --quiet https://github.com/espressif/crosstool-NG/releases/download/esp-12.2.0_20230208/${basefile}.tar.xz
    # xz -d ${basefile}.tar.xz
    # tar xf ${basefile}.tar
    # rm ${basefile}.tar
  # fi

  # command xtensa-esp32-elf-gcc --version
# }

# function xtensa-esp32s2-gcc-toolchain {
  # add_path "${NUTTXTOOLS}"/xtensa-esp32s2-elf/bin

  # if [ ! -f "${NUTTXTOOLS}/xtensa-esp32s2-elf/bin/xtensa-esp32s2-elf-gcc" ]; then
    # local basefile
    # basefile=xtensa-esp32s2-elf-12.2.0_20230208-x86_64-linux-gnu
    # cd "${NUTTXTOOLS}"
    # # Download the latest ESP32 S2 GCC toolchain prebuilt by Espressif
    # wget --quiet https://github.com/espressif/crosstool-NG/releases/download/esp-12.2.0_20230208/${basefile}.tar.xz
    # xz -d ${basefile}.tar.xz
    # tar xf ${basefile}.tar
    # rm ${basefile}.tar
  # fi

  # command xtensa-esp32s2-elf-gcc --version
# }

# function xtensa-esp32s3-gcc-toolchain {
  # add_path "${NUTTXTOOLS}"/xtensa-esp32s3-elf/bin

  # if [ ! -f "${NUTTXTOOLS}/xtensa-esp32s3-elf/bin/xtensa-esp32s3-elf-gcc" ]; then
    # local basefile
    # basefile=xtensa-esp32s3-elf-12.2.0_20230208-x86_64-linux-gnu
    # cd "${NUTTXTOOLS}"
    # # Download the latest ESP32 S3 GCC toolchain prebuilt by Espressif
    # wget --quiet https://github.com/espressif/crosstool-NG/releases/download/esp-12.2.0_20230208/${basefile}.tar.xz
    # xz -d ${basefile}.tar.xz
    # tar xf ${basefile}.tar
    # rm ${basefile}.tar
  # fi

  # command xtensa-esp32s3-elf-gcc --version
# }

# function u-boot-tools {
  # if ! type mkimage &> /dev/null; then
    # sudo apt-get install -y u-boot-tools
  # fi
# }

# function wasi-sdk {
  # add_path "${NUTTXTOOLS}"/wamrc

  # if [ ! -f "${NUTTXTOOLS}/wasi-sdk/bin/clang" ]; then
    # local wasibasefile
    # local wasmbasefile
    # wasibasefile=wasi-sdk-19.0-linux
    # wasmbasefile=wamrc-1.1.2-x86_64-ubuntu-20.04
    # cd "${NUTTXTOOLS}"
    # mkdir wamrc

    # # Download the latest WASI-enabled WebAssembly C/C++ toolchain prebuilt by WASM
    # wget --quiet https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-19/${wasibasefile}.tar.gz
    # tar xzf ${wasibasefile}.tar.gz
    # mv wasi-sdk-19.0 wasi-sdk
    # rm ${wasibasefile}.tar.gz
    # cd wamrc
    # # Download the latest "wamrc" AOT compiler prebuilt by WAMR
    # wget --quiet https://github.com/bytecodealliance/wasm-micro-runtime/releases/download/WAMR-1.1.2/${wasmbasefile}.tar.gz
    # tar xzf ${wasmbasefile}.tar.gz
    # rm ${wasmbasefile}.tar.gz

  # fi

  # export WASI_SDK_PATH="${NUTTXTOOLS}/wasi-sdk"
  # echo "export WASI_SDK_PATH=${NUTTXTOOLS}/wasi-sdk" >> "${NUTTXTOOLS}"/env.sh

  # command "${WASI_SDK_PATH}"/bin/clang --version
  # command wamrc --version
# }

setup_links() {
  # Configure ccache
  mkdir -p "${NUTTXTOOLS}"/ccache/bin/
  ln -sf "$(which ccache)" "${NUTTXTOOLS}"/ccache/bin/aarch64-none-elf-gcc
  ln -sf "$(which ccache)" "${NUTTXTOOLS}"/ccache/bin/aarch64-none-elf-g++
  ln -sf "$(which ccache)" "${NUTTXTOOLS}"/ccache/bin/arm-none-eabi-gcc
  ln -sf "$(which ccache)" "${NUTTXTOOLS}"/ccache/bin/arm-none-eabi-g++
  ln -sf "$(which ccache)" "${NUTTXTOOLS}"/ccache/bin/avr-gcc
  ln -sf "$(which ccache)" "${NUTTXTOOLS}"/ccache/bin/avr-g++
  ln -sf "$(which ccache)" "${NUTTXTOOLS}"/ccache/bin/cc
  ln -sf "$(which ccache)" "${NUTTXTOOLS}"/ccache/bin/c++
  ln -sf "$(which ccache)" "${NUTTXTOOLS}"/ccache/bin/clang
  ln -sf "$(which ccache)" "${NUTTXTOOLS}"/ccache/bin/clang++
  ln -sf "$(which ccache)" "${NUTTXTOOLS}"/ccache/bin/gcc
  ln -sf "$(which ccache)" "${NUTTXTOOLS}"/ccache/bin/g++
#  ln -sf "$(which ccache)" "${NUTTXTOOLS}"/ccache/bin/p32-gcc
#  ln -sf "$(which ccache)" "${NUTTXTOOLS}"/ccache/bin/rx-elf-gcc
#  ln -sf "$(which ccache)" "${NUTTXTOOLS}"/ccache/bin/riscv-none-elf-gcc
#  ln -sf "$(which ccache)" "${NUTTXTOOLS}"/ccache/bin/riscv-none-elf-g++
#  ln -sf "$(which ccache)" "${NUTTXTOOLS}"/ccache/bin/sparc-gaisler-elf-gcc
#  ln -sf "$(which ccache)" "${NUTTXTOOLS}"/ccache/bin/sparc-gaisler-elf-g++
  ln -sf "$(which ccache)" "${NUTTXTOOLS}"/ccache/bin/x86_64-elf-gcc
  ln -sf "$(which ccache)" "${NUTTXTOOLS}"/ccache/bin/x86_64-elf-g++
#  ln -sf "$(which ccache)" "${NUTTXTOOLS}"/ccache/bin/xtensa-esp32-elf-gcc
#  ln -sf "$(which ccache)" "${NUTTXTOOLS}"/ccache/bin/xtensa-esp32-elf-g++
#  ln -sf "$(which ccache)" "${NUTTXTOOLS}"/ccache/bin/xtensa-esp32s2-elf-gcc
#  ln -sf "$(which ccache)" "${NUTTXTOOLS}"/ccache/bin/xtensa-esp32s2-elf-g++
#  ln -sf "$(which ccache)" "${NUTTXTOOLS}"/ccache/bin/xtensa-esp32s3-elf-gcc
#  ln -sf "$(which ccache)" "${NUTTXTOOLS}"/ccache/bin/xtensa-esp32s3-elf-g++
}

install_build_tools() {
  mkdir -p "${NUTTXTOOLS}"
  echo "#!/usr/bin/env sh" > "${NUTTXTOOLS}"/env.sh

  install="arm_clang_toolchain arm_gcc_toolchain arm64_gcc_toolchain avr_gcc_toolchain gen_romfs kconfig_frontends rust c_cache"

  oldpath=$(cd . && pwd -P)
  echo "${oldpath}"
  for func in ${install}; do
    ${func}
  done
  echo "${oldpath}"
  cd "${oldpath}"

  echo "PATH=${PATH}" >> "${NUTTXTOOLS}"/env.sh
  echo "export PATH" >> "${NUTTXTOOLS}"/env.sh
}

install_build_tools
