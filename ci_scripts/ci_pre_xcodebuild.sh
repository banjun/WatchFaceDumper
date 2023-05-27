#!/bin/sh

if [[ $CI_WORKFLOW = 'podspec on PR' || $CI_WORKFLOW = 'podspec on main' ]];
then
  bundle exec pod lib lint --private
fi
