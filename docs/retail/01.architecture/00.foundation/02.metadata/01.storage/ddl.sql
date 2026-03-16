-- DDL version: metadata-foundation-v6 (MySQL 8 + column/table comments)

CREATE TABLE IF NOT EXISTS `metadata_entity` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `code` VARCHAR(100) NOT NULL COMMENT '实体编码（全局业务编码）',
  `name` VARCHAR(255) NOT NULL COMMENT '实体名称',
  `scope` ENUM('PLATFORM','TENANT') NOT NULL DEFAULT 'PLATFORM' COMMENT '作用域',
  `status` ENUM('DRAFT','ACTIVE','DISABLED') NOT NULL DEFAULT 'DRAFT' COMMENT '状态',
  `customizable` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否允许下层定制',
  `props_json` JSON NOT NULL COMMENT '扩展属性JSON（非基础控制字段）',
  `version` INT NOT NULL DEFAULT 1 COMMENT '版本号（定义版本）',
  `yn` CHAR(1) NOT NULL DEFAULT 'N' COMMENT '软删除标记（N=有效，Y=删除）',
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
  `created_by_id` BIGINT DEFAULT NULL COMMENT '创建人ID',
  `modified_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '修改时间',
  `modified_by_id` BIGINT DEFAULT NULL COMMENT '修改人ID',
  PRIMARY KEY (`id`),
  KEY `idx_entity_scope_status` (`scope`, `status`, `yn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='实体定义（props）';

CREATE TABLE IF NOT EXISTS `metadata_field` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `entity_code` VARCHAR(100) NOT NULL COMMENT '归属实体编码',
  `code` VARCHAR(100) NOT NULL COMMENT '字段编码（实体内）',
  `name` VARCHAR(255) NOT NULL COMMENT '字段名称',
  `scope` ENUM('PLATFORM','TENANT') NOT NULL DEFAULT 'PLATFORM' COMMENT '作用域',
  `status` ENUM('DRAFT','ACTIVE','DISABLED') NOT NULL DEFAULT 'ACTIVE' COMMENT '状态',
  `customizable` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否允许下层定制',
  `props_json` JSON NOT NULL COMMENT '字段扩展属性JSON（type/required/readOnly/params等）',
  `yn` CHAR(1) NOT NULL DEFAULT 'N' COMMENT '软删除标记（N=有效，Y=删除）',
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
  `created_by_id` BIGINT DEFAULT NULL COMMENT '创建人ID',
  `modified_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '修改时间',
  `modified_by_id` BIGINT DEFAULT NULL COMMENT '修改人ID',
  PRIMARY KEY (`id`),
  KEY `idx_field_entity_code` (`entity_code`, `code`, `yn`),
  KEY `idx_field_entity_status` (`entity_code`, `status`, `yn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='字段定义（fields）';

CREATE TABLE IF NOT EXISTS `metadata_link` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `entity_code` VARCHAR(100) NOT NULL COMMENT '归属实体编码',
  `code` VARCHAR(100) NOT NULL COMMENT '关系编码（实体内）',
  `name` VARCHAR(255) NOT NULL COMMENT '关系名称',
  `status` ENUM('DRAFT','ACTIVE','DISABLED') NOT NULL DEFAULT 'ACTIVE' COMMENT '状态',
  `props_json` JSON NOT NULL COMMENT '关系扩展属性JSON（type/foreignEntity/foreign/required等）',
  `yn` CHAR(1) NOT NULL DEFAULT 'N' COMMENT '软删除标记（N=有效，Y=删除）',
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
  `created_by_id` BIGINT DEFAULT NULL COMMENT '创建人ID',
  `modified_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '修改时间',
  `modified_by_id` BIGINT DEFAULT NULL COMMENT '修改人ID',
  PRIMARY KEY (`id`),
  KEY `idx_link_entity_code` (`entity_code`, `code`, `yn`),
  KEY `idx_link_entity_status` (`entity_code`, `status`, `yn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='关系定义（links）';

