#! /bin/sh
# Copyright (C) 2002-2015 Free Software Foundation, Inc.
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

# Check that Automake does not warns about nested variables expansion,
# variables with non-POSIX names, or GNU make function calls.

. test-init.sh

cat > Makefile.am <<'END'
define get-libname
$(addprefix lib, $(1))
endef

v0 = $(shell LC_ALL=C && export LC_ALL && echo foo* bar*)
v1 = $(sort $(wildcard foo* bar*))
v2 = $(call get-libname, foo)
v3 = sub/$(addsuffix .a, ${v2})
v4 = $(v3)
v4 += $(notdir ${v3})

x = 1
mu1 = okey-dokey
bla = $(mu$x)
bli = $(mu$(x))
blo = $(mu${x})
blu = $(mu1)

bar$(x) = 6
baz${x} = 7
zap$x = 8

.a^very-weird!var@name%accepted;by,gnu/make = wow

.PHONY: do/test my/prereq
my/prereq:
	@: Do nothing.
do/test: my/prereq
	: \
	  && test '$(v0)' = 'foo.sh bar.sh bar.txt' \
	  && test '$(v1)' = 'bar.sh bar.txt foo.sh' \
	  && test $(v3) = sub/libfoo.a \
	  && test '$(v4)' = 'sub/libfoo.a libfoo.a' \
	  && test $(bla) = okey-dokey \
	  && test $(bli) = okey-dokey \
	  && test $(blo) = okey-dokey \
	  && test $(blu) = okey-dokey \
	  && test $(bar1) = 6 \
	  && test $(baz1) = 7 \
	  && test $(zap1) = 8 \
	  && test $(.a^very-weird!var@name%accepted;by,gnu/make) = wow \
## See automake bug#9587 .
	  && test '$(@F)' = 'test' \
	  && test '$(@D)' = 'do' \
	  && test '$(<F)' = 'prereq' \
	  && test '$(<D)' = 'my'
END

echo AC_OUTPUT >> configure.ac

$ACLOCAL
AUTOMAKE_run
test ! -s stderr

: > foo.sh
: > bar.sh
: > bar.txt

$AUTOCONF
./configure
$MAKE 'do/test'

:
