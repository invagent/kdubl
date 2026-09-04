## 法国 (FR) 标准字段填写指南

> 来源：Pagero《Best Practice Content — France》v1.30（2026-06-12），`Invoice and related subtype` 表。
> 本文档描述**法国 B2B / B2G 电子发票（Flux 10.1 Billing）标准字段**（EN 16931 BT/BG 业务术语）的**是否必填 / 填入条件 / 填值要求 / 适用场景**，是"怎么填"的字段级参考。
>
> - 法国专用**扩展字段**（`EXT-FR-FE-*`、`TaxReport*`、付款申报 Flux 10.2/10.4）详见 [[FR_EXTENSIONS]]（`FR_EXTENSIONS.md`）。本文档为标准字段的补充，`EXT-FR-FE-*` 字段仅在结构需要时列出并标注，不重复展开。
> - PUF 路径基于源格式为 Pagero Universal Format 的映射；PUF 根元素为 `Invoice`。贷项通知单（CreditNote）需将 `cac:InvoiceLine` → `cac:CreditNoteLine`、`cbc:InvoicedQuantity` → `cbc:CreditedQuantity`。

### 必填性图例

| 标记 | 含义 | 说明 |
|------|------|------|
| **M** | Mandatory（必填） | 必须提供的字段 |
| **CM** | Conditionally Mandatory（条件必填） | 满足特定条件时必填，见"填入条件"列 |
| **O** | Optional（可选） | 非强制 |
| Legal | 法律要求 | 法国税法层面要求（`X` 表示是） |
| Tech | 技术要求 | 通道/格式技术层面要求（`X` 表示是） |

---

### 0. 代码表（填值时引用）

#### 0.1 业务流程码（Business Process Codes，BT-23，写入 `cbc:InvoiceTypeCode/@name`）

| 码 | 名称 | 说明 | 类型 |
|----|------|------|------|
| B1 | 货物发票 | 货物销售发票 | 标准 |
| S1 | 服务发票 | 服务发票 | 标准 |
| M1 | 混合发票（货物+服务） | 货物与服务合并（互不附属） | 标准 |
| B2 | 货物发票（已付款） | 货物已付款 | 预付 |
| S2 | 服务发票（已付款） | 服务已付款 | 预付 |
| M2 | 混合发票（已付款） | 混合且已付款 | 预付 |
| B4 | 货物最终发票（预付款后） | 预付款后的最终发票（货物） | 预付款后最终 |
| S4 | 服务最终发票（预付款后） | 预付款后的最终发票（服务） | 预付款后最终 |
| M4 | 混合最终发票（预付款后） | 预付款后的最终混合发票 | 预付款后最终 |
| S5 | 分包商服务发票 | 分包商提供的服务 | 分包 |
| S6 | 共同承包商服务发票 | 共同承包商提供的服务 | 共同承包 |
| B7 | 货物发票（e-reporting，VAT 已收） | 已 e-reporting 的货物发票 | e-reporting |
| S7 | 服务发票（e-reporting，VAT 已收） | 已 e-reporting 的服务发票 | e-reporting |

#### 0.2 单据类型码（Document Type Codes，BT-3，写入 `cbc:InvoiceTypeCode`）

| 码 | 名称 | UBL 消息类型 | 自开票 |
|----|------|-------------|-------|
| 261 | 自开票贷项通知单 | CreditNote | 是 |
| 262 | 全局折扣贷项通知单（Avoir pour Remise Globale） | CreditNote | 否 |
| 380 | 发票 | Invoice | 否 |
| 381 | 贷项通知单 | CreditNote | 否 |
| 384 | 更正发票 | Invoice | 否 |
| 386 | 预付款发票 | Invoice | 否 |
| 389 | 自开票发票 | Invoice | 是 |
| 393 | 保理发票（Facture affacturée） | Invoice | 否 |
| 396 | 保理贷项通知单（Avoir affacturé） | CreditNote | 否 |
| 471 | 自开票更正发票 | Invoice | 是 |
| 472 | 更正保理发票 | Invoice | 否 |
| 473 | 自开票更正保理发票 | Invoice | 是 |
| 500 | 自开票预付款发票 | Invoice | 是 |
| 501 | 自开票保理发票 | Invoice | 是 |
| 502 | 自开票保理贷项通知单 | CreditNote | 是 |
| 503 | 预付款贷项通知单 | CreditNote | 否 |

#### 0.3 备注主题码（Text Codes / UNTDID 4451，BT-21，写入 `cbc:Note`，格式 `#码#备注文本`）

