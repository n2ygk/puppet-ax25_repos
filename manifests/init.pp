# == Class: ax25_repos
#
# Pull in RPM repos for various AX25 libraries and tools that are not available in the
# "usual" CentOS repos. For example, CentOS doesn't include the ham radio stuff that is included
# in Fedora, so grab the SRPMs from Fedora and "rpmbuild --rebuild" them and make them
# available under CentOS. This step was done elsewhere and the output is in files/
#
# TODO: Automate the rpmbuild steps here.
#
# === Parameters
#
# None
#
# === Variables
#
# ::osfamily, ::operatingsystemmajrelease, ::operatingsystem
#
# === Examples
#
#  include ax25_repos
#
# === Authors
#
# Alan Crosswell <n2ygk@weca.org>
#
# === Copyright
#
# Copyright 2016 Alan Crosswell
#
class ax25_repos {
  $reponame = "ax25-el${::operatingsystemmajrelease}-${::operatingsystem}-repo".downcase
  anchor { 'ax25_repos::begin': } ->
  class { 'ax25_repos::install': reponame => $reponame} ->
  class { 'ax25_repos::build': reponame => $reponame} ->
  class { 'ax25_repos::add_repo': reponame => $reponame} ->
  anchor { 'ax25_repos::end': }
}
