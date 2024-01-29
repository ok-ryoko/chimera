# Copyright 2023 OK Ryoko
# SPDX-License-Identifier: BSD-2-Clause

MAKEFLAGS += --warn-undefined-variables
SHELL := /bin/sh
.SHELLFLAGS := -euc
.DEFAULT_GOAL := help
.SUFFIXES:

VERSION := 20240122

.PHONY: setup #? Prepare the development environment
setup:
	git config --local core.hooksPath .githooks

.PHONY: build #? Build a Chimera Linux image for this machine's architecture at localhost/chimera
build:
	@./scripts/build.sh $(VERSION)

.PHONY: lint #? Lint all shell scripts against the POSIX.2 specification
lint:
	shellcheck --shell=sh .githooks/* scripts/*.sh

.PHONY: clean #? Remove all Chimera Linux build artifacts
clean:
	rm -fr dist

.PHONY: help #? Describe all targets documented in the Makefile
help:
	@awk -f scripts/make_help.awk GNUmakefile