CREATE TABLE IF NOT EXISTS `metadata_index` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `entity_code` VARCHAR(100) NOT NULL COMMENT '归属实体编码',
  `code` VARCHAR(100) NOT NULL COMMENT '索引编码（实体内）',
  `status` ENUM('DRAFT','ACTIVE','DISABLED') NOT NULL DEFAULT 'ACTIVE' COMMENT '状态',
  `props_json` JSON NOT NULL COMMENT '索引扩展属性JSON（fields/unique等）',
  `yn` CHAR(1) NOT NULL DEFAULT 'N' COMMENT '软删除标记（N=有效，Y=删除）',
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
  `created_by_id` BIGINT DEFAULT NULL COMMENT '创建人ID',
  `modified_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '修改时间',
  `modified_by_id` BIGINT DEFAULT NULL COMMENT '修改人ID',
  PRIMARY KEY (`id`),
  KEY `idx_index_entity_code` (`entity_code`, `code`, `yn`),
  KEY `idx_index_entity_status` (`entity_code`, `status`, `yn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='索引定义（indexes）';

CREATE TABLE IF NOT EXISTS `metadata_attribute` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `entity_code` VARCHAR(100) NOT NULL COMMENT '归属实体编码',
  `code` VARCHAR(100) NOT NULL COMMENT '属性编码（实体内）',
  `name` VARCHAR(255) NOT NULL COMMENT '属性名称',
  `scope` ENUM('PLATFORM','TENANT') NOT NULL DEFAULT 'PLATFORM' COMMENT '作用域',
  `status` ENUM('DRAFT','ACTIVE','DISABLED') NOT NULL DEFAULT 'ACTIVE' COMMENT '状态',
  `customizable` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否允许下层定制',
  `props_json` JSON NOT NULL COMMENT '属性扩展属性JSON（type/required/isMultilang/parentId等）',
  `yn` CHAR(1) NOT NULL DEFAULT 'N' COMMENT '软删除标记（N=有效，Y=删除）',
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
  `created_by_id` BIGINT DEFAULT NULL COMMENT '创建人ID',
  `modified_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '修改时间',
  `modified_by_id` BIGINT DEFAULT NULL COMMENT '修改人ID',
  PRIMARY KEY (`id`),
  KEY `idx_attribute_entity_code` (`entity_code`, `code`, `yn`),
  KEY `idx_attribute_entity_status` (`entity_code`, `status`, `yn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='属性定义（attribute）';

CREATE TABLE IF NOT EXISTS `metadata_client` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `entity_code` VARCHAR(100) NOT NULL COMMENT '归属实体编码',
  `scope` ENUM('PLATFORM') NOT NULL DEFAULT 'PLATFORM' COMMENT '作用域（固定PLATFORM）',
  `customizable` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否允许租户覆盖',
  `props_json` JSON NOT NULL COMMENT '客户端配置JSON（controller/views/recordViews/relationshipPanels）',
  `yn` CHAR(1) NOT NULL DEFAULT 'N' COMMENT '软删除标记（N=有效，Y=删除）',
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
  `created_by_id` BIGINT DEFAULT NULL COMMENT '创建人ID',
  `modified_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '修改时间',
  `modified_by_id` BIGINT DEFAULT NULL COMMENT '修改人ID',
  PRIMARY KEY (`id`),
  KEY `idx_client_entity_scope` (`entity_code`, `scope`, `yn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='客户端定义（client）';

CREATE TABLE IF NOT EXISTS `metadata_layout_profile` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `code` VARCHAR(100) NOT NULL COMMENT '布局方案编码（profile.code）',
  `name` VARCHAR(255) NOT NULL COMMENT '布局方案名称',
  `scope` ENUM('PLATFORM','TENANT','USER') NOT NULL DEFAULT 'PLATFORM' COMMENT '作用域',
  `tenant_id` BIGINT DEFAULT NULL COMMENT '租户ID（PLATFORM为空）',
  `owner` VARCHAR(100) NOT NULL COMMENT '归属主体（platform/tenantId/userId）',
  `status` ENUM('DRAFT','ACTIVE','DISABLED') NOT NULL DEFAULT 'DRAFT' COMMENT '状态',
  `customizable` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否允许下一层派生',
  `props_json` JSON NOT NULL COMMENT '布局方案扩展属性JSON',
  `yn` CHAR(1) NOT NULL DEFAULT 'N' COMMENT '软删除标记（N=有效，Y=删除）',
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
  `created_by_id` BIGINT DEFAULT NULL COMMENT '创建人ID',
  `modified_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '修改时间',
  `modified_by_id` BIGINT DEFAULT NULL COMMENT '修改人ID',
  PRIMARY KEY (`id`),
  KEY `idx_layout_profile_scope_owner_code` (`scope`, `owner`, `code`, `yn`),
  KEY `idx_layout_profile_scope_owner_status` (`scope`, `owner`, `status`, `yn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='布局方案定义（layout profile）';

