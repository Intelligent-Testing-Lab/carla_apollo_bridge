#!/bin/bash

# immediately exit on error 
set -eo pipefail

# set up some nicer logs
MESSAGE_C='\033[0m'
INFO_C='\033[0;32m'
ERROR_C='\033[0;31m'

INFO=1
ERROR=2

# define main log function
function log() {
    local log_level_int=$1
    local log_level_str=$2 # second func arg
    local message=${@:3} # pass in any arg after 3rd

    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    # assign log colour based on log level
    local log_c=$([[ $log_level_int -eq $ERROR ]] && $ERROR_C || $INFO)
    
    echo -e "[$timestamp] ${ERROR_C} [$log_level_str] ${MESSAGE_C} - $message"
}

function error(){
    log $ERROR "ERROR" $@
}

function info(){
    log $INFO "INFO" $@
}

# Copy map files to /apollo/modules/map/data
#cp -r map/. /apollo_workspace/modules/map/data

# get a list of maps
# for each map
# copy exact folder structure directly in /apollo_workspace/data/map_data/[map]
# for each file, create a symlink to /apollo_workspace/modules/map/data/[file]
APOLLO_MAP_MODULE_DIR="/apollo_workspace/modules/map/data"
APOLLO_MAP_DATA_DIR="/apollo_workspace/data/map_data"
CARLA_BRIDGE_ROOT_DIR="/carla_bridge"

for map in "$CARLA_BRIDGE_ROOT_DIR/map/"*; do
    
    base_map_name=$(basename "$map")

    apollo_map_module="$APOLLO_MAP_MODULE_DIR/$base_map_name"
    apollo_map_data="$APOLLO_MAP_DATA_DIR/$base_map_name"

    # check if /apollo_workspace/modules/map/data/$map exists -> create if not    
    if [ ! -d "$apollo_map_module" ]; then
        mkdir "$apollo_map_module"
        info "Created map module folder: $apollo_map_module"
    else    
        error "$apollo_map_module exists already, skipping..."
        continue
    fi

    # check if /apollo_workspace/data/map_data/$map exists -> create if not    
    if [ ! -d "$apollo_map_data" ]; then
        mkdir "$apollo_map_data"
        info "Created map data folder: $apollo_map_data"
     else    
        error "$apollo_map_data exists already, skipping..."
        continue
    fi

    # go through the map files
    for file in "$CARLA_BRIDGE_ROOT_DIR/map/$base_map_name/"*; do

        file_base_name=$(basename "$file")

        # check if its a regular file, skip if not
        if [ ! -f "$file"]; then
            error "$file is not a valid file and it will be skipped. $base_map_name may not function correctly in Apollo"
            continue
        fi

        # define the file location in the module folder
        apollo_map_file_loc="$APOLLO_MAP_MODULE_DIR/$base_map_name/$file_base_name"
        apollo_data_symlink_loc="$APOLLO_MAP_DATA_DIR/$base_map_name/$file_base_name"

        # if it doesn't exist, copy it over
        if [ ! -f "$apollo_map_file_loc" ]; then 
            cp "$file" "$apollo_map_module"
            info "Successfully copied file"
        else
            error "$apollo_map_file_loc already exists."  
        fi

        # verify a symlink doesn't exist
        if [ ! -L "$apollo_data_symlink_loc" ]; then
            ln -s "$apollo_map_file_loc" "$apollo_data_symlink_loc"
            info "Created symlink $apollo_map_file_loc >> $apollo_data_symlink_loc"
        else   
            echo "Symlink to $apollo_data_symlink_loc already exists."
        fi 
    done
done

echo "Installing Requirements..."
# Install requirements
pip3 install -r requirements.txt

echo "Adding Cyber RT and Apollo to PYTHONPATH environmental variable"
# Set environment variables
# need to update to Apollo 10 paths 
if [ -f ~/.bashrc ] && ! grep -q 'export PYTHONPATH=$PYTHONPATH:/opt/apollo/neo/python/cyber' ~/.bashrc; then
    echo 'export PYTHONPATH=$PYTHONPATH:/opt/apollo/neo/python/cyber' >> ~/.bashrc
    echo 'export PYTHONPATH=$PYTHONPATH:/opt/apollo/neo/python/cyber/python' >> ~/.bashrc
    echo 'export PYTHONPATH=$PYTHONPATH:/opt/apollo' >> ~/.bashrc
    echo 'export PYTHONPATH=$PYTHONPATH:/apollo_workspace/modules' >> ~/.bashrc
    echo 'export PYTHONPATH=$PYTHONPATH:/apollo_workspace/bazel-bin' >> ~/.bashrc
fi
source ~/.bashrc