#!/usr/bin/env perl
# Copyright (C) 2026 Free Software Foundation, Inc.
# Written by Kamila Szewczyk (szewczyk@cs.uni-saarland.de, k@iczelia.net).
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

use strict;
use warnings;
use File::Spec;

@ARGV == 2 or die "usage: $0 SRCDIR BUILDDIR\n";
my ($srcdir, $builddir) = @ARGV;
my $errors = 0;

sub read_file {
  my ($dir, $name) = @_;
  my $path = File::Spec->catfile($dir, split m{/}, $name);
  open my $fh, '<', $path or die "check-versions: cannot read $path: $!\n";
  local $/;
  return <$fh>;
}

sub value {
  my ($text, $pattern, $label) = @_;
  my @values = $text =~ /$pattern/g;
  @values == 1
    or die "check-versions: expected one $label, found " . @values . "\n";
  return $values[0];
}

sub check {
  my ($actual, $expected, $label) = @_;
  if ($actual ne $expected) {
    warn "check-versions: $label is '$actual', expected '$expected'\n";
    $errors++;
  }
}

my $configure = read_file($srcdir, 'configure.ac');
my $version = value($configure,
  qr/^AC_INIT\(\s*\[[^\]]*\],\s*\[([^\]]+)\]/m,
  'configure.ac AC_INIT version');
my $api = value($configure, qr/^APIVERSION=([0-9.]+)\s*$/m,
  'configure.ac APIVERSION');
my ($base, $micro) = $version =~ /\A([0-9]+\.[0-9]+)(?:\.([0-9]+))?\z/;
defined $base or die "check-versions: unrecognized package version '$version'\n";
check($api, $base, 'configure.ac APIVERSION');

my $m4 = read_file($srcdir, 'm4/amversion.m4');
check(value($m4, qr/^\[am__api_version='([^']+)'/m,
  'm4/amversion.m4 am__api_version'), $api, 'm4/amversion.m4 am__api_version');
check(value($m4, qr/^m4_if\(\[\$1\],\s*\[([^\]]+)\]/m,
  'm4/amversion.m4 version guard'), $version, 'm4/amversion.m4 version guard');
check(value($m4, qr/^\[AM_AUTOMAKE_VERSION\(\[([^\]]+)\]\)/m,
  'm4/amversion.m4 AM_AUTOMAKE_VERSION'), $version,
  'm4/amversion.m4 AM_AUTOMAKE_VERSION');

my $config = read_file($builddir, 'lib/Automake/Config.pm');
my $makefile = read_file($builddir, 'Makefile');
for my $name ('VERSION', 'APIVERSION') {
  my $expected = $name eq 'VERSION' ? $version : $api;
  check(value($config, qr/^our \$$name = '([^']+)';/m,
    "lib/Automake/Config.pm $name"), $expected, "lib/Automake/Config.pm $name");
  check(value($makefile, qr/^$name\s*=\s*([^\s]+)\s*$/m,
    "Makefile $name"), $expected, "Makefile $name");
}

my $manual = read_file($srcdir, 'doc/version.texi');
for my $name ('VERSION', 'EDITION') {
  check(value($manual, qr/^\@set $name ([^\s]+)\s*$/m,
    "doc/version.texi $name"), $version, "doc/version.texi $name");
}

# Development versions and pretests may describe the upcoming stable release.
if (!defined $micro || $micro < 90) {
  my $news = read_file($srcdir, 'NEWS');
  my ($news_version) = $news =~ /^New in ([^\s]+) /m;
  defined $news_version or die "check-versions: no release heading in NEWS\n";
  check($news_version, $version, 'NEWS first release heading');
}

exit($errors ? 1 : 0);
