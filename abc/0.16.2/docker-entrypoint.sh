#!/bin/bash
set -e

if [[ "$1" == "bitcoin-cli" || "$1" == "bitcoin-tx" || "$1" == "bitcoind" || "$1" == "test_bitcoin" ]]; then
	mkdir -p "$BITCOIN_DATA"

	cat <<-EOF > "$BITCOIN_DATA/bitcoin.conf"
		server=1
		rest=1
		txindex=1
		reindex=1
		printtoconsole=1
		rpcallowip=::/0
		rpcpassword=${BITCOIN_RPC_PASSWORD:-password}
		rpcuser=${BITCOIN_RPC_USER:-bitcoin}
		zmqpubhashblock=tcp://0.0.0.0:28332
		zmqpubhashtx=tcp://0.0.0.0:28332
		zmqpubrawblock=tcp://0.0.0.0:28332
		zmqpubrawtx=tcp://0.0.0.0:28332
		EOF
	chown bitcoin:bitcoin "$BITCOIN_DATA/bitcoin.conf"

	# ensure correct ownership and linking of data directory
	# we do not update group ownership here, in case users want to mount
	# a host directory and still retain access to it
	chown -R bitcoin "$BITCOIN_DATA"
	ln -sfn "$BITCOIN_DATA" /home/bitcoin/.bitcoin
	chown -h bitcoin:bitcoin /home/bitcoin/.bitcoin

	exec gosu bitcoin "$@"
fi

exec "$@"