| 码 | 名称 | 必填性 | 条件 / 必填文本 |
|----|------|--------|----------------|
| BAR | 处理类型限定 | **M** | 法国 e-invoicing 必填。允许多个 BAR 但值必须一致（BR-FR-31）。取值之一："B2B"、"B2BINT"、"B2C"、"OUTOFSCOPE"、"ARCHIVEONLY" |
| AAB | 提前付款折扣 | **M** | 所有 e-invoicing 必填（BR-FR-05），每张发票仅一次（BR-FR-06）。必填：折扣条款，或明确声明"无提前付款折扣" |
| PMD | 逾期付款罚金 | **M** | 所有 e-invoicing 必填（BR-FR-05），每张发票仅一次 |
| PMT | 催收费用（€40） | **M** | 逾期付款固定 €40 催收赔偿，所有 e-invoicing 必填，每张发票仅一次 |
| TXD | 单一应税主体成员 | CM | 交易发生在单一应税主体成员与第三方之间时必填（G1.52/G1.76）。必填文本："MEMBRE_ASSUJETTI_UNIQUE" |
| BLU | 环保参与费 / DEEE 环保贡献 | CM | 适用环保参与费/WEEE 或其他环保税时必填（G1.52）。必填文本："Eco-participation (L. 541-10 du code de l'environnement)" 或 "Eco-contribution DEEE" |
| ADN | B2G 指示 | CM | 发票适用法国 B2G 处理（CHORUS PRO 附加规则）时必填（BR-FR-07） |
| ABL | 法律信息 | O | 贸易注册号（RCS）等法律注册信息 |
| REG | 注册数据 | O | 股本等公司注册监管信息 |
| ACC | 保理代位求偿条款 | O | 保理安排与代位求偿条款 |
| ABU | 合同条款 / 保留金 | O | 合同保留条款或 Retenue de garantie |
| AAI | 一般信息 | O | 纸质发票底部常见的一般信息 |
| SUR | 供应商备注 | O | 供应商附加说明 |
| CUS | 海关信息 | O | 海关相关细节 |
| PAI | 第三方付款 | O | 管理场景4：第三方已付或应付部分发票金额 |

#### 0.4 Party 标识方案（`@schemeID`）

| 方案码 | 说明 | 长度/格式 | 用于 EndpointID | 用于 PartyIdentification |
|--------|------|-----------|-----------------|--------------------------|
| 0002 | SIREN（法国公司注册号） | 9 位 | 否 | 是 |
| 0009 | SIRET（机构标识） | 14 位（SIREN 9 + 机构 5） | 是 | 是（B2G 强制主标识） |
| 0021 | SWIFT | 变长 | 是 | 是 |
| 0060 | DUNS | 9 位 | 是 | 是 |
| 0088 | GLN | 13 位 | 是 | 是 |
| 0223 | UE_HORS_FRANCE（欧盟内 VAT 号） | ≤18 | 否 | 是（须与 BT-31 一致） |
| 0224 | CODE ROUTAGE（平台路由标识） | ≤100 | 是 | 是（G1.83 路由必填限定） |
| 0225 | 电子发票电子地址 | SIREN 或 SIREN_XXX | 是 | 否 |
| 0226 | PARTICULIER（个人标识） | 80 位 | 否 | 是（仅 B2G） |
| 0227 | HORS_UE（非欧盟标识） | ≤18 | 否 | 是 |
| 0231 | SIREN ASSUJETTI UNIQUE（单一应税主体） | 9 位 | 否 | 是（仅一个值） |

---

### 1. 单据级字段（Document Level）

