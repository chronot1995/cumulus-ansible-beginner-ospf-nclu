#!/bin/bash
git add .
sleep 2
git commit -m "$(date +%s)"
sleep 2
git push