CREATE TABLE IF NOT EXISTS `metadata_layout` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `entity_code` VARCHAR(100) NOT NULL COMMENT '归属实体编码',
  `profile_id` BIGINT NOT NULL COMMENT '关联布局方案ID',
  `type` ENUM('list','detail','form','relationship') NOT NULL COMMENT '布局类型',
  `customizable` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否允许在派生方案中修改',
  `props_json` JSON NOT NULL COMMENT '布局配置JSON',
  `yn` CHAR(1) NOT NULL DEFAULT 'N' COMMENT '软删除标记（N=有效，Y=删除）',
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
  `created_by_id` BIGINT DEFAULT NULL COMMENT '创建人ID',
  `modified_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '修改时间',
  `modified_by_id` BIGINT DEFAULT NULL COMMENT '修改人ID',
  PRIMARY KEY (`id`),
  KEY `idx_layout_entity_profile_type` (`entity_code`, `profile_id`, `type`, `yn`),
  KEY `idx_layout_profile` (`profile_id`, `yn`),
  CONSTRAINT `fk_layout_profile` FOREIGN KEY (`profile_id`) REFERENCES `metadata_layout_profile` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='布局定义（layout）';

CREATE TABLE IF NOT EXISTS `metadata_customization` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `tenant_id` BIGINT NOT NULL COMMENT '租户ID',
  `entity_code` VARCHAR(100) NOT NULL COMMENT '归属实体编码',
  `target_type` ENUM('field','attribute') NOT NULL COMMENT '目标类型',
  `target_code` VARCHAR(100) NOT NULL COMMENT '目标编码',
  `props_json` JSON NOT NULL COMMENT '覆盖属性JSON（对应API properties）',
  `yn` CHAR(1) NOT NULL DEFAULT 'N' COMMENT '软删除标记（N=有效，Y=删除）',
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
  `created_by_id` BIGINT DEFAULT NULL COMMENT '创建人ID',
  `modified_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '修改时间',
  `modified_by_id` BIGINT DEFAULT NULL COMMENT '修改人ID',
  PRIMARY KEY (`id`),
  KEY `idx_customization_tenant_entity_target` (`tenant_id`, `entity_code`, `target_type`, `target_code`, `yn`),
  KEY `idx_customization_tenant_entity` (`tenant_id`, `entity_code`, `yn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Metadata Customization（Field/Attribute覆盖）';

CREATE TABLE IF NOT EXISTS `metadata_client_customization` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `tenant_id` BIGINT NOT NULL COMMENT '租户ID',
  `entity_code` VARCHAR(100) NOT NULL COMMENT '归属实体编码',
  `props_json` JSON NOT NULL COMMENT '客户端覆盖属性JSON（对应API properties）',
  `yn` CHAR(1) NOT NULL DEFAULT 'N' COMMENT '软删除标记（N=有效，Y=删除）',
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
  `created_by_id` BIGINT DEFAULT NULL COMMENT '创建人ID',
  `modified_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '修改时间',
  `modified_by_id` BIGINT DEFAULT NULL COMMENT '修改人ID',
  PRIMARY KEY (`id`),
  KEY `idx_client_customization_tenant_entity` (`tenant_id`, `entity_code`, `yn`),
  KEY `idx_client_customization_tenant` (`tenant_id`, `yn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Client Customization（租户覆盖）';
