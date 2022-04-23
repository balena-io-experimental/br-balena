###############################################################################
#
# balena-supervisor
#
###############################################################################

BALENA_SUPERVISOR_VERSION = 12.11.38
BALENA_SUPERVISOR_SITE = $(call github,balena-os,balena-supervisor,v$(BALENA_SUPERVISOR_VERSION))
BALENA_SUPERVISOR_LICENSE = Apache-2.0
BALENA_SUPERVISOR_LICENSE_FILES = LICENSE.md
BALENA_SUPERVISOR_DEPENDENCIES = host-libcurl
BALENA_SUPERVISOR_PKGDIR = $(BR2_EXTERNAL_BALENA_PATH)/package/balena-supervisor
BALENA_SUPERVISOR_IMAGE = $(shell $(BALENA_SUPERVISOR_PKGDIR)/query-supervisor.sh \
			  v$(BALENA_SUPERVISOR_VERSION) $(BR2_PACKAGE_BALENA_SUPERVISOR_TARGET_ARCH))

ifeq ($(BALENA_SUPERVISOR_IMAGE),)
$(error "Could not retrieve supervisor image for version v$(BALENA_SUPERVISOR_VERSION)")
endif

BALENA_SUPERVISOR_SYSTEMD_SERVICES = \
	resin-data.mount \
	balena-supervisor.service \
	update-balena-supervisor.service \
	update-balena-supervisor.timer \
	migrate-supervisor-state.service

define BALENA_SUPERVISOR_INSTALL_TARGET_CMDS
	$(INSTALL) -d $(TARGET_DIR)/etc/balena-supervisor/
	$(INSTALL) -m 0755 $(BALENA_SUPERVISOR_PKGDIR)/supervisor.conf \
		$(TARGET_DIR)/etc/balena-supervisor
	$(SED) "s,@LED_FILE@,/dev/null,g" \
		$(TARGET_DIR)/etc/balena-supervisor/supervisor.conf
	$(SED) "s,@SUPERVISOR_VERSION@,v$(BALENA_SUPERVISOR_VERSION),g" \
		$(TARGET_DIR)/etc/balena-supervisor/supervisor.conf
	$(SED) "s,@SUPERVISOR_IMAGE@,$(BALENA_SUPERVISOR_IMAGE),g" \
		$(TARGET_DIR)/etc/balena-supervisor/supervisor.conf

	$(INSTALL) -d $(TARGET_DIR)/resin-data

	$(INSTALL) -m 0755 \
		$(BALENA_SUPERVISOR_PKGDIR)/update-balena-supervisor \
		$(TARGET_DIR)/usr/bin/
	$(INSTALL) -m 0755 \
		$(BALENA_SUPERVISOR_PKGDIR)/start-balena-supervisor \
		$(TARGET_DIR)/usr/bin/

endef

define BALENA_SUPERVISOR_INSTALL_INIT_SYSTEMD
	$(foreach service,$(BALENA_SUPERVISOR_SYSTEMD_SERVICES), \
		$(INSTALL) -D -m 644 \
			$(BALENA_SUPERVISOR_PKGDIR)/$(service) \
			$(TARGET_DIR)/usr/lib/systemd/system/$(service)
	)

	ln -sf balena-supervisor.service \
		$(TARGET_DIR)/usr/lib/systemd/system/resin-supervisor.service
	ln -sf update-balena-supervisor.service \
		$(TARGET_DIR)/usr/lib/systemd/system/update-resin-supervisor.service
	ln -sf update-balena-supervisor.timer \
		$(TARGET_DIR)/usr/lib/systemd/system/update-resin-supervisor.timer

	# disable these resin aliases from being enabled by `systemctl preset-all`
	echo -e "disable resin-supervisor.service" \
		"\ndisable update-resin-supervisor.service" \
		"\ndisable update-resin-supervisor.timer" \
		> $(TARGET_DIR)/usr/lib/systemd/system-preset/80-legacy-resin.preset

	sed -i -e 's,@BASE_BINDIR@,/bin,g' \
	       -e 's,@SBINDIR@,/sbin,g' \
	       -e 's,@BINDIR@,/usr/bin,g' \
		$(TARGET_DIR)/usr/lib/systemd/system/*.service

	$(INSTALL) -d $(TARGET_DIR)/usr/lib/balena-supervisor
	$(INSTALL) -m 0755 \
		$(BALENA_SUPERVISOR_PKGDIR)/balena-supervisor-healthcheck \
		$(TARGET_DIR)/usr/lib/balena-supervisor/balena-supervisor-healthcheck

	$(INSTALL) -m 0755 \
		$(BALENA_SUPERVISOR_PKGDIR)/tmpfiles-supervisor.conf \
		$(TARGET_DIR)/etc/tmpfiles.d/supervisor.conf
endef

$(eval $(generic-package))
