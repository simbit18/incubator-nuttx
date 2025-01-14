#!/usr/bin/env pswd
############################################################################
# tools/ci/platforms/windows.ps1
#
# SPDX-License-Identifier: Apache-2.0
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

# windows native

Set-PSDebug -Trace 0

Write-Host "Run windows.ps1 !!!" -ForegroundColor Yellow
Write-Host "======================"
function add_path() {
   param (
        [string]$path
    )
  $env:PATH = "$path;$env:PATH"
}

function arm_clang_toolchain {
Write-Host "arm_clang_toolchain !!!"
  add_path "$NUTTXTOOLS\clang-arm-none-eabi\bin"
  try {
      if (-not (Test-Path -Path "$NUTTXTOOLS\clang-arm-none-eabi\bin\clang.exe")) {
          # Download the file
          $basefile="LLVMEmbeddedToolchainForArm-17.0.1-Windows-x86_64"
          Set-Location "$NUTTXTOOLS"
          # Download the latest ARM clang toolchain prebuilt by ARM
          Invoke-WebRequest -Uri "https://github.com/ARM-software/LLVM-embedded-toolchain-for-Arm/releases/download/release-17.0.1/$basefile.zip" -OutFile "$NUTTXTOOLS\$basefile.zip" -ErrorAction Stop
          Expand-Archive "$NUTTXTOOLS\$basefile.zip"
          Move-Item -Path "$basefile\$basefile" -Destination "clang-arm-none-eabi"
          Remove-Item "$basefile*" -Force
        }
      clang --version
  } catch {
      Write-Error "Failed to download the file: $_"
  }
}

function arm_gcc_toolchain() {
Write-Host "arm_gcc_toolchain !!!"
    add_path "$NUTTXTOOLS\gcc-arm-none-eabi\bin"
    try {
        if (-not (Test-Path -Path "$NUTTXTOOLS\gcc-arm-none-eabi\bin\arm-none-eabi-gcc.exe")) {
            # Download the file
            $basefile="arm-gnu-toolchain-13.2.Rel1-mingw-w64-i686-arm-none-eabi"
            Set-Location "$NUTTXTOOLS"
            # Download the latest ARM GCC toolchain prebuilt by ARM
            Invoke-WebRequest -Uri "https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/binrel/$basefile.zip" -OutFile "$NUTTXTOOLS\$basefile.zip" -ErrorAction Stop
            Expand-Archive "$NUTTXTOOLS\$basefile.zip"
            Move-Item -Path "$basefile\$basefile" -Destination "gcc-arm-none-eabi"
            Remove-Item "$basefile*" -Force
        }
        arm-none-eabi-gcc --version
    } catch {
        Write-Error "Failed to download the file: $_"
    }
}

function arm64_gcc_toolchain() {
Write-Host "arm64_gcc_toolchain !!!"
  add_path "$NUTTXTOOLS\gcc-aarch64-none-elf\bin"
  try {
      if (-not (Test-Path -Path "$NUTTXTOOLS\gcc-aarch64-none-elf\bin\aarch64-none-elf-gcc.exe")) {
          # Download the file
          $basefile="arm-gnu-toolchain-13.2.rel1-mingw-w64-i686-aarch64-none-elf"
          Set-Location "$NUTTXTOOLS"
          # Download the latest ARM64 GCC toolchain prebuilt by ARM
          Invoke-WebRequest -Uri "https://developer.arm.com/-/media/Files/downloads/gnu/13.2.Rel1/binrel/$basefile.zip" -OutFile "$NUTTXTOOLS\$basefile.zip" -ErrorAction Stop
          Expand-Archive "$NUTTXTOOLS\$basefile.zip"
          Move-Item -Path "$basefile\$basefile" -Destination "gcc-aarch64-none-elf"
          Remove-Item "$basefile*" -Force
        }
      aarch64-none-elf-gcc --version
  } catch {
      Write-Error "Failed to download the file: $_"
  }  
}

function kconfig_frontends() {
Write-Host "kconfig_frontends !!!"
  add_path "$NUTTXTOOLS\kconfig-frontends\bin"
  try {
      if (-not (Test-Path -Path "$NUTTXTOOLS\kconfig-frontends\bin\kconfig-conf.exe")) {
          # Download the file
          $basefile="kconfig-frontends-windows-mingw64"
          Set-Location "$NUTTXTOOLS"
          # Download the kconfig-frontends toolchain prebuilt
          Invoke-WebRequest -Uri "https://github.com/simbit18/kconfig-frontends-windows-mingw64/releases/download/kconfig-frontends-4.11.0/$basefile.zip" -OutFile "$NUTTXTOOLS\$basefile.zip" -ErrorAction Stop
          Expand-Archive "$NUTTXTOOLS\$basefile.zip"
          Move-Item -Path "$basefile\$basefile" -Destination "kconfig-frontends"
          Remove-Item "$basefile*" -Force
          Write-Host "File downloaded successfully to kconfig-frontends"
      }
  } catch {
      Write-Error "Failed to download the file: $_"
  }
}


function riscv_gcc_toolchain() {
Write-Host "riscv_gcc_toolchain !!!"
  add_path "$NUTTXTOOLS\riscv-none-elf-gcc\bin"
  try {
      if (-not (Test-Path -Path "$NUTTXTOOLS\riscv-none-elf-gcc\bin\riscv-none-elf-gcc.exe")) {
          $basefile="xpack-riscv-none-elf-gcc-13.2.0-2-win32-x64"
          Set-Location "$NUTTXTOOLS"
          # Download the latest RISCV GCC toolchain prebuilt by xPack
          Invoke-WebRequest -Uri "https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/download/v13.2.0-2/$basefile.zip" -OutFile "$NUTTXTOOLS\$basefile.zip" -ErrorAction Stop
          Expand-Archive "$NUTTXTOOLS\$basefile.zip"
          Move-Item -Path "$basefile\xpack-riscv-none-elf-gcc-13.2.0-2" -Destination "riscv-none-elf-gcc"
          Remove-Item "$basefile*" -Force
      }
      riscv-none-elf-gcc --version
  } catch {
      Write-Error "Failed to download the file: $_"
  }
}

function install_build_tools {
  $install="arm_clang_toolchain arm_gcc_toolchain arm64_gcc_toolchain riscv_gcc_toolchain kconfig_frontends"
  $splitArray=$install.Split(" ")
  $oldpath = Get-Location

  Write-Host "oldpath: $oldpath" -ForegroundColor Green
  foreach ( $node in $splitArray )
  {
    & $node
  }
  Set-Location "$oldpath"
}

install_build_tools