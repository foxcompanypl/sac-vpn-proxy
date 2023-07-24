#/bin/bash
REPO=$(git config --get remote.origin.url | grep -Po "(?<=git@github\.com:)(.*?)(?=.git)")
branch=$(git symbolic-ref --short HEAD)
version=""
latestVersion="latest"
version=$(docker run --rm alpine/semver semver -c -i $1 $(cat VERSION))
echo "Version: $version"
echo "$version" >VERSION
git commit -am "chore: release $version"
git tag -a "$version" -m "version $version"
git push origin $branch
git push --tags
