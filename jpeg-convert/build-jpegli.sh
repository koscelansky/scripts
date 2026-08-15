HASH=031a0077f5799a6041004267fc12b956c1f52a20

# install tools
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
    ca-certificates \
    wget \
    cmake

# install dependencies
apt-get update
apt-get install -y --no-install-recommends \
    ninja-build \
    clang \
    libhwy-dev \
    liblcms2-dev \
    zlib1g-dev \
    libpng-dev \
    libjpeg-dev \
    libgif-dev \
    libopenexr-dev

# sjpeg must is not in package manager, so we prepare it as third-party dependency
# the library seems in maintainance mode, so we can use this rather old hash
SJPEG_HASH=94e0df6d0f8b44228de5be0ff35efb9f946a13c9
wget https://github.com/webmproject/sjpeg/archive/$SJPEG_HASH.tar.gz -O sjpeg.tar.gz
tar -xzf sjpeg.tar.gz
mv sjpeg-$SJPEG_HASH sjpeg

# and with jpeg turbo, it seems like even when installed system wide, it will still
# expect it in third_party, so we will just put it there
JPEGTURBO_HASH=8ecba3647edb6dd940463fedf38ca33a8e2a73d1
wget https://github.com/libjpeg-turbo/libjpeg-turbo/archive/$JPEGTURBO_HASH.tar.gz -O libjpeg-turbo.tar.gz
tar -xzf libjpeg-turbo.tar.gz
mv libjpeg-turbo-$JPEGTURBO_HASH libjpeg-turbo

# get jpegli from selected HASH 
wget https://github.com/google/jpegli/archive/$HASH.tar.gz -O jpegli.tar.gz
tar -xzf jpegli.tar.gz
mv jpegli-$HASH jpegli
cd jpegli
# move dependencies to third_party, so that jpegli can find them
mv ../sjpeg ./third_party/
mv ../libjpeg-turbo ./third_party/

# and build it
TARGETS=all SKIP_TESTS=1 ./ci.sh release \
    -DJPEGLI_ENABLE_DOXYGEN=OFF \
    -DJPEGLI_ENABLE_BENCHMARK=OFF \
    -DBUILD_TESTING=OFF \
    -DJPEGLI_ENABLE_MANPAGES=OFF \
