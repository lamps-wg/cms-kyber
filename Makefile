DEPS_FILES := \
	CMS-KYBER-2024.asn \
	./example/ML-KEM-512.pub \
	./example/ML-KEM-512.keyid \
	./example/ML-KEM-512.cms \
	./example/ML-KEM-512.cms.txt \
	./example/ML-KEM-512-seed.priv \
	./example/ML-KEM-512-expanded.priv \
	./example/ML-KEM-512-both.priv \
	./example/cek.txt \
	./example/ciphertext.txt \
	./example/decrypted.txt \
	./example/encrypted_cek.txt \
	./example/kek.txt \
	./example/ori_info.txt \
	./example/plaintext.txt \
	./example/shared_secret.txt
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