| BT | 字段 | 必填 | 填入条件 / 填值要求 | PUF 路径 |
|----|------|------|--------------------|----------|
| BT-1 | 发票号 | **M** | 唯一顺序号；**不超过 20 字符**（PPF 约 2026年12月起接受 35 字符） | `cbc:ID` |
| BT-2 | 发票开具日期 | **M** | 开票日期 | `cbc:IssueDate` |
| BT-3 | 发票类型码 | **M** | 见 §0.2 单据类型码 | `cbc:InvoiceTypeCode` |
| BT-23 | 业务流程类型 | **M** | 见 §0.1 业务流程码 | `cbc:InvoiceTypeCode/@name` |
| —(N/A) | 自开票指示 | CM | 自开票时必填，值为 `true`；缺失视为 false | `ext:UBLExtensions/.../puf:SelfBilled` |
| BT-5 | 发票币种码 | **M** | 除会计币种税额外，所有金额的币种 | `cbc:DocumentCurrencyCode` |
| BT-6 | VAT 会计币种码 | CM | 会计币种；文档币种非 EUR 时一般为 EUR | `cbc:TaxCurrencyCode` |
| —(N/A) | 汇率 | CM | 文档币种转税币种的汇率；VAT 须以欧元列示，用 ECB 最新公布汇率，并在发票上注明 | `cac:TaxExchangeRate/cbc:CalculationRate` |
| BT-7 | VAT 纳税义务发生日 | O | 法国一般不用，优先用 BT-8；与 BT-8 互斥 | `cbc:TaxPointDate` |
| BT-8 | VAT 纳税义务发生日代码 | CM | 与开票日不同时必填；与 BT-7 互斥。值：3=开票日、35=交付日、432=已付日 | `cac:InvoicePeriod/cbc:DescriptionCode` |
| BT-9 | 付款到期日 | CM | 适用时必填 | `cbc:DueDate` |
| BT-10 | 买方参考 | O | 买方参考（your reference） | `cbc:BuyerReference` |
| BT-11 | 项目参考 | O | — | `cac:ProjectReference/cbc:ID` |
| BT-12 | 合同参考 | CM | **发票类型码=262（全局折扣贷项）时必填** | `cac:ContractDocumentReference/cbc:ID` |
| BT-13 | 采购订单参考 | CM | 买方事先建立了采购订单时填 | `cac:OrderReference/cbc:ID` |
| BT-14 | 销售订单参考 | O | 卖方开具 | `cac:OrderReference/cbc:SalesOrderID` |
| BT-15 | 收货通知参考 | O | — | `cac:ReceiptDocumentReference/cbc:ID` |
| BT-16 | 发货通知参考 | O | — | `cac:DespatchDocumentReference/cbc:ID` |
| BT-17 | 招标/标段参考 | O | — | `cac:OriginatorDocumentReference/cbc:ID` |
| BT-18 | 被开票对象标识 | O | 用于 UC5 目录参考（`DocumentTypeCode='50'`） | `cac:AdditionalDocumentReference/cbc:ID` |
| BT-19 | 买方会计参考 | O | 记账数据入账位置 | `cbc:AccountingCost` |
| BT-20 | 付款条款 | CM | 付款条款文本描述（含罚则） | `cac:PaymentTerms/cbc:Note` |
| BT-73 | 计费周期开始日 | CM | **发票类型码=262 时必填** | `cac:InvoicePeriod/cbc:StartDate` |
| BT-74 | 计费周期结束日 | CM | **发票类型码=262 时必填** | `cac:InvoicePeriod/cbc:EndDate` |
| BT-21 | 发票备注主题码 | **M** | 见 §0.3；`cbc:Note` 前缀 `#码#` | `cbc:Note` |
| BT-22 | 发票备注 | **M** | 非结构化文本信息 | `cbc:Note` |

> **法国强制备注（BT-21/BT-22）**：至少必须携带 `BAR`（处理类型：B2B/B2BINT/B2C/OUTOFSCOPE/ARCHIVEONLY）、`AAB`（提前付款折扣）、`PMD`（逾期罚金）、`PMT`（€40 催收费）四类。写法示例：`<cbc:Note>#BAR#B2B</cbc:Note>`。

---

### 2. 更正/贷项场景引用段（BG-3，条件必填段）

**何时出现**：贷项通知单 / 更正发票场景（CM 段）。

| BT | 字段 | 必填 | 填入条件 / 填值要求 | PUF 路径 |
|----|------|------|--------------------|----------|
| BT-25 | 前序发票参考 | **M** | 贷项/借项场景必填 | `cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID` |
| EXT-FR-FE-02 | 前序发票类型 | O | 取自 UNTDID 1001（扩展字段，见 [[FR_EXTENSIONS]]） | `.../cbc:DocumentTypeCode` |
| BT-26 | 前序发票开具日期 | CM | 贷项/借项场景必填 | `.../cbc:IssueDate` |

---

### 3. 卖方信息（BG-4，必填段）

| BT | 字段 | 必填 | 填入条件 / 填值要求 | PUF 路径 |
|----|------|------|--------------------|----------|
| BT-27 | 卖方名称 | **M** | 完整法定名称 | `cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName` |
| BT-28 | 卖方商号 | O | 别于法定名称的经营名称 | `.../cac:PartyName/cbc:Name` |
| BT-29 | SIRET | CM | 卖方 SIRET，`@schemeID='0009'`（14 位） | `.../cac:PartyIdentification/cbc:ID[@schemeID='0009']` |
| BT-30 | SIREN | **M** | 卖方 SIREN，`@schemeID='0002'`（9 位） | `.../cac:PartyLegalEntity/cbc:CompanyID[@schemeID='0002']` |
| BT-31 | 卖方 VAT 号 | CM | 卖方 VAT 标识 | `.../cac:PartyTaxScheme[.../cbc:ID='VAT']/cbc:CompanyID` |
| BT-34 | 卖方电子地址 | CM | 可在 Pagero Online 设置；UC17、UC19（状态路由至卖方/开票代理）必填，UC11 仅自开票变体 | `cac:AccountingSupplierParty/cac:Party/cbc:EndpointID` |

#### 3.1 卖方地址（BG-5，必填段 — 完整地址法律强制）

| BT | 字段 | 必填 | 填值要求 | PUF 路径 |
|----|------|------|---------|----------|
| BT-35 | 卖方街道 | **M** | 街道名+门牌 | `.../cac:PostalAddress/cbc:StreetName` |
| BT-37 | 卖方城市 | **M** | — | `.../cbc:CityName` |
| BT-38 | 卖方邮编 | **M** | — | `.../cbc:PostalZone` |
| BT-39 | 卖方国家子区划 | O | 地区/省/州等 | `.../cbc:CountrySubentity` |
| BT-40 | 卖方国家码 | **M** | 国家代码 | `.../cac:Country/cbc:IdentificationCode` |

