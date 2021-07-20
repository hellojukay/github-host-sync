# github-host-sync
同步 github hosts  https://github.com/521xueweihan/GitHub520

# build && install
```
dune build --release

cp _build/default/github_host_sync.exe /usr/local/bin/
cp github_host_sync.service /usr/lib/systemd/system
systemctl enable github_host_sync.service
systemctl start github_host_sync.service
```