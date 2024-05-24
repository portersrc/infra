#!/bin/bash

# old:
#buildctl \
#  build \
#  --frontend dockerfile.v0 \
#  --output type=image,name=ghcr.io/portersrc/coco:busybox,push=true,compression=zstd,compression-level=12,force-compression=true,oci-mediatypes=true \
#  --local dockerfile=. \
#  --local context=.


#docker \
#  buildx \
#  build \
#  --frontend dockerfile.v0 \
#  --output type=image,name=ghcr.io/portersrc/coco:busybox,push=true,compression=zstd,compression-level=12,force-compression=true,oci-mediatypes=true \
#  --local dockerfile=. \
#  --local context=.

# doesn't do shit
#DOCKER_BUILDKIT=1 docker \
#  build \
#  --output type=image,name=ghcr.io/portersrc/coco:busybox,push=true,compression=zstd,compression-level=12,force-compression=true,oci-mediatypes=true \
#  .

# This one "works" (doesnt zstd but still creates gzip image and pushes)
#docker \
#  buildx \
#  build \
#  --output type=image,name=ghcr.io/portersrc/coco:busybox,push=true,compression=zstd,compression-level=12,force-compression=true,oci-mediatypes=true \
#  .


echo "2023.09.18 This last one was uncommented and i guess was the last thing I had tried or was using for this helper script (?i guess it was a helper script?). This came from containers/test-container-image-rs/ and was beside the Dockerfile there"
#/home/porter/wo/buildkit/bin/buildctl \
#  build \
#  --frontend dockerfile.v0 \
#  --output type=image,name=ghcr.io/portersrc/coco:busybox,push=true,compression=zstd,compression-level=12,force-compression=true,oci-mediatypes=true \
#  --local dockerfile=. \
#  --local context=.
