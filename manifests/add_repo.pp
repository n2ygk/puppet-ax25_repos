class ax25_repos::add_repo ($reponame = undef) {
  require yum
  file {"/var/local/repos/${reponame}/RPMS":
    source => "/root/rpmbuild/RPMS",
    recurse => true,
  } ->
  exec {'createrepo':
    command => "/usr/bin/createrepo /var/local/repos/${reponame}",
  } ->
  yum::managed_yumrepo { "ax25":
    descr    => 'Ham Radio AX25 libraries and tools',
    baseurl  => "file:///var/local/repos/${reponame}",
    enabled  => 1,
    gpgcheck => 0,
    priority => 90,
  }
}
