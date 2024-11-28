DEPS_FILES := \
	CMS-KYBER-2024.asn \
	./example/ML-KEM-512.pub \
	./example/ML-KEM-512.keyid \
	./example/ML-KEM-512.cms \
	./example/ML-KEM-512.cms.txt \
	./example/ML-KEM-512.priv \
	./example/decrypted.txt
LIBDIR := lib
include $(LIBDIR)/main.mk

$(LIBDIR)/main.mk:
ifneq (,$(shell grep "path *= *$(LIBDIR)" .gitmodules 2>/dev/null))
	git submodule sync
	git submodule update --init
else
ifneq (,$(wildcard $(ID_TEMPLATE_HOME)))
	ln -s "$(ID_TEMPLATE_HOME)" $(LIBDIR)
else
	git clone -q --depth 10 -b main \
	    https://github.com/martinthomson/i-d-template $(LIBDIR)
endif
endif
