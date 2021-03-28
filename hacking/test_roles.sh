#!/usr/bin/env bash

set -eu

cleanup() {
    ./hacking/cleanup.sh
}

trap cleanup err exit

./hacking/build.sh

# Molecule doesn't seem to pick up on the collection install in ansible_collections,
# even with ANSIBLE_COLLECTIONS_PATH set. As a workaround, install the collection
# into the user collection directory.
ansible-galaxy collection install maxhoesel-pterodactyl-*.tar.gz

ansible-lint -vv

for role in roles/*; do
    # Try to run test.sh if it exists, run molecule test if not
    (cd "$role" && (./molecule/test.sh || molecule test))
done
