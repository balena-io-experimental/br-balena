###############################################################################
#
# balena-config-vars
#
###############################################################################

BALENA_CONFIG_VARS_VERSION = 2.96.0
BALENA_CONFIG_VARS_SITE = $(call github,balena-os,meta-balena,v$(BALENA_CONFIG_VARS_VERSION))
BALENA_CONFIG_VARS_LICENSE = Apache-2.0
BALENA_CONFIG_VARS_SUBDIR = $(@D)/meta-balena-common/recipes-support/balena-config-vars/balena-config-vars

BALENA_CONFIG_VARS_SCRIPTS = \
	balena-config-vars \
	os-networkmanager \
	os-udevrules \
	os-sshkeys \
	os-config-json

BALENA_CONFIG_VARS_SYSTEMD_SERVICES = \
	config-json.path \
	config-json.service \
	os-networkmanager.service \
	os-udevrules.service \
	os-sshkeys.service \
	os-config-json.service

define BALENA_CONFIG_VARS_INSTALL_TARGET_CMDS
	$(foreach script,$(BALENA_CONFIG_VARS_SCRIPTS), \
		$(INSTALL) -D -m 0755 \
			$(BALENA_CONFIG_VARS_SUBDIR)/$(script) \
			$(TARGET_DIR)/sbin/
	)

	$(INSTALL) -c -m 0644 $(BALENA_CONFIG_VARS_SUBDIR)/unit-conf.json \
		$(TARGET_DIR)/etc/systemd/

endef

define BALENA_CONFIG_VARS_INSTALL_INIT_SYSTEMD
	$(foreach service,$(BALENA_CONFIG_VARS_SYSTEMD_SERVICES), \
		$(INSTALL) -D -m 644 \
			$(BALENA_CONFIG_VARS_SUBDIR)/$(service) \
			$(TARGET_DIR)/usr/lib/systemd/system/$(service)
	)

	sed -i -e 's,@BASE_BINDIR@,/bin,g' \
	       -e 's,@SBINDIR@,/sbin,g' \
	       -e 's,@BINDIR,/usr/bin,g' \
		$(TARGET_DIR)/usr/lib/systemd/system/*.service
endef

$(eval $(generic-package))
