#!/bin/bash

# Create the data directory
mkdir -p /app/data

# Create the symbolic link
ln -s ${SEMANTIC_KITTI_DIR} /app/data/semantic_kitti

# Then start your application (replace this line with how you start your application)
python3 your_application.py
