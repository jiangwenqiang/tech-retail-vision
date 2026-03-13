---
title: Capability Model - Field
taxonomy:
    category: docs
---

# Field

字段（Field）是实体上的结构化数据单元，绑定具体字段类型并定义业务约束。

## 核心能力

1. 字段定义：名称、标签、类型、默认值
2. 约束控制：必填、唯一、可搜索、可排序
3. 数据治理：脱敏、审计、变更追踪
4. 显示协同：支持被客户端布局引用

## 关键关系

1. `field -> entity`（所属关系）
2. `field -> field_type`（类型关系）
3. `field -> attribute`（扩展关系）
