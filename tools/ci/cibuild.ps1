#!/usr/bin/env pswd
############################################################################
# tools/ci/cibuild.ps1
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

Set-PSDebug -Trace 0

Write-Host "===================================================================================="
Write-Host "Run cibuild.ps1 !!!" -ForegroundColor Yellow
$timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
Write-Host "Start: $timestamp" -ForegroundColor Yellow
Write-Host "======================"


$CID = Get-Location
Write-Host "CID: $CID" -ForegroundColor Green
$CIWORKSPACE = Resolve-Path("$CID\..\..\..") # "$CID".Split("\", 3)
Write-Host "CIWORKSPACE: $CIWORKSPACE" -ForegroundColor Green
$CIPLAT="$CIWORKSPACE\nuttx\tools\ci\platforms"
Write-Host "CIPLAT: $CIPLAT" -ForegroundColor Green
$nuttx="$CIWORKSPACE\nuttx"
$apps="$CIWORKSPACE\apps"

# Check if source directory exists
if (-Not (Test-Path -Path $apps)) {
    Write-Host "Directory '$apps' does not exist." -ForegroundColor Red
    exit 1
}


if ($IsWindows -or $ENV:OS) {
    Write-Host "Windows $ENV:OS"
} else {
    Write-Host "Not Windows"
}

function install_tools {
#  export NUTTXTOOLS=${CIWORKSPACE}/tools
#  mkdir -p "${NUTTXTOOLS}"
   $NUTTXTOOLS="$CIWORKSPACE\tools"
   $env:NUTTXTOOLS = "$NUTTXTOOLS"
   if (-not (Test-Path -Path $NUTTXTOOLS)) {
      New-Item -ItemType Directory -Path $NUTTXTOOLS -Force
   }
   $Pathps1="$CIPLAT\windows.ps1"
   # Check if the file exists
   if (Test-Path $Pathps1) {
       try {
           # Run the script
           Write-Host "Executing script: $Pathps1"
           & $Pathps1
           Write-Host "Script executed successfully." -ForegroundColor Yellow
       }
       catch {
           # Handle errors
           Write-Host "An error occurred while executing the script: $_" -ForegroundColor Red
       }
   }
   else {
       Write-Host "The specified script does not exist: $Pathps1" -ForegroundColor Red
       exit 1
   }

#  source "${CIWORKSPACE}"/tools/env.sh
}

# Function to display the help
function usage {
    # cls
    Write-Host ""
    Write-Host "====================" -ForegroundColor Cyan
    Write-Host "      Build NuttX      " -ForegroundColor Yellow
    Write-Host "====================" -ForegroundColor Cyan
    Write-Host "USAGE: $0 [-h] [-i] [-s] [-c] [-*] <testlist>"
    Write-Host "Where:"
    Write-Host "  -i install tools"
    Write-Host "  -s setup repos"
    Write-Host "  -c enable ccache"
    Write-Host "  -* support all options in testbuild.ps1"
    Write-Host "  -h will show this help text and terminate"
    Write-Host "  <testlist> select testlist file"
    Write-Host ""
    exit 1
}

function enable_ccache {
  Write-Host "enable_ccache: to-do"
}

function setup_repos {
  Write-Host "setup_repos: to-do"
}
# Function to check if Git is installed
function Check-Git {
    try {
        git --version | Out-Null
    } catch {
        Write-Host "Git is not installed. Please install Git to use this script." -ForegroundColor Red
        exit 1
    }
}


function run_builds {
  if ($builds -eq $null) {
   Write-Host "ERROR: Missing test list file"  -ForegroundColor Red
   usage
  }
  
  Write-Host "options: $options build: $builds" -ForegroundColor Yellow
<#   foreach ( $build in $builds ) {
    & $nuttx\tools\testbuild.ps1 $options $build
  } #>

<#   if [ -d "${CCACHE_DIR}" ]; then
    # Print a summary of configuration and statistics counters
    ccache -s
  fi #>
}



# Main script execution
Check-Git

$builds = @()
write-host "There are a total of $($args.count) arguments"
if (!$args[0]) {
   usage
}
for ( $i = 0; $i -lt $args.count; $i++ ) {
    write-host "Argument  $i is $($args[$i])"
        switch -regex ($($args[$i])) {
        '-h' {
            usage
        }
<#         '-d' {
            Write-Host "Debug -d" -ForegroundColor Green
            Set-PSDebug -Trace 1
            continue
        } #>
        '-i' {
            install_tools
            continue
        }
        '-c' {
            enable_ccache
            continue
        }
        '-s' {
            setup_repos
            continue
        }
        { $_ -like '-*' } {
            Write-Host "3 -*" -ForegroundColor Green
            $options += "$($args[$i]) " #$args[0]
            continue
        }
        default {
            Write-Host "Default $($args[$i])" -ForegroundColor Green
            $builds += $($args[$i])
        }
    }
}

run_builds
