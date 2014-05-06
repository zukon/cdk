#
# TF7700 installer
#
tfinstaller:
	@export PATH=$(hostprefix)/bin:$(PATH) && \
	$(MAKE) $(MAKE_OPTS) -C tfinstaller

#
# U-BOOT for the TF7700
#
HOST_U_BOOT := host-u-boot
U_BOOT_RAWVERSION := 1.3.1_stm23_0043
U_BOOT_VERSION := $(U_BOOT_RAWVERSION)-43
U_BOOT_DIR := u-boot/u-boot-sh4-$(U_BOOT_RAWVERSION)
U_BOOT_PREFIX	:= stlinux23-$(HOST_U_BOOT)-source-sh4
TFINSTALLER_DIR := tfinstaller

RPMS/noarch/$(U_BOOT_PREFIX)-$(U_BOOT_VERSION).noarch.rpm: \
		$(archivedir)/$(U_BOOT_PREFIX)-$(U_BOOT_VERSION).src.rpm
	rpm $(DRPM) --nosignature -Uhv $< && \
	mv SPECS/stm-$(HOST_U_BOOT).spec SPECS/stm-$(HOST_U_BOOT).spec_ && \
	sed -e "s/if_target_cpu sh/if 1/g" SPECS/stm-$(HOST_U_BOOT).spec_ > SPECS/stm-$(HOST_U_BOOT).spec && \
	rm SPECS/stm-$(HOST_U_BOOT).spec_ && \
	rpmbuild $(DRPMBUILD) -bb -v --clean --define "_stm_short_build_id 23" --define "_stm_target_name sh4" --define "_stm_pkg_prefix stlinux23" --target=sh --define "_stm_uboot_dir $(buildprefix)/u-boot" SPECS/stm-$(HOST_U_BOOT).spec

$(D)/u-boot-utils.do_prepare:  RPMS/noarch/$(U_BOOT_PREFIX)-$(U_BOOT_VERSION).noarch.rpm $(buildprefix)/Patches/u-boot-1.3.1_stm23_0043_tf7700.patch
	rm -fr $(U_BOOT_DIR)
	@rpm $(DRPM) --ignorearch --nodeps -Uhv $< && \
	(cd $(U_BOOT_DIR) && \
		patch -p1 < $(lastword $^) && \
		$(MAKE) tf7700_config )
	touch $@

$(D)/u-boot-utils.do_compile: bootstrap $(D)/u-boot-utils.do_prepare
	cd $(U_BOOT_DIR) && \
		$(MAKE)
	touch $@

$(D)/u-boot-utils: \
$(D)/%u-boot-utils: $(D)/u-boot-utils.do_compile $(TFINSTALLER_DIR)/u-boot.ftfd

$(TFINSTALLER_DIR)/u-boot.ftfd: $(U_BOOT_DIR)/u-boot.bin $(TFINSTALLER_DIR)/tfpacker
	$(TFINSTALLER_DIR)/tfpacker $< $@
	$(TFINSTALLER_DIR)/tfpacker -t $< $(@D)/Enigma_Installer.tfd

$(TFINSTALLER_DIR)/tfpacker:
	$(MAKE) -C $(TFINSTALLER_DIR) tfpacker

#
# HOST-U-BOOT-TOOLS
#
HOST_U_BOOT_TOOLS := host-u-boot-tools
U_BOOT_TOOLS_VERSION := 1.3.1_stm23-7

RPMS/sh4/stlinux23-$(HOST_U_BOOT_TOOLS)-$(U_BOOT_TOOLS_VERSION).sh4.rpm: \
		$(archivedir)/stlinux23-$(HOST_U_BOOT_TOOLS)-$(U_BOOT_TOOLS_VERSION).src.rpm
	rpm $(DRPM) --nosignature -Uhv $< && \
	rpmbuild $(DRPMBUILD) -bb -v --clean --target=sh4-linux --define "_stm_short_build_id 23" --define "_stm_pkg_prefix stlinux23" --define "_stm_uboot_dir $(buildprefix)/u-boot" SPECS/stm-$(HOST_U_BOOT_TOOLS).spec

$(D)/$(HOST_U_BOOT_TOOLS): u-boot-utils.do_prepare RPMS/sh4/stlinux23-$(HOST_U_BOOT_TOOLS)-$(U_BOOT_TOOLS_VERSION).sh4.rpm | bootstrap-cross
	@rpm $(DRPM) --ignorearch --nodeps -Uhv $(lastword $^) && \
	touch $@

