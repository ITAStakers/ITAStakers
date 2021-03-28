#/bin/bash

# Automatic withdraw and delegatation script for Cosmos based Chains by ITAStakers
#
# If you have found it useful, your delegation, even a small one, would be appreciated =)
# Sentinel Validator address: sentvaloper1z2qgaj3flw2r2gdn7yq22623p7adykwg8fw93z
# Bitsong Validator address: bitsongvaloper1fkj2cn209yeexxyets98evrcmmds23hck0lyzq

while :
do

# Parameters
LCD_IP="127.0.0.1" #127.0.0.1 or public RPC IP

CLI="sentinelhubcli"
CHAIN_ID="sentinelhub-1"
TICKER="udvpn"

INTERVAL=600 #seconds

PASSWORD=""
KEY_NAME=""

VAL_ADDR="sentvaloper..."
VAL_NAME=""
OWNER_ADDR="sent1..."
SAVE_FOR_FEES="10000000" #minimum amount to safe on wallet to pay fees => 10

# Start
echo
echo "Withdrawing validator commissions and rewards ..."


echo $PASSWORD | $CLI tx distribution withdraw-rewards $VAL_ADDR --from $KEY_NAME --commission --gas-prices 0.1$TICKER --gas-adjustment 1.5 --gas auto --chain-id $CHAIN_ID --node "tcp://$LCD_IP:26657" --trust-node -y > /dev/null

sleep 10

echo "Getting account balance..."

BALANCE=`curl -s -X GET "http://$LCD_IP:1317/bank/balances/$OWNER_ADDR" -H  "accept: application/json" | jq -r .result[].amount` > /dev/null

echo "Account balance ${BALANCE}$TICKER"

if [[ $BALANCE -gt $SAVE_FOR_FEES ]]
then

	AMOUNT=`expr $BALANCE - $SAVE_FOR_FEES`

	echo "Delegating $AMOUNT$TICKER to $VAL_NAME of $BALANCE$TICKER ..."

	echo $PASSWORD | $CLI tx staking delegate $VAL_ADDR $AMOUNT$TICKER --from $KEY_NAME --gas-prices 0.1$TICKER --gas-adjustment 1.5 --gas auto --chain-id $CHAIN_ID --node tcp://$LCD_IP:26657 --trust-node -y > /dev/null

	sleep 3

	echo
	echo "$AMOUNT$TICKER delegated to $VAL_NAME"
	
else

	echo "Balance is under safe amount of ${SAVE_FOR_FEES}. I'll try on next round"
	
fi

echo
echo "Next round in ${INTERVAL} seconds"
sleep $INTERVAL
done