#### 3.2 卖方联系人（BG-6，可选段）

| BT | 字段 | 必填 | PUF 路径 |
|----|------|------|----------|
| BT-41 | 卖方联系点 | O | `.../cac:Contact/cbc:Name` |
| BT-42 | 卖方电话 | O | `.../cac:Contact/cbc:Telephone` |
| BT-43 | 卖方邮箱 | O | `.../cac:Contact/cbc:ElectronicMail` |

#### 3.3 税务代表方（BG-11 / BG-12，条件必填 — 用于 UC38/UC39）

| BT | 字段 | 必填 | 填入条件 | PUF 路径 |
|----|------|------|---------|----------|
| BT-62 | 税务代表名称 | **M** | 存在税务代表时段内必填 | `cac:TaxRepresentativeParty/cac:PartyName/cbc:Name` |
| BT-63 | 税务代表 VAT 号 | **M** | 同上 | `.../cac:PartyTaxScheme[.../cbc:ID='VAT']/cbc:CompanyID` |
| BT-64 | 税务代表街道 | CM | 段被填充时必填 | `.../cac:PostalAddress/cbc:StreetName` |
| BT-66 | 税务代表城市 | CM | 同上 | `.../cbc:CityName` |
| BT-67 | 税务代表邮编 | CM | 同上 | `.../cbc:PostalZone` |
| BT-68 | 税务代表国家子区划 | O | — | `.../cbc:CountrySubentity` |
| BT-69 | 税务代表国家码 | **M** | — | `.../cac:Country/cbc:IdentificationCode` |

> 卖方代理方（Seller Agent，`EXT-FR-FE-BG-03`）、开票方（Invoicer，`EXT-FR-FE-BG-05`）为法国扩展 Party，详见 [[FR_EXTENSIONS]]。

---

### 4. 买方信息（BG-7，必填段）

| BT | 字段 | 必填 | 填入条件 / 填值要求 | PUF 路径 |
|----|------|------|--------------------|----------|
| BT-44 | 买方名称 | **M** | 完整法定名称 | `cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName` |
| BT-45 | 买方商号 | O | — | `.../cac:PartyName/cbc:Name` |
| BT-46 | SIRET | CM | 买方 SIRET，`@schemeID='0009'`，建议提供 | `.../cac:PartyIdentification/cbc:ID[@schemeID='0009']` |
| BT-47 | SIREN | **M** | 买方 SIREN，`@schemeID='0002'` | `.../cac:PartyLegalEntity/cbc:CompanyID[@schemeID='0002']` |
| BT-48 | 买方 VAT 号 | CM | 买方 VAT 标识 | `.../cac:PartyTaxScheme[.../cbc:ID='VAT']/cbc:CompanyID` |
| BT-49 | 买方电子地址 | O | Pagero 可用其他 ID 路由；需精确指定端点时填。**是法国 e-invoicing 路由的推荐机制（SIRENacheteur_SERVICECODE 模式）** | `cac:AccountingCustomerParty/cac:Party/cbc:EndpointID` |
| —(N/A) | 收件人唯一标识（客户号） | O | 可用于 Pagero Online 路由 | `cac:AccountingCustomerParty/cbc:SupplierAssignedAccountID` |

#### 4.1 买方地址（BG-8，必填段 — 完整地址法律强制）

| BT | 字段 | 必填 | PUF 路径 |
|----|------|------|----------|
| BT-50 | 买方街道 | **M** | `.../cac:PostalAddress/cbc:StreetName` |
| BT-52 | 买方城市 | **M** | `.../cbc:CityName` |
| BT-53 | 买方邮编 | **M** | `.../cbc:PostalZone` |
| BT-54 | 买方国家子区划 | O | `.../cbc:CountrySubentity` |
| BT-55 | 买方国家码 | **M** | `.../cac:Country/cbc:IdentificationCode` |

#### 4.2 买方联系人（BG-9，可选段）

| BT | 字段 | 必填 | PUF 路径 |
|----|------|------|----------|
| BT-56 | 买方联系点 | O | `.../cac:Contact/cbc:Name` |
| BT-57 | 买方电话 | O | `.../cac:Contact/cbc:Telephone` |
| BT-58 | 买方邮箱 | O | `.../cac:Contact/cbc:ElectronicMail` |

> 买方代理方（Buyer Agent，`EXT-FR-FE-BG-01`）、被开票方（Invoicee，`EXT-FR-FE-BG-04`）为法国扩展 Party，详见 [[FR_EXTENSIONS]]。

---

### 5. 交付信息（BG-13，条件必填段）

**何时出现**：货物运至不同于买方的收货人/地址时。

