---
title: 租户元数据扩展模型 - 适用范围与可见性
taxonomy:
    category: docs
---

# 适用范围与可见性

## 核心字段

1. `visibility_scope`：`GLOBAL` / `TENANT`
2. `visibility_tenants`：租户可见范围集合

## 规则

1. `GLOBAL` 对全租户生效
2. `TENANT` 仅对指定租户生效
3. 可见性仅控制“是否可用”，不替代版本发布流程
