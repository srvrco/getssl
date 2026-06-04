# How to do a release of getssl

## Update the version and tag the release

1. `git pull`
2. `git branch -c release_2_nn`
3. `git switch release_2_nn`
4. update VERSION in `getssl` and `getssl.spec`
5. update the changelog in `getssl`
6. update the rpm and deb packages in README.md
7. create the plain text version of README using `pandoc -t plain README.md > README`
8. `git commit -m"Update version to v2.nn"`
9. `git tag -a v2.nn -m"Release 2.nn"`
10. `git push origin release_2_nn`
11. `git push --tags`

## Create a PR to Merge the release_2_nn branch into main

1. `gh pr create --title "Release 2.nn"`
2. `gh pr merge nnn`

## Build the .deb and .rpm packages

1. Create the release and deb/rpm packages using the deploy github action `gh workflow run "Deploy getssl" --field tags=v2.nn`
2. Wait for the build process to finish `gh release view v2.nn`

## Change the status of the release from draft to pre-release

1. `gh release edit 2.nn --draft=false --prerelease`

## Test the .deb file using the following steps

1. Test that the package can be installed using a cloud instance
   1. Start an Ubuntu ec2 instance from AWS Console (or Azure or Google Cloud)
   2. Or use the instant-ec2.sh script from my Github gist to start an Ubuntu ec2 instance
      1. `git clone git@gist.github.com:12c297e0645920c413273c9d15edbc68.git instant-ec2`
      2. `./instant-ec2/instant-ec2.sh --start`
2. ssh into the host
3. download the deb package
   `wget https://github.com/srvrco/getssl/releases/download/v2.nn/getssl_2.nn-1_all.deb`
4. install the deb package
   `dpkg -i getssl_2.nn-1_all.deb`
5. Check it's installed correctly
   `getssl --version`

## Change the release from pre-release to latest

1. `gh release edit v2.nn --latest`

## Update the latest tag post-release

1. `git switch master`
2. `git pull`
3. `git tag -f -a latest -m "Update latest to v2.nn"`
4. `git push --force --tags`
