#
# HOST-U-BOOT-TOOLS SMALL
#
HOST_U_BOOT_TOOLS := host_u_boot_tools
$(D)/host_u_boot_tools: @DEPENDS_host_u_boot_tools@
	@PREPARE_host_u_boot_tools@
	cp -Ppr @DIR_host_u_boot_tools@/opt/STM/STLinux-2.4/host/bin/* $(hostprefix)/bin
	@CLEANUP_host_u_boot_tools@
	touch $@

