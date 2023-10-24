#!/bin/sh -
#
# Copyright 2023 OK Ryoko
# SPDX-License-Identifier: BSD-2-Clause
#
# SYNOPSIS:
#
#   ./build.sh [-a ARCH] [-h] [-k] [-r REPO] VERSION
#
# DESCRIPTION:
#
#   Create a Chimera Linux container image in local storage, printing the ID of
#   the new image to standard output
#
# OPTIONS:
#
#   -a ARCH Use the provided architecture instead of the automatically detected
#           architecture. Supported values are aarch64, ppc64, ppc64le, riscv64
#           and x86_64.
#
#   -h      Print synopsis to standard output and exit
#
#   -k      Keep the working container
#
#   -r REPO Use this repository name instead of the default (localhost/chimera)
#
#   -u      Fetch the rootfs tarball checksums unconditionally
#
# NOTES:
#
#   Requires an Internet connection and depends on the availability of the curl
#   and Buildah programs
#
#   Creates a directory named 'dist' in the working directory in which download
#   artifacts will be stored for future runs

set -o errexit
set -o nounset

usage() {
	printf 'usage: %s [-a ARCHITECTURE] [-h] [-k] [-r REPOSITORY] [-u] VERSION\n' "$0"
}

while getopts 'a:hkr:u' opt; do
	case "${opt}" in
		a)
			arch="${OPTARG}"
			;;
		h)
			usage
			exit 0
			;;
		k)
			keep='1'
			;;
		r)
			repository="${OPTARG}"
			;;
		u)
			update='1'
			;;
		?)
			usage
			exit 2
			;;
	esac
done
shift $((OPTIND-1))

readonly chimera_version="${1:?$(usage && exit 2)}"
readonly arch="${arch:-"$(uname -m)"}"
readonly keep="${keep:-0}"
readonly repository="${repository:-localhost/chimera}"
readonly update="${update:-0}"

mkdir -p 'dist'
cd 'dist'

readonly url_base="https://repo.chimera-linux.org/live/${chimera_version}"
readonly checksums='sha256sums.txt'

if ! [ -f "${checksums}" ] || ! [ -f "${tarball}" ] || [ "${update}" = '1' ]; then
	curl --show-error --silent "${url_base}/${checksums}" | grep 'bootstrap' >> "${checksums}"
	sort -k 2 -u "${checksums}" > "${checksums}-"
	mv -f "${checksums}-" "${checksums}"
fi

readonly tarball="chimera-linux-${arch}-ROOTFS-${chimera_version}-bootstrap.tar.gz"

if ! [ -f "${tarball}" ]; then
	curl --remote-name --show-error --silent "${url_base}/${tarball}"
fi

sha256sum --check --ignore-missing --status "${checksums}"

export BUILDAH_FORMAT='oci'

ctr="$(buildah from scratch)"

# shellcheck disable=SC2317
defer() {
	if [ "${keep}" = '0' ]; then
		buildah rm "${ctr}" > '/dev/null'
	fi
}
trap defer EXIT

buildah add --quiet "${ctr}" "${tarball}" '/'

readonly ref="${repository}:${chimera_version}-${arch}"

readonly label_documentation='https://chimera-linux.org/docs/'
readonly label_url='https://chimera-linux.org/'
readonly label_title='Chimera Linux Base Container'
readonly label_description="Image containing a bootstrapped environment for containers based on Chimera Linux ${chimera_version}"

buildah config \
	--annotation=- \
	--arch "${arch}" \
	--cmd '/bin/sh' \
	--label "org.opencontainers.image.created=$(date --rfc-3339=ns --utc)" \
	--label "org.opencontainers.image.url=${label_url}" \
	--label "org.opencontainers.image.documentation=${label_documentation}" \
	--label "org.opencontainers.image.version=${chimera_version}" \
	--label "org.opencontainers.image.ref.name=${ref}" \
	--label "org.opencontainers.image.title=${label_title}" \
	--label "org.opencontainers.image.description=${label_description}" \
	--os 'linux' \
	"${ctr}"

buildah commit --quiet "${ctr}" "${ref}"

exit 0
