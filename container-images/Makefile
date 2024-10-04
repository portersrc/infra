
#
# FIXME need docker login for pushing to work...
#
# FIXME dont want to use sudo for buildctl. also, i have to add some way
# of running  buildkit daemon, which id prefer not to:
#   $ sudo ./buildkitd
# I would have to run that in background and then make kill it at the end.
#

.PHONY: unsig \
cosign-sig \
simple-sig \
enc-unsig \
enc-cosign-sig \
test-container-unencrypted \
test-container-encrypted \
busybox \
busybox-gzip \
busybox-zstd \
busybox-enc-jwe

SHELL=/bin/bash



LOCAL_SIGSTORE_PATH=$(HOME)/.local/share/containers/sigstore
ETC_SIGSTORE_PATH=/etc/containers/ghcr_verification/signatures

# FIXME Replace portersrc
COCO_PKG=portersrc/test-container
COCO_IMGRS_PKG=portersrc/test-container-image-rs

# FIXME Replace /home/porter/wo etc.
BUILDCTL_PATH=/home/porter/wo/buildkit/bin
GUEST_COMPONENTS_PATH=/home/porter/wo/confidential-containers/guest-components




all: \
    unsig \
    cosign-sig \
    simple-sig \
    enc-unsig \
    enc-cosign-sig \
    test-container-unencrypted \
    test-container-encrypted \
    busybox
# Not part of 'all' target for now:
#    busybox-gzip
#    busybox-zstd
#    busybox-enc-jwe



unsig:
	docker build \
      -t ghcr.io/$(COCO_PKG):unsig \
      -f dockerfiles/alpine-with-sshd/Dockerfile \
      .
	docker push ghcr.io/$(COCO_PKG):unsig


cosign-sig:
	docker build \
      -t ghcr.io/$(COCO_PKG):cosign-sig \
      -f dockerfiles/alpine-with-sshd/Dockerfile \
      .
	docker push ghcr.io/$(COCO_PKG):cosign-sig
	# FIXME Replace expect script with something better
	${CURDIR}/scripts/make-cosign-sig.exp $(COCO_PKG) cosign-sig



# FIXME Can we get `sudo` out of here?
# FIXME Use --sign-passphrase-file to automatically unlock the signing key
#       (and not have to enter the password manually)
# FIXME depends on importing the git@runner.com key:
#       gpg --batch --import github-runner.keys
simple-sig:
	skopeo \
      copy \
      --debug \
      --insecure-policy \
      --sign-by git@runner.com \
      --sign-passphrase-file $(shell pwd)/keys/sign/git-runner-password.txt \
      docker-daemon:ghcr.io/$(COCO_PKG):unsig \
      docker://ghcr.io/$(COCO_PKG):simple-sig
	# FIXME Find a nicer way to store the sha256 digest into a variable
	# FIXME commenting out the below because not needed for building images for CI
	#$(eval DIGEST=$(shell skopeo inspect docker://ghcr.io/$(COCO_PKG):simple-sig | jq -r .Digest | sed 's/:/=/'))
	#sudo mkdir -p $(ETC_SIGSTORE_PATH)/$(COCO_PKG)@$(DIGEST)
	#sudo cp \
    #  $(LOCAL_SIGSTORE_PATH)/$(COCO_PKG)@$(DIGEST)/signature-1 \
    #  $(ETC_SIGSTORE_PATH)/$(COCO_PKG)@$(DIGEST)


# FIXME This requires coco-keyprovider running from guest-components...
#       Not obvious how to fix this without proper dependency management and
#       what-have-you... this entire thing could be done inside of its OWN
#       container, i guess.
#       To be clear, before issuing this make target, have to do something like:
#         $ cd guest-components/attestation-agent/coco_keyprovider
#         $ RUST_LOG=coco_keyprovider cargo run --release -- --socket 127.0.0.1:50000
enc-unsig: unsig
	OCICRYPT_KEYPROVIDER_CONFIG="$(shell pwd)/configs/ocicrypt.conf" \
    skopeo copy \
      --insecure-policy \
      --encryption-key provider:attestation-agent:keypath=$(shell pwd)/keys/encrypt/key1::keyid=kbs:///default/key/key_id1::algorithm=A256GCM \
      docker-daemon:ghcr.io/$(COCO_PKG):unsig \
      docker://ghcr.io/$(COCO_PKG):enc-unsig

