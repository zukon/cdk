#
# diff helper
#
enigma2-nightly-diff \
neutrino-mp-next-diff \
neutrino-mp-tangos-diff \
neutrino-mp-martii-github-diff \
neutrino-mp-github-next-cst-diff \
libstb-hal-next-diff \
libstb-hal-github-diff \
libstb-hal-github-old-diff :
	cd $(sourcedir) && diff -NEbur --exclude-from=$(buildprefix)/scripts/diff-exclude $(subst -diff,,$@).org $(subst -diff,,$@) > $(cvsdir)/$@ ; [ $$? -eq 1 ]

# keeping all patches together in one file
# uncomment if needed
#
# Neutrino MP from github
NEUTRINO_MP_LIBSTB_GH_PATCHES += 
NEUTRINO_MP_GH_PATCHES += 

# Neutrino MP from github
NEUTRINO_MP_LIBSTB_GH_OLD_PATCHES += 
NEUTRINO_MP_GH_NEXT_CST_PATCHES += 

# Neutrino MP from martii
NEUTRINO_MP_MARTII_GH_PATCHES += 

# Neutrino MP from gitourius
NEUTRINO_MP_LIBSTB_PATCHES += 
NEUTRINO_MP_PATCHES += 

# Neutrino MP Next from gitourius
NEUTRINO_MP_LIBSTB_NEXT_PATCHES += 
NEUTRINO_MP_NEXT_PATCHES += 

# Neutrino MP Tango
NEUTRINO_MP_TANGOS_PATCHES += 

# Neutrino HD2
NEUTRINO_HD2_PATCHES+= $(PATCHES)/neutrino-hd2-exp.diff
