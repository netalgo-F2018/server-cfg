#!/bin/bash

echo ===begin cfg_packages
bash cfg_packages.sh
echo ===end cfg_packages
echo -e "\n\n"

echo ===begin cfg_pdump_env
bash cfg_pdump_env.sh
echo ===end cfg_pdump_env
echo -e "\n\n"

echo ===begin cfg_workspace
bash cfg_workspace.sh
echo ===end cfg_workspace
echo -e "\n\n"
