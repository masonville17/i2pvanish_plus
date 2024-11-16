#!/bin/bash
# Add non-root user and switch to it
useradd -m i2puser
cd /home/i2puser && chown -R i2puser /home/i2puser