| BT | 字段 | 必填 | 填入条件 / 填值要求 | PUF 路径 |
|----|------|------|--------------------|----------|
| BT-70 | 收货方名称 | O | — | `cac:Delivery/cac:DeliveryParty/cac:PartyName/cbc:Name` |
| BT-71 | 收货地点标识 | O | — | `cac:Delivery/cac:DeliveryLocation/cbc:ID` |
| BT-72 | 实际交付日期 | CM | 交付/服务完成日已确定且与开票日不同时必填（CGI art. 242 nonies A 10°，G1.38/G1.39）；**2026-09-01 起强制（G6.11）** | `cac:Delivery/cbc:ActualDeliveryDate` |

#### 5.1 交付条款（EXT-FR-FE-BG-14，INCOTERMS，可选段 — 扩展）

| 字段 | 必填 | 填值要求 | PUF 路径 |
|------|------|---------|----------|
| 交付条款码（EXT-FR-FE-185） | O | UNTDID 4053 + INCOTERMS：1、2、CFR、CIF、CIP、CPT、DAP、DAT、DDP、EXW、FAS、FCA、FOB | `cac:DeliveryTerms/cbc:ID` |
| 交付地点名称（EXT-FR-FE-186） | O | 港口、交付地等 | `cac:Delivery/cac:DeliveryLocation/cbc:Name` |

#### 5.2 收货地址（BG-15，条件必填段）

| BT | 字段 | 必填 | PUF 路径 |
|----|------|------|----------|
| BT-75 | 收货街道 | **M** | `cac:Delivery/cac:DeliveryLocation/cac:Address/cbc:StreetName` |
| BT-77 | 收货城市 | **M** | `.../cbc:CityName` |
| BT-78 | 收货邮编 | **M** | `.../cbc:PostalZone` |
| BT-79 | 收货国家子区划 | CM | `.../cbc:CountrySubentity` |
| BT-80 | 收货国家码 | **M** | `.../cac:Country/cbc:IdentificationCode` |

---

### 6. 收款方信息（BG-10，可选段）

**何时出现**：收款方非卖方时（如保理服务）。

| BT | 字段 | 必填 | 填入条件 / 填值要求 | PUF 路径 |
|----|------|------|--------------------|----------|
| BT-59 | 收款方名称 | CM | 段被填充时必填 | `cac:PayeeParty/cac:PartyName/cbc:Name` |
| BT-60 | 收款方标识 | CM | 如 SIRET，`@schemeID='0009'` | `cac:PayeeParty/cac:PartyIdentification/cbc:ID[@schemeID='0009']` |
| BT-61 | 收款方法定注册标识 | O | SIREN | `cac:PayeeParty/cac:PartyLegalEntity/cbc:CompanyID[@schemeID='0002']` |

> 收款方 VAT、Party 类型指示、收款方电子地址（`EXT-FR-FE-27/26/29`）为法国扩展，详见 [[FR_EXTENSIONS]]。付款方（Payer，`EXT-FR-FE-BG-02`）亦为扩展 Party。

---

### 7. 付款指令（BG-16，条件必填段）

| BT | 字段 | 必填 | 填入条件 / 填值要求 | PUF 路径 |
|----|------|------|--------------------|----------|
| BT-81 | 付款方式类型码 | **M** | 结算方式代码 | `cac:PaymentMeans/cbc:PaymentMeansCode` |
| BT-84 | 付款账户标识 | **M** | 收款金融账户唯一标识（IBAN 等） | `cac:PaymentMeans/cac:PayeeFinancialAccount/cbc:ID` |
| BT-86 | SWIFT/BIC | O | 付款服务商标识 | `.../cac:FinancialInstitutionBranch/cbc:ID` |
| BT-85 | 付款账户名称 | CM | UC08、UC10 必填 | `.../cac:PayeeFinancialAccount/cbc:Name` |

#### 7.1 卡支付明细（BG-18，条件必填 — 用于 UC07）

| BT | 字段 | 必填 | 填入条件 | PUF 路径 |
|----|------|------|---------|----------|
| BT-87 | 卡主账号（PAN） | **M** | UC07 卡支付时必填 | `cac:PaymentMeans/cac:CardAccount/cbc:PrimaryAccountNumberID` |
| BT-87-1 | 卡网络标识 | **M** | 存在 BG-18 卡支付时作为 UBL 结构强制子元素 | `.../cac:CardAccount/cbc:NetworkID` |
| BT-88 | 持卡人姓名 | O | — | `.../cac:CardAccount/cbc:HolderName` |

---

### 8. 单据级折扣与费用

#### 8.1 单据级折扣（BG-20，条件必填 — 适用时）

