#! /bin/sh
# Copyright (C) 2011-2015 Free Software Foundation, Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Auxiliary test to set up common data used by many tests on TAP support.

. test-init.sh

echo AC_OUTPUT >> configure.ac

cat > Makefile.am << 'END'
TEST_LOG_DRIVER = $(srcdir)/tap-driver
TEST_LOG_COMPILER = cat
TESTS = all.test
END

cat > test-driver <<'END'
#!/bin/sh
echo "$0: required by Automake, but should never be actually used" >&2
exit 1
END
chmod a+x test-driver

$ACLOCAL
$AUTOCONF
$AUTOMAKE

./configure

rm -rf autom4te*.cache

# So that the data files we've created won't be removed at exit.
keep_testdirs=yes

:
