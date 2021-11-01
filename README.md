# c-lightning on Raspberry Pi

このリポジトリでは、Raspberry Pi上でTor + c-lightningの環境をセットアップするためのdocker-compose.ymlを提供しています。

## 事前準備

事前に以下の作業が必要です。

* Raspberry PiのOSのセットアップ（64 bit版を使用。[ここから](https://downloads.raspberrypi.org/raspios_arm64/images/) 入手可能です。）
* docker/docker-composeのインストール

## セットアップ

セットアップしたRaspberry Pi上で以下を実行します。

    $ git clone https://github.com/azuchi/c-lightning-on-raspberry-pi.git
    $ cd c-lightning-on-raspberry-pi.git
    $ cp cp .env.sample .env
    $ ./setup.sh

`cp`コマンドで、`.env`ファイルがコピーされるので、自分の環境に合わせて以下を設定します。

```
# Bitcoin
BITCOIN_NETWORK=bitcoin
BITCOIN_RPC_HOST=<Bitcoin Coreが動作しているマシンのIP>
BITCOIN_RPC_PORT=8332
BITCOIN_RPC_USER=<Bitcoin CoreのRPCユーザー>
BITCOIN_RPC_PASSWORD=<Bitcoin CoreのRPCパスワード>

# c-lightning
LIGHTNING_ALIAS=<LNノードのエイリアス>
LIGHTNING_RGB=＜LNノードのカラー（Hex値）＞
```

設定が完了したら、起動します。

    $ docker-compose up -d

以上で、セットアップは完了です。

### lightning-cliを利用

コンテナ上のc-lightningに対してCLIでコマンドを実行できるよう、`bin/lightning-cli`を用意しています。

    $ ./bin/lightning-cli getinfo

など各CLIコマンドを実行できます。

### Umbrelとの連携

ローカルで稼働しているUmbrel上のBitcoin Coreを使用する場合は、Umbrel側の以下の設定を変更する必要があります。

`/home/umbrel/umbrel/docker-compose.yml`の`bitcoin`のポート設定にRPCのポートを追加:

```yaml
bitcoin:
    container_name: bitcoin
    image: lncm/bitcoind:v22.0@sha256:37a1adb29b3abc9f972f0d981f45e41e5fca2e22816a023faa9fdc0084aa4507
    depends_on: [ tor, manager, nginx ]
    volumes:
        - ${PWD}/bitcoin:/data/.bitcoin
    restart: on-failure
    stop_grace_period: 15m30s
    ports:
        - "$BITCOIN_P2P_PORT:$BITCOIN_P2P_PORT"
        - "$BITCOIN_RPC_PORT:$BITCOIN_RPC_PORT" # ←この行を追加
    networks:
        default:
            ipv4_address: $BITCOIN_IP
```

`/home/umbrel/umbrel/bitcoin/bitcoin.conf`に`rpcallowip`の設定を追加:

```
rpcallowip=c-lightningが稼働するRaspberri PiのIPの範囲を指定（例：192.168.50.1/24など）
```

設定を変更したら、再起動して設定を反映させます。

**※ この設定は、Umbrelをバージョンアップするとリセットされるため、その際は再度設定が必要です。**