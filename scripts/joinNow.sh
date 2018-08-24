#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

# This script is designed to be run in the org3cli container as the
# second step of the EYFN tutorial. It joins the org3 peers to the
# channel previously setup in the transfer tutorial and install the
# chaincode as version 2.0 on peer0.org3.
#

echo
echo "========= Getting Org3 on to your transfer network ========= "
echo
CHANNEL_NAME="$1"
DELAY="$2"
LANGUAGE="$3"
TIMEOUT="$4"
: ${CHANNEL_NAME:="test"}
: ${DELAY:="3"}
: ${LANGUAGE:="golang"}
: ${TIMEOUT:="10"}
LANGUAGE=`echo "$LANGUAGE" | tr [:upper:] [:lower:]`
COUNTER=1
MAX_RETRY=5
ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/transfer.com/orderers/orderer.transfer.com/msp/tlscacerts/tlsca.transfer.com-cert.pem

CC_SRC_PATH="github.com/chaincode/transfer"


# import utils
. scripts/utils.sh

echo "Fetching channel config block from orderer..."
set -x
peer channel fetch 0 $CHANNEL_NAME.block -o orderer.transfer.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA >&log.txt
res=$?
set +x
cat log.txt
verifyResult $res "Fetching config block from orderer has Failed"

echo "===================== Having peer0.org3 join the channel ===================== "
joinChannelWithRetry 0 3
echo "===================== peer0.org3 joined the channel \"$CHANNEL_NAME\" ===================== "
echo "Installing chaincode 2.0 on peer0.org3..."
installChaincode 0 3 2.0

echo
echo "========= Got Org3 halfway onto your transfer network ========= "
echo

exit 0
