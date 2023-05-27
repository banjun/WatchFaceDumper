#!/bin/sh
set -ex

if [[ $CI_WORKFLOW = 'podspec on PR' || $CI_WORKFLOW = 'podspec on main' ]];
then
  cd ..
  bundle exec pod lib lint --private
fi
