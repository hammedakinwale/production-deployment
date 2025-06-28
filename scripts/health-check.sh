#!/bin/bash
curl --fail http://localhost:$PORT/health || exit 1