#!/bin/bash

BASEDIR=$(dirname $(readlink -f "$0"))/..
BUILD_AREA=$BASEDIR/build-area

plugin_name=$1
pack_name=$1

# Colors
red='\e[0;31m'
green='\e[1;32m'
lightgreen='\e[0;32m'
blue='\e[1;34m'
yellow='\e[1;33m'
NC='\e[0m' # No Color

# first arg: name of the obs package
# second arg: path of the source files
function obs_push {
    # lib, plugin, pack
    package_type=$1
    # package name
    package=$2

    echo
    echo "============================================================="
    echo "             Prepare ${package}"
    echo "============================================================="


    # Checkout the package
    echo -e "${blue}Checkout OBS repo${NC}"
    cd ${BASEDIR}/obs.tmp
    rm -rf ${OBS_REPO}/${package_type}-${package}
    osc co ${OBS_REPO}/${package_type}-${package}

    # Check if the OBS orig
    echo -e "${blue}Decompress OBS ${archive_name} archive${NC}"
    rm -rf /tmp/${package}_OBS_ORIG
    mkdir -p /tmp/${package}_OBS_ORIG
    if [ -f ${BASEDIR}/obs.tmp/${OBS_REPO}/${package_type}-${package}/${package}*.orig.tar.gz ]; then
        tar -xf ${BASEDIR}/obs.tmp/${OBS_REPO}/${package_type}-${package}/${package}*.orig.tar.gz -C /tmp/${package}_OBS_ORIG --force-local
    else
        empty=1
    fi

    if [ -f ${BASEDIR}/obs.tmp/${OBS_REPO}/${package_type}-${package}/${package}*.debian.tar.gz ]; then
        tar -xf ${BASEDIR}/obs.tmp/${OBS_REPO}/${package_type}-${package}/${package}*.debian.tar.gz -C /tmp/${package}_OBS_ORIG/${package} --force-local
    else
        empty=1
    fi

    if [ $empty -ne 1 ];then
        # Get differences from obs and local dir
        echo -e "${blue}Compare ${archive_name} archives${NC}"
        diff -r ${BUILD_AREA}/${package_type}s/${package}/ /tmp/${package}_OBS_ORIG/${package}/ --exclude=.git*
    fi

    #Only update the source has changed
    if [ $? -ne 0 ] || [ $empty -eq 1 ]; then
        echo -e "${yellow}Source has changed, uploading to obs...${NC}"

        # Remove the old files
        rm ${BASEDIR}/obs.tmp/${OBS_REPO}/${package_type}-${package}/*

        prefix=monitoring-${package_type}s-sfl
        # Copy the new files
        cp ${BUILD_AREA}/${package_type}s/${prefix}-${package}*.tar.gz ${BASEDIR}/obs.tmp/${OBS_REPO}/${package_type}-${package}/
        cp ${BUILD_AREA}/${package_type}s/${prefix}-${package}*.dsc ${BASEDIR}/obs.tmp/${OBS_REPO}/${package_type}-${package}/
        cp ${BUILD_AREA}/${package_type}s/${prefix}-${package}*.changes ${BASEDIR}/obs.tmp/${OBS_REPO}/${package_type}-${package}/
        cp ${BUILD_AREA}/${package_type}s/${prefix}-${package}*.debian.tar.gz ${BASEDIR}/obs.tmp/${OBS_REPO}/${package_type}-${package}/

        # Add the changes and commit
        echo -e "${blue}SENDING to OBS${NC}"
        osc addremove ${BASEDIR}/obs.tmp/${OBS_REPO}/${package_type}-${package}/*
        osc commit ${BASEDIR}/obs.tmp/${OBS_REPO}/${package_type}-${package} -m "Updated ${package}"
        if [[ $? -eq 0 ]]
        then
            echo -e "${green}sent to OBS${NC}"
        else
            echo -e "${red}ERROR: NOT sent to OBS${NC}"
        fi
    else
        echo -e "${lightgreen}Sources inchanged. Skipping OBS upload...${NC}"
    fi
}


# This is the sfl-shinken-plugins directory
DIR=$(pwd)

# Open Build Service repository
OBS_REPO=home:sfl-monitoring:monitoring-tools

mkdir -p ${BASEDIR}/obs.tmp && cd ${BASEDIR}/obs.tmp

# plugins
if [ "$plugin_name" != "" ]
then
    # prefix
    prefix=monitoring-plugins-sfl
    if [ -d ${BUILD_AREA}/plugins/${prefix}-${plugin_name} ]
    then
        obs_push plugin $plugin_name
    else
        echo -e "\n${red}${plugin_name} is NOT built${NC}"
    fi

else
    for plugin in `(cd ${BASEDIR}/plugins && ls -d */ | tr -d '/')`
    do
        obs_push plugin $plugin
    done
fi

# packs
if [ "$pack_name" != "" ]
then
    # prefix
    prefix=monitoring-packs-sfl
    if [ -d ${BUILD_AREA}/packs/${prefix}-$pack_name ]
    then
        obs_push pack $pack_name
    else
        echo -e "\n${red}${pack_name} is NOT built${NC}"
    fi

else
    for pack in `(cd ${BASEDIR}/packs && ls -d */ | tr -d '/')`
    do
        obs_push pack $pack
    done
fi
