#!/bin/bash

cd hdp-cairo && make setup VENV_PATH=../venv && cd ..
source venv/bin/activate && cd hdp-cairo && make build && cd ..