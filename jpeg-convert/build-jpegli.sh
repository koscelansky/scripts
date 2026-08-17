HASH=031a0077f5799a6041004267fc12b956c1f52a20

# download jpeg turbo, it seems like even when installed system wide, it will still
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
mv ../libjpeg-turbo ./third_party/

# and build it
TARGETS=tools/cjpegli SKIP_TESTS=1 ./ci.sh release \
    -DJPEGLI_ENABLE_FUZZERS=OFF \
    -DJPEGLI_ENABLE_DOXYGEN=OFF \
    -DJPEGLI_ENABLE_BENCHMARK=OFF \
    -DBUILD_TESTING=OFF \
    -DJPEGLI_ENABLE_MANPAGES=OFF \
    -DJPEGLI_ENABLE_OPENEXR=OFF \
    -DJPEGLI_ENABLE_SJPEG=OFF
