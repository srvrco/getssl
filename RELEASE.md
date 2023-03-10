# How to do a release of getssl

## Update the version and tag the release

1. git pull
2. git branch -c release_2_nn
3. git switch release_2_nn
4. update VERSION in `getssl` and `getssl.spec`
5. git commit -m"Update version to v2.nn"
6. git tag -a v2.nn
8. git push origin release_2_nn
9. git push --tags

## The github release-and-package action should:

1. Build the .deb and .rpm packages
2. create a draft release containing the packages and the release note

## Can test the .deb file using the following steps:

1. Change the status from draft to pre-release
2. Test that the package can be installed using a cloud instance
   1. Start an Ubuntu ec2 instance from AWS Console (or Azure or Google Cloud)
   2. Or use the instant-ec2.sh script from my Github gist to start an Ubuntu ec2 instance
      1. git clone git@gist.github.com:12c297e0645920c413273c9d15edbc68.git instant-ec2
      2. ./instant-ec2/instant-ec2.sh
3. download the deb package
   `wget https://github.com/srvrco/getssl/releases/download/v2.nn/getssl_2.nn-1_all.deb`
4. install the deb package
   `dpkg -i getssl_2.nn-1_all.deb`
5. Check it's installed correctly
   `getssl --version`

## Update the latest tag post-release

1. git tag -f -a latest
2. git push --force --tags
