#!/usr/bin/env sh
# 从 Open WebUI v0.1.116 源码构建 AWDP07 的可复现镜像。
set -eu

IMAGE=${1:?用法: build-open-webui-116.sh IMAGE_TAG}
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
SOURCE_REPOSITORY=${SOURCE_REPOSITORY:-https://github.com/T0ka1Teio/DVLAA}

# 该历史版本的 GHCR 标签已不可用；固定源码提交由 Git tag 保证。
git clone --branch v0.1.116 --depth 1 https://github.com/open-webui/open-webui.git "$WORK/open-webui"

# 历史依赖在当前 PyPI 中已经发生变化：保留应用源码版本，并使构建可复现。
python3 - "$WORK/open-webui" <<'PY'
from pathlib import Path
import sys
root = Path(sys.argv[1])
requirements = root / "backend" / "requirements.txt"
text = requirements.read_text()
text = text.replace(
    "litellm==1.30.7",
    "litellm @ git+https://github.com/BerriAI/litellm.git@v1.30.7",
)
requirements.write_text(text)

dockerfile = root / "Dockerfile"
text = dockerfile.read_text()
text = text.replace(
    "apt-get install ffmpeg libsm6 libxext6  -y",
    "apt-get install ffmpeg libsm6 libxext6 git -y",
)
dockerfile.write_text(text)

rag_main = root / "backend" / "apps" / "rag" / "main.py"
text = rag_main.read_text()
text = text.replace(
    "from langchain.text_splitter import RecursiveCharacterTextSplitter",
    "from langchain_text_splitters import RecursiveCharacterTextSplitter",
)
rag_main.write_text(text)
PY

BASE_IMAGE="${IMAGE}-base"
docker build --tag "$BASE_IMAGE" "$WORK/open-webui"
docker build \
  --build-arg "BASE_IMAGE=$BASE_IMAGE" \
  --build-arg "SOURCE_REPOSITORY=$SOURCE_REPOSITORY" \
  --tag "$IMAGE" \
  --file "$ROOT/Dockerfile.open-webui-labels" \
  "$ROOT"
docker image rm "$BASE_IMAGE" >/dev/null 2>&1 || true