---
title: 元数据存储层架构 - 数据库表结构
taxonomy:
    category: docs
---

# 元数据存储层架构 - 数据库表结构

## 概述

本文档定义元数据管理系统的数据库表结构和 DDL，对应业务规格：[00.specs/00.foundation/02.metadata/04.runtime-storage/](../../../00.specs/00.foundation/02.metadata/04.runtime-storage/)

## 设计原则

1. **统一前缀**：所有表名以 `metadata_` 开头
2. **主键规范**：统一使用 `id BIGINT AUTO_INCREMENT`
3. **软删除**：使用 `yn CHAR(1)` 字段（N=有效，Y=删除）
4. **审计字段**：`created_at/created_by_id/modified_at/modified_by_id`
5. **版本控制**：`version INT` 字段记录当前版本
6. **扩展性**：使用 JSON 字段承载可扩展参数
7. **唯一索引**：所有唯一索引必须包含 `yn` 字段

## 表结构清单

### 核心表（必需）

1. `metadata_entity` - 实体元数据
2. `metadata_field` - 字段元数据
3. `metadata_attribute` - 属性元数据
4. `metadata_client` - 客户端配置元数据
5. `metadata_version` - 版本审计表

### 扩展表（可选）

1. `metadata_group` - 实体维度分组（仅当需要业务语义分组时启用）

## DDL 定义

### metadata_entity - 实体元数据表

```sql
CREATE TABLE `metadata_entity` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `code` VARCHAR(100) NOT NULL COMMENT '实体编码',
  `name` VARCHAR(255) NOT NULL COMMENT '实体名称（单数）',
  `name_plural` VARCHAR(255) DEFAULT NULL COMMENT '实体名称（复数）',
  `type` ENUM('Base','Hierarchy','ReferenceData','Relation','Archive') NOT NULL DEFAULT 'Base' COMMENT '实体类型',
  `icon_class` VARCHAR(100) DEFAULT NULL COMMENT '图标样式类',
  `color` VARCHAR(30) DEFAULT NULL COMMENT '显示颜色',
  `primary_entity_id` BIGINT DEFAULT NULL COMMENT '主实体ID（派生场景）',
  `customizable` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否可自定义',
  `layouts_enabled` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否启用布局',
  `tab_enabled` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否显示导航',
  `acl_enabled` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否启用权限控制',
  `importable` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否允许导入',
  `stream_disabled` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否禁用动态流',
  `em_hidden` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否隐藏管理入口',
  `options_json` JSON DEFAULT NULL COMMENT '扩展配置JSON',
  `version` INT NOT NULL DEFAULT 1 COMMENT '当前版本号',
  `is_active` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否生效',
  `yn` CHAR(1) NOT NULL DEFAULT 'N' COMMENT '软删除标记：N有效，Y删除',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by_id` BIGINT DEFAULT NULL COMMENT '创建人ID',
  `modified_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `modified_by_id` BIGINT DEFAULT NULL COMMENT '修改人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_metadata_entity_code` (`code`,`yn`),
  KEY `idx_metadata_entity_type` (`type`,`yn`),
  KEY `idx_metadata_entity_primary` (`primary_entity_id`),
  CONSTRAINT `fk_metadata_entity_primary` FOREIGN KEY (`primary_entity_id`) REFERENCES `metadata_entity` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='实体元数据';
```

**索引说明**：
- `uq_metadata_entity_code`：实体编码唯一性约束（含软删除）
- `idx_metadata_entity_type`：按类型查询索引
- `idx_metadata_entity_primary`：主实体关联查询

### metadata_group - 实体维度分组表

```sql
CREATE TABLE `metadata_group` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `entity_id` BIGINT NOT NULL COMMENT '所属实体ID',
  `code` VARCHAR(100) NOT NULL COMMENT '分组编码（实体内唯一）',
  `name` VARCHAR(255) NOT NULL COMMENT '分组名称',
  `description` VARCHAR(500) DEFAULT NULL COMMENT '分组说明',
  `sort_order` INT NOT NULL DEFAULT 0 COMMENT '排序号',
  `is_system` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否系统内置',
  `version` INT NOT NULL DEFAULT 1 COMMENT '当前版本号',
  `is_active` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否生效',
  `yn` CHAR(1) NOT NULL DEFAULT 'N' COMMENT '软删除标记：N有效，Y删除',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by_id` BIGINT DEFAULT NULL COMMENT '创建人ID',
  `modified_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `modified_by_id` BIGINT DEFAULT NULL COMMENT '修改人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_metadata_group_entity_code` (`entity_id`,`code`,`yn`),
  UNIQUE KEY `uq_metadata_group_id_entity` (`id`,`entity_id`),
  KEY `idx_metadata_group_entity_sort` (`entity_id`,`sort_order`,`yn`),
  CONSTRAINT `fk_metadata_group_entity` FOREIGN KEY (`entity_id`) REFERENCES `metadata_entity` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='实体维度分组定义';
