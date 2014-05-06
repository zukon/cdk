#########################################################################################
#
# HOST-RPMCONFIG
#
HOST_RPMCONFIG = host-rpmconfig
HOST_RPMCONFIG_VERSION = 2.4-33
HOST_RPMCONFIG_SPEC = stm-$(HOST_RPMCONFIG).spec
HOST_RPMCONFIG_SPEC_PATCH = $(HOST_RPMCONFIG_SPEC).$(HOST_RPMCONFIG_VERSION).diff
HOST_RPMCONFIG_PATCHES = stm-$(HOST_RPMCONFIG)-$(HOST_RPMCONFIG_VERSION)-ignore-skip-cvs-errors.patch \
			 stm-$(HOST_RPMCONFIG)-$(HOST_RPMCONFIG_VERSION)-autoreconf-add-libtool-macros.patch

HOST_RPMCONFIG_RPM = RPMS/noarch/$(STLINUX)-$(HOST_RPMCONFIG)-$(HOST_RPMCONFIG_VERSION).noarch.rpm

$(HOST_RPMCONFIG_RPM): \
		$(addprefix Patches/,$(HOST_RPMCONFIG_SPEC_PATCH) $(HOST_RPMCONFIG_PATCHES)) \
		$(archivedir)/$(STLINUX)-$(HOST_RPMCONFIG)-$(HOST_RPMCONFIG_VERSION).src.rpm
	rpm $(DRPM) --nosignature -Uhv $(lastword $^) && \
	$(if $(HOST_RPMCONFIG_SPEC_PATCH),( cd SPECS && patch -p1 $(HOST_RPMCONFIG_SPEC) < $(buildprefix)/Patches/$(HOST_RPMCONFIG_SPEC_PATCH) ) &&) \
	$(if $(HOST_RPMCONFIG_PATCHES),cp $(addprefix Patches/,$(HOST_RPMCONFIG_PATCHES)) SOURCES/ &&) \
	rpmbuild $(DRPMBUILD) -bb -v --clean --rmsource --target=sh4-linux SPECS/$(HOST_RPMCONFIG_SPEC)

$(D)/$(HOST_RPMCONFIG): $(HOST_RPMCONFIG_RPM)
	@rpm $(DRPM) --ignorearch --nodeps -Uhv --badreloc --relocate $(STM_RELOCATE)=$(prefix) $<
	touch $@

#########################################################################################
#
#
#
$(D)/binutils: @DEPENDS_binutils@ directories
	@PREPARE_binutils@
	cp -Ppr @DIR_binutils@/opt/STM/STLinux-2.4/devkit/sh4/* $(hostprefix)/
	sed -i "s,^libdir=.*,libdir='$(hostprefix)/lib'," $(hostprefix)/lib/libopcodes.la
	sed -i "s,^libdir=.*,libdir='$(hostprefix)/lib'," $(hostprefix)/lib/libbfd.la
	@CLEANUP_binutils@
	touch $@

$(D)/linux_kernel_headers: @DEPENDS_linux_kernel_headers@ binutils
	@PREPARE_linux_kernel_headers@
	cp -Ppr @DIR_linux_kernel_headers@/opt/STM/STLinux-2.4/devkit/sh4/* $(targetprefix)/
	@CLEANUP_linux_kernel_headers@
	touch $@

$(D)/glibc: @DEPENDS_glibc@ linux_kernel_headers
	@PREPARE_glibc@
	cp -Ppr @DIR_glibc@/opt/STM/STLinux-2.4/devkit/sh4/* $(targetprefix)/
	@INSTALL_glibc@
	@CLEANUP_glibc@
	touch $@

$(D)/gcc: @DEPENDS_gcc@ glibc
	@PREPARE_gcc@
	cp -Ppr @DIR_gcc@/opt/STM/STLinux-2.4/devkit/sh4/* $(hostprefix)/
	ln -sf $(targetprefix)/target/etc $(targetprefix)/etc
	ln -sf $(targetprefix)/target/lib $(targetprefix)/lib
	ln -sf $(targetprefix)/target/usr/include $(targetprefix)/usr/include
	ln -sf $(targetprefix)/target/usr/lib $(targetprefix)/usr/lib
	ln -sf $(targetprefix)/target $(hostprefix)/target
	sed -i "s,^libdir=.*,libdir='$(hostprefix)/sh4-linux/lib'," $(hostprefix)/sh4-linux/lib/lib{std,sup}c++.la
	@CLEANUP_gcc@
	touch $@

$(D)/libncurses: $(D)/bootstrap @DEPENDS_libncurses@
	@PREPARE_libncurses@
	cd @DIR_libncurses@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--prefix=/usr \
			--with-terminfo-dirs=/usr/share/terminfo \
			--disable-big-core \
			--without-debug \
			--without-progs \
			--without-ada \
			--without-profile \
			--with-shared \
			--disable-rpath \
			--without-cxx-binding \
			--with-fallbacks='linux vt100 xterm' && \
		$(MAKE) libs HOSTCC=gcc \
			HOSTCCFLAGS="$(CFLAGS) -DHAVE_CONFIG_H -I../ncurses -DNDEBUG -D_GNU_SOURCE -I../include" \
			HOSTLDFLAGS="$(LDFLAGS)" && \
			@INSTALL_libncurses@
	@CLEANUP_libncurses@
	touch $@

#
# FILESYSTEM
#
host-filesystem:
	$(INSTALL) -d $(prefix)
	$(INSTALL) -d $(configprefix)
	$(INSTALL) -d $(devkitprefix)
	$(INSTALL) -d $(hostprefix)
	$(INSTALL) -d $(hostprefix)/{bin,doc,etc,include,info,lib,man,share,var}
	$(INSTALL) -d $(hostprefix)/man/man{1..9}
	touch .deps/$@

$(D)/directories:
	$(INSTALL) -d $(targetprefix)/{bin,boot,dev,dev.static,mnt,proc,root,sbin,sys,tmp,usr,var}
	$(INSTALL) -d $(targetprefix)/target/etc/rc.d/{rc0.d,rc1.d,rc2.d,rc3.d,rc4.d,rc5.d,rc6.d,rcS.d}
	$(INSTALL) -d $(targetprefix)/target/etc/network
	$(INSTALL) -d $(targetprefix)/var/etc
	ln -sf /tmp $(targetprefix)/var/run
	$(INSTALL) -d $(hostprefix)/$(target)
	$(INSTALL) -d $(hostprefix)/bin
	$(INSTALL) -d $(bootprefix)
	touch $@

