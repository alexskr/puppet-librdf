#
# Class: raptor2
#
# Description: This class installs raptor2
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#

class librdf::raptor2 (
  String $raptor2_ver = '2.0.16',
  String $checksum    = '0a71f13b6eaa0a04bf411083d89d7bc2',
) {
  $librdf_url = 'https://download.librdf.org/source/'

  #Packages required for compiling raptor2
  ensure_packages([
      'gcc',
      'make',
      'libcurl-devel',
      'libxml2-devel',
      'libxslt-devel',
  ])

  archive { "/usr/local/src/raptor2-${raptor2_ver}.tar.gz":
    ensure        => present,
    extract       => true,
    checksum      => $checksum,
    checksum_type => 'md5',
    extract_path  => '/usr/local/src',
    source        => "${librdf_url}/raptor2-${raptor2_ver}.tar.gz",
    creates       => "/usr/local/src/raptor2-${raptor2_ver}",
    user          => 'root',
    group         => 'root',
    cleanup       => true,
  }

  -> file { '/usr/local/src/raptor2':
    ensure => symlink,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    target => "/usr/local/src/raptor2-${raptor2_ver}",
  }

  -> exec { './configure':
    cwd      => "/usr/local/src/raptor2-${raptor2_ver}",
    provider => 'shell', #required for ./configure command
    creates  => "/usr/local/src/raptor2-${raptor2_ver}/libtool",
    timeout  => 1200,
  }

  -> exec { 'build_raptor':
    command => 'make && make install',
    cwd     => "/usr/local/src/raptor2-${raptor2_ver}",
    path    => '/bin:/usr/bin',
    unless  => "test $(/usr/local/bin/rapper -v) = ${raptor2_ver}",
    timeout => 1200,
  }
}
