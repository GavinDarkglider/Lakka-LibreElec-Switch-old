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

PKG_NAME="mesa"
PKG_VERSION="18.3.1"
PKG_ARCH="any"
PKG_LICENSE="OSS"
PKG_SITE="http://www.mesa3d.org/"
PKG_URL="https://mesa.freedesktop.org/archive/$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_DEPENDS_TARGET="toolchain Python:host expat glproto dri2proto presentproto libdrm libXext libXdamage libXfixes libXxf86vm libxcb libX11 systemd dri3proto libxshmfence libXrandr openssl"
PKG_SECTION="graphics"
PKG_SHORTDESC="mesa: 3-D graphics library with OpenGL API"
PKG_LONGDESC="Mesa is a 3-D graphics library with an API which is very similar to that of OpenGL*. To the extent that Mesa utilizes the OpenGL command syntax or state machine, it is being used with authorization from Silicon Graphics, Inc. However, the author makes no claim that Mesa is in any way a compatible replacement for OpenGL or associated with Silicon Graphics, Inc. Those who want a licensed implementation of OpenGL should contact a licensed vendor. While Mesa is not a licensed OpenGL implementation, it is currently being tested with the OpenGL conformance tests. For the current conformance status see the CONFORM file included in the Mesa distribution."

PKG_IS_ADDON="no"
PKG_AUTORECONF="yes"

# configure GPU drivers and dependencies:
  get_graphicdrivers

if [ "$LLVM_SUPPORT" = "yes" ]; then
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET elfutils llvm"
  export LLVM_CONFIG="$SYSROOT_PREFIX/usr/bin/llvm-config-host"
  MESA_GALLIUM_LLVM="--enable-llvm --enable-llvm-shared-libs"
else
  MESA_GALLIUM_LLVM="--disable-llvm"
fi

if [ "$VDPAU_SUPPORT" = "yes" -a "$DISPLAYSERVER" = "x11" ]; then
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET libvdpau"
  MESA_VDPAU="--enable-vdpau"
else
  MESA_VDPAU="--disable-vdpau"
fi

XA_CONFIG="--disable-xa"
for drv in $GRAPHIC_DRIVERS; do
  [ "$drv" = "vmware" ] && XA_CONFIG="--enable-xa"
done

if [ "$OPENGLES_SUPPORT" = "yes" ]; then
  MESA_GLES="--enable-gles2"
else
  MESA_GLES="--disable-gles2"
fi
 
PKG_CONFIGURE_OPTS_TARGET="CC_FOR_BUILD=$HOST_CC \
                           CXX_FOR_BUILD=$HOST_CXX \
                           CFLAGS_FOR_BUILD= \
                           CXXFLAGS_FOR_BUILD= \
                           LDFLAGS_FOR_BUILD= \
                           X11_INCLUDES= \
                           DRI_DRIVER_INSTALL_DIR=$XORG_PATH_DRI \
                           DRI_DRIVER_SEARCH_DIR=$XORG_PATH_DRI \
                           --disable-debug \
                           --disable-mangling \
                           --enable-texture-float \
                           --enable-asm \
                           --disable-selinux \
                           --enable-opengl \
                           --disable-gles1 \
                           $MESA_GLES \
                           --enable-dri \
                           --enable-dri3 \
                           --enable-glx \
                           --disable-osmesa \
                           --disable-gallium-osmesa \
                           --enable-egl --with-egl-platforms=x11,drm \
                           $XA_CONFIG \
                           --enable-gbm \
                           --disable-nine \
                           --disable-xvmc \
                           $MESA_VDPAU \
                           --disable-omx-bellagio \
                           --disable-va \
                           --disable-opencl \
                           --enable-opencl-icd \
                           --disable-gallium-tests \
                           --enable-shared-glapi \
                           --enable-driglx-direct \
                           --enable-glx-tls \
                           $MESA_GALLIUM_LLVM \
                           --disable-silent-rules \
                           --with-gallium-drivers=$GALLIUM_DRIVERS \
                           --with-dri-drivers=$DRI_DRIVERS \
                           --with-vulkan-drivers=no \
                           --with-sysroot=$SYSROOT_PREFIX"

pre_configure_target() {
  export LIBS="-lxcb-dri3 -lxcb-dri2 -lxcb-xfixes -lxcb-present -lxcb-sync -lxshmfence -lz"
}

post_makeinstall_target() {
  # rename and relink to cooperate with nvidia drivers
  if [ "$DISPLAYSERVER" == "x11" ]; then
    rm -rf $INSTALL/usr/lib/libGL.so
    rm -rf $INSTALL/usr/lib/libGL.so.1
    ln -sf libGL.so.1 $INSTALL/usr/lib/libGL.so
    ln -sf /var/lib/libGL.so $INSTALL/usr/lib/libGL.so.1
    mv $INSTALL/usr/lib/libGL.so.1.2.0 $INSTALL/usr/lib/libGL_mesa.so.1
  fi
  if [ "$DEVICE" = "L4T" ]; then
    mv $INSTALL/usr/lib/libglapi* $INSTALL/
    rm -rf $INSTALL/usr/lib/*.so*
    rm -rf $INSTALL/usr/lib/*/*.so*
    mv $INSTALL/libglapi* $INSTALL/usr/lib/
  fi
}
