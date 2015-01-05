#! /bin/sh
# Copyright (C) 2012-2015 Free Software Foundation, Inc.
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

#
# Check support for private automake working directory in builddir:
#
#  * internal variables:
#      $(am.dir)
#      $(am.dir.abs)
#      $(am.top-dir)
#      $(am.top-dir.abs)
#
#  * cleaning rules and "make distcheck" interaction.
#

. test-init.sh

d=.am

cat >> configure.ac <<'END'
AC_CONFIG_FILES([xsrc/Makefile])
AC_OUTPUT
END

cat > Makefile.am <<'END'
SUBDIRS = . xsrc
all-local: | $(am.dir)
END

mkdir xsrc
cat >> xsrc/Makefile.am <<'END'
subdir:
	mkdir $@
all-local: | $(am.dir) subdir
	: > $(am.dir)/sub
	: > $(am.top-dir)/top
	(cd ./subdir && : > $(am.dir.abs)/abs-sub)
	rmdir subdir
	(cd /tmp && : > $(am.top-dir.abs)/abs-top)
END

sort > exp <<END
$d
$d/top
$d/abs-top
xsrc/$d
xsrc/$d/sub
xsrc/$d/abs-sub
END

$ACLOCAL
$AUTOCONF
$AUTOMAKE

do_check ()
{
  srcdir=$1
  $srcdir/configure
  $MAKE
  # The grep is to ignore files used internally by Automake-NG.
  find $d xsrc/$d | grep -v '\.mk$' | sort > got
  cat $srcdir/exp
  cat got
  diff $srcdir/exp got
}

mkdir build
cd build
do_check ..

cd ..
do_check .

$MAKE distcheck
$MAKE clean
test -d $d
$MAKE distclean
test ! -e $d

:
