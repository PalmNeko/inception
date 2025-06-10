
# inception

42 project

# VB構築

1. ubuntu 22.04 のインストール
1. `/etc/default/locale`を変更して、`LANG="en_US"`を`LANG="en_US.UTF-8"`にする。
1. (device -> insert guest additionsを選択する。)
1. `sudo apt install virtualbox-guest-utils`
1. ポート443をポートフォワーディングする。
1. `curl -fsSL https://get.docker.com -o get-docker.sh`
1. `sh ./get-docker.sh`
1. rootlessのインストールオプション設定
1. [特権ポートの公開](https://matsuand.github.io/docs.docker.jp.onthefly/engine/security/rootless/#exposing-privileged-ports)
```sh
sudo setcap cap_net_bind_service=ep $(which rootlesskit)
systemctl --user restart docker
```
