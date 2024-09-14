# Security Policy

## Scope

The repository owner claims responsibility for:

- correcting logical vulnerabilities in the [shell scripts] and [release workflow definition];
- ensuring that build artifacts are not fetched from a compromised domain, and
- deleting container images at *[ghcr.io/ok-ryoko/chimera]* that are known to contain vulnerabilities.

The repository owner disclaims responsibility for correcting security issues inherent to Chimera Linux that have been propagated through the bootstrap rootfs tarballs from which the container images are built.

## Supported versions

Only the scripts in the latest commit in branch *main* are supported. All container images stored at *ghcr.io/ok-ryoko/chimera* are supported.

## Reporting a vulnerability

If you have a GitHub account, then please use this repository’s [private vulnerability reporting] feature. Otherwise, please contact the repository owner at [ryoko@kyomu.jp.net][contact].

[contact]: mailto:ryoko@kyomu.jp.net
[ghcr.io/ok-ryoko/chimera]: https://github.com/ok-ryoko/chimera/pkgs/container/chimera
[private vulnerability reporting]: https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing-information-about-vulnerabilities/privately-reporting-a-security-vulnerability
[release workflow definition]: https://github.com/ok-ryoko/chimera/blob/main/.github/workflows/release.yml
[shell scripts]: https://github.com/ok-ryoko/chimera/tree/main/scripts
