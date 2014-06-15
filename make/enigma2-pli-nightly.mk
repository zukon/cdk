#
# yaud-enigma2-pli-nightly
#
yaud-enigma2-pli-nightly: yaud-none host_python lirc \
		boot-elf enigma2-pli-nightly enigma2-plugins release
	@TUXBOX_YAUD_CUSTOMIZE@

#
# enigma2-pli-nightly
#
ENIGMA2_DEPS  = bootstrap libncurses libcrypto libcurl libid3tag libmad libpng libjpeg libgif_e2 libfreetype libfribidi libsigc libreadline
ENIGMA2_DEPS += libexpat libdvbsipp python libxml2 libxslt elementtree zope_interface twisted pyopenssl pythonwifi pilimaging pyusb pycrypto
ENIGMA2_DEPS += lxml libxmlccwrap libdreamdvd tuxtxt32bpp sdparm hotplug_e2 wpa_supplicant wireless_tools minidlna opkg ethtool
ENIGMA2_DEPS += $(MEDIAFW_DEP) $(EXTERNALLCD_DEP)

E_CONFIG_OPTS =

if ENABLE_EXTERNALLCD
E_CONFIG_OPTS += --with-graphlcd
endif

if ENABLE_EPLAYER3
E_CONFIG_OPTS += --enable-libeplayer3
endif

if ENABLE_MEDIAFWGSTREAMER
E_CONFIG_OPTS += --enable-mediafwgstreamer
endif

$(D)/enigma2-pli-nightly.do_prepare: | $(ENIGMA2_DEPS)
	REVISION=""; \
	HEAD="master"; \
	DIFF="0"; \
	clear; \
	echo ""; \
	echo "Choose between the following revisions:"; \
	echo "========================================================================================================"; \
	echo " 0) Newest                 - E2 OpenPli gstreamer / libplayer3    (Can fail due to outdated patch)     "; \
	echo "========================================================================================================"; \
	echo " 1) use your own e2 git dir without patchfile"; \
	echo " 2) inactive"; \
	echo "========================================================================================================"; \
	echo " 3) Mon, 28 Jan 2013 21:30 - E2 OpenPli gstreamer / libplayer3 ce3b90e73e88660bafe900f781d434dd6bd25f71"; \
	echo " 4) Sat,  2 Mar 2013 21:36 - E2 OpenPli gstreamer / libplayer3 4361a969cde00cd37d6d17933f2621ea49b5a30a"; \
	echo " 5) Fri, 10 May 2013 15:43 - E2 OpenPli gstreamer / libplayer3 20a5a1f00cdadeff6d0e02861cf7ba8436fc49c5"; \
	echo " 6) Mon, 28 Oct 2013 14:16 - E2 OpenPli gstreamer / libplayer3 16cada2e02407c588382b95acc8f016ec4a29452"; \
	echo " 7) Mon, 30 Dec 2013 18:33 - E2 OpenPli gstreamer / libplayer3 715a3024ad7ae3e89dad039bfb8ae49350552c39"; \
	echo " 8) Sun, 23 Feb 2014 10:05 - E2 OpenPli gstreamer / libplayer3 e858a47a49c4fd8cdf22b29ea7278e6b4a2bddae"; \
	echo " 9) Tue, 25 Mar 2014 18:17 - E2 OpenPli gstreamer / libplayer3 7272840d7db98a88f5c8b2882cc78d7ddc04e5e6"; \
	echo "========================================================================================================"; \
	echo "Media Framwork : $(MEDIAFW)"; \
	echo "External LCD   : $(EXTERNALLCD)"; \
	read -p "Select         : "; \
	[ "$$REPLY" == "0" ] && DIFF="0"; \
	[ "$$REPLY" == "1" ] && DIFF="1" && REVISION=""; \
	[ "$$REPLY" == "2" ] && DIFF="2" && REVISION=""; \
	[ "$$REPLY" == "3" ] && DIFF="3" && REVISION="ce3b90e73e88660bafe900f781d434dd6bd25f71"; \
	[ "$$REPLY" == "4" ] && DIFF="4" && REVISION="4361a969cde00cd37d6d17933f2621ea49b5a30a"; \
	[ "$$REPLY" == "5" ] && DIFF="5" && REVISION="20a5a1f00cdadeff6d0e02861cf7ba8436fc49c5"; \
	[ "$$REPLY" == "6" ] && DIFF="6" && REVISION="16cada2e02407c588382b95acc8f016ec4a29452"; \
	[ "$$REPLY" == "7" ] && DIFF="7" && REVISION="715a3024ad7ae3e89dad039bfb8ae49350552c39"; \
	[ "$$REPLY" == "8" ] && DIFF="8" && REVISION="e858a47a49c4fd8cdf22b29ea7278e6b4a2bddae"; \
	[ "$$REPLY" == "9" ] && DIFF="9" && REVISION="7272840d7db98a88f5c8b2882cc78d7ddc04e5e6"; \
	echo "Revision       : "$$REVISION; \
	echo ""; \
	if [ "$$REPLY" != "1" ]; then \
		REPO="git://git.code.sf.net/p/openpli/enigma2"; \
		rm -rf $(appsdir)/enigma2-nightly; \
		rm -rf $(appsdir)/enigma2-nightly.org; \
		[ -d "$(archivedir)/enigma2-pli-nightly.git" ] && \
		(cd $(archivedir)/enigma2-pli-nightly.git; git pull ; git checkout HEAD; cd "$(buildprefix)";); \
		[ -d "$(archivedir)/enigma2-pli-nightly.git" ] || \
		git clone -b $$HEAD $$REPO $(archivedir)/enigma2-pli-nightly.git; \
		cp -ra $(archivedir)/enigma2-pli-nightly.git $(appsdir)/enigma2-nightly; \
		[ "$$REVISION" == "" ] || (cd $(appsdir)/enigma2-nightly; git checkout "$$REVISION"; cd "$(buildprefix)";); \
		cp -ra $(appsdir)/enigma2-nightly $(appsdir)/enigma2-nightly.org; \
		cd $(appsdir)/enigma2-nightly && patch -p1 < "../../cdk/Patches/enigma2-pli-nightly.$$DIFF.diff"; \
	fi
	touch $@

