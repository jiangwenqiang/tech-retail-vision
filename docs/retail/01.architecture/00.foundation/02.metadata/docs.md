---
title: 元数据系统架构设计
taxonomy:
    category: docs
---

# 元数据系统架构设计

## 概述

本文档定义元数据管理系统在架构层的落地方案，对应业务规格：
- [规格总览](../../../00.specs/00.foundation/02.metadata/00.overview.md)
- [Entity](../../../00.specs/00.foundation/02.metadata/01.entity.md)
- [Field Type](../../../00.specs/00.foundation/02.metadata/02.field-type.md)
- [Attribute](../../../00.specs/00.foundation/02.metadata/03.attribute.md)
- [Client](../../../00.specs/00.foundation/02.metadata/04.client.md)
- [Layout Profile](../../../00.specs/00.foundation/02.metadata/05.layout-profile.md)
- [Layout](../../../00.specs/00.foundation/02.metadata/06.layout.md)
- [Customization](../../../00.specs/00.foundation/02.metadata/07.customization.md)

## 架构分层

1. Storage：元数据表与约束（`entityCode` 强归属、业务唯一键）
2. Services：三模型合并、校验、缓存、审计
3. API：元数据管理接口与运行时解析接口
4. Security：认证授权与租户隔离
5. Operations：监控、告警、容量与故障处理

## 核心规则

1. 可见性由 `status` 决定；`customizable` 仅控制 overlay/派生权限
2. Client 定制为 Tenant 覆盖；Layout 定制为 Profile 派生（Tenant/User）
3. Layout 运行时按 `USER -> TENANT -> PLATFORM` 逐层命中同维度 `Layout(entityCode + profileId + type)`
4. `LayoutProfile` 以 `code` 作为方案编码；引用表达统一使用 `profile.code`
5. `Field/Attribute/Client/Layout` 必须显式绑定 `entityCode`

## 子域目录

1. [01. 存储层架构](./01.storage/)
2. [02. 服务层架构](./02.services/)
3. [03. API 层架构](./03.api/)
4. [04. 安全架构](./04.security/)
5. [05. 运维架构](./05.operations/)
