#/bin/bash
REPO=$(git config --get remote.origin.url | grep -Po "(?<=git@github\.com:)(.*?)(?=.git)")
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
docker build -t $REPO:$version --no-cache ./build
docker tag $REPO:$version $REPO:$latestVersion
docker push $REPO:$version
docker push $REPO:$latestVersion