# FIXME see as enc-unsig about coco-keyprovider
# FIXME see cosign-sig about replacing expect script
enc-cosign-sig: cosign-sig
	OCICRYPT_KEYPROVIDER_CONFIG="$(shell pwd)/configs/ocicrypt.conf" \
    skopeo copy \
      --insecure-policy \
      --encryption-key provider:attestation-agent:keypath=$(shell pwd)/keys/encrypt/key1::keyid=kbs:///default/key/key_id1::algorithm=A256GCM \
      docker-daemon:ghcr.io/$(COCO_PKG):cosign-sig \
      docker://ghcr.io/$(COCO_PKG):enc-cosign-sig
	./scripts/make-cosign-sig.exp $(COCO_PKG) enc-cosign-sig


test-container-unencrypted:
	docker build \
      -t ghcr.io/portersrc/test-container:unencrypted \
      -f dockerfiles/alpine-with-sshd/Dockerfile \
      .
	docker push ghcr.io/portersrc/test-container:unencrypted


# FIXME see as enc-unsig about coco-keyprovider
test-container-encrypted: test-container-unencrypted
	OCICRYPT_KEYPROVIDER_CONFIG="$(shell pwd)/configs/ocicrypt.conf" \
    skopeo copy \
      --insecure-policy \
      --encryption-key provider:attestation-agent:keypath=$(shell pwd)/keys/encrypt/key1::keyid=kbs:///default/key/key_id1::algorithm=A256GCM \
      docker-daemon:ghcr.io/$(COCO_PKG):unencrypted \
      docker://ghcr.io/$(COCO_PKG):encrypted


busybox:
	docker build -t ghcr.io/$(COCO_IMGRS_PKG):busybox dockerfiles/busybox
	docker push ghcr.io/$(COCO_IMGRS_PKG):busybox


# FIXME Requires buildkitd to be running.
#       Not entirely sure where I got it from, but I have tarball of this:
#         buildkit-v0.12.1.linux-amd64.tar.gz
#       I run it like so:
#         $ sudo ./buildkitd
# FIXME Requires buildctl to be installed (or at least have some path, which
#       for now I specified with BUILDCTL_PATH).
busybox-gzip:
	sudo -E \
    $(BUILDCTL_PATH)/buildctl build \
      --frontend dockerfile.v0 \
      --output type=image,name=ghcr.io/$(COCO_IMGRS_PKG):busybox-gzip,push=true,compression=gzip,compression-level=8,force-compression=true,oci-mediatypes=true \
      --local dockerfile=$(shell pwd)/dockerfiles/busybox \
      --local context=$(shell pwd)/dockerfiles/busybox

# FIXME See busybox-gzip on buildkitd running
# FIXME See busybox-gzip on buildctl path
busybox-zstd:
	sudo -E \
    $(BUILDCTL_PATH)/buildctl build \
      --frontend dockerfile.v0 \
      --output type=image,name=ghcr.io/$(COCO_IMGRS_PKG):busybox-zstd,push=true,compression=zstd,compression-level=12,force-compression=true,oci-mediatypes=true \
      --local dockerfile=$(shell pwd)/dockerfiles/busybox \
      --local context=$(shell pwd)/dockerfiles/busybox


# FIXME requires public_key_for_tests.pem (see generate_test_data.md)
busybox-enc-jwe: busybox
	skopeo copy \
      --dest-compress-format gzip \
      --encryption-key jwe:$(GUEST_COMPONENTS_PATH)/image-rs/test_data/public_key_for_tests.pem \
      docker://ghcr.io/$(COCO_IMGRS_PKG):busybox \
      docker://ghcr.io/$(COCO_IMGRS_PKG):busybox-encrypted-jwe

hack:
	@echo "hacking on the makefile"
