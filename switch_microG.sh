#!/bin/bash

#
# Switch script to switch/checkout to the defined branches
# for each build variant and to apply the respective patches
#
# After initial `repo sync`, the branches are initially
# created and checked out
# ------------------------------------------------------------


switch_branches() {
  TOPDIR=$PWD
  cd $2
  echo "-"
  echo "$PWD"
  if [ "$2" == ".repo/local_manifests" ] ; then
    REMOTE="origin"
  else
    REMOTE="github"
  fi
  if [ -n "$(git branch --list $1)" ]; then
    git checkout $1
    git pull $REMOTE $1 --ff-only
  else
    git fetch $REMOTE $1
    git checkout -b $1 $REMOTE/$1
  fi
  cd $TOPDIR
}

switch_zpatch() {
  TOPDIR=$PWD
  cd z_patches
  echo "-"
  echo "$PWD"
  case "$2" in
    R) ./patches_reverse.sh
       cd $TOPDIR
       switch_branches $1 z_patches
       ;;
    S) ./patches_apply.sh
       ;;
  esac
  cd $TOPDIR
}

#
# Main run
#
case "$1" in
  microG)
    BRANCH1="lin-18.1-microG"
    BRANCH2="lineage-18.1"
    BRANCH3="lin-18.1-microG"
    BRANCH4="lin-18.1-microG"
    BRANCH5="lin-18.1-microG"
    BRANCHZ="lin-18.1-microG"
    PATCHV="S"
    ;;
  hmalloc)
    BRANCH1="lin-18.1-microG"
    BRANCH2="lin-18.1-hmalloc"
    BRANCH3="lin-18.1-hmalloc"
    BRANCH4="lin-18.1-microG"
    BRANCH5="lin-18.1-microG"
    BRANCHZ="lin-18.1-hmalloc"
    PATCHV="S"
    ;;
  default)
    BRANCH1="lineage-18.1"
    BRANCH2="lineage-18.1"
    BRANCH3="lineage-18.1"
    BRANCH4="lineage-18.1"
    BRANCH5="lineage-18.1"
    BRANCHZ="lineage-18.1"
    PATCHV="S"
    ;;
  reference)
    BRANCH1="lineage-18.1"
    BRANCH2="lineage-18.1"
    BRANCH3="lineage-18.1"
    BRANCH4="changelog"
    BRANCH5="lineage-18.1"
    BRANCHZ="lineage-18.1"
    PATCHV="N"
    ;;
  GmsCompat)
    BRANCH1="lin-18.1-microG"
    BRANCH2="lin-18.1-hmalloc"
    BRANCH3="lin-18.1-hmalloc"
    BRANCH4="lin-18.1-GmsCompat"
    BRANCH5="lin-18.1-GmsCompat"
    BRANCHZ="lin-18.1-GmsCompat"
    PATCHV="S"
    ;;
  GmsClm)
    BRANCH1="lin-18.1-microG"
    BRANCH2="lineage-18.1"
    BRANCH3="lin-18.1-microG"
    BRANCH4="lin-18.1-GmsCompat"
    BRANCH5="lin-18.1-GmsCompat"
    BRANCHZ="lin-18.1-GmsClm"
    PATCHV="S"
    ;;
  *)
    echo "usage: switch_microg.sh default | microG | reference"
    echo "-"
    echo "  default   - LineageOS 18.1"
    echo "  microG    - hardened microG build (low memory devices)"
    echo "  hmalloc   - hardened microG build with hardened-malloc"
    echo "  GmsCompat - hardened build with sandboxed Google Play services"
    echo "  GmsClm    - hardened build with sandboxed GMS (low memory devices)"
    echo "  reference - 100% LineageOS 18.1 (no patches - for 'repo sync')"
    exit
    ;;
esac

switch_zpatch $BRANCHZ R

switch_branches $BRANCH1 art
switch_branches $BRANCH2 bionic
switch_branches $BRANCH1 build/make
switch_branches $BRANCH3 build/soong
switch_branches $BRANCH5 frameworks/base
switch_branches $BRANCH1 frameworks/native
switch_branches $BRANCH1 frameworks/opt/net/wifi
switch_branches $BRANCH5 libcore
switch_branches $BRANCH1 packages/apps/Bluetooth
switch_branches $BRANCH1 packages/apps/Camera2
switch_branches $BRANCH1 packages/apps/Contacts
switch_branches $BRANCH1 packages/apps/Jelly
switch_branches $BRANCH1 packages/apps/LineageParts
switch_branches $BRANCH1 packages/apps/Nfc
switch_branches $BRANCH1 packages/apps/Settings
switch_branches $BRANCH1 packages/apps/Trebuchet
switch_branches $BRANCH1 packages/modules/NetworkStack
switch_branches $BRANCH3 system/core
switch_branches $BRANCH3 system/sepolicy
switch_branches $BRANCH5 vendor/lineage
switch_branches $BRANCHZ .repo/local_manifests
switch_branches $BRANCH4 OTA

switch_zpatch $BRANCH1 $PATCHV
