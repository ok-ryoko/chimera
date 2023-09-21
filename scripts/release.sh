#!/bin/sh -
#
# Copyright 2023 OK Ryoko
# SPDX-License-Identifier: BSD-2-Clause
#
# SYNOPSIS:
#
#   ./release.sh [-h] VERSION
#
# DESCRIPTION:
#
#   Build an image containing a bootstrapped environment for containers based on
#   Chimera Linux for each supported architecture
#
#   Add each image to a multi-architecture image index
#
#   Push the index and images to ghcr.io/ok-ryoko/chimera:VERSION and
#   ghcr.io/ok-ryoko/chimera:latest
#
# REQUIREMENTS:
#
#   - Working Internet connection
#   - Authentication to ghcr.io/ok-ryoko
#   - Authorization to write packages to ghcr.io/ok-ryoko
#   - curl
#   - Buildah v1.30.0
#
# NOTES:
#
#   Intended to be run on a continuous integration server
#
#   Does not clean up intermediate entities such as containers and images in the
#   event of an error

set -o errexit
set -o nounset

usage() {
	printf 'usage: %s [-h] VERSION\n' "$0"
}

while getopts 'h' opt; do
	case "${opt}" in
		h) usage && exit 0 ;;
		?) usage && exit 2 ;;
	esac
done
shift $((OPTIND-1))

readonly chimera_version="${1:?$(usage && exit 2)}"
readonly domain='ghcr.io'
readonly namespace='ok-ryoko'
readonly path="${namespace}/chimera"
readonly repository="${domain}/${path}"

buildah login --get-login "${domain}/${namespace}" > '/dev/null'

readonly url_base='https://repo.chimera-linux.org/live/latest'
readonly checksums='sha256sums.txt'

curl --show-error --silent "${url_base}/${checksums}" | grep 'bootstrap' > "${checksums}"

readonly manifest="${repository}:${chimera_version}"
readonly manifest_latest="${repository}:latest"

export BUILDAH_FORMAT='oci'

printf '%s\n' "Creating manifest ${manifest}..."
buildah manifest create "${manifest}"

readonly label_authors='OK Ryoko <ryoko@kyomu.jp.net>'
readonly label_url='https://chimera-linux.org/'
readonly label_documentation='https://chimera-linux.org/docs/'
readonly label_source="https://github.com/${path}"
readonly label_title='Chimera Linux Base Container'
readonly label_description="Image containing a bootstrapped environment for containers based on Chimera Linux ${chimera_version}"

readonly arches='aarch64 ppc64 ppc64le riscv64 x86_64'
# shellcheck disable=SC2086
for arch in $arches; do
	ref="${manifest}-${arch}"
	printf '%s\n' "Building image ${ref}..."
	tar_file="chimera-linux-${arch}-ROOTFS-${chimera_version}-bootstrap.tar.gz"
	curl --remote-name --show-error --silent "${url_base}/${tar_file}"
	sha256sum --check --ignore-missing --status "${checksums}"
	ctr="$(buildah from --isolation='chroot' scratch)"
	buildah add --quiet "${ctr}" "${tar_file}" '/'
	buildah config \
		--annotation='-' \
		--arch "${arch}" \
		--cmd '/bin/sh' \
		--label "org.opencontainers.image.created=$(date --rfc-3339=ns --utc)" \
		--label "org.opencontainers.image.authors=${label_authors}" \
		--label "org.opencontainers.image.url=${label_url}" \
		--label "org.opencontainers.image.documentation=${label_documentation}" \
		--label "org.opencontainers.image.source=${label_source}" \
		--label "org.opencontainers.image.version=${chimera_version}" \
		--label "org.opencontainers.image.ref.name=${ref}" \
		--label "org.opencontainers.image.title=${label_title}" \
		--label "org.opencontainers.image.description=${label_description}" \
		--os 'linux' \
		"${ctr}"
	buildah commit \
		--manifest "${manifest}" \
		--squash \
		"${ctr}" \
		"${ref}"
	buildah rm "${ctr}"
done
unset -v arch

printf '%s\n' "Pushing manifest ${manifest}..."
buildah manifest push \
	--all \
	--tls-verify \
	"${manifest}" \
	"docker://${manifest}"

buildah tag "${manifest}" "${manifest_latest}"
printf '%s\n' "Pushing manifest ${manifest_latest}..."
buildah manifest push \
	--all \
	--rm \
	--tls-verify \
	"${manifest_latest}" \
	"docker://${manifest_latest}"

exit 0
