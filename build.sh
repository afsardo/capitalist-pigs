#!/bin/bash

forc build -p contracts/src/bacon
forc build -p contracts/src/bacon --output-directory contracts/out/debug
forc build -p contracts/src/bacon_distributor
forc build -p contracts/src/bacon_distributor --output-directory contracts/out/debug
forc build -p contracts/src/pigs
forc build -p contracts/src/pigs --output-directory contracts/out/debug
forc build -p contracts/src/piglets
forc build -p contracts/src/piglets --output-directory contracts/out/debug
forc build -p contracts/src/staking
forc build -p contracts/src/staking --output-directory contracts/out/debug
forc build -p contracts/src/truffles
forc build -p contracts/src/truffles --output-directory contracts/out/debug
forc build -p contracts/src/truffles_pool
forc build -p contracts/src/truffles_pool --output-directory contracts/out/debug

forc build -p contracts/src/mock_contract
forc build -p contracts/src/mock_contract --output-directory contracts/out/debug
