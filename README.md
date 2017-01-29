# ax25_repos

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with ax25_repos](#setup)
    * [What ax25_repos affects](#what-ax25_repos-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with ax25_repos](#beginning-with-ax25_repos)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

ax25_repos downloads SRPMs and builds an RPM repo containing the "Fedora hams" Amateur Radio AX.25
tools so that the (CentOS) host can use them. This includes building an AX.25 kernel since
the default CentOS kernel does not enable `CONFIG_HAMRADIO` the way the Fedora kernel does.

## Module Description


## Setup

### What ax25_repos affects

* /var/local/repos/ax25-*
* /etc/repos.d

## Usage

`include ax25_repos`

## Reference

## Limitations

Limited to CentOS 6 & 7.

## Development

https://wiki.centos.org/HowTos/I_need_the_Kernel_Source


