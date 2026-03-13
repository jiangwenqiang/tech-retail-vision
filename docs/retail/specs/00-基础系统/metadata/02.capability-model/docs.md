---
title: Capability Model
taxonomy:
    category: docs
---

# 元模型能力拆分

本目录按子域拆分能力模型，避免单文档过大，便于分工维护与变更评审。

## 子域目录

1. [Entity](/Users/hermes/Workspace/personal/atrocore/docs/99.metadata/02.capability-model/01.entity/docs.md)
2. [Field Type](/Users/hermes/Workspace/personal/atrocore/docs/99.metadata/02.capability-model/02.field-type/docs.md)
3. [Field](/Users/hermes/Workspace/personal/atrocore/docs/99.metadata/02.capability-model/03.field/docs.md)
4. [Attribute](/Users/hermes/Workspace/personal/atrocore/docs/99.metadata/02.capability-model/04.attribute/docs.md)
5. [Client](/Users/hermes/Workspace/personal/atrocore/docs/99.metadata/02.capability-model/05.client/docs.md)

---

## 6. 横切能力：版本审计与发布控制

### 6.1 统一版本表

- 表：`metadata_version`
- 对象类型：`ENTITY/GROUP/FIELD/ATTRIBUTE/CLIENT`

### 6.2 版本操作

1. `INSERT`
2. `UPDATE`
3. `DELETE`
4. `PUBLISH`
5. `ROLLBACK`

### 6.3 发布门禁建议

1. 结构校验通过
2. 引用完整性通过
3. 分组与面板引用存在性通过
4. 回滚演练通过

### 6.4 回滚策略

1. 读取目标对象最近稳定快照
2. 以事务恢复主表
3. 写回滚版本记录
4. 刷新缓存并输出差异报告

---

## 7. 实施建议（工程侧）

1. 先落地主能力：`entity/field/attribute/client/version`
2. 显示分组统一走 `metadata_client.client_json`
3. `metadata_group` 仅作为未来业务语义分组的可选扩展
4. 所有写接口统一启用：
   - 版本号校验
   - 事务
   - 版本快照
   - 审计日志
5. 配置域能力单独见：`docs/98.config`
