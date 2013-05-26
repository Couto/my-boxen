require boxen::environment
require homebrew
require gcc

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $luser,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::home}/homebrew/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::luser}"
  ]
}

File {
  group => 'staff',
  owner => $luser
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => Class['git']
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {

  # core modules, needed for most things
  include dnsmasq
  include git
  include hub
  include iterm2::dev
  include virtualbox
  include vagrant
  include caffeine
  include firefox
  # include firefox::nightly
  include chrome::dev
  include chrome::canary
  include imageoptim
  include alfred
  include skype
  include zsh
  include sublime_text_3

  # fail if FDE is not enabled
  if $::root_encrypted == 'no' {
    fail('Please enable full disk encryption and try again')
  }

  # Set OSX configurations
  include osx::global::enable_keyboard_control_access
  include osx::finder::show_all_on_desktop
  include osx::finder::empty_trash_securely
  include osx::finder::unhide_library
  include osx::universal_access::ctrl_mod_zoom

  
  class { 'osx::global::key_repeat_delay':
    delay => 0
  }

  class { 'osx::global::key_repeat_rate':
    rate => 0
  }

  osx::recovery_message {
    'If this Mac is found, please call (+351) 919 427 831':
  }

  # Clone my dotfiles
  repository { 'Personal dotfiles' :
    path => "/Users/${::boxen_user}/.dotfiles",
    source => 'Couto/.dotfiles',
    provider => 'git',
    ensure => present,
  }

  vim::bundle { [
    'scrooloose/syntastic',
    'scrooloose/nerdtree',
    'Lokaltog/powerline',
    'kien/ctrlp.vim'
  ]:
    require => [
        Repository["/Users/${::boxen_user}/.dotfiles"],
        File["/Users/${::boxen_user}/.vim"]
    ]
  }

  # node versions
  include nodejs::v0_10

  # default ruby versions
  include ruby::1_8_7
  include ruby::1_9_2
  include ruby::1_9_3
  include ruby::2_0_0

  # common, useful packages
  package {
    [
      'ack',
      'findutils',
      'gnu-tar',
      'tmux',
      'git-extras',
      'htop-osx',
      'nmap',
      'tree',
      'z',
      'ctags',
      'lesspipe',
      'phantomjs'
    ]:
  }

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }

  # Link all files from my dotfiles folder
  file { "/Users/${::boxen_user}/.gitconfig":
    ensure => link,
    target => "/Users/${::boxen_user}/.dotfiles/link/gitconfig",
    require => Repository["/Users/${::boxen_user}/.dotfiles"]
  }

  file { "/Users/${::boxen_user}/.zshrc":
    ensure => link,
    target => "/Users/${::boxen_user}/.dotfiles/link/zshrc",
    require => Repository["/Users/${::boxen_user}/.dotfiles"]
  }

  file { "/Users/${::boxen_user}/.vim":
    ensure => link,
    target => "/Users/${::boxen_user}/.dotfiles/vim",
    require => Repository["/Users/${::boxen_user}/.dotfiles"]
  }


  file { "/Users/${::boxen_user}/.vimrc":
    ensure => link,
    target => "/Users/${::boxen_user}/.dotfiles/link/vimrc",
    require => Repository["/Users/${::boxen_user}/.dotfiles"]
  }


  file { "/Users/${::boxen_user}/.tmux.conf":
    ensure => link,
    target => "/Users/${::boxen_user}/.dotfiles/link/tmux.conf",
    require => Repository["/Users/${::boxen_user}/.dotfiles"]
  }

  file { "/Users/${::boxen_user}/.tmux-powerlinerc":
    ensure => link,
    target => "/Users/${::boxen_user}/.dotfiles/link/tmux-powerlinerc",
    require => Repository["/Users/${::boxen_user}/.dotfiles"]
  }

  file { "/Users/${::boxen_user}/.rainbarf.conf":
    ensure => link,
    target => "/Users/${::boxen_user}/.dotfiles/link/rainbarf.conf",
    require => Repository["/Users/${::boxen_user}/.dotfiles"]
  }

  file { "/Users/${::boxen_user}/Library/Fonts/Menlo-ForPowerline.ttc":
    ensure => present,
    source => "/Users/${::boxen_user}/.dotfiles/font/Menlo-ForPowerline.ttc",
    mode => 0644,
    owner => $boxen_user,
    group => 'staff',
    require => Repository["/Users/${::boxen_user}/.dotfiles"]
  }

