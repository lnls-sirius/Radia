# This Makefile is to compile RADIA with optional compilation of FFTW-2.1.5 library.
#
# The following options are available:
# - `make all` - will compile FFTW, C++ core and Python lib;
# - `make fftw` - will compile FFTW only;
# - `make` - will compile C++ core and Python lib;
# - `make clean` - will clean temporary files.
# - `make install` - will compile FFTW, C++ core and Python lib and install Python package;
# - `make uninstall` - will clean temporary files and uninstall Python package

root_dir = $(realpath .)
env_dir = $(root_dir)/env
ext_dir = $(root_dir)/ext_lib
gcc_dir = $(root_dir)/cpp/gcc
py_dir = $(root_dir)/cpp/py
fftw_version = fftw-2.1.5
fftw_dir = $(fftw_version)
fftw_file = $(fftw_version).tar.gz
log_fftw = /dev/null
examples_dir = $(env_dir)/radia_python
export MODE ?= 0
timeout=20

nofftw: core pylib

all: clean fftw core pylib

fftw:
	if [ ! -d "$(ext_dir)" ]; then \
	    mkdir $(ext_dir); \
	fi; \
	cd $(ext_dir); \
	if [ ! -f "$(fftw_file)" ]; then \
	    wget https://raw.githubusercontent.com/ochubar/SRW/master/ext_lib/$(fftw_file); \
	fi; \
	if [ -d "$(fftw_dir)" ]; then \
	    rm -rf $(fftw_dir); \
	fi; \
	tar -zxf $(fftw_file); \
	cd $(fftw_dir); \
	./configure --enable-float --with-pic; \
	sed 's/^CFLAGS = /CFLAGS = -fPIC /' -i Makefile; \
	make -j8 && cp fftw/.libs/libfftw.a $(ext_dir); \
	cd $(root_dir); \
	rm -rf $(ext_dir)/$(fftw_dir);

core:
	#cd $(gcc_dir); make -j8 clean lib
	cd $(gcc_dir); make clean lib

pylib:
	cd $(py_dir); make python

clean:
	rm -f $(ext_dir)/libfftw.a $(gcc_dir)/libradia.a $(gcc_dir)/radia*.so; \
	rm -rf $(ext_dir)/$(fftw_dir)/py/build/;
	if [ -d $(root_dir)/.git ]; then rm -f $(examples_dir)/radia*.so && (git checkout $(examples_dir)/radia*.so 2>/dev/null || :); fi;

install: clean fftw core
	cd $(py_dir); make install

uninstall: clean
	cd $(py_dir); make uninstall

.PHONY: all clean core fftw nofftw pylib install uninstall