```

**索引说明**：
- `uq_metadata_group_entity_code`：分组编码在实体内唯一
- `uq_metadata_group_id_entity_id`：ID 和实体 ID 组合唯一
- `idx_metadata_group_entity_sort`：排序查询优化

### metadata_field - 字段元数据表

```sql
CREATE TABLE `metadata_field` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `entity_id` BIGINT NOT NULL COMMENT '所属实体ID',
  `group_id` BIGINT DEFAULT NULL COMMENT '所属分组ID（实体内）',
  `code` VARCHAR(100) NOT NULL COMMENT '字段编码（实体内唯一）',
  `name` VARCHAR(255) NOT NULL COMMENT '字段名称',
  `field_type` VARCHAR(50) NOT NULL COMMENT '字段类型',
  `relation_type` ENUM('oneToOne','oneToMany','manyToOne','manyToMany') DEFAULT NULL COMMENT '关系类型',
  `foreign_entity_id` BIGINT DEFAULT NULL COMMENT '关联实体ID',
  `foreign_code` VARCHAR(100) DEFAULT NULL COMMENT '关联字段编码',
  `required_flag` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否必填',
  `read_only_flag` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否只读',
  `is_multilang` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否多语言',
  `customizable` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否可自定义',
  `default_value_json` JSON DEFAULT NULL COMMENT '默认值JSON',
  `options_json` JSON DEFAULT NULL COMMENT '选项配置JSON',
  `conditions_json` JSON DEFAULT NULL COMMENT '条件配置JSON',
  `params_json` JSON DEFAULT NULL COMMENT '参数配置JSON',
  `sort_order` INT NOT NULL DEFAULT 0 COMMENT '排序号',
  `version` INT NOT NULL DEFAULT 1 COMMENT '当前版本号',
  `is_active` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否生效',
  `yn` CHAR(1) NOT NULL DEFAULT 'N' COMMENT '软删除标记：N有效，Y删除',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by_id` BIGINT DEFAULT NULL COMMENT '创建人ID',
  `modified_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `modified_by_id` BIGINT DEFAULT NULL COMMENT '修改人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_metadata_field_entity_code` (`entity_id`,`code`,`yn`),
  KEY `idx_metadata_field_type` (`field_type`,`yn`),
  KEY `idx_metadata_field_group` (`group_id`,`yn`),
  KEY `idx_metadata_field_foreign_entity` (`foreign_entity_id`),
  CONSTRAINT `fk_metadata_field_entity` FOREIGN KEY (`entity_id`) REFERENCES `metadata_entity` (`id`),
  CONSTRAINT `fk_metadata_field_foreign_entity` FOREIGN KEY (`foreign_entity_id`) REFERENCES `metadata_entity` (`id`),
  CONSTRAINT `fk_metadata_field_group_simple` FOREIGN KEY (`group_id`) REFERENCES `metadata_group` (`id`),
  CONSTRAINT `fk_metadata_field_group_entity` FOREIGN KEY (`group_id`,`entity_id`) REFERENCES `metadata_group` (`id`,`entity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='字段元数据';
```

**索引说明**：
- `uq_metadata_field_entity_code`：字段编码在实体内唯一
- `idx_metadata_field_type`：按字段类型查询
- `idx_metadata_field_group`：按分组查询字段
- `idx_metadata_field_foreign_entity`：关联实体查询

**外键约束**：
- `fk_metadata_field_entity`：字段所属实体
- `fk_metadata_field_foreign_entity`：关联实体
- `fk_metadata_field_group_simple`：所属分组
- `fk_metadata_field_group_entity`：分组实体一致性

### metadata_attribute - 属性元数据表

```sql
CREATE TABLE `metadata_attribute` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `entity_id` BIGINT NOT NULL COMMENT '所属实体ID',
  `group_id` BIGINT DEFAULT NULL COMMENT '所属分组ID（实体内）',
  `code` VARCHAR(100) NOT NULL COMMENT '属性编码（实体内唯一）',
  `name` VARCHAR(255) NOT NULL COMMENT '属性名称',
  `attribute_type` VARCHAR(50) NOT NULL COMMENT '属性类型',
  `attribute_panel_id` BIGINT DEFAULT NULL COMMENT '属性面板ID',
  `extensible_enum_id` BIGINT DEFAULT NULL COMMENT '扩展枚举ID',
  `composite_attribute_id` BIGINT DEFAULT NULL COMMENT '父复合属性ID',
  `is_multilang` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否多语言',
  `required_flag` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否必填',
  `read_only_flag` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否只读',
  `data_json` JSON DEFAULT NULL COMMENT '动态数据JSON',
  `params_json` JSON DEFAULT NULL COMMENT '参数配置JSON',
  `sort_order` INT NOT NULL DEFAULT 0 COMMENT '排序号',
  `version` INT NOT NULL DEFAULT 1 COMMENT '当前版本号',
  `is_active` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否生效',
  `yn` CHAR(1) NOT NULL DEFAULT 'N' COMMENT '软删除标记：N有效，Y删除',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by_id` BIGINT DEFAULT NULL COMMENT '创建人ID',
  `modified_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `modified_by_id` BIGINT DEFAULT NULL COMMENT '修改人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_metadata_attribute_entity_code` (`entity_id`,`code`,`yn`),
  KEY `idx_metadata_attribute_type` (`attribute_type`,`yn`),
  KEY `idx_metadata_attribute_group` (`group_id`,`yn`),
  KEY `idx_metadata_attribute_composite` (`composite_attribute_id`,`yn`),
  CONSTRAINT `fk_metadata_attribute_entity` FOREIGN KEY (`entity_id`) REFERENCES `metadata_entity` (`id`),
  CONSTRAINT `fk_metadata_attribute_group_simple` FOREIGN KEY (`group_id`) REFERENCES `metadata_group` (`id`),
  CONSTRAINT `fk_metadata_attribute_group_entity` FOREIGN KEY (`group_id`,`entity_id`) REFERENCES `metadata_group` (`id`,`entity_id`),
  CONSTRAINT `fk_metadata_attribute_composite` FOREIGN KEY (`composite_attribute_id`) REFERENCES `metadata_attribute` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='属性元数据';
```

**索引说明**：
- `uq_metadata_attribute_entity_code`：属性编码在实体内唯一
- `idx_metadata_attribute_type`：按属性类型查询
- `idx_metadata_attribute_group`：按分组查询属性
- `idx_metadata_attribute_composite`：复合属性父子关系查询

**外键约束**：
- `fk_metadata_attribute_entity`：属性所属实体
- `fk_metadata_attribute_group_simple`：所属分组
- `fk_metadata_attribute_group_entity`：分组实体一致性
- `fk_metadata_attribute_composite`：复合属性自关联

### metadata_client - 客户端配置元数据表

```sql
CREATE TABLE `metadata_client` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `scope_type` ENUM('ENTITY','APP','MODULE') NOT NULL DEFAULT 'ENTITY' COMMENT '作用域类型',
  `entity_id` BIGINT DEFAULT NULL COMMENT '实体ID（作用域为ENTITY时使用）',
  `scope_code` VARCHAR(100) NOT NULL COMMENT '作用域编码',
  `client_json` JSON NOT NULL COMMENT '客户端配置JSON',
  `version` INT NOT NULL DEFAULT 1 COMMENT '当前版本号',
  `is_active` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否生效',
  `yn` CHAR(1) NOT NULL DEFAULT 'N' COMMENT '软删除标记：N有效，Y删除',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by_id` BIGINT DEFAULT NULL COMMENT '创建人ID',
  `modified_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `modified_by_id` BIGINT DEFAULT NULL COMMENT '修改人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_metadata_client_scope` (`scope_type`,`scope_code`,`is_active`,`yn`),
  KEY `idx_metadata_client_entity` (`entity_id`,`yn`),
  CONSTRAINT `fk_metadata_client_entity` FOREIGN KEY (`entity_id`) REFERENCES `metadata_entity` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='客户端元数据';
```

**索引说明**：
- `uq_metadata_client_scope`：作用域唯一性约束
- `idx_metadata_client_entity`：按实体查询客户端配置

### metadata_version - 版本审计表

```sql
CREATE TABLE `metadata_version` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `object_type` ENUM('ENTITY','GROUP','FIELD','ATTRIBUTE','CLIENT') NOT NULL COMMENT '对象类型',
  `object_id` BIGINT NOT NULL COMMENT '对象ID',
  `version` INT NOT NULL COMMENT '版本号',
  `operation` ENUM('INSERT','UPDATE','DELETE','PUBLISH','ROLLBACK') NOT NULL COMMENT '操作类型',
  `snapshot_json` JSON NOT NULL COMMENT '对象快照JSON',
  `comment` VARCHAR(500) DEFAULT NULL COMMENT '变更说明',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by_id` BIGINT DEFAULT NULL COMMENT '创建人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_metadata_version_obj_ver` (`object_type`,`object_id`,`version`),
  KEY `idx_metadata_version_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='统一版本记录';
```

**索引说明**：
- `uq_metadata_version_obj_ver`：对象版本唯一性约束
- `idx_metadata_version_created`：按创建时间查询版本历史

## 字段类型与 JSON 字段结构

### options_json 字段结构

用于存储字段或属性的扩展配置，结构根据具体字段类型而定：

```json
{
  "maxLength": 255,
  "min": 0,
  "max": 100,
  "pattern": "^[a-zA-Z0-9]+$",
  "dropdown": ["option1", "option2"],
  "defaultDate": "today",
  "audit": false,
  "filterable": true
}
```

### conditions_json 字段结构

用于存储字段或属性的条件显示规则：

```json
{
  "visible": "entity.type == 'Base'",
  "required": "entity.importable == true",
  "readOnly": "user.role != 'admin'"
}
```

### client_json 字段结构

用于存储客户端配置，包含布局、视图、面板等信息：

```json
{
  "controller": "controllers/record",
  "views": {
    "list": "views/record/list",
    "detail": "views/record/detail"
  },
  "recordViews": {
    "list": "views/record/panels/list",
    "detail": "views/record/panels/detail"
  },
  "relationshipPanels": {
    "relatedEntity": {
      "layout": "list",
      "select": true,
      "create": true
    }
  }
}
```

## 数据完整性约束

### 外键级联规则

1. **删除约束**：所有外键默认为 `RESTRICT`，防止误删除
2. **软删除处理**：应用层负责软删除时的数据一致性
3. **循环引用处理**：`composite_attribute_id` 自关联通过应用层验证

### 唯一性约束

1. **编码唯一性**：code、name 等编码字段在相应范围内唯一
2. **软删除处理**：唯一索引包含 `yn` 字段，允许软删除后重用编码
3. **版本唯一性**：每个对象的每个版本号唯一

## 性能优化建议

### 索引策略

1. **查询优化**：为常用查询路径创建复合索引
2. **软删除过滤**：所有索引包含 `yn` 字段以优化软删除查询
3. **排序优化**：为 `sort_order`、`created_at` 等排序字段创建索引

### 分区策略

对于大型部署，考虑对 `metadata_version` 表按时间分区：

```sql
ALTER TABLE metadata_version
PARTITION BY RANGE (YEAR(created_at)) (
  PARTITION p2023 VALUES LESS THAN (2024),
  PARTITION p2024 VALUES LESS THAN (2025),
  PARTITION p2025 VALUES LESS THAN (2026),
  PARTITION p_future VALUES LESS THAN MAXVALUE
);
```

## 迁移策略

### 版本升级

1. **DDL 版本控制**：每个 DDL 变更需要版本号
2. **增量迁移**：使用 ALTER TABLE 而非重建表
3. **回滚脚本**：为每个 DDL 变更准备回滚脚本

### 数据迁移

1. **快照备份**：迁移前创建表快照
2. **分批迁移**：大量数据分批处理
3. **验证脚本**：迁移后运行数据完整性验证

## 相关文档

- 业务规格：[00.specs/00.foundation/02.metadata/04.runtime-storage/](../../../00.specs/00.foundation/02.metadata/04.runtime-storage/)
- 服务层架构：[../02.services/](../02.services/)
- 安全架构：[../04.security/](../04.security/)
