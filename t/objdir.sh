#! /bin/sh
# Copyright (C) 2012-2014 Free Software Foundation, Inc.
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

# A directory named 'obj' could create problems with BSD make, but
# shouldn't with GNU make; so check that
#  - the old portability warning diagnosing it is gone, and
#  - such a directory truly causes no problems with GNU make.

am_create_testdir=empty
. test-init.sh

cat > configure.ac <<END
AC_INIT([$me], [1.0])
AC_CONFIG_AUX_DIR([obj])
AM_INIT_AUTOMAKE
AC_REQUIRE_AUX_FILE([Makefile])
AC_CONFIG_FILES([Makefile])
AC_OUTPUT
END

mkdir obj
cat > obj/Makefile <<'END'
$(error GNU make should not consider this)
all:
	echo "GNU make should not consider this"; exit 1
END

cat > Makefile.am <<'END'
check-local:
	test -f $(srcdir)/obj/Makefile
END

$ACLOCAL
$AUTOMAKE -a
$AUTOCONF

test -f obj/install-sh
test ! -f install-sh

./configure
# This first make invocation actually fails with NetBSD make
# and FreeBSD 8.2 make.
$MAKE
$MAKE distcheck

:
