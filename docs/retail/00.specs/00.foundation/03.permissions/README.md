# 权限模型

面向零售行业的多租户权限模型。在现有元数据授权架构（RBAC + ABAC）基础上，扩展为覆盖业务实体的完整权限控制体系。

## 文档列表

- [00. 方案总览](./00.overview.md) — 权限系统整体设计、分层架构、判定流程
- [01. 角色定义](./01.role.md) — Role 实体定义、预设角色、角色分配
- [02. 实体权限](./02.entity-permission.md) — 实体级 CRUD 控制（能不能操作）
- [03. 范围权限](./03.scope-permission.md) — 记录级过滤（能操作哪些记录，含 scope/field/expression/callback）
- [04. 字段权限](./04.field-permission.md) — 字段级读写/脱敏控制
