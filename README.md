# Chimera Linux OCI Container Images

This repository provides **unofficial** [OCI] container images for [Chimera Linux] as well as POSIX shell scripts for building said images using [Buildah] and [Podman].

## Usage

If you trust the [release workflow], then you can pull the latest image using your favorite container management tool:

```sh
img="$(podman pull --quiet 'ghcr.io/ok-ryoko/chimera:latest')"
podman run --rm "${img}" lsb_release --all
```

```
LSB Version:	1.0
Distributor ID:	Chimera
Description:	Chimera Linux
Release:	    rolling
Codename:	    chimera
```

If you have [GNU Make], [curl] and [Buildah], then you can also build container images locally for yourself. Running

```sh
git clone 'https://github.com/ok-ryoko/chimera'
cd chimera
make build
```

… will by default create an image in the repository *localhost/chimera* for your machine’s architecture.

## Trust statement

The [build] and [release] scripts in this repository trust the domain *repo.chimera-linux.org* as well as the artifacts listed at *https://repo.chimera-linux.org/live/latest*. The [release wrapper script], which assembles and pushes image indexes to *ghcr.io/ok-ryoko/chimera*, also trusts the domain *quay.io* and the images at *quay.io/containers/buildah*.

## License

This project is free and open source software licensed under the [BSD 2-Clause “Simplified” License][license].

[build]: ./scripts/build.sh
[Buildah]: https://buildah.io/
[Chimera Linux]: https://chimera-linux.org/
[curl]: https://curl.se/
[GNU Make]: https://www.gnu.org/software/make/
[license]: ./LICENSE
[OCI]: https://opencontainers.org/
[Podman]: https://podman.io/
[release]: ./scripts/release.sh
[release workflow]: ./.github/workflows/release.yml
[release wrapper script]: ./scripts/release_wrapper.sh
