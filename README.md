# GitHub Actions + Docker + Nginx Demo

一个学习 GitHub Actions 的练习项目，演示如何在提交代码到 main 分支时自动构建 Docker 镜像并推送到 GitHub Packages。

start test

## 项目结构

```
.
├── .github/workflows/
│   └── docker-publish.yml  # GitHub Actions 工作流
├── public/
│   └── index.html          # 前端页面
├── Dockerfile              # Docker 构建文件
├── nginx.conf              # Nginx 配置
└── README.md
```

## 工作原理

1. 当代码推送到 `main` 分支时，GitHub Actions 自动触发
2. 工作流登录到 GitHub Container Registry (ghcr.io)
3. 构建 Docker 镜像（基于 nginx:alpine）
4. 推送镜像到 GitHub Packages

## 本地测试

```bash
# 构建镜像
docker build -t hello-nginx .

# 运行容器
docker run -p 8080:80 hello-nginx

# 访问 http://localhost:8080
```

## 拉取已发布的镜像

```bash
docker pull ghcr.io/<owner>/<repo>:latest
docker run -p 8080:80 ghcr.io/<owner>/<repo>:latest
```

将 `<owner>/<repo>` 替换为实际的 GitHub 用户名和仓库名。

## 配置要求

仓库需要启用以下权限（默认已启用）：
- **Actions** - 读写权限
- **Packages** - 读写权限

## 服务器部署配置

工作流会自动将镜像部署到服务器 `40.81.208.36`，部署目录为 `/home/zero/learn`。

### 配置 SSH 秘钥

1. **在本地生成 SSH 密钥对**（如果没有的话）：
   ```bash
   ssh-keygen -t ed25519 -C "github-actions-deploy"
   ```
   按提示操作，建议不设置密码以便自动化部署。

2. **将公钥添加到服务器**：
   ```bash
   # 复制公钥内容
   cat ~/.ssh/id_ed25519.pub

   # 登录服务器，将公钥添加到 authorized_keys
   ssh zero@40.81.208.36
   echo "公钥内容" >> ~/.ssh/authorized_keys
   ```

   或使用 ssh-copy-id：
   ```bash
   ssh-copy-id -i ~/.ssh/id_ed25519.pub zero@40.81.208.36
   ```

3. **将私钥添加到 GitHub Secrets**：
   - 进入 GitHub 仓库 → Settings → Secrets and variables → Actions
   - 点击 "New repository secret"
   - Name: `SSH_PRIVATE_KEY`
   - Value: 粘贴私钥内容（包括 `-----BEGIN` 和 `-----END` 行）
   ```bash
   # 查看私钥内容
   cat ~/.ssh/id_ed25519
   ```

4. **确保服务器已安装 Docker**：
   ```bash
   # 在服务器上检查 Docker
   docker --version

   # 如未安装，参考 Docker 官方文档安装
   ```

### 部署流程

1. 推送代码到 `main` 分支
2. GitHub Actions 自动构建并推送 Docker 镜像
3. 通过 SSH 连接服务器，拉取最新镜像并重启容器