$(appsdir)/enigma2-pli-nightly/config.status:
	cd $(appsdir)/enigma2-nightly && \
		./autogen.sh && \
		sed -e 's|#!/usr/bin/python|#!$(hostprefix)/bin/python|' -i po/xml2po.py && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--with-libsdl=no \
			--datadir=/usr/local/share \
			--libdir=/usr/lib \
			--bindir=/usr/bin \
			--prefix=/usr \
			--sysconfdir=/etc \
			--with-boxtype=none \
			PKG_CONFIG=$(hostprefix)/bin/$(target)-pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			PY_PATH=$(targetprefix)/usr \
			$(PLATFORM_CPPFLAGS) \
			$(E_CONFIG_OPTS)

$(D)/enigma2-pli-nightly.do_compile: $(appsdir)/enigma2-pli-nightly/config.status
	cd $(appsdir)/enigma2-nightly && \
		$(MAKE) all
	touch $@

$(D)/enigma2-pli-nightly: enigma2-pli-nightly.do_prepare enigma2-pli-nightly.do_compile
	$(MAKE) -C $(appsdir)/enigma2-nightly install DESTDIR=$(targetprefix)
	if [ -e $(targetprefix)/usr/bin/enigma2 ]; then \
		$(target)-strip $(targetprefix)/usr/bin/enigma2; \
	fi
	if [ -e $(targetprefix)/usr/local/bin/enigma2 ]; then \
		$(target)-strip $(targetprefix)/usr/local/bin/enigma2; \
	fi
	touch $@

enigma2-pli-nightly-clean:
	rm -f $(D)/enigma2-pli-nightly
	rm -f $(D)/enigma2-pli-nightly.do_compile
	cd $(appsdir)/enigma2-nightly && \
		$(MAKE) distclean

enigma2-pli-nightly-distclean:
	rm -f $(D)/enigma2-pli-nightly
	rm -f $(D)/enigma2-pli-nightly.do_compile
	rm -f $(D)/enigma2-pli-nightly.do_prepare
	rm -rf $(appsdir)/enigma2-nightly
	rm -rf $(appsdir)/enigma2-nightly.org
