#### CONFIGURE VARIABLE

# export ERLC_EMULATOR to fix a bug in R9B with native compilation
ERLC_EMULATOR=/usr/bin/erl
export ERLC_EMULATOR
ERL=/usr/bin/erl
ERLC=/usr/bin/erlc
SED=/bin/sed
ERL_OPTS=
# FIXME
DIALYZER=/usr/bin/dialyzer

ERLDIR=/usr/lib/erlang
export ERLDIR

USENEWTIMEAPI=yes

ERLANG_XMERL_DIR=/usr/lib/erlang/lib/xmerl-1.3.18/include

raw_erlang_prefix=${exec_prefix}/lib/erlang/

PACKAGE_TARNAME=tsung

prefix=/usr
exec_prefix=${prefix}
bindir=${exec_prefix}/bin
libdir=${exec_prefix}/lib
datadir=${datarootdir}
datarootdir=${prefix}/share
docdir=${datarootdir}/doc/${PACKAGE_TARNAME}
TEMPLATES_SUBDIR=tsung/templates

CONFIGURE_DEPENDENCIES=vsn.mk
CONFIG_STATUS_DEPENDENCIES=vsn.mk

VERSION=1.7.1_dev
PACKAGE=tsung
DTD=tsung-1.0.dtd

#### END OF SUBSTITUTION

SVN_REVISION=$Revision$

ERL_COMPILER_OPTIONS="[warn_unused_vars]"
export ERL_COMPILER_OPTIONS

ifeq ($(TYPE),debug)
OPT =+debug_info -DDEBUG
else
 ifeq ($(TYPE),native)
   OPT:=+native
  else
   OPT = +strict_record_tests
  endif
endif

EBIN = ./ebin
EBIN_TEST = ./ebin-test

ifeq ($(TYPE),test)
OPT =+export_all +debug_info
EBIN = $(EBIN_TEST)
endif

ifeq ($(USENEWTIMEAPI),yes)
OPT  += -Dnew_time_api
endif


INC = ./include
CC  = $(ERLC)

ESRC = ./src
ifeq ($(TYPE),snapshot)
DAY=$(shell date +"%Y%m%d")
distdir = $(PACKAGE)-$(VERSION)-$(DAY)
else
distdir = $(PACKAGE)-$(VERSION)
endif

# installation path
BINDIR    = $(bindir)
LIBDIR    = $(libdir)/tsung/
TOOLS_BINDIR = $(LIBDIR)/bin
CONFDIR   = $(docdir)/examples
SHARE_DIR = $(datadir)/tsung/
TEMPLATES_DIR = $(datadir)/$(TEMPLATES_SUBDIR)
MAN_DIR   = $(datadir)/man/man1/
DOC_DIR   = $(docdir)

# custom behaviours
BEHAVIORS  = $(EBIN)/ts_plugin.beam $(EBIN)/gen_ts_transport.beam

ERLANG_LIB_DIR = $(libdir)/erlang/lib

APPLICATION = tsung
CONTROLLER_APPLICATION = tsung_controller
RECORDER_APPLICATION = tsung_recorder

RECORDER_TARGETDIR = $(LIBDIR)/$(RECORDER_APPLICATION)-$(VERSION)
CONTROLLER_TARGETDIR = $(LIBDIR)/$(CONTROLLER_APPLICATION)-$(VERSION)
TARGETDIR = $(LIBDIR)/$(APPLICATION)-$(VERSION)

