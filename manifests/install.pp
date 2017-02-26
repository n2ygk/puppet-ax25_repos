class ax25_repos::install ($reponame = undef) {
  if $::osfamily == 'RedHat' and $::operatingsystem == 'CentOS' {
    # copy files into /var/local/repos
    file { '/var/local/repos':
      ensure => 'directory'
    }
    # these just have the an empty RPM repo tree.
    file { "/var/local/repos/${reponame}":
      source => "puppet:///modules/ax25_repos/${reponame}",
      recurse => true
    }
    file {'/root/build-kmods.sh':
      ensure => 'present',
      source => "puppet:///modules/ax25_repos/build-kmods.sh",
      mode   => '0755',
    }
    # git, compilers, editors, etc.
    exec { 'yum groupinstall Development Tools':
      command => '/usr/bin/yum -y --disableexcludes=all groupinstall "Development Tools"',
      unless  => '/usr/bin/yum grouplist "Development Tools" | /bin/grep "^Installed"',
      timeout => 600,
    }
    $pkgs = [ 'emacs','cvs','wget','zlib-devel', 'ncurses-devel',
              'libXt-devel', 'libXi-devel', 'fltk-devel', 'libX11-devel',
              'mesa-libGL-devel','gtk2-devel','alsa-lib-devel','alsa-utils',
              'libxml2-devel','audiofile-devel', # 'hamlib-devel',
              'xorg-x11-xauth','xterm','xorg-x11-fonts-100dpi','xorg-x11-fonts-ISO8859-1-100dpi',
              'rpm-build', 'createrepo']
    ensure_packages($pkgs, {'ensure' => 'installed'})

    file { '/root/rpmbuild/':
      ensure  => 'directory',
    } ->
    file { '/root/rpmbuild/SRPMS/':
      ensure  => 'directory',
    }
    # maybe I should just revert back to Fedora and bag CentOS....
    $fedora = 'https://dl.fedoraproject.org/pub/fedora/linux/releases/24/Everything/source/tree/Packages'
    $manyfiles =
    [
     "${fedora}/l/libax25-1.0.5-2.fc24.src.rpm",
     "${fedora}/a/ax25-apps-1.0.5-2.fc24.src.rpm",
     "${fedora}/a/ax25-tools-1.0.3-2.fc24.src.rpm",
     "${fedora}/a/aprsd-2.2.5-15.6.fc24.13.src.rpm",
     "${fedora}/a/aprsdigi-3.5.1-7.fc24.src.rpm",
     "${fedora}/s/soundmodem-0.20-4.fc24.src.rpm",
     ]
    wget::fetch { $manyfiles:
      destination => '/root/rpmbuild/SRPMS/',
    }
  }
  else {
    fail {'Only supported for CentOS.':}
  }
}

  
