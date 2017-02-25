#!/usr/bin/env bash

# mkdir for dist
mkdir dist

# fetch tensorboard
git clone https://github.com/dmlc/tensorboard.git
# replace setup.py
cp setup.py tensorboard/python/
cd tensorboard

# make protobufs for logging part first
make all

# get tensorflow
git clone https://github.com/tensorflow/tensorflow
cd tensorflow
# chekcout a specific tag, currently we use v1.0.0-rc1
git checkout -b v1.0.0-rc1 v1.0.0-rc1

# run configuration.
bash configure < ../../tools/travis_wheel/configure.conf
# hack bazel compile time
git apply ../../tools/travis_wheel/bazel-hacking.patch
# build tensorboard
bazel build tensorflow/tensorboard:tensorboard

# prepare pip installation package
cp -r ../../tools/* bazel-bin/tensorflow/tools/
# get .whl file in python/dist/
bash bazel-bin/tensorflow/tools/pip_package/build_pip_package.sh ../python/dist/

# install tensorboard package from .whl file
set -eo pipefail

cd ..
cp -r python/dist/*.whl ../dist/
pip install python/dist/*.whl

# clean up
#rm -rf tensorflow/

