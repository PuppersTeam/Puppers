#!/bin/bash

echo "Securing CI..."

# Generate a temporary GPG2 input file for automatically generating a key
cat >TEMP_GPG_INPUT <<EOF
    Key-Type: default
    Subkey-Type: default
    Name-Real: PT CI
    Name-Comment: PT OPS CI Base Key
    Name-Email: ci@puppers.team
    Expire-Date: 0
    %no-ask-passphrase
    %no-protection
    %transient-key
    %commit
EOF

# Actually generate the GPG2 key from the TEMP_GPG_INPUT file
gpg2 --batch --generate-key TEMP_GPG_INPUT

# Delete the TEMP_GPG_INPUT file
rm -rf TEMP_GPG_INPUT

echo "GPG2 Key generated..."

# Init the pass store with the generated GPGP2 key
pass init ci@puppers.team

# Create docker directory
mkdir ~/.docker

# Create docker config file
cat >config.json <<EOF
{
    "credsStore": "pass"
}
EOF

# Move config to docker directory
mv config.json ~/.docker/config.json

echo "Docker Config created..."

echo "Logging in..."

echo "$CI_JOB_TOKEN" | docker login \
  -u gitlab-ci-token \
  --password-stdin \
  registry.gitlab.com
