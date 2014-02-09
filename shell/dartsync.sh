#!/bin/bash

# Add your locations to this array.
# Another example array would be:
#
# locations=("/vagrant/sample_apps/*:/home/vagrant/dartapps/", "/vagrant/myapp:/home/vagrant/dartapps/myapp")
#
locations=("/vagrant/sample_apps/*:/home/vagrant/dartapps/")


## DO NOT TOUCH BELOW UNLESS YOU KNOW WHAT YOU'RE DOING
#######################################################
for combination in "${locations[@]}" ; do
	origin=${combination%%:*}
	destination=${combination#*:}
	mkdir -p "$destination"
	sudo rsync -a --exclude=pubspec.lock --exclude=packages ${origin} ${destination}
done
#######################################################