# github actions deploy能力

## 实现从发布代码到"测试/生产"环境的一键部署

1. 需要修改上次的yml文件增加deploy能力节点

> 关键部分:

```yml
name: 构建并推送 Docker 镜像   # 工作流名称

on:
  push:
    branches:
      - main                        # 只在 main 分支推送时触发

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}   # 镜像名 = github.repository，例如 ghcr.io/用户名/仓库名

  deploy:
    needs: build-and-push              # 等待镜像构建完成
    runs-on: ubuntu-latest

    steps:
      - name: 部署到服务器
        uses: appleboy/ssh-action@v1.0.3
        env:
          REGISTRY: ghcr.io
          IMAGE_NAME: ${{ github.repository }}
        with:
          host: 40.81.208.36
          username: zero
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          envs: REGISTRY,IMAGE_NAME
          script: |
            cd /home/zero/learn
            docker pull ${REGISTRY}/${IMAGE_NAME}:latest
            docker stop app || true
            docker rm app || true
            docker run -d --name app -p 2222:80 ${REGISTRY}/${IMAGE_NAME}:latest
```

2. 配置私钥与公钥,需要先在服务器中生成
3. 开始提交commit到远程仓库即可