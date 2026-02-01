# GitHub Actions + Docker + Nginx Demo

一个学习 GitHub Actions 的练习项目，演示如何：
1. 在提交代码到 main 分支时自动构建 Docker 镜像并推送到 GitHub Packages
2. 自动将带有 `copilot` 标签的 Issue 分配给 GitHub Copilot coding agent

## 项目结构

```
.
├── .github/workflows/
│   ├── copilot-auto-assign.yml  # Copilot 自动分配工作流
│   └── docker-publish.yml       # Docker 构建和部署工作流
├── public/
│   └── index.html               # 前端页面
├── Dockerfile                   # Docker 构建文件
├── nginx.conf                   # Nginx 配置
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

## Copilot 自动分配功能

本项目配置了 GitHub Actions 工作流，可以自动将 Issue 分配给 GitHub Copilot coding agent。

### 使用方法

1. **创建或打开一个 Issue**
2. **添加标签 `copilot`** 到该 Issue
3. GitHub Actions 会自动触发，将该 Issue 分配给 Copilot coding agent
4. Copilot 会自动开始处理该 Issue

### 配置要求

- 需要在仓库设置中启用 GitHub Copilot coding agent
- 需要配置 Personal Access Token (PAT) 作为仓库 Secret：
  - 进入 GitHub 仓库 → Settings → Secrets and variables → Actions
  - 点击 "New repository secret"
  - Name: `COPILOT_PAT`
  - Value: 具有 `repo` 权限的 Personal Access Token

### 工作流程

1. 当 Issue 被添加 `copilot` 标签时，工作流自动触发
2. 通过 GraphQL API 获取 Copilot bot ID 和仓库信息
3. 使用 GraphQL mutation 将 Issue 分配给 Copilot coding agent
4. Copilot 自动创建分支并开始处理 Issue

## 服务器部署配置

工作流会自动将镜像部署到服务器 `40.81.208.36`，部署目录为 `/home/zero/learn`。

### 配置 SSH 秘钥

1. **在本地生成 SSH 密钥对**（如果没有的话）：
   ```bash
   ssh-keygen -t github_actions -C "github-actions-deploy"
   ```
   按提示操作，建议不设置密码以便自动化部署。
 
2. **将公钥添加到服务器**：
   ```bash
   # 复制公钥内容
   cat ~/.ssh/id_github_actions.pub

   # 登录服务器，将公钥添加到 authorized_keys
   ssh zero@40.81.208.36
   echo "公钥内容" >> ~/.ssh/authorized_keys
   ```

   或使用 ssh-copy-id：
   ```bash
   ssh-copy-id -i ~/.ssh/id_github_actions.pub zero@40.81.208.36
   ```

3. **将私钥添加到 GitHub Secrets**：
   - 进入 GitHub 仓库 → Settings → Secrets and variables → Actions
   - 点击 "New repository secret"
   - Name: `SSH_PRIVATE_KEY`
   - Value: 粘贴私钥内容（包括 `-----BEGIN` 和 `-----END` 行）
   ```bash
   # 查看私钥内容
   cat ~/.ssh/id_github_actions
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