TEMPLATES = $(wildcard $(ESRC)/templates/*.thtml)
TEMPLATES_STYLE = $(wildcard $(ESRC)/templates/style/*.js)
TEMPLATES_STYLE += $(wildcard $(ESRC)/templates/style/*.css)
TMP       = $(wildcard *~) $(wildcard src/*~) $(wildcard inc/*~)
INC_FILES = $(wildcard $(INC)/*.hrl)
LIBSRC    = $(wildcard $(ESRC)/lib/*.erl)
TESTSRC    = $(wildcard $(ESRC)/test/*.erl)
SRC       = $(wildcard $(ESRC)/$(APPLICATION)/*.erl)
CONTROLLER_SRC  = $(wildcard $(ESRC)/$(CONTROLLER_APPLICATION)/*.erl)
RECORDER_SRC    = $(wildcard $(ESRC)/$(RECORDER_APPLICATION)/*.erl)
CONFFILE_SRC = $(wildcard examples/*.xml.in)
CONFFILE = $(basename $(CONFFILE_SRC))
TEST_CONFFILE_SRC = $(wildcard src/test/*.xml.in)
TEST_CONFFILE = $(basename $(TEST_CONFFILE_SRC))
USERMANUAL = docs/_build/latex/Tsung.pdf
USERMANUAL_IMG = $(wildcard docs/images/*.png)
USERMANUAL_SRC = $(wildcard docs/*.rst docs/*.txt)
MANPAGES   = $(wildcard man/*.1)
PERL_SCRIPTS_SRC = $(wildcard $(ESRC)/*.pl.in)
PERL_SCRIPTS = $(basename $(PERL_SCRIPTS_SRC))

TSPLOT_SRC = $(wildcard $(ESRC)/tsung-plotter/*.py.in)
TSPLOT = $(basename $(TSPLOT_SRC))
TSUNG_PLOTTER_LIB= $(wildcard $(ESRC)/tsung-plotter/tsung/*.py)
TSUNG_PLOTTER_CONF= $(wildcard $(ESRC)/tsung-plotter/tsung/*.conf) $(wildcard $(ESRC)/tsung-plotter/*.conf)

TARGET   = $(addsuffix .beam, $(basename \
             $(addprefix $(EBIN)/, $(notdir $(SRC)))))
LIB_TARGET   = $(addsuffix .beam, $(basename \
             $(addprefix $(EBIN)/, $(notdir $(LIBSRC)))))
CONTROLLER_TARGET   = $(addsuffix .beam, $(basename \
             $(addprefix $(EBIN)/, $(notdir $(CONTROLLER_SRC)))))
RECORDER_TARGET   = $(addsuffix .beam, $(basename \
             $(addprefix $(EBIN)/, $(notdir $(RECORDER_SRC)))))
TEST_TARGET   = $(addsuffix .beam, $(basename \
             $(addprefix $(EBIN)/, $(notdir $(TESTSRC)))))
DEBIAN    = debian/changelog debian/control debian/compat debian/copyright debian/docs debian/tsung.dirs debian/rules

APPFILES   = $(EBIN)/$(APPLICATION).app
APPFILES_IN   = $(ESRC)/$(APPLICATION)/$(APPLICATION).app.in
CONTROLLER_APPFILES   = $(EBIN)/$(CONTROLLER_APPLICATION).app
CONTROLLER_APPFILES_IN   = $(ESRC)/$(CONTROLLER_APPLICATION)/$(CONTROLLER_APPLICATION).app.in
RECORDER_APPFILES   = $(EBIN)/$(RECORDER_APPLICATION).app
RECORDER_APPFILES_IN   = $(ESRC)/$(RECORDER_APPLICATION)/$(RECORDER_APPLICATION).app.in

SCRIPT   = $(BINDIR)/tsung
REC_SCRIPT   = $(BINDIR)/tsung-recorder
PWD = $(shell pwd)

DIST_COMMON=Makefile.in $(CONFFILE_SRC) $(PERL_SCRIPTS_SRC) $(TSPLOT_SRC) tsung.sh.in tsung-recorder.sh.in tsung.spec.in $(CONTROLLER_APPFILES_IN)

DOC_OPTS={def,{version,\"$(VERSION)\"}}

.PHONY: doc

tsung: Makefile config.status $(PERL_SCRIPTS)  $(TSPLOT) tsung.sh tsung-recorder.sh tsung.spec $(TARGET) $(RECORDER_TARGET) $(CONTROLLER_TARGET) $(LIB_TARGET)  $(CONTROLLER_APPFILES) $(APPFILES) $(RECORDER_APPFILES)

buildtest: $(TEST_TARGET)

fulltest:  clean test

test:
	@mkdir -p $(EBIN_TEST)
	$(MAKE) TYPE=test dotest

dotest: tsung buildtest $(CONFFILE) $(TEST_CONFFILE)
	$(ERL) -noshell -pa $(EBIN_TEST) -s ts_test_all run -s init stop

edoc:
	$(ERL) -noshell -eval "edoc:application($(APPLICATION), \"./$(ESRC)/$(APPLICATION)\", [$(DOC_OPTS)])" -s init stop
	$(ERL) -noshell -eval "edoc:application($(CONTROLLER_APPLICATION), \
          \"./$(ESRC)/$(CONTROLLER_APPLICATION)\", [$(DOC_OPTS)])" -s init stop
	$(ERL) -noshell -eval "edoc:application($(RECORDER_APPLICATION),  \
          \"./$(ESRC)/$(RECORDER_APPLICATION)\", [$(DOC_OPTS)])" -s init stop

# TODO: remove -Wno_behaviours, but only if R15B became a requirement.
# see http://erlang.org/pipermail/erlang-questions/2012-January/063608.html
dialyzer:
	$(DIALYZER) -r ebin  -I ./include/ -Wno_undefined_callbacks

all: clean tsung

debug:
	$(MAKE) TYPE=debug

native:
	$(MAKE) TYPE=native

rpm:	release tsung.spec
	rpmbuild -ta $(distdir).tar.gz

validate: $(CONFFILE)
	@for i in $(CONFFILE); do xmlproc_val $$i; done

deb:
	fakeroot debian/rules clean
	debian/rules build
	fakeroot debian/rules binary

show:
	@echo $(LIBSRC)

clean:
	-rm -fr $(EBIN_TEST)
	-rm -f $(TARGET) $(TMP)
	-rm -f $(RECORDER_APPFILES)  $(CONTROLLER_APPFILES) $(APPFILES)
	-rm -f $(EBIN)/*.app  $(PERL_SCRIPTS) $(TSPLOT) $(CONFFILE)
	-rm -f $(EBIN)/*.beam tsung.sh tsung.spec tsung.xml tsung.sh tsung-recorder.sh
	-rm -f *.xml config.log src/test/*.xml src/test/usersdb.csv

install: tsung doc install_recorder install_controller $(CONFFILE)
	-rm -f $(TMP)

	install -d $(DESTDIR)$(TARGETDIR)/priv
	install -d $(DESTDIR)$(TARGETDIR)/ebin
	install -d $(DESTDIR)$(TARGETDIR)/src
	install -d $(DESTDIR)$(TARGETDIR)/include
	install -d $(DESTDIR)$(TOOLS_BINDIR)/
	install -d $(DESTDIR)$(BINDIR)/

	install -pm 0644 $(INC_FILES) $(DESTDIR)$(TARGETDIR)/include/
	install -pm 0644 $(TARGET) $(DESTDIR)$(TARGETDIR)/ebin/
	install -pm 0644 $(LIB_TARGET) $(DESTDIR)$(TARGETDIR)/ebin/


	install -pm 0644 $(APPFILES) $(DESTDIR)$(TARGETDIR)/ebin/

	install -pm 0644 $(SRC) $(DESTDIR)$(TARGETDIR)/src/

# install the man page
	install -d $(DESTDIR)$(MAN_DIR)
	install -pm 0644 $(MANPAGES) $(DESTDIR)$(MAN_DIR)

# create startup script
	install -pm 0755 tsung.sh $(DESTDIR)$(SCRIPT)
	install -pm 0755 tsung-recorder.sh $(DESTDIR)$(REC_SCRIPT)
	install -pm 0755 $(PERL_SCRIPTS) $(DESTDIR)$(TOOLS_BINDIR)
# tsung-plotter
	install -pm 0755 $(TSPLOT) $(DESTDIR)$(BINDIR)/tsplot
	install -d $(DESTDIR)$(LIBDIR)/tsung_plotter
	install -d $(DESTDIR)$(SHARE_DIR)/tsung_plotter
	install -pm 0644 $(TSUNG_PLOTTER_LIB) $(DESTDIR)$(LIBDIR)/tsung_plotter
	install -pm 0644 $(TSUNG_PLOTTER_CONF) $(DESTDIR)$(SHARE_DIR)/tsung_plotter

	install -d $(DESTDIR)$(CONFDIR)
	install -pm 0644 $(CONFFILE) $(DESTDIR)$(CONFDIR)/

	install -d $(DESTDIR)$(TEMPLATES_DIR)
	install -d $(DESTDIR)$(TEMPLATES_DIR)/style
	install -pm 0644 $(TEMPLATES) $(DESTDIR)$(TEMPLATES_DIR)/
	install -pm 0644 $(TEMPLATES_STYLE) $(DESTDIR)$(TEMPLATES_DIR)/style
	install -pm 0644 $(DTD) $(DESTDIR)$(SHARE_DIR)/

install_recorder:
	install -d $(DESTDIR)$(RECORDER_TARGETDIR)/priv
	install -d $(DESTDIR)$(RECORDER_TARGETDIR)/ebin
	install -d $(DESTDIR)$(RECORDER_TARGETDIR)/src
	install -d $(DESTDIR)$(RECORDER_TARGETDIR)/include

	install -pm 0644 $(INC_FILES) $(DESTDIR)$(RECORDER_TARGETDIR)/include
	install -pm 0644 $(RECORDER_TARGET) $(DESTDIR)$(RECORDER_TARGETDIR)/ebin

	install -pm 0644 $(RECORDER_APPFILES) $(DESTDIR)$(RECORDER_TARGETDIR)/ebin

	install -pm 0644 $(RECORDER_SRC) $(DESTDIR)$(RECORDER_TARGETDIR)/src

install_controller:
	install -d $(DESTDIR)$(CONTROLLER_TARGETDIR)/priv
	install -d $(DESTDIR)$(CONTROLLER_TARGETDIR)/ebin
	install -d $(DESTDIR)$(CONTROLLER_TARGETDIR)/src
	install -d $(DESTDIR)$(CONTROLLER_TARGETDIR)/include
	install -pm 0644 $(INC_FILES) $(DESTDIR)$(CONTROLLER_TARGETDIR)/include
	install -pm 0644 $(CONTROLLER_TARGET) $(DESTDIR)$(CONTROLLER_TARGETDIR)/ebin

	install -pm 0644 $(CONTROLLER_APPFILES) $(DESTDIR)$(CONTROLLER_TARGETDIR)/ebin

	install -pm 0644 $(CONTROLLER_SRC) $(DESTDIR)$(CONTROLLER_TARGETDIR)/src

uninstall:
	rm -rf $(TARGETDIR) $(SCRIPT)

Makefile: Makefile.in config.status
	@$(SHELL) ./config.status --file=$@

%.pl:  %.pl.in vsn.mk
	@$(SHELL) ./config.status --file=$@

%.py:  %.py.in vsn.mk
	@$(SHELL) ./config.status --file=$@

%.spec:  %.spec.in vsn.mk
	@$(SHELL) ./config.status --file=$@

%.xml:  %.xml.in
	@$(SHELL) ./config.status --file=$@

%.sh :%.sh.in vsn.mk
	@$(SHELL) ./config.status --file=$@

$(APPFILES): $(APPFILES_IN)
	@$(SHELL) ./config.status --file=$@:$<

$(CONTROLLER_APPFILES): $(CONTROLLER_APPFILES_IN)
	@$(SHELL) ./config.status --file=$@:$<

$(RECORDER_APPFILES): $(RECORDER_APPFILES_IN)
	@$(SHELL) ./config.status --file=$@:$<

config.status: configure $(CONFIG_STATUS_DEPENDENCIES)
	$(SHELL) ./config.status --recheck


configure: configure.ac $(CONFIGURE_DEPENDENCIES)
	@echo "running autoconf"
	@autoconf

doc:
	$(MAKE) -C man man

user_guide:
	$(MAKE) -C docs latexpdf

release: Makefile tsung.spec doc user_guide
	rm -fr $(distdir)
	mkdir -p $(distdir)
	tar zcf tmp.tgz $(SRC) $(APPFILES_IN) $(INC_FILES) $(LIBSRC) \
		$(CONTROLLER_SRC) $(CONTROLLER_APPFILES_IN) $(TESTSRC) \
		$(RECORDER_APPFILES_IN) \
		$(RECORDER_SRC) $(TEMPLATES) $(TEMPLATES_STYLE)\
		man/*.erl man/*.txt man/*.dia man/*.png man/Makefile man/*.sgml man/*.1 \
		docs/*.rst docs/Makefile docs/*.txt docs/README docs/*.py docs/_static docs/_templates \
		$(USERMANUAL) $(USERMANUAL_SRC) $(USERMANUAL_IMG) $(DTD) \
		COPYING README.md LISEZMOI TODO $(CONFFILE_SRC) $(TEST_CONFFILE_SRC) \
		tsung.sh.in vsn.mk  src/test/*.csv src/test/*.txt \
		src/test/*.out \
		$(DEBIAN)  $(PERL_SCRIPTS_SRC) CONTRIBUTORS CHANGELOG.md \
		$(TSPLOT_SRC) $(TSUNG_PLOTTER_CONF) $(TSUNG_PLOTTER_LIB)\
		configure configure.ac config.guess *.m4 config.sub Makefile.in \
		install-sh tsung.spec.in tsung.spec tsung-recorder.sh.in
	tar -C $(distdir) -zxf tmp.tgz
	mkdir $(distdir)/ebin
	tar zvcf  $(distdir).tar.gz $(distdir)
	rm -fr $(distdir)
	rm -fr tmp.tgz

snapshot:
	$(MAKE) TYPE=snapshot release

$(EBIN)/%.beam: src/test/%.erl $(INC_FILES)
	@echo  "Compiling test $< ... "
	@$(CC) -W0 $(OPT) -I $(INC) -I $(ERLANG_XMERL_DIR) -o $(EBIN) $<

$(EBIN)/%.beam: src/lib/%.erl $(INC_FILES)
	@echo  "Compiling  $< ... "
	@$(CC) -W0 $(OPT) -I $(INC) -I $(ERLANG_XMERL_DIR) -o $(EBIN) $<

# to avoid circular dependency
$(EBIN)/ts_plugin.beam: src/$(APPLICATION)/ts_plugin.erl $(INC_FILES)
	@echo  "Compiling  $< ... "
	@$(CC) $(OPT) -I $(INC) -I $(ERLANG_XMERL_DIR) -pa $(EBIN) -o $(EBIN) $<

# to avoid circular dependency
$(EBIN)/gen_ts_transport.beam: src/$(APPLICATION)/gen_ts_transport.erl $(INC_FILES)
	@echo  "Compiling  $< ... "
	@$(CC) $(OPT) -I $(INC) -I $(ERLANG_XMERL_DIR) -pa $(EBIN) -o $(EBIN) $<

$(EBIN)/%.beam: src/$(APPLICATION)/%.erl $(INC_FILES) $(BEHAVIORS)
	@echo  "Compiling  $< ... "
	@$(CC) $(OPT) -I $(INC) -I $(ERLANG_XMERL_DIR) -pa $(EBIN) -o $(EBIN) $<

$(EBIN)/%.beam: src/$(RECORDER_APPLICATION)/%.erl  $(INC_FILES) $(BEHAVIORS)
	@echo  "Compiling  $< ... "
	@$(CC) $(OPT) -I $(INC) -I $(ERLANG_XMERL_DIR) -pa $(EBIN) -o $(EBIN) $<

$(EBIN)/%.beam: src/$(CONTROLLER_APPLICATION)/%.erl  $(INC_FILES) $(BEHAVIORS)
	@echo "Compiling  $< ... "
	@$(CC) $(OPT) -I $(INC) -I $(ERLANG_XMERL_DIR) -pa $(EBIN) -o $(EBIN) $<

%:%.sh
# Override makefile default implicit rule
