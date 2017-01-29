class ax25_repos::build ($reponame = undef) {
  notify {'rpmbuild start...':} ->
  exec {'rebuild ax.25 rpms':
    command => 'for i in /root/rpmbuild/SRPMS/*.src.rpm do; rpmbuild -ba $i; done',
    timeout => 600,
  } ->
  notify {'... rpmbuild complete':} ->
  notify {'kernel build start ...':} ->
  exec {'rebuild kernel':
    command => '/root/build-kmods.sh',
    timeout => 6000,
  } ->
  notify {'... kernel build complete':} ->
}
