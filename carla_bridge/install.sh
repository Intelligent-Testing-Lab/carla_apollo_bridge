#!/bin/bash

# Copy map files to /apollo/modules/map/data
cp -r map/. /apollo/modules/map/data

# run script to generate sim and routing maps for all carla_town instances

# Install requirements
pip3 install -r requirements.txt

# Set environment variables
# need to update to Apollo 10 paths 
if [ -f ~/.bashrc ] && ! grep -q 'export PYTHONPATH=$PYTHONPATH:/opt/apollo/neo/python/cyber' ~/.bashrc; then
    echo 'export PYTHONPATH=$PYTHONPATH:/opt/apollo/neo/python/cyber' >> ~/.bashrc
    echo 'export PYTHONPATH=$PYTHONPATH:/opt/apollo/neo/python/cyber/python' >> ~/.bashrc
    echo 'export PYTHONPATH=$PYTHONPATH:/opt/apollo' >> ~/.bashrc
    echo 'export PYTHONPATH=$PYTHONPATH:/opt/apollo/modules' >> ~/.bashrc
    echo 'export PYTHONPATH=$PYTHONPATH:/apollo_workspace/bazel-bin' >> ~/.bashrc
fi
source ~/.bashrc