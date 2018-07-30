
CC = gcc
CFLAGS = -g -O2 -Wall -fPIC --shared -std=c99
INCLUDE = -Iskynet/3rd/lua -Iskynet/skynet-src

.PHONY: all

all: log luaclib cservice \
	skynet/skynet \
	luaclib/cjson.so \
	luaclib/skiplist.so \
	cservice/ex_loggersvr.so\


luaclib:: luaclib/
	-mkdir luaclib
luaclib/::

cservice:: cservice/
	-mkdir cservice
cservice/::

log:: log/
	-mkdir log
log/::

luaclib/cjson.so::luaclib-src/lua-cjson/*.c
	cd luaclib-src/lua-cjson && $(MAKE)
	mv luaclib-src/lua-cjson/cjson.so luaclib/

luaclib/skiplist.so:: luaclib-src/skiplist/lua-skiplist.c luaclib-src/skiplist/skiplist.c
	$(CC)  $(CFLAGS)  $(INCLUDE) -DLUA_COMPAT_5_2 $^ -o $@

cservice/ex_loggersvr.so: cservice-src/ex_loggersvr/ex_loggersvr.c
	$(CC)  $(CFLAGS)  -I$(INCLUDE) $^ -o $@

skynet/skynet:: skynet/Makefile skynet/lualib-src/* skynet/service-src/* skynet/skynet-src/*
	cd skynet && $(MAKE) linux -j8

clean:
	rm -rf luaclib/
	rm -rf cservice/
	cd skynet/ && make clean
