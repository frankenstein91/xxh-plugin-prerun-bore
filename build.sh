#!/usr/bin/env bash

main() {
	need_cmd curl
  need_cmd grep
  need_cmd mkdir
  need_cmd rm
  need_cmd cut
  need_cmd tar
  need_cmd xargs
	need_cmd chmod
	build
}

build() {

  CDIR="$(cd "$(dirname "$0")" && pwd)"
  build_dir=$CDIR/build

  while getopts A:K:q option
  do
    case "${option}"
    in
      q) QUIET=1;;
      A) ARCH=${OPTARG};;
      K) KERNEL=${OPTARG};;
    esac
  done

  rm -rf $build_dir
  mkdir -p $build_dir

  for f in *prerun.sh
  do
      cp $CDIR/$f $build_dir/
  done

  cd $build_dir
  # get CPU architecture
  if [ -z "$ARCH" ]; then
    ARCH=$(uname -m)
  fi
  # get os type
  if [ -z "$KERNEL" ]; then
    KERNEL=$(uname -s)
  fi
  echo "Downloading bore..."
  # get release from github
  curl -s https://api.github.com/repos/ekzhang/bore/releases/latest | grep browser_download_url | grep $ARCH | grep -i $KERNEL | cut -d '"' -f 4 | xargs curl -L -o bore.tar.gz
  echo "Extracting bore..."
  tar -xzf bore.tar.gz
  chmod +x bore
  rm bore.tar.gz

}

cmd_chk() {
  >&2 echo Check "$1"
	command -v "$1" >/dev/null 2>&1
}

need_cmd() {
  if ! cmd_chk "$1"; then
    error "need $1 (command not found)"
    exit 1
  fi
}

main "$@" || exit 1
