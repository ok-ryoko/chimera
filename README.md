# Chimera Linux OCI Container Images

This repository provides **unofficial** [OCI] container images for [Chimera Linux] built from the official bootstrap rootfs tarballs. It also provides POSIX shell scripts for building said images using [Buildah] and [Podman] both locally and on GitHub.

## Usage

If you trust the owner of this repository as well as the [release workflow definition], then you can pull the latest image using your favorite container management tool:

```sh
img="$(podman pull --quiet 'ghcr.io/ok-ryoko/chimera:latest')"
podman run --rm "${img}" lsb_release --all
```

```
LSB Version:	1.0
Distributor ID:	Chimera
Description:	Chimera Linux
Release:	rolling
Codename:	chimera
```

If you have [make], [curl] and [Buildah] installed, then you can also build container images locally for yourself. Running

```sh
git clone 'https://github.com/ok-ryoko/chimera'
cd chimera
make build
```

… should by default create an image in the repository *localhost/chimera* for your machine’s architecture. Alternatively, you can skip make and run the [build] script directly, e.g.,

```sh
./scripts/build.sh '20230915'
```

## Release policy and schedule

Container images are built and pushed to *[ghcr.io/ok-ryoko/chimera]* using the GitHub Actions workflow titled `release`. The owner of this repository triggers this workflow manually when (1) they learn that a new set of Chimera Linux build artifacts has been published or (2) one of the release scripts has changed in a way that affects the contents or integrity of the container images.

## Trust statement

The [build] and [release] scripts in this repository trust the domain *repo.chimera-linux.org* as well as the artifacts listed at *https://repo.chimera-linux.org/live/latest*.

The [release wrapper script], which assembles and pushes image indexes to *ghcr.io/ok-ryoko/chimera*, also trusts the domain *quay.io* and the images at *quay.io/containers/buildah*. This trust is needed to leverage a more recent version of Buildah than that available in the [GitHub-hosted Ubuntu 22.04 LTS runner].

## License

This project is free and open source software licensed under the [BSD 2-Clause “Simplified” License][license].

[build]: ./scripts/build.sh
[Buildah]: https://buildah.io/
[Chimera Linux]: https://chimera-linux.org/
[curl]: https://curl.se/
[ghcr.io/ok-ryoko/chimera]: https://github.com/ok-ryoko/chimera/pkgs/container/chimera
[GitHub-hosted Ubuntu 22.04 LTS runner]: https://github.com/actions/runner-images/blob/main/images/linux/Ubuntu2204-Readme.md
[license]: ./LICENSE
[make]: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/make.html
[OCI]: https://opencontainers.org/
[Podman]: https://podman.io/
[release workflow definition]: ./.github/workflows/release.yml
[release wrapper script]: ./scripts/release_wrapper.sh
[release]: ./scripts/release.sh
