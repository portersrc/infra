#
# This makefile's targets rebuild various container images that can be used
# for development and testing in the CoCo project.
# They also are intended to serve as an up-to-date reference for creating
# new images.
#
# Note: The targets push to ghcr, which requires proper credentials and
# `docker login`.
#

.PHONY: unsig \
cosign-sig \
simple-sig \
enc-unsig \
enc-cosign-sig \
test-container-unencrypted \
test-container-encrypted \
busybox

SHELL=/bin/bash


# FIXME need to choose sane package URLs/names/tags
COCO_PKG=confidential-containers/test-container
COCO_PKG_IMGRS=confidential-cointainers/test-container-image-rs



all: \
	unsig \
	cosign-sig \
	simple-sig \
	enc-unsig \
	enc-cosign-sig \
	test-container-unencrypted \
	test-container-encrypted \
	busybox



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


# NOTE: This depends on a gpg key owned by git@runner.com.
# That is, before issuing this make target, have to do something like:
#   $ gpg --batch --import ./keys/sign/github-runner.keys
simple-sig:
	skopeo \
	  copy \
	  --debug \
	  --insecure-policy \
	  --sign-by git@runner.com \
	  --sign-passphrase-file $(shell pwd)/keys/sign/git-runner-password.txt \
	  docker-daemon:ghcr.io/$(COCO_PKG):unsig \
	  docker://ghcr.io/$(COCO_PKG):simple-sig


# NOTE: This requires coco-keyprovider running from guest-components...
# That is, before issuing this make target, have to do something like:
#   $ cd guest-components/attestation-agent/coco_keyprovider
#   $ RUST_LOG=coco_keyprovider cargo run --release -- --socket 127.0.0.1:50000
enc-unsig: unsig
	OCICRYPT_KEYPROVIDER_CONFIG="$(shell pwd)/configs/ocicrypt.conf" \
	skopeo copy \
	  --insecure-policy \
	  --encryption-key provider:attestation-agent:keypath=$(shell pwd)/keys/encrypt/key1::keyid=kbs:///default/key/key_id1::algorithm=A256GCM \
	  docker-daemon:ghcr.io/$(COCO_PKG):unsig \
	  docker://ghcr.io/$(COCO_PKG):enc-unsig


# NOTE: see enc-unsig about coco-keyprovider
# NOTE: see cosign-sig about replacing expect script
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
	  -t ghcr.io/$(COCO_PKG):unencrypted \
	  -f dockerfiles/alpine-with-sshd/Dockerfile \
	  .
	docker push ghcr.io/$(COCO_PKG):unencrypted


# NOTE: see enc-unsig about coco-keyprovider
test-container-encrypted: test-container-unencrypted
	OCICRYPT_KEYPROVIDER_CONFIG="$(shell pwd)/configs/ocicrypt.conf" \
	skopeo copy \
	  --insecure-policy \
	  --encryption-key provider:attestation-agent:keypath=$(shell pwd)/keys/encrypt/key1::keyid=kbs:///default/key/key_id1::algorithm=A256GCM \
	  docker-daemon:ghcr.io/$(COCO_PKG):unencrypted \
	  docker://ghcr.io/$(COCO_PKG):encrypted


busybox:
	docker build -t ghcr.io/$(COCO_PKG_IMGRS):busybox dockerfiles/busybox
	docker push ghcr.io/$(COCO_PKG_IMGRS):busybox
