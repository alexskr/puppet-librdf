#
# Class: rasqal
#
# Description: This class installs rasqal
#
# Parameters:
#
# Actions:
#
# Requires:  raptor2
#
# Sample Usage:
#

class librdf::rasqal(
  $rasqal_ver = '0.9.33',
  $checksum   = '1f5def51ca0026cd192958ef07228b52',
) {

  $librdf_url = 'http://download.librdf.org/source/'

  require librdf::raptor2
  ensure_packages([
    'gcc',
    'make',
    'libxml2-devel',
    'mpfr-devel',
    'pcre-devel',
  ])

  archive{ "/usr/local/src/rasqal-${rasqal_ver}.tar.gz":
    ensure        => present,
    extract       => true,
    checksum      => $checksum,
    checksum_type => 'md5',
    extract_path  => '/usr/local/src',
    source        => "${librdf_url}/rasqal-${rasqal_ver}.tar.gz",
    creates       => "/usr/local/src/rasqal-${rasqal_ver}",
    user          => 'root',
    group         => 'root',
    cleanup       => true,
  }

  -> file { '/usr/local/src/rasqal':
    ensure  => symlink,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    target  => "/usr/local/src/rasqal-${rasqal_ver}",
  }

  -> exec { './configure_rasqal':
    command  => 'export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig/ && ./configure --with-regex-library=pcre',
    cwd      => "/usr/local/src/rasqal-${rasqal_ver}",
    provider => 'shell', #required for ./configure command
    creates  => "/usr/local/src/rasqal-${rasqal_ver}/libtool",
    timeout  => 1200,
  }

  -> exec { 'build_rasqal':
    command => 'make && make install',
    cwd     => "/usr/local/src/rasqal-${rasqal_ver}",
    path    => '/bin:/usr/bin',
    unless  => "test $( export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig && /usr/local/bin/rasqal-config --version) = ${rasqal_ver}",
    timeout => 1200,
  }

}
