#!/usr/bin/env bash
set -ex

./llvm.sh 17 all

# Clone the repository if it doesn't exist
git clone --branch=v${TENSORFLOW_ADDONS_VERSION} --depth=1 --recursive https://github.com/tensorflow/addons /opt/tensorflow_addons || \
git clone --depth=1 --recursive https://github.com/tensorflow/addons /opt/tensorflow_addons

cd /opt/tensorflow_addons 
pip3 install -r requirements.txt

export HERMETIC_PYTHON_VERSION="${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}"
export PYTHON_BIN_PATH="$(which python3)"
export PYTHON_LIB_PATH="$(python3 -c 'import site; print(site.getsitepackages()[0])')"
export TF_NEED_CUDA=1
export TF_CUDA_CLANG=1
export CLANG_CUDA_COMPILER_PATH="/usr/lib/llvm-17/bin/clang"
export HERMETIC_CUDA_VERSION=12.6.1
export HERMETIC_CUDNN_VERSION=9.4.0
export HERMETIC_CUDA_COMPUTE_CAPABILITIES=8.7

bazel build build_pip_pkg
bazel-bin/build_pip_pkg /opt/tensorflow_addons/wheels

pip3 install /opt/tensorflow_addons/wheels/tensorflow_addons*.whl

cd /opt/tensorflow_addons
pip3 install 'numpy<2'

# Optionally upload to a repository using Twine
twine upload --verbose /opt/tensorflow_addons/wheels/tensorflow-addons*.whl || echo "Failed to upload wheel to ${TWINE_REPOSITORY_URL}"
