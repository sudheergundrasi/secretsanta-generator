#!/bin/bash
echo "Stopping existing app if running"
pkill -f secretsanta-0.0.1-SNAPSHOT.jar || true
