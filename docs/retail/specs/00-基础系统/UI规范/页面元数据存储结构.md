# 页面元数据存储结构（MySQL）

本结构基于当前元数据规范调整：`schemaVersion` 下沉到 `view`，`i18n` 仅保留语言/区域标识，视图内容通过 `view.sections` 与 `view.rules` 表达层级关系。

## 设计原则
- 页面、区块、组件、字段分层存储
- 所有语义标识统一使用 `*_code`，并保证唯一
- 表间关联统一通过 `code` 字段，不通过 `id` 字段
- 可变结构用 JSON 字段保存（props/options/validators 等）
- 规则与数据源独立存储
- 支持草稿/发布与版本管理

## 表结构定义

### 1) 视图表 `ui_view`
```sql
CREATE TABLE ui_view (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  view_code VARCHAR(128) NOT NULL UNIQUE,       -- 视图语义编码，如 product-edit
  name VARCHAR(128) NOT NULL,                   -- 已本地化名称
  route VARCHAR(256) NOT NULL,
  layout_type VARCHAR(32) NOT NULL,             -- form/list/detail/split/tabs/wizard
  layout_json JSON NULL,                        -- layout 其他参数
  permissions JSON NULL,
  i18n JSON NULL,                               -- {lang,region,currencyCode,timeZone,...}
  schema_version VARCHAR(32) NOT NULL,          -- view.schemaVersion
  status VARCHAR(16) NOT NULL DEFAULT 'draft',  -- draft/published/archived
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  published_at DATETIME NULL
);
```

### 2) 区块表 `ui_section`
```sql
CREATE TABLE ui_section (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  view_code VARCHAR(128) NOT NULL,
  section_code VARCHAR(128) NOT NULL UNIQUE,
  title VARCHAR(128) NULL,                      -- 已本地化标题
  description VARCHAR(256) NULL,                -- 已本地化描述
  sort_order INT NOT NULL DEFAULT 0,
  FOREIGN KEY (view_code) REFERENCES ui_view(view_code)
);
```

### 3) 组件表 `ui_component`
```sql
CREATE TABLE ui_component (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  section_code VARCHAR(128) NOT NULL,
  component_code VARCHAR(128) NOT NULL UNIQUE,
  type VARCHAR(64) NOT NULL,                    -- form/table/card/tabs/tree...
  props JSON NULL,
  actions JSON NULL,
  rules JSON NULL,                              -- 组件级规则（JSON Logic）
  sort_order INT NOT NULL DEFAULT 0,
  FOREIGN KEY (section_code) REFERENCES ui_section(section_code)
);
```

### 4) 字段表 `ui_field`
```sql
CREATE TABLE ui_field (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  component_code VARCHAR(128) NOT NULL,
  field_code VARCHAR(128) NOT NULL UNIQUE,
  label VARCHAR(128) NULL,                      -- 已本地化显示名
  field_type VARCHAR(64) NOT NULL,              -- 输入/展示类型，如 input/select/treeSelect/date...
  binding VARCHAR(256) NULL,
  format VARCHAR(64) NULL,
  required TINYINT(1) NOT NULL DEFAULT 0,
  read_only TINYINT(1) NOT NULL DEFAULT 0,
  visible TINYINT(1) NOT NULL DEFAULT 1,
  default_value JSON NULL,
  options JSON NULL,                            -- 选项来源（static/api/dataSource）
  validators JSON NULL,
  permissions JSON NULL,
  i18n JSON NULL,                               -- {lang,region,...} 可选
  sort_order INT NOT NULL DEFAULT 0,
  FOREIGN KEY (component_code) REFERENCES ui_component(component_code)
);
```

### 5) 数据源表 `ui_data_source`
```sql
CREATE TABLE ui_data_source (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  view_code VARCHAR(128) NOT NULL,
  source_code VARCHAR(128) NOT NULL UNIQUE,     -- 数据源编码（建议与业务模型/视图模型名称对齐，如 productDetail）
  method VARCHAR(16) NOT NULL,
  url VARCHAR(256) NOT NULL,
  params JSON NULL,
  mapping JSON NULL,
  cache JSON NULL,
  FOREIGN KEY (view_code) REFERENCES ui_view(view_code)
);
```

### 6) 页面规则表 `ui_rule`
```sql
CREATE TABLE ui_rule (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  view_code VARCHAR(128) NOT NULL,
  scope VARCHAR(32) NOT NULL DEFAULT 'view',    -- view/component
  rule_json JSON NOT NULL,                      -- JSON Logic when/then
  sort_order INT NOT NULL DEFAULT 0,
  FOREIGN KEY (view_code) REFERENCES ui_view(view_code)
);
```

### 7) 菜单与视图关系表 `ui_menu_view`
用于建立菜单与 `ui_view` 的映射关系，支持一个菜单绑定多个页面视图（如列表、详情、编辑）。

```sql
CREATE TABLE ui_menu_view (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  menu_code VARCHAR(128) NOT NULL,              -- 菜单编码（来源于菜单系统）
  view_code VARCHAR(128) NOT NULL,              -- 关联的页面视图编码
  view_type VARCHAR(32) NOT NULL,               -- main/create/edit/detail
  is_default TINYINT(1) NOT NULL DEFAULT 0,     -- 是否菜单默认加载视图
  sort_order INT NOT NULL DEFAULT 0,
  UNIQUE KEY uk_menu_view (menu_code, view_code, view_type),
  FOREIGN KEY (view_code) REFERENCES ui_view(view_code)
);
```

## 说明
- 页面切换语言时需重新请求元数据，因此 `name/title/label` 存储为已本地化文本。
- `i18n` 字段用于标识语言/区域与货币时区参数，不保存 i18nKey。
- `rules` 可放在 `ui_rule`（页面级），组件级规则放在 `ui_component.rules`。
- `ui_field.field_type` 表达 UI 渲染类型；业务字段语义类型由业务模型的 `type` 定义，两者通过 `binding` 关联。
- `ui_data_source.source_code` 作为业务模型数据源命名空间，`binding` 使用 `source_code.field_path` 进行字段绑定。
- 菜单点击默认加载 `ui_menu_view.is_default=1` 的主视图，新增/编辑/详情视图按 `view_type` 跳转并按需加载。
