#!/bin/sh -
#
# Copyright 2023 OK Ryoko
# SPDX-License-Identifier: BSD-2-Clause

set -o errexit
set -o nounset

usage() {
	printf 'usage: %s [-a ARCHITECTURE] [-r REPOSITORY] VERSION\n' "$0"
}

while getopts a:hr: opt; do
	case "${opt}" in
		a)
			arch="${OPTARG}"
			;;
		h)
			usage
			exit 0
			;;
		r)
			repository="${OPTARG}"
			;;
		?)
			usage
			exit 2
			;;
	esac
done
shift $((OPTIND-1))

readonly chimera_version="${1:?$(usage && exit 2)}"
readonly url_base='https://repo.chimera-linux.org/live/latest'

mkdir -p dist
cd dist
curl --remote-name --silent "${url_base}/sha256sums.txt"

readonly arch="${arch:-"$(uname --machine)"}"
readonly tar_file="chimera-linux-${arch}-ROOTFS-${chimera_version}-bootstrap.tar.gz"

if ! [ -f "${tar_file}" ]; then
	curl --remote-name --silent "${url_base}/${tar_file}"
fi

sha256sum --check --ignore-missing --status 'sha256sums.txt'

export BUILDAH_FORMAT='oci'

ctr="$(buildah from scratch)"

# shellcheck disable=SC2317
defer() {
	if [ "${ctr}" ]; then
		buildah rm "${ctr}" >'/dev/null'
	fi
}
trap defer EXIT

buildah add --quiet "${ctr}" "${tar_file}" '/'

readonly repository="${repository:-localhost/chimera}"
readonly ref="${repository}:${chimera_version}-${arch}"

readonly label_url='https://chimera-linux.org/'
readonly label_title='Chimera Linux Base Container'
readonly label_description="Image containing a bootstrapped environment for containers based on Chimera Linux ${chimera_version}"

buildah config \
	--annotation=- \
	--arch "${arch}" \
	--cmd '/bin/sh' \
	--label "org.opencontainers.image.created=$(date --rfc-3339=ns --utc)" \
	--label "org.opencontainers.image.url=${label_url}" \
	--label "org.opencontainers.image.version=${chimera_version}" \
	--label "org.opencontainers.image.ref.name=${ref}" \
	--label "org.opencontainers.image.title=${label_title}" \
	--label "org.opencontainers.image.description=${label_description}" \
	--os 'linux' \
	"${ctr}"

buildah commit --quiet "${ctr}" "${ref}"

exit 0
