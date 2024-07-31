#!/opt/homebrew/bin/zsh
# vim:sw=4:ts=4:et

echo "-----------------------------------------------------------------------------------------------"
echo "Hihi starts releasing"
echo "-----------------------------------------------------------------------------------------------"
echo "\n"
date
pwd

export AWS_DEFAULT_PROFILE=mm

if docker buildx ls | grep -q buildnginxphpfpm; then
    echo 'found'
    docker buildx rm buildnginxphpfpm
    echo 'buildnginxphpfpm removed'
else
    echo 'not found'
fi

export BUILD_CMD=build
# export BUILD_CMD=release
# export BUILD_CMD=releaseDockerHub

set -e



export VERSION_OS=bookworm
export VERSION_NGINX=1.27.0
export VERSION_PHP=8.3.9
export IS_LATEST=true
make $BUILD_CMD
