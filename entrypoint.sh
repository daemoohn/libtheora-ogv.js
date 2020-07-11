#!/bin/bash

## getting the source code
git clone https://github.com/brion/theora.git

## set a random version tag
cd theora
version="no-tag"
cd ..

## verify if this specific version has already been uploaded to bintray
bintray_response=`curl -u$1:$2 https://api.bintray.com/packages/daemoohn/libtheora-ogv.js/libtheora-ogv.js/versions/$version`
if [[ $bintray_response != *"Version '$version' was not found"* ]]; then
  curl -X DELETE -u$1:$2 https://api.bintray.com/packages/daemoohn/libtheora-ogv.js/libtheora-ogv.js/versions/$version
fi

## getting ogg source code
git clone https://gitlab.xiph.org/xiph/ogg.git

## configureOgg.sh
cd ogg
if [ ! -f configure ]; then
  # generate configuration script
  sed -i.bak 's/$srcdir\/configure/#/' autogen.sh
  ./autogen.sh
fi
cd ..

## compileOggJs.sh
dir=`pwd`

# set up the build directory
mkdir -p build
cd build

mkdir -p js
cd js

mkdir -p root
mkdir -p libogg
cd libogg

# finally, run configuration script
emconfigure ../../../ogg/configure \
    --prefix="$dir/build/js/root" \
    --disable-shared \
|| exit 1

# compile libogg
emmake make -j4 || exit 1
emmake make install || exit 1

cd $dir

## configureTheora.sh
cd theora
if [ ! -f configure ]; then
  # generate configuration script
  # disable running configure automatically
  sed -i.bak 's/$srcdir\/configure/#/' autogen.sh
  ./autogen.sh
  
  # disable oggpack_writealign test
  sed -i.bak 's/$ac_cv_func_oggpack_writealign/yes/' configure
  
fi
cd ..

## compileTheoraJs.sh
dir=`pwd`

# set up the build directory
mkdir -p build
cd build

mkdir -p js
cd js

mkdir -p root
mkdir -p libtheora
cd libtheora
  
# finally, run configuration script
emconfigure ../../../theora/configure \
    --disable-oggtest \
    --prefix="$dir/build/js/root" \
    --with-ogg="$dir/build/js/root" \
    --disable-asm \
    --disable-examples \
    --disable-encode \
    --disable-shared \
|| exit 1

# compile libtheora
emmake make -j4 || exit 1
emmake make install || exit 1

cd $dir/build/js/root

## upload to bintray
zip -r $dir/libtheora-ogv.js.zip . 
curl -T $dir/libtheora-ogv.js.zip -u$1:$2 https://api.bintray.com/content/daemoohn/libtheora-ogv.js/libtheora-ogv.js/$version/libtheora-ogv.js.zip?publish=1
