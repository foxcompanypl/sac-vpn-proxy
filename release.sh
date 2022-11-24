#/bin/bash
USERNAME=liskeee
IMAGE=sac-vpn-proxy
#
branch=$(git symbolic-ref --short HEAD)
version=""
latestVersion="latest"
if [ "$branch" == "master" ]; then
    version=$(docker run --rm alpine/semver semver -c -i $1 $(cat VERSION))
    echo "Version: $version"
    echo "$version" >VERSION
    git commit -am "chore: release $version"
    git tag -a "$version" -m "version $version"
    git push origin master
    git push --tags
else
    version=$(git log -1 --pretty=format:%h)
    latestVersion="$branch"
fi
docker build -t $USERNAME/$IMAGE:$version --no-cache ./build
docker tag $USERNAME/$IMAGE:$version $USERNAME/$IMAGE:$latestVersion
docker push $USERNAME/$IMAGE:$version
docker push $USERNAME/$IMAGE:$latestVersion
