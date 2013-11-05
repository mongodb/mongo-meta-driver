# Makefile for MongoDB Sphinx documentation
# MAKEFLAGS += -j
# MAKEFLAGS += -r
MAKEFLAGS += --no-print-directory

# Build directory tweaking.

noop:
output = build
include $(output)/makefile.meta

DOCS_SOURCE ?= source
DOCS_DIR ?= ./

help:
	@echo "Please use \`make <target>' where <target> is one of"
	@echo "	 html		to make standalone HTML files"
	@echo "	 dirhtml	to make HTML files named index.html in directories"
	@echo
	@echo "MongoDB Meta Driver Specific Targets."
	@echo "	 publish	runs publication process and then deploys the build to $(public-output)"
	@echo "	 push		runs publication process and pushes to docs site to production."
	@echo "	 pdfs		generates pdfs more efficently than latexpdf."
	@echo
#
# Meta targets that control the build and publication process.
#

.PHONY: push publish-if-up-to-date

publish:initial-dependencies
	$(MAKE) sphinx-components
	$(MAKE) static-components
	@echo [build]: $(primary-branch) branch is succeessfully deployed to '$(public-output)'.


######################################################################
#
# Targets that should/need only be accessed in publication
#
######################################################################

# Deployment targets to kick off the rest of the build process. Only
# access these targets through the ``publish`` target.
.PHONY: initial-dependencies static-components sphinx-components post-processing

initial-dependencies:$(DOCS_SOURCE)/about.txt
	@echo [build]: completed the pre-publication routine for the $(primary-branch) branch of the Manual.
static-components:$(public-branch-output)/release.txt $(public-output)/index.html $(public-output)/osd.xml links
	@echo [build]: completed building and migrating all non-Sphinx components of the build.
sphinx-components:$(public-branch-output)/
	@echo [build]: completed the publication routine for all Sphinx Components of the Manual Build.

.PHONY:$(DOCS_SOURCE)/about.txt setup

setup:
	@mkdir -p $(public-branch-output)
	@echo [build]: created $(public-branch-output)

$(branch-output)/singlehtml/contents.html:$(branch-output)/singlehtml
$(DOCS_SOURCE)/about.txt:setup
	@touch $@
	@echo [build]: touched '$@' to ensure a fresh build.
$(branch-output)/dirhtml:dirhtml
	@touch $@
	@echo [build]: touched $@ to ensure proper migration.
$(branch-output)/html:html
	@touch $@
	@echo [build]: touched $@ to ensure proper migration.
$(branch-output)/singlehtml:singlehtml
	@touch $@
	@echo [build]: touched $@ to ensure proper migration.
#
# Migrating and processing the dirhtml and singlehtml as needed.
#
$(public-branch-output)/:$(branch-output)/dirhtml
	@cp -R $</* $@
	@echo [build]: migrated '$</*' to '$@'

# Deployment related work for the non-Sphinx aspects of the build.
$(public-branch-output)/release.txt:$(public-output)/latest
	@echo [build]: generating '$@' with current release hash.
	@git rev-parse --verify HEAD >|$@
$(public-output)/latest:$(public-output) 
	@fab process.input:master process.output:$@ process.create_link
$(public-output):
	@mkdir -p $@
	@echo [build]: created $(branch-output)/

.PHONY:links

links: $(public-branch-output)/specifications
$(public-branch-output)/specifications:$(public-branch-output)/specification
	@$(DOCS_DIR)/bin/create-link $(notdir $<) $(notdir $@) $@

$(public-output)/index.html:$(DOCS_DIR)/themes/meta-driver/index.html
	@cp $< $@
	@echo [build]: migrated $@
$(public-output)/osd.xml:$(DOCS_DIR)/themes/meta-driver/osd.xml
	@cp $< $@
	@echo [build]: migrated $@
