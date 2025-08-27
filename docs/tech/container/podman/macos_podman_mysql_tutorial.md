# macOS 使用 Podman 运行 MySQL 容器（通用教程）

本文档提供在 macOS 上安装 Podman 并运行 MySQL 容器的通用流程，支持数据持久化、配置文件挂载以及容器升级。

---

## 1. 安装 Podman

### 1.1 使用 Homebrew 安装
```bash
brew install podman
```

### 1.2 初始化 Podman Machine
```bash
podman machine init
podman machine start
```

> Podman 在 macOS 上使用虚拟机运行容器。

---

## 2. 拉取 MySQL 镜像

使用 DaoCloud 镜像加速：
```bash
podman pull docker.m.daocloud.io/library/mysql:latest
```

> 或者指定版本：
```bash
podman pull docker.m.daocloud.io/library/mysql:<version>
```

---

## 3. 给镜像打本地 tag（可选）

为了方便使用本地镜像：
```bash
podman tag docker.m.daocloud.io/library/mysql:latest mysql:latest
```

之后可以直接用 `mysql:latest` 来创建容器。

---

## 4. 创建数据目录

在宿主机上创建用于挂载的 MySQL 数据目录：
```bash
mkdir -p <YOUR_DATA_DIR>
```

> `<YOUR_DATA_DIR>` 可替换为你希望存储 MySQL 数据的路径。

---

## 5. 创建 MySQL 配置文件（可选）

`<YOUR_CONF_DIR>/my.cnf` 示例：
```ini
[mysqld]
# 字符集设置
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
init_connect='SET NAMES utf8mb4'

# 表名大小写不敏感
lower_case_table_names = 1

# SQL 模式
sql_mode = STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION
```

> `<YOUR_CONF_DIR>` 为存放配置文件的路径。
> 不必指定 datadir、socket、pid-file 路径，使用容器默认即可。

---

## 6. 运行 MySQL 容器

```bash
podman run -d \
  --name <CONTAINER_NAME> \
  -e MYSQL_ROOT_PASSWORD=<ROOT_PASSWORD> \
  -e MYSQL_DATABASE=<DATABASE_NAME> \
  -e MYSQL_USER=<USER_NAME> \
  -e MYSQL_PASSWORD=<USER_PASSWORD> \
  -v <YOUR_DATA_DIR>:/var/lib/mysql:Z \
  -v <YOUR_CONF_DIR>/my.cnf:/etc/mysql/conf.d/my.cnf:Z \
  -p <HOST_PORT>:3306 \
  mysql:latest
```

**参数说明**：
- `<CONTAINER_NAME>`：容器名称  
- `<ROOT_PASSWORD>`：root 用户密码  
- `<DATABASE_NAME>`：创建的默认数据库  
- `<USER_NAME>` / `<USER_PASSWORD>`：普通用户和密码  
- `<HOST_PORT>`：宿主机端口映射  

---

## 7. 连接 MySQL

### 7.1 使用命令行
```bash
podman exec -it <CONTAINER_NAME> mysql -u <USER_NAME> -p
```

### 7.2 使用客户端（如 DBeaver）
- Host：`localhost`
- Port：`<HOST_PORT>`
- User：`<USER_NAME>`
- Password：`<USER_PASSWORD>`

---

## 8. 升级容器镜像

1. 拉取新镜像：
```bash
podman pull docker.m.daocloud.io/library/mysql:latest
```

2. （可选）打 tag：
```bash
podman tag docker.m.daocloud.io/library/mysql:latest mysql:latest
```

3. 停止旧容器：
```bash
podman stop <CONTAINER_NAME>
```

4. 删除旧容器：
```bash
podman rm <CONTAINER_NAME>
```

5. 用新镜像重新创建容器（保留数据卷）：
```bash
podman run -d \
  --name <CONTAINER_NAME> \
  -e MYSQL_ROOT_PASSWORD=<ROOT_PASSWORD> \
  -e MYSQL_DATABASE=<DATABASE_NAME> \
  -e MYSQL_USER=<USER_NAME> \
  -e MYSQL_PASSWORD=<USER_PASSWORD> \
  -v <YOUR_DATA_DIR>:/var/lib/mysql:Z \
  -v <YOUR_CONF_DIR>/my.cnf:/etc/mysql/conf.d/my.cnf:Z \
  -p <HOST_PORT>:3306 \
  mysql:latest
```

> 升级前确保数据已备份，并确认版本兼容性。

---

## 9. 查看容器和 MySQL 版本

```bash
podman ps
podman exec -it <CONTAINER_NAME> mysql -V
```

---

## 10. 停止和删除容器

停止：
```bash
podman stop <CONTAINER_NAME>
```

删除：
```bash
podman rm <CONTAINER_NAME>
```

---

## 11. 总结

- Podman 在 macOS 上通过虚拟机运行容器  
- 数据目录挂载保证数据持久化  
- 配置文件可以简化，只保留字符集、表名大小写和 SQL 模式  
- 升级镜像需要停止并重新创建容器  
- 给镜像打 tag 可以简化命令，不用每次写完整仓库地址  

