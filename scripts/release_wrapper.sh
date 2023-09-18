#!/bin/sh -
#
# Copyright 2023 OK Ryoko
# SPDX-License-Identifier: BSD-2-Clause
#
# SYNOPSIS:
#
#   ./release_wrapper.sh [-h] VERSION
#
# DESCRIPTION:
#
#   Run a Buildah build script for Chimera Linux container images inside a
#   container containing Buildah, forwarding registry credentials
#
# REQUIREMENTS:
#
#   - Privileges to build containers inside a container
#   - Valid authentication file at $XDG_RUNTIME_DIR/containers/auth.json
#   - Podman v3.4.4
#   - Buildah v1.23.1
#   - Working Internet connection
#   - release.sh (included)
#
# NOTES:
#
#   Intended to be run only in a trusted continuous integration environment for
#   which recent versions of Buildah aren't generally available

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

readonly storage="/var/lib/containers-tmp"
mkdir -p "${storage}"

readonly secret='authfile'
podman secret create "${secret}" "${XDG_RUNTIME_DIR}/containers/auth.json"

# shellcheck disable=SC2317
defer() {
	rm --force --recursive "${storage}"
	podman secret rm "${secret}"
}
trap defer EXIT

readonly buildah_repository='quay.io/containers/buildah'
readonly buildah_tag='v1.30.0'
readonly buildah_ref="${buildah_repository}:${buildah_tag}"

ctr="$(buildah from "docker://${buildah_ref}")"
readonly ctr

buildah add "${ctr}" './scripts/release.sh'
img="$(buildah commit --squash "${ctr}")"
readonly img

podman run \
	--env "REGISTRY_AUTH_FILE=/run/secrets/${secret}" \
	--privileged \
	--secret "${secret}" \
	--volume "${storage}:/var/lib/containers" \
	"${img}" \
	'/release.sh' "${chimera_version}"

exit 0
