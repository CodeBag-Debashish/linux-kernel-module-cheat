################################################################################
#
# PARSEC_BENCHMARK
#
################################################################################

PARSEC_BENCHMARK_VERSION = master
PARSEC_BENCHMARK_SITE = git@github.com:cirosantilli/parsec-benchmark.git
PARSEC_BENCHMARK_SITE_METHOD = git

define PARSEC_BENCHMARK_BUILD_CMDS
  cd $(@D) && . env.sh && for pkg in $(BR2_PACKAGE_PARSEC_BENCHMARK_BUILD_LIST); do \
    HOSTCC='$(HOSTCC)' \
      M4='$(HOST_DIR)/usr/bin/m4' \
      MAKE='$(MAKE)' \
      OSTYPE=linux \
      TARGET_CROSS='$(TARGET_CROSS)' \
      HOSTTYPE='$(BR2_ARCH)' \
      parsecmgmt -a build -p $$pkg \
    ; \
  done
endef

define PARSEC_BENCHMARK_INSTALL_TARGET_CMDS
  # This is a bit coarse and makes the image huge with useless source code,
  # and input files, but I don't feel like creating per-package installs.
  # And it doesn't matter much for simulators anyways.
  mkdir -p '$(TARGET_DIR)/parsec/'

  # TODO make this nicer. EXTRACT_CMDS and EXTRA_DOWNLOADS would be good candidates,
  # but they don't run with OVERRIDE_SRCDIR.
  '$(PARSEC_BENCHMARK_PKGDIR)/parsec-benchmark/get-inputs' $(if $(filter $(V),1),-v,) '$(DL_DIR)' '$(TARGET_DIR)/parsec/'

  # We must exclude mkg3states because Buildroot does an ISA check on all binaries
  # and fails if a mismatch is present, and this is a host utility. So annoying.
  rsync -a $(if $(filter $(V),1),-v,) --exclude 'ext/splash2/apps/volrend/obj/*/libtiff/mkg3states' '$(@D)/' '$(TARGET_DIR)/parsec/'
endef

$(eval $(generic-package))
