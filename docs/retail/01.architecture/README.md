# 架构设计文档

## 概述

本目录包含零售系统的架构设计和实现细节，与 `specs/` 目录的业务规格描述相对应。

## 目录结构原则

### specs/ 目录
- **业务模型和规格**：回答"是什么"
- **目标读者**：产品经理、业务分析师、架构师
- **内容**：业务概念、数据模型（业务视角）、业务流程、验证规则

### architecture/ 目录
- **架构设计和实现**：回答"怎么做"
- **目标读者**：开发工程师、技术架构师、运维工程师
- **内容**：系统架构、数据库 DDL、API 规范、服务设计、性能优化

## 目录结构

```
architecture/
├── 00.foundation/          # 基础系统架构设计
│   ├── 02.metadata/        # 元数据系统架构
│   │   ├── 01.storage/     # 存储层架构
│   │   │   ├── database-schema.md    # 数据库表结构
│   │   │   ├── ddl.sql              # DDL 定义
│   │   │   └── indexing.md          # 索引设计
│   │   ├── 02.services/    # 服务层架构
│   │   │   ├── metadata-service.md   # 元数据服务接口
│   │   │   ├── validation-service.md # 验证服务实现
│   │   │   └── governance-service.md # 治理服务实现
│   │   ├── 03.api/        # API 层架构
│   │   │   ├── rest-api.md          # REST API 规范
│   │   │   └── graphql-api.md       # GraphQL API
│   │   ├── 04.security/    # 安全架构
│   │   │   ├── authentication.md    # 认证机制
│   │   │   ├── authorization.md     # 授权实现
│   │   │   └── data-isolation.md    # 多租户数据隔离
│   │   └── 05.operations/  # 运维架构
│   │       ├── monitoring.md        # 监控实现
│   │       ├── alerting.md          # 告警配置
│   │       └── deployment.md        # 部署流程
│   └── README.md
└── README.md
```

## 内容映射

### specs/00.foundation/02.metadata → architecture/00.foundation/02.metadata

| specs 章节 | architecture 章节 | 内容区别 |
|-----------|------------------|---------|
| 02.baseline-metadata/02.field-type | - | specs: 字段类型业务含义<br>arch: 字段类型数据结构 |
| 04.runtime-storage | 01.storage | specs: 存储模型业务概念<br>arch: DDL、索引、迁移 |
| 05.governance | 02.services, 05.operations | specs: 治理流程业务规则<br>arch: 服务实现、运维配置 |

## 文档规范

### 架构文档要求

1. **具体实现**：包含代码示例、配置样例、API 定义
2. **可操作性**：提供可直接使用的 DDL、API 规范
3. **技术决策**：说明技术选型理由和权衡
4. **性能考虑**：包含性能分析、优化方案
5. **安全考量**：说明安全实现细节

### 引用规范

- architecture 文档可以引用 specs 中的业务概念
- specs 文档不应包含技术实现细节，可链接到 architecture 文档
- 使用相对路径引用：`[详见架构设计](../../architecture/00.foundation/02.metadata/01.storage/database-schema.md)`

## 维护原则

1. **同步更新**：业务规格变更时，同步更新架构设计文档
2. **版本管理**：重大架构变更需要更新文档版本
3. **代码对应**：文档应与代码实现保持一致
4. **实战验证**：架构方案应经过实际项目验证
