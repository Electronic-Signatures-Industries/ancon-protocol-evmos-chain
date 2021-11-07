
KEY="mykey"
CHAINID="evmos_9000-1"
MONIKER="localtestnet"
KEYRING="test"
KEYALGO="eth_secp256k1"
LOGLEVEL="info"
# to trace evm
#TRACE="--trace"
TRACE=""
MNEMONICA="lend lock kit kiss walnut flower expect text upset nut arrive hub waste stairs climb neither must crowd harvest network wife lizard shiver obtain"
# validate dependencies are installed
command -v jq > /dev/null 2>&1 || { echo >&2 "jq not installed. More info: https://stedolan.github.io/jq/download/"; exit 1; }

# remove existing daemon
rm -rf ~/.evmosd*

make install

evmosd config keyring-backend $KEYRING
evmosd config chain-id $CHAINID

# if $KEY exists it should be deleted
(echo $MNEMONICA) | evmosd keys  add $KEY --keyring-backend $KEYRING --algo $KEYALGO --recover  

# Set moniker and chain-id for Evmos (Moniker can be anything, chain-id must be an integer)
evmosd init $MONIKER --chain-id $CHAINID 


if [[ $1 == "pending" ]]; then
  echo "pending mode is on, please wait for the first block committed."
fi

cp app.toml $HOME/.evmosd/config/app.toml

cp config.toml $HOME/.evmosd/config/config.toml

cp gen.json $HOME/.evmosd/config/genesis.json

# Start the node (remove the --pruning=nothing flag if historical queries are not needed)
evmosd start --pruning=nothing $TRACE --log_level $LOGLEVEL --minimum-gas-prices=0.0001aphoton --rpc.unsafe=true  --json-rpc.api  eth,txpool,personal,net,debug,web3,miner
