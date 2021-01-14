#!/bin/sh

while :
do
	cp ~/Library/Safari/LastSession.plist ~/Library/Containers/[your-bundle-identifier]/Data/Documents/LastSession.plist
	sleep 30
done
