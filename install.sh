#!/bin/sh

echo "+ Uninstalling Gem:"
gem uninstall plugg

echo "+ Building Gemspec"
rake build --trace

echo "+ Installing Gem"
rake install --trace
