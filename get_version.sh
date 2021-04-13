#!/bin/bash
#
# Description: This is a helper script which returns a version used
# in generating a unique artifact name.
#

get_version () {
  local base=$1
  local branch=$2

  if [[ $branch == snapshot/* ]]; then
    version=$(echo "$branch" | cut -d '/' -f 2)
  elif [[ $branch == release-* ]]; then
    version=$(echo "$branch" | cut -d- -f 2)
  else
    version=${base}-$(echo $branch | sed 's/[/\]/\-/g')
  fi

  echo $version
}

base=""
if [ "$#" -ne 1 ]; then
  echo "$0 expects one argument."
  echo "Syntax: $0 <base>"
  exit 1
fi
base=$1

branch=""
if [ ! -z ${BUILDKITE_BRANCH+x} ]; then
  branch=${BUILDKITE_BRANCH}
else
  echo "Variable \$BUILDKITE_BRANCH not defined."
  exit 2
fi

version="$(get_version $base $branch)"

if [ ! -z ${GERRIT_CHANGE_NUMBER+x} ]; then
  version=${version}-change.${GERRIT_CHANGE_NUMBER}

  if [ ! -z ${GERRIT_PATCHSET_NUMBER+x} ]; then
    version=${version}.${GERRIT_PATCHSET_NUMBER}
  fi
fi

if [ ! -z ${BUILDKITE_BUILD_NUMBER+x} ]; then
  version=${version}.${BUILDKITE_BUILD_NUMBER}
else
  echo "Variable \$BUILDKITE_BUILD_NUMBER not defined."
  exit 3
fi

echo $version
