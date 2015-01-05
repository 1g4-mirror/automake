## automake - create Makefile.in from Makefile.am
## Copyright (C) 2012-2015 Free Software Foundation, Inc.

## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.

## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.

## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Internal make variables that point to a sandbox directory where we can
# play freely to implement internal details that require interaction with
# the filesystem.  It is not created by default; recipes needing it
# should add an order-only dependency on it, as in:
#
#     am-rule: am-prereqs | $(am.dir)
#         [recipe creating/using files in $(am.dir)]
#
am.dir = .am

# Its counterpart with an absolute path, for recipes that can chdir around.
am.dir.abs = $(abs_builddir)/$(am.dir)

# Its counterpart for use in subdir makefiles, in case they need to refer
# to the top-level $(am.dir) directory.
am.top-dir = $(top_builddir)/$(am.dir)

# Its counterpart with an absolute path and for use in subdir makefiles.
am.top-dir.abs = $(abs_top_builddir)/$(am.dir)

am.clean.dist.d += $(am.dir)

$(am.dir):
	@mkdir $@
