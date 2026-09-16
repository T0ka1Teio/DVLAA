# DVLAA AWDP07 Open WebUI 镜像

此仓库仅用于构建并发布 AWDP07 所需的 Open WebUI v0.1.116 GHCR 镜像。

镜像：ghcr.io/t0ka1teio/dvlaa-open-webui:v0.1.116


## DVLAA AWDP07 修复说明

本镜像用于修复 [DVLAA（Damn Vulnerable LLM and Agent Application）](https://github.com/Tcotl/DVLAA) 在启动 AWDP07 真实环境时无法拉取历史 Open WebUI 镜像的问题。

DVLAA 原始配置位于 `integrations/upstream/docker-compose.yaml`，其中的历史引用：

```yaml
image: ghcr.io/open-webui/open-webui:v0.1.116
```

对应的 GitHub Release 源码仍存在，但 GHCR 已不再提供该历史镜像标签。此仓库从 Open WebUI `v0.1.116` 源码构建并公开发布可拉取镜像，保持 AWDP07 需要的历史版本。

### 在 DVLAA 中替换镜像

1. 打开 DVLAA 项目中的 `integrations/upstream/docker-compose.yaml`。
2. 找到 `open-webui:` 服务下的镜像配置。
3. 将原始镜像行替换为：

```yaml
image: ghcr.io/t0ka1teio/dvlaa-open-webui:v0.1.116
```

替换后的服务片段如下：

```yaml
open-webui:
  image: ghcr.io/t0ka1teio/dvlaa-open-webui:v0.1.116
  restart: unless-stopped
  networks:
    - default
    - dvlaa-net
```

### 拉取并启动 AWDP07

在 DVLAA 项目根目录执行：

```bash
cd integrations/upstream
docker compose pull open-webui
docker compose up -d open-webui
docker compose ps open-webui
```

确认服务状态为 `Up` 后，回到 DVLAA 根目录继续安装或启动：

```bash
cd ../..
sh install.sh
```

也可以先验证镜像是否可用：

```bash
docker pull ghcr.io/t0ka1teio/dvlaa-open-webui:v0.1.116
```

该镜像只替代 AWDP07 的 Open WebUI 历史镜像；DVLAA 的其他上游服务仍按原有 Compose 配置启动。