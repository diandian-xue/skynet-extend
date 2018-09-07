
CC = gcc
CFLAGS = -g -O2 -Wall -fPIC --shared -std=c99
INCLUDE = -Iskynet/3rd/lua -Iskynet/skynet-src

.PHONY: all

all: log luaclib cservice \
	skynet/skynet \
	luaclib/cjson.so \
	luaclib/skiplist.so \
	luaclib/protobuf.so \
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


skynet/skynet:: skynet/Makefile skynet/lualib-src/* skynet/service-src/* skynet/skynet-src/*
	cd skynet && $(MAKE) linux -j8

luaclib/cjson.so::luaclib-src/lua-cjson/*.c
	cd luaclib-src/lua-cjson && $(MAKE)
	cp luaclib-src/lua-cjson/cjson.so luaclib/

luaclib/skiplist.so:: luaclib-src/skiplist/lua-skiplist.c luaclib-src/skiplist/skiplist.c
	$(CC)  $(CFLAGS)  $(INCLUDE) -DLUA_COMPAT_5_2 $^ -o $@
	
luaclib/protobuf.so:: luaclib-src/pbc/src/* luaclib-src/pbc/tool/* luaclib-src/pbc/binding/lua53/*
	cd luaclib-src/pbc/ && $(MAKE)
	cd luaclib-src/pbc/binding/lua53/ && $(MAKE)
	cp luaclib-src/pbc/binding/lua53/protobuf.so luaclib/
	cp -r luaclib-src/pbc/binding/lua53/protobuf.lua lualib/

cservice/ex_loggersvr.so: cservice-src/ex_loggersvr/ex_loggersvr.c
	$(CC)  $(CFLAGS)  $(INCLUDE) $^ -o $@


clean:
	rm -rf luaclib/
	rm -rf cservice/
	cd skynet/ && $(MAKE) clean
	cd luaclib-src/pbc/ && $(MAKE) clean
	cd luaclib-src/pbc/binding/lua53/ && $(MAKE)
