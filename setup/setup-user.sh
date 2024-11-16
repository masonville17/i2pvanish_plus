#!/bin/bash
./.prefs
# Add non-root user and switch to it
useradd -m $I2P_USER
cd /home/$I2P_USER && chown -R $I2P_USER /home/$I2P_USER