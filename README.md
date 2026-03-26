# Bind9 Rock

A distroless-like bind9 image based on Ubuntu. 

## Chiselled image

This image was created with [Chisel](https://documentation.ubuntu.com/chisel) to reduce the content of this image to only the essentials. This creates a more compact image with a smaller overall attack surface. Details on the content of this image can be found under the `bind9_bins` and `bind9-utils_bins` slice(s) in the [chisel-releases](https://github.com/canonical/chisel-releases)
repository.

## Available versions

* [bind9-9.20 (Ubuntu 26.04)](./bind9/9.20-26.04/rockcraft.yaml)