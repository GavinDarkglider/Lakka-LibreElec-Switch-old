################################################################################
#      This file is part of OpenELEC - http://www.openelec.tv
#      Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
#
#  OpenELEC is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 2 of the License, or
#  (at your option) any later version.
#
#  OpenELEC is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with OpenELEC.  If not, see <http://www.gnu.org/licenses/>.
################################################################################

PKG_NAME="libXmu"
PKG_VERSION="1.1.2"
PKG_ARCH="any"
PKG_LICENSE="OSS"
PKG_SITE="http://www.X.org"
PKG_URL="http://xorg.freedesktop.org/archive/individual/lib/$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_DEPENDS_TARGET="toolchain util-macros xextproto libXext libX11 libXt"
PKG_SECTION="x11/lib"
PKG_SHORTDESC="libxmu: X11 miscellaneous utility library"
PKG_LONGDESC="LibXmu provides a set of miscellaneous utility convenience functions for X libraries to use."

PKG_IS_ADDON="no"
PKG_AUTORECONF="no"

PKG_CONFIGURE_OPTS_TARGET="--enable-static --enable-shared --with-gnu-ld --without-xmlto"

pre_configure_target() {
  CFLAGS="$CFLAGS -fPIC -DPIC"
}
