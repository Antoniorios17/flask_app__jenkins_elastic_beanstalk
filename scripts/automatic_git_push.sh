#!/bin/bash

# The script will automatically push to the repository when executed
# it will include the date as part of the commit message
git add .
git commit -m "updated script - $(date +'%d-%m-%Y')"
git push origin main