| BT | 字段 | 必填 | 填入条件 / 填值要求 | PUF 路径 |
|----|------|------|--------------------|----------|
| BT-92 | 折扣金额（不含税） | **M** | 段被填充时必填 | `cac:AllowanceCharge[cbc:ChargeIndicator='false']/cbc:Amount` |
| BT-93 | 折扣基数 | O | 与百分比配合计算 | `.../cbc:BaseAmount` |
| BT-94 | 折扣百分比 | O | 与基数配合计算 | `.../cbc:MultiplierFactorNumeric` |
| BT-95 | 折扣 VAT 类别码 | **M** | UNTDID 5305 | `.../cac:TaxCategory/cbc:ID` |
| BT-96 | 折扣 VAT 税率 | CM | 适用时 | `.../cac:TaxCategory/cbc:Percent` |
| BT-97 | 折扣原因（文本） | CM | **BR-33：BT-97 或 BT-98 二选一必填** | `.../cbc:AllowanceChargeReason` |
| BT-98 | 折扣原因码 | CM | **BR-33：同上** | `.../cbc:AllowanceChargeReasonCode` |

#### 8.2 单据级费用（BG-21，条件必填 — 适用时）

| BT | 字段 | 必填 | 填入条件 / 填值要求 | PUF 路径 |
|----|------|------|--------------------|----------|
| BT-99 | 费用金额（不含税） | **M** | 段被填充时必填 | `cac:AllowanceCharge[cbc:ChargeIndicator='true']/cbc:Amount` |
| BT-100 | 费用基数 | O | — | `.../cbc:BaseAmount` |
| BT-101 | 费用百分比 | O | — | `.../cbc:MultiplierFactorNumeric` |
| BT-102 | 费用 VAT 类别码 | **M** | UNTDID 5305 | `.../cac:TaxCategory/cbc:ID` |
| BT-103 | 费用 VAT 税率 | CM | 适用时 | `.../cac:TaxCategory/cbc:Percent` |
| BT-104 | 费用原因（文本） | CM | **BR-38：BT-104 或 BT-105 二选一必填** | `.../cbc:AllowanceChargeReason` |
| BT-105 | 费用原因码 | CM | **BR-38：同上** | `.../cbc:AllowanceChargeReasonCode` |

---

### 9. 单据合计金额（BG-22，必填段）

| BT | 字段 | 必填 | 填入条件 / 填值要求 | PUF 路径 |
|----|------|------|--------------------|----------|
| BT-106 | 发票行净额合计 | **M** | 所有行净额之和 | `cac:LegalMonetaryTotal/cbc:LineExtensionAmount` |
| BT-107 | 单据级折扣合计 | CM | 存在单据级折扣时 | `cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount` |
| BT-108 | 单据级费用合计 | CM | 存在单据级费用时 | `cac:LegalMonetaryTotal/cbc:ChargeTotalAmount` |
| BT-109 | 不含税总额 | **M** | — | `cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount` |
| BT-110 | VAT 总额 | **M** | — | `cac:TaxTotal/cbc:TaxAmount` |
| BT-111 | 会计币种 VAT 总额 | CM | **文档币种（BT-5）非 EUR 时必填** | `cac:TaxTotal/cbc:TaxAmount`（`@currencyID`=BT-6） |
| BT-112 | 含税总额 | **M** | — | `cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount` |
| BT-113 | 已付金额 | CM | 预付金额之和 | `cac:LegalMonetaryTotal/cbc:PrepaidAmount` |
| BT-114 | 舍入金额 | CM | 用于凑整应付金额 | `cac:LegalMonetaryTotal/cbc:PayableRoundingAmount` |
| BT-115 | 应付金额 | **M** | 待支付的未结金额 | `cac:LegalMonetaryTotal/cbc:PayableAmount` |

---

### 10. VAT 分解（BG-23，必填段，按税率/税类别）

| BT | 字段 | 必填 | 填入条件 / 填值要求 | PUF 路径 |
|----|------|------|--------------------|----------|
| BT-116 | VAT 类别应税额 | **M** | 同一税类别码+税率下的应税额之和 | `cac:TaxTotal/cac:TaxSubtotal/cbc:TaxableAmount` |
| BT-117 | VAT 类别税额 | **M** | 该税类别的税额 | `.../cbc:TaxAmount` |
| —(N/A) | 会计币种 VAT 类别税额 | O | 以卖方所在国会计币种表达 | `.../ext:UBLExtensions/.../puf:TaxCurrencyTaxAmount` |
| BT-118 | VAT 类别码 | **M** | UNTDID 5305 | `.../cac:TaxCategory/cbc:ID` |
| BT-119 | VAT 类别税率 | **M** | 百分比 | `.../cac:TaxCategory/cbc:Percent` |
| BT-120 | VAT 免税原因文本 | CM | 免税/不计税时必填 | `.../cac:TaxCategory/cbc:TaxExemptionReason` |
| BT-121 | VAT 免税原因码 | CM | 免税/不计税时必填 | `.../cac:TaxCategory/cbc:TaxExemptionReasonCode` |

---

### 11. 发票行（BG-25，必填段，逐行）

| BT | 字段 | 必填 | 填入条件 / 填值要求 | PUF 路径 |
|----|------|------|--------------------|----------|
| BT-126 | 发票行标识 | **M** | 行内唯一；PUF 必填，缺失则用行位置 | `cac:InvoiceLine/cbc:ID` |
| BT-129 | 发票数量 | **M** | 贷项单用 `cbc:CreditedQuantity` | `cac:InvoiceLine/cbc:InvoicedQuantity` |
| EXT-FR-FE-183 | 行备注主题码 | O | 见 §0.3；`cbc:Note` 前缀 `#码#`（扩展） | `cac:InvoiceLine/cbc:Note` |
| BT-127 | 发票行备注 | CM | 主题码置于备注开头 `#码#`；**环保税（DEEE）场景必填** | `cac:InvoiceLine/cbc:Note` |
| BT-128 | 发票行对象标识 | O | `@schemeID` 取 UNTDID 1153（ON/VN/DQ/CR）；EXTENDED-CTC-FR 允许 0..n | `cac:InvoiceLine/cac:DocumentReference/cbc:ID` |
| BT-130 | 数量计量单位码 | **M** | — | `cac:InvoiceLine/cbc:InvoicedQuantity/@unitCode` |
| BT-131 | 发票行净额 | **M** | — | `cac:InvoiceLine/cbc:LineExtensionAmount` |
| BT-133 | 成本中心 | O | — | `cac:InvoiceLine/cbc:AccountingCost` |

> 行级前序单据引用（`EXT-FR-FE-BG-06`，UC20 场景）、发货通知引用（`EXT-FR-FE-BG-07`）、订单明细（`EXT-FR-FE-BG-09`）、行级交付信息与地址（`EXT-FR-FE-BG-10`）、子行分组/父行（`EXT-FR-FE-163/162`）均为法国扩展，详见 [[FR_EXTENSIONS]]。BT-132（采购订单行引用，"PO 引用提供时 CM"）也在此段。

#### 11.1 发票行周期（BG-26，条件必填）

| BT | 字段 | 必填 | PUF 路径 |
|----|------|------|----------|
| BT-134 | 行周期开始日 | CM | `cac:InvoiceLine/cac:InvoicePeriod/cbc:StartDate` |
| BT-135 | 行周期结束日 | CM | `cac:InvoiceLine/cac:InvoicePeriod/cbc:EndDate` |

#### 11.2 发票行折扣（BG-27，条件必填 — 适用时）

| BT | 字段 | 必填 | 填入条件 | PUF 路径 |
|----|------|------|---------|----------|
| BT-136 | 行折扣金额 | **M** | 段被填充时 | `cac:InvoiceLine/cac:AllowanceCharge[cbc:ChargeIndicator='false']/cbc:Amount` |
| BT-137 | 行折扣基数 | O | — | `.../cbc:BaseAmount` |
| BT-138 | 行折扣百分比 | O | — | `.../cbc:MultiplierFactorNumeric` |
| BT-139 | 行折扣原因（文本） | CM | **BR-42：BT-139 或 BT-140 二选一** | `.../cbc:AllowanceChargeReason` |
| BT-140 | 行折扣原因码 | CM | **BR-42：同上** | `.../cbc:AllowanceChargeReasonCode` |

#### 11.3 发票行费用（BG-28，条件必填 — 适用时）

| BT | 字段 | 必填 | 填入条件 | PUF 路径 |
|----|------|------|---------|----------|
| BT-141 | 行费用金额 | **M** | 段被填充时 | `cac:InvoiceLine/cac:AllowanceCharge[cbc:ChargeIndicator='true']/cbc:Amount` |
| BT-142 | 行费用基数 | O | — | `.../cbc:BaseAmount` |
| BT-143 | 行费用百分比 | O | — | `.../cbc:MultiplierFactorNumeric` |
| BT-144 | 行费用原因（文本） | CM | **BR-44：BT-144 或 BT-145 二选一** | `.../cbc:AllowanceChargeReason` |
| BT-145 | 行费用原因码 | CM | **BR-44：同上** | `.../cbc:AllowanceChargeReasonCode` |

#### 11.4 价格明细（BG-29，必填段）

| BT | 字段 | 必填 | 填入条件 / 填值要求 | PUF 路径 |
|----|------|------|--------------------|----------|
| BT-146 | 商品净单价 | **M** | 单个单位价格 | `cac:InvoiceLine/cac:Price/cbc:PriceAmount` |
| BT-147 | 商品价格折扣 | CM | 仅当按单位提供折扣、且未含在毛单价中 | `.../cac:Price/cac:AllowanceCharge[cbc:ChargeIndicator='false']/cbc:Amount` |
| BT-148 | 商品毛单价 | CM | 扣减折扣前的不含税单价 | `.../cac:Price/cac:AllowanceCharge[cbc:ChargeIndicator='false']/cbc:BaseAmount` |

#### 11.5 行税信息（BG-30，必填段）

| BT | 字段 | 必填 | 填入条件 / 填值要求 | PUF 路径 |
|----|------|------|--------------------|----------|
| BT-151 | 项目 VAT 类别码 | **M** | UNTDID 5305 | `cac:InvoiceLine/cac:TaxTotal/cac:TaxSubtotal/cac:TaxCategory/cbc:ID` |
| BT-152 | 项目 VAT 税率 | CM | 适用时 | `.../cac:TaxCategory/cbc:Percent` |

#### 11.6 商品信息（BG-31，必填段）

| BT | 字段 | 必填 | 填入条件 / 填值要求 | PUF 路径 |
|----|------|------|--------------------|----------|
| BT-153 | 商品名称 | **M** | — | `cac:InvoiceLine/cac:Item/cbc:Name` |
| BT-154 | 商品描述 | O | 比名称更详细的描述 | `.../cbc:Description` |
| BT-155 | 卖方商品标识 | O | — | `.../cac:SellersItemIdentification/cbc:ID` |
| BT-156 | 买方商品标识 | O | — | `.../cac:BuyersItemIdentification/cbc:ID` |
| BT-157 | 标准商品标识 | O | 注册方案标识 | `.../cac:StandardItemIdentification/cbc:ID` |
| BT-158 | 商品分类标识 | O | 如 CPV、UNSPSC，须带方案标识 BT-158-1 | `.../cac:CommodityClassification/cbc:ItemClassificationCode` |
| BT-158-1 | 商品分类方案标识 | CM | **BT-158 提供时必填**，取 UNTDID 7143 | `.../cbc:ItemClassificationCode/@listID` |
| BT-159 | 商品原产国 | O | — | `.../cac:OriginCountry/cbc:IdentificationCode` |

> 每父行单位数量（`EXT-FR-FE-191`，复合商品组成）为法国扩展。

#### 11.7 商品属性（BG-32，可选段）

| BT | 字段 | 必填 | 填入条件 / 填值要求 | PUF 路径 |
|----|------|------|--------------------|----------|
| BT-160 | 属性名称 | **M** | 段被填充时必填；EXTENDED-CTC-FR 可为码。例：Colour | `.../cac:AdditionalItemProperty/cbc:Name` |
| BT-161 | 属性值 | **M** | **与测量值（EXT-FR-FE-160）二选一必填**。例：Red | `.../cac:AdditionalItemProperty/cbc:Value` |

> 属性码（`EXT-FR-FE-159`，UNTDID 6313）、属性测量值及其单位（`EXT-FR-FE-160/161`，如 25 kg CO2）为法国扩展，详见 [[FR_EXTENSIONS]]。

---

### 12. 典型场景填写要点

| 场景 | 关键字段组合 |
|------|-------------|
| **标准 B2B 货物发票** | BT-3=380、BT-23=B1、BT-21/22 携带 BAR=B2B + AAB + PMD + PMT；卖买双方 SIREN(BT-30/47) 必填 |
| **服务发票** | BT-23=S1；如服务完成日与开票日不同 → BT-72 实际交付日 |
| **贷项通知单** | BT-3=381、UBL 类型 CreditNote；BG-3 段 BT-25/26 引用前序发票;行数量用 `cbc:CreditedQuantity` |
| **全局折扣贷项（262）** | BT-3=262 → **BT-12 合同参考 + BT-73/74 计费周期 强制必填** |
| **更正发票** | BT-3=384（或自开票 471）；BG-3 引用被更正发票 |
| **外币发票（非 EUR）** | BT-5≠EUR → **BT-6 会计币种 + 汇率(TaxExchangeRate) + BT-111 会计币种 VAT 总额 必填** |
| **卡支付（UC07）** | BG-18：BT-87 PAN + BT-87-1 网络标识 必填 |
| **异地收货** | BG-13/BG-15：BT-72 实际交付日（条件）+ 收货地址 BT-75/77/78/80 |
| **保理（393/396）** | BG-10 收款方为保理方；备注可加 ACC |
| **免税/零税** | BG-23：BT-118 类别码 + BT-120/121 免税原因（文本或码）必填 |
| **环保税 DEEE** | 备注码 BLU + 行备注 BT-127（含 DEEE 说明）必填 |
| **B2G（Chorus Pro）** | 备注码 ADN；SIRET(0009) 作为主标识强制 |
| **自开票** | BT-3∈{261,389,471,500,501,502}；自开票指示=true |

---

### 13. 变更记录参考（源文件 CHANGELOG 摘要）

- **v1.30（2026-06-12）**：BT-1 发票号最大长度回退至 20 字符（35 字符扩展计划推迟至约 2026-12）。
- **v1.28**：新增 BT-128 发票行对象标识（EXTENDED-CTC-FR 下 0..n 可重复）。
- **v1.27**：BT-72 实际交付日条件更正 —— 交付/服务完成日与开票日不同时必填，2026-09-01 起强制（G6.11）；BT-88 持卡人姓名改为可选。
- **v1.23**：新增单据类型 262；BT-12/BT-73/BT-74 增加"类型码=262 时必填"条件。
- **v1.20**：BT-20 付款条款 M → CM。

> 完整变更历史见源文件 `src/test/resources/report/pagero/fr/Best_practice_content_France_v1.30.xlsx`（`About` 表 CHANGELOG）。
