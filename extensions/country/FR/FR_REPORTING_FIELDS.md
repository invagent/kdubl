## 法国 (FR) 电子上报字段填写指南（e-reporting）

> 来源：
> - Pagero《Best Practice Content — France, Reporting Invoice》**v1.18**（2026-06-12），`Invoice Reporting` 表 —— 覆盖 **Flux 10.1**（B2B 国际发票上报）、**B2C 发票上报**、**Flux 10.3**（B2C 交易/POS 汇总上报）。
> - Pagero《Best Practice Content — France, Reporting Payment》**v1.2**（2026-04-15），`Payment Reporting` 表 —— 覆盖 **Flux 10.2**（B2B 发票付款上报）、**Flux 10.4**（B2C 收据/交易付款上报）。
>
> 本文档描述**上报（e-reporting）场景**下各字段的**是否必填 / 填入条件 / 填值要求 / PUF 路径**。上报与开票（e-invoicing）不是同一件事:
>
> | 文档 | 覆盖场景 | 承载结构 |
> |------|---------|---------|
> | [[FR_STANDARD_FIELDS]] | e-invoicing（境内 B2B 开票，Flux 1 clearance） | `Invoice` |
> | **本文档 §1–§3（发票/交易上报）** | Flux 10.1 / B2C 发票 / Flux 10.3 交易 | `Invoice`（同 UBL 结构，字段义务不同） |
> | **本文档 §4（付款上报）** | Flux 10.2 / 10.4 | **`TaxReport`**（独立根元素，非 Invoice） |
> | [[FR_EXTENSIONS]] | 上报元数据扩展字段与 KDUBL TaxReport 定义 | 两者 |

### 关键结论:上报的 XML 长什么样

- **发票上报 / 交易上报（Flux 10.1 / 10.3）走 `Invoice` 结构**，与 e-invoicing 发票同一套 UBL 语法。区别只在**字段义务**（哪些必填/NA）和**上报元数据**（`Entry type`、`Report period` 等，放在 PUF `RestrictedInformation` 扩展块，见 §1.1）。
- **付款上报（Flux 10.2 / 10.4）走 `TaxReport` 结构**，根元素 `TaxReport`，与 `Invoice` 完全不同（见 §4）。
- Pagero 负责把逐张 PUF `Invoice` 聚合成传输给 PPF 的 Flux 10 格式；B2C 建议以 `RECEIPTTRANSACTION` 按日+类别（TLB1/TPS1 等）分组上报。

### 三种上报义务列（发票/交易上报）

源表把义务拆成三列，对应三种上报口径:

| 列 | 口径 | Entry type | Transaction type | 典型场景 |
|----|------|-----------|------------------|---------|
| **B2B** | B2B 国际发票上报（Flux 10.1） | INVOICE | B2B（默认） | 跨境 B2B 发票（销项 B2Bi / 进项 Bi2B） |
| **B2C** | B2C 发票上报 | INVOICE | B2C | 逐张 B2C 发票 |
| **TX** | B2C 交易/POS 汇总上报（Flux 10.3） | RECEIPTTRANSACTION | B2C | 按日汇总的现金销售/POS |

> **M**=必填 **CM**=条件必填 **O**=可选 **NA**=不适用（该口径下不使用）。
> 下文每字段用 `B2B / B2C / TX` 三段义务表示。

---

### 0. 上报专用代码表

#### 0.1 单据类型码（BT-3，发票上报，`cbc:InvoiceTypeCode`）

上报侧支持的类型（与开票略有差异，503 仍在评估中，无 262）:

| 码 | 名称 | UBL 类型 | 自开票 |
|----|------|---------|-------|
| 380 | 发票 | Invoice | 否 |
| 381 | 贷项通知单（仅 UBL CreditNote 内） | CreditNote | 否 |
| 384 | 更正发票 | Invoice | 否 |
| 386 | 预付款发票 | Invoice | 否 |
| 261/389/471/500/501/502 | 自开票各类型 | Invoice/CreditNote | 是 |
| 393/396/472/473 | 保理各类型 | Invoice/CreditNote | 否/是 |

> UBL CreditNote 对应元素为 `cbc:CreditNoteTypeCode`；自开票通过 Self-billing 指示表达。

#### 0.2 备注主题码（Text Codes，上报侧仅 3 个，见 §1.3）

上报最佳实践只保留 **AAB**（提前付款折扣）、**TXD**（单一应税主体成员，文本 "Membre d'un assujetti unique"）、**BLU**（环保参与费/DEEE）。

#### 0.3 Party 标识方案（上报侧，`@schemeID`）

> **注意:上报侧不接受 SIRET(0009)** 作为 party 标识（v1.16 起移除），销/进项方默认用 **SIREN(0002)**。

| 方案码 | 说明 | 长度 |
|--------|------|------|
| 0002 | SIREN（法国法人号，默认） | 9 位数字 |
| 0223 | UE_HORS_FRANCE（欧盟内 VAT 号） | ≤18 |
| 0227 | HORS_UE（非欧盟标识） | ≤18 |
| 0228 | RIDET（新喀里多尼亚） | 9–10 |
| 0229 | TAHITI（法属波利尼西亚） | 9 |

#### 0.4 交易类别码（TT-81，行级，B2C/交易上报，`puf:RestrictedInformation[Key='CategoryCode']`）

| 码 | 含义 |
|----|------|
| TLB1 | 应缴 VAT 的货物供应 |
| TPS1 | 应缴 VAT 的服务供应 |
| TNT1 | 在法国不缴 VAT 的货物和服务供应 |
| TMA1 | 适用 VAT 差额（margin）方案的交易 |

#### 0.5 纳税义务发生日代码（BT-8 / TT-24，`cbc:DescriptionCode`）

| 码 | 含义 |
|----|------|
| 3 | 发票开具日期（UBL；CII 用 5） |
| 35 | 实际交付日期 |
| 432 | 已付日期 |

> 仅当卖方选择"按借记计税"（TVA sur les débits）时以码 3 表示，才必填。

---

## 第一部分:发票 / 交易上报（Flux 10.1 / 10.3，`Invoice` 结构）

### 1. 单据级字段

#### 1.1 上报元数据（PUF `RestrictedInformation` 扩展，上报特有）

这些是**上报专有**的控制字段，e-invoicing 侧没有。在 KDUBL 中通过 `cac:AdditionalDocumentReference` 承载（见 [[FR_EXTENSIONS]] §3–§8），在 PUF 中落在 `ext:UBLExtensions/.../puf:RestrictedInformation[puf:Key=...]/puf:Value`。

| TT | 字段 | B2B / B2C / TX | 填入条件 / 填值 | PUF Key |
|----|------|----------------|----------------|---------|
| TT-1 | 发票人报告 ID | O / O / O | 发票人自定义报告 ID（勿与 Pagero 聚合报告 ID 混淆） | `issuerAssignedReportId` |
| TT-4 | 报送传输类型 | CM / CM / CM | **仅 `RECTIFICATION`（更正）时必填** | `transmissionType` |
| TT-17 | 报告周期开始日 | CM / CM / CM | Flux 10 传输级必填;单张 PUF 强烈建议，跨多日期时必填（否则 Pagero 聚合时推断） | `reportPeriodStart` |
| TT-18 | 报告周期结束日 | CM / CM / CM | 同上 | `reportPeriodEnd` |
| N/A | 分类标识（销/进项） | **M / M / M** | 见下（写入 `cbc:ProfileID`，非 BT-23） | `cbc:ProfileID` |
| TT-29 | 归档类型（Entry type） | O / O / **M** | INVOICE / RECEIPTTRANSACTION;缺省 INVOICE。**交易汇总(TX)必填 RECEIPTTRANSACTION** | `entryType` |
| N/A | 交易类型（Transaction type） | O / **M** / **M** | B2B / B2C;缺省 B2B | `transactionType` |

**分类标识（ProfileID，销项/进项）** —— 写入 `Invoice/cbc:ProfileID`，是 Pagero 特有分类（非 EN 16931 BT-23）:

| 值 | 方向 |
|----|------|
| `urn:pagero.com:puf:billing:1.0` | 销项发票 / POS |
| `urn:pagero.com:puf:purchase:1.0` | 进项发票 |

> KDUBL 侧对应 `urn:piaozone.com:profile:bill:v1.0`（销项）/ `urn:piaozone.com:profile:payable:v1.0`（进项），见 [[FR_STANDARD_FIELDS]] §1 与 [[FR_EXTENSIONS]] §1。

#### 1.2 基础字段

| BT | 字段 | B2B / B2C / TX | 填入条件 / 填值 | PUF 路径 |
|----|------|----------------|----------------|---------|
| BT-1 | 单据号 | M / M / M | ≤20 字符（约 2026-12 起 35）。B2C/交易法国规范不强制，但 PUF schema 必填 | `cbc:ID` |
| BT-2 | 开具日期 | M / M / M | B2C/交易法国规范不强制，PUF schema 必填 | `cbc:IssueDate` |
| BT-3 | 单据类型 | M / CM / **NA** | 见 §0.1;贷项 CreditNote 用 `cbc:CreditNoteTypeCode` | `cbc:InvoiceTypeCode` |
| N/A | 自开票指示 | CM / NA / NA | 自开票时 `true` | `.../puf:SelfBilled` |
| BT-23 | 业务流程 | M / CM / **NA** | 见 [[FR_STANDARD_FIELDS]] §0.1 业务流程码 | `cbc:InvoiceTypeCode/@name` |
| BT-5 | 单据币种 | M / M / M | **B2C/交易必须 EUR**;B2B 任意币种，非 EUR 则 BT-6 必填 | `cbc:DocumentCurrencyCode` |
| BT-6 | 税币种 | CM / NA / NA | **文档币种非 EUR 时必填** | `cbc:TaxCurrencyCode` |
| BT-7 | 纳税义务发生日 | **NA / NA / NA** | Flux 10 不用，仅用 BT-8 码;与 BT-8 互斥（BR-CO-3） | `cbc:TaxPointDate` |
| BT-8 | 纳税义务发生日代码 | CM / CM / **NA** | 仅"按借记计税"时以码 3 表示才必填 | `cac:InvoicePeriod/cbc:DescriptionCode` |
| BT-9 | 付款到期日 | CM / O / **NA** | 应付额(BT-115)为正时，BT-9 或 BT-20 须其一 | `cbc:DueDate` |
| BT-73 | 发票周期开始日 | CM / O / **NA** | 用则起止都要 | `cac:InvoicePeriod/cbc:StartDate` |
| BT-74 | 发票周期结束日 | CM / O / **NA** | 用则起止都要 | `cac:InvoicePeriod/cbc:EndDate` |

#### 1.3 备注（BG-1，`cbc:Note`，格式 `#码#文本`）

| BT | 字段 | B2B / B2C / TX | 填入条件 / 填值 |
|----|------|----------------|----------------|
| BT-21 | 备注主题码 | CM / O / **NA** | 见 §0.2;`cbc:Note` 前缀 `#码#` |
| BT-22 | 备注文本 | CM / O / **NA** | 适用受监管备注时必填:AAB（escompte）、TXD（单一应税主体）、BLU（环保/DEEE）。**B2C 不要求** |

> 示例:`<cbc:Note>#AAB#Les réglements reçus avant la date d'échéance ne donneront pas lieu à escompte.</cbc:Note>`
>
> **与开票的重要差异**:e-invoicing 侧 BAR/AAB/PMD/PMT 四码强制（见 [[FR_STANDARD_FIELDS]] §0.3、§1）;**上报侧 `cbc:Note` 只在受监管备注适用时按 CM 携带（AAB/TXD/BLU），且 B2C 不要求**。上报最佳实践表未列 BAR/PMD/PMT 为上报必填。

#### 1.4 更正/贷项引用（BG-3，条件必填段）

| BT | 字段 | B2B / B2C / TX | 填入条件 | PUF 路径 |
|----|------|----------------|---------|---------|
| BT-25 | 前序单据号 | CM / CM / **NA** | 贷项场景必填 | `cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID` |
| BT-26 | 前序单据开具日期 | CM / CM / **NA** | 使用 BG-3 时必填 | `.../cbc:IssueDate` |

### 2. 交易方与地址

#### 2.1 卖方（BG-4 / BG-5）

| BT | 字段 | B2B / B2C / TX | 填入条件 / 填值 | PUF 路径 |
|----|------|----------------|----------------|---------|
| BT-27 | 名称 | O / O / O | 法定名称 | `cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName` |
| BT-28 | 商号 | O / O / O | — | `.../cac:PartyName/cbc:Name` |
| BT-30 | 卖方标识 | **M / M / M** | 销项/交易用 **SIREN(0002)**，见 §0.3 | `.../cac:PartyLegalEntity/cbc:CompanyID[@schemeID=...]` |
| BT-31 | VAT 号 | CM / O / O | 卖方标识为 SIREN(0002)/欧盟 VAT(0223)，或 VAT 分解含免税(E)类别时必填 | `.../cac:PartyTaxScheme[.../cbc:ID='VAT']/cbc:CompanyID` |
| BT-40 | 卖方国家码 | **M / M / M** | 地址段(BG-5)必填 | `.../cac:PostalAddress/cac:Country/cbc:IdentificationCode` |

#### 2.2 买方（BG-7 / BG-8）

| BT | 字段 | B2B / B2C / TX | 填入条件 / 填值 | PUF 路径 |
|----|------|----------------|----------------|---------|
| BT-44/45 | 买方名称 | O / O / **NA** | B2C 无真实名称时建议填 "B2C" | `cac:AccountingCustomerParty/.../cbc:Name` 或 `.../PartyLegalEntity/cbc:RegistrationName` |
| BT-47 | 买方标识 | **M** / NA / NA | 进项用 **SIREN(0002)**;Flux 10 仅上报 B2B 国际发票，买方总是可识别 | `.../cac:PartyLegalEntity/cbc:CompanyID[@schemeID=...]` |
| BT-48 | 买方 VAT 号 | CM / NA / NA | 买方标识为 SIREN(0002)/欧盟 VAT(0223) 时必填 | `.../cac:PartyTaxScheme[.../cbc:ID='VAT']/cbc:CompanyID` |
| BG-8 | 买方地址 | CM / O / **NA** | B2B 国际上报法律要求;B2C 不要求 | — |
| BT-55 | 买方国家码 | CM / O / **NA** | 法律发票要件（CGI art. 242 nonies A） | `.../cac:PostalAddress/cac:Country/cbc:IdentificationCode` |

#### 2.3 税务代表（BG-11）

| BT | 字段 | B2B / B2C / TX | 填入条件 | PUF 路径 |
|----|------|----------------|---------|---------|
| BT-63 | 税务代表 VAT 号 | CM / CM / **NA** | 使用税务代表时必填 | `cac:TaxRepresentativeParty/cac:PartyTaxScheme[.../cbc:ID='VAT']/cbc:CompanyID` |

#### 2.4 交付信息与地址（BG-13 / BG-15）

| BT | 字段 | B2B / B2C / TX | 填入条件 / 填值 | PUF 路径 |
|----|------|----------------|----------------|---------|
| BT-72 | 实际交付日期（文档级） | CM / O / **NA** | B2C/交易改用**行级**交付日期（§3.1） | `cac:Delivery/cbc:ActualDeliveryDate` |
| BG-15 | 收货地址 | CM / O / **NA** | — | — |
| BT-75 | 收货街道 | M / O / NA | 段被填充时 | `cac:Delivery/cac:DeliveryLocation/cac:Address/cbc:StreetName` |
| BT-77 | 收货城市 | M / O / NA | — | `.../cbc:CityName` |
| BT-78 | 收货邮编 | M / O / NA | — | `.../cbc:PostalZone` |
| BT-79 | 收货国家子区划 | O / O / NA | — | `.../cbc:CountrySubentity` |
| BT-80 | 收货国家码 | M / O / NA | — | `.../cac:Country/cbc:IdentificationCode` |

### 3. 金额、税与发票行

#### 3.1 单据级折扣/费用（BG-20 / BG-21）

| BT | 字段 | B2B / B2C / TX | 填入条件 | PUF 路径 |
|----|------|----------------|---------|---------|
| BT-92 | 单据级折扣金额 | CM / CM / **NA** | 存在单据级折扣时;B2C 不要求 | `cac:AllowanceCharge[cbc:ChargeIndicator='false']/cbc:Amount` |
| BT-95 | 折扣 VAT 类别码 | CM / CM / NA | 同上 | `.../cac:TaxCategory/cbc:ID` |
| BT-96 | 折扣 VAT 税率 | CM / CM / NA | 类别带税率时 | `.../cac:TaxCategory/cbc:Percent` |
| BT-99 | 单据级费用金额 | CM / CM / **NA** | 存在单据级费用时;B2C 不要求 | `cac:AllowanceCharge[cbc:ChargeIndicator='true']/cbc:Amount` |
| BT-102 | 费用 VAT 类别码 | CM / CM / NA | 同上 | `.../cac:TaxCategory/cbc:ID` |
| BT-103 | 费用 VAT 税率 | CM / CM / NA | 类别带税率时 | `.../cac:TaxCategory/cbc:Percent` |

#### 3.2 单据合计（BG-22）

| BT | 字段 | B2B / B2C / TX | 填入条件 | PUF 路径 |
|----|------|----------------|---------|---------|
| BT-109 | 不含税总额 | M / O / M | — | `cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount` |
| BT-110 | VAT 总额 | M / O / M | — | `cac:TaxTotal/cbc:TaxAmount` |
| BT-111 | 会计币种 VAT 总额 | CM / NA / NA | 文档币种非 EUR 时必填 | `cac:TaxTotal/cbc:TaxAmount`（@currencyID=BT-6） |
| BT-115 | 应付金额 | **M / M / M** | PUF schema 必填 | `cac:LegalMonetaryTotal/cbc:PayableAmount` |

#### 3.3 VAT 分解（BG-23）

| BT | 字段 | B2B / B2C / TX | 填入条件 / 填值 | PUF 路径 |
|----|------|----------------|----------------|---------|
| BT-116 | VAT 类别应税额 | M / O / M | — | `cac:TaxTotal/cac:TaxSubtotal/cbc:TaxableAmount` |
| BT-117 | VAT 类别税额 | M / O / M | — | `.../cbc:TaxAmount` |
| BT-118 | VAT 类别码 | M / O / **NA** | 标准=S，免税=E（PUF-012-TAXCATEGORYCODE） | `.../cac:TaxCategory/cbc:ID` |
| BT-119 | VAT 类别税率 | **M / O / M** | 每个分解行必填（TT-57/TT-86 为 1..1）;免税/反向/零税率填 0 | `.../cac:TaxCategory/cbc:Percent` |
| BT-120 | VAT 免税原因文本 | CM / CM / **NA** | 类别码为免税(E)时必填 | `.../cac:TaxCategory/cbc:TaxExemptionReason` |
| BT-121 | VAT 免税原因码 | CM / CM / **NA** | 类别码为免税(E)时必填，用 EN 16931 VATEX 码 | `.../cac:TaxCategory/cbc:TaxExemptionReasonCode` |

#### 3.4 发票行（BG-25）

> **重要简化:进项（AP / 进口国际采购）上报不要求行级明细** —— 依 DGFiP 简化（spec v3.2 §2.3.3，2025-08-29 部长函），Flux 10.1 所有行级标签对进项国际交易可选。BG-25 及其子段（BG-30 税、BG-27/28 折费、BG-29 价格、BG-31 商品）在进项上报都可省。

| BT | 字段 | B2B / B2C / TX | 填入条件 / 填值 | PUF 路径 |
|----|------|----------------|----------------|---------|
| TT-81 | 交易类别码 | O / CM / **M** | 汇总交易(TX)必填;B2C 发票也须带以便聚合入 Flux 10.3。见 §0.4（TLB1/TPS1/TNT1/TMA1） | `.../puf:RestrictedInformation[Key='CategoryCode']/puf:Value` |
| TT-24 | 纳税义务发生日代码（行级） | O / CM / CM | 仅"按借记计税"以码 3 表示才必填 | `cac:InvoiceLine/cac:InvoicePeriod/cbc:DescriptionCode` |
| BT-126 | 发票行标识 | **M / M / M** | PUF schema 必填 | `cac:InvoiceLine/cbc:ID` |
| BT-129 | 发票数量 | M / O / O | 贷项用 `cbc:CreditedQuantity` | `cac:InvoiceLine/cbc:InvoicedQuantity` |
| BT-130 | 数量单位码 | M / O / O | 贷项用 CreditNote 对应路径 | `.../cbc:InvoicedQuantity/@unitCode` |
| BT-127 | 发票行备注 | CM / O / **NA** | 适用受监管行备注（如 DEEE）时;B2C 不要求 | `cac:InvoiceLine/cbc:Note` |
| TT-61-0 | 行备注主题码 | CM / O / **NA** | 见 §0.2;`cbc:Note` 前缀 `#码#` | `cac:InvoiceLine/cbc:Note` |
| BT-131 | 发票行净额 | **M / M / M** | — | `cac:InvoiceLine/cbc:LineExtensionAmount` |
| N/A | 行级实际交付日期 | O / CM / **M** | B2C/交易表示交易发生日 | `cac:InvoiceLine/cac:Delivery/cbc:ActualDeliveryDate` |

**行级税信息（BG-30，进项可省）:**

| 字段 | B2B / B2C / TX | 填入条件 | PUF 路径 |
|------|----------------|---------|---------|
| 行税额 | O / CM / **M** | 汇总交易及 B2C 发票聚合入 Flux 10.3 时必填;B2B 在文档级带税 | `cac:InvoiceLine/cac:TaxTotal/cbc:TaxAmount` |
| 行税小计-应税额 | O / CM / M | 同上 | `.../cac:TaxSubtotal/cbc:TaxableAmount` |
| 行税小计-税额 | O / CM / M | 同上 | `.../cac:TaxSubtotal/cbc:TaxAmount` |
| 行税小计-税率 | O / CM / M | 同上 | `.../cac:TaxSubtotal/cac:TaxCategory/cbc:Percent` |

**行级折扣/费用（BG-27 / BG-28，进项可省）:** BT-136/141（金额，段内 CM）、BT-139/140、BT-144/145（原因文本或码，各须其一）—— B2B/B2C 为 CM，TX 为 NA。BT-137/138/142/143（基数/百分比）为 O。

**价格明细（BG-29，进项可省）:**

| BT | 字段 | B2B / B2C / TX | 填入条件 | PUF 路径 |
|----|------|----------------|---------|---------|
| BT-146 | 商品净单价 | M / O / **NA** | — | `cac:InvoiceLine/cac:Price/cbc:PriceAmount` |
| BT-147 | 商品价格折扣 | CM / O / NA | 仅按单位折扣且未含在毛价中 | `.../cac:Price/cac:AllowanceCharge[cbc:ChargeIndicator='false']/cbc:Amount` |
| BT-148 | 商品毛单价 | CM / O / NA | 仅当有单位折扣时;无毛价时 Flux 10.1 用净单价填充（BR-FR-MAP-22） | `.../cac:Price/cac:AllowanceCharge[cbc:ChargeIndicator='false']/cbc:BaseAmount` |

**商品信息（BG-31，进项可省）:**

| BT | 字段 | B2B / B2C / TX | 填入条件 | PUF 路径 |
|----|------|----------------|---------|---------|
| BT-153 | 商品名称 | M / O / O | B2C 无真实名称时建议填 "B2C" | `cac:InvoiceLine/cac:Item/cbc:Name` |

---

## 第二部分:付款上报（Flux 10.2 / 10.4，`TaxReport` 结构）

> 付款上报**不用 `Invoice`，用独立根元素 `TaxReport`**。两种子流:
> - **Flux 10.2（B2B）**:逐张发票付款上报，`Payment data type = INVOICE`。
> - **Flux 10.4（B2C）**:收据/交易付款汇总上报，`Payment data type = RECEIPTTRANSACTION`。
>
> KDUBL 侧 `TaxReport` 承载格式定义见 [[FR_EXTENSIONS]] §11。义务列为 `B2B / B2C`。

### 4. TaxReport 字段

#### 4.1 文档级（`TaxReport` 根下）

| TT | 字段 | B2B / B2C | 填入条件 / 填值 | PUF 路径 |
|----|------|-----------|----------------|---------|
| TT-1 | 发票人报告 ID | O / O | 发票人自定义（勿与 Pagero 聚合报告 ID 混淆） | `TaxReport/cbc:ID` |
| TT-3 | 报告开具日期 | CM / CM | PUF 必填 | `TaxReport/cbc:IssueDate` |
| N/A | 分类标识 | CM / CM | 法国付款上报固定 **INCOME**（INCOME/EXPENSE） | `TaxReport/ClassificationIdentifier` |
| TT-4 | 报送传输类型 | CM / CM | **仅 `RECTIFICATION` 时必填** | `TaxReport/Type` |
| TT-89 | 报告周期开始日 | CM / CM | 强烈建议;跨多日期时必填 | `TaxReport/ReportPeriod/cbc:StartDate` |
| TT-90 | 报告周期结束日 | CM / CM | 同上 | `TaxReport/ReportPeriod/cbc:EndDate` |
| TT-13 | 发票人/卖方标识 | **M / M** | SIREN(0002)（也接受 SIRET 0009，ISO 6523） | `TaxReport/cac:IssuerParty/cac:PartyLegalEntity/cbc:CompanyID[@schemeID='0002']` |

#### 4.2 付款级（`TaxReport/Payment`，1..n）

| TT | 字段 | B2B / B2C | 填入条件 / 填值 | PUF 路径 |
|----|------|-----------|----------------|---------|
| TT-94 | 币种 | **M / M** | **必须 EUR** | `TaxReport/Payment/cbc:DocumentCurrencyCode` |
| N/A | 付款数据类型 | **M / M** | INVOICE=Flux 10.2（B2B 逐张）;RECEIPTTRANSACTION=Flux 10.4（B2C 汇总） | `TaxReport/Payment/ReferencedDocument/PaymentDataType` |
| TT-91 | 发票号/标识 | **M** / — | 仅发票付款上报（10.2）适用 | `TaxReport/Payment/ReferencedDocument/cbc:ID` |
| TT-102 | 发票日期 | **M** / — | 仅发票付款上报（10.2）适用 | `TaxReport/Payment/ReferencedDocument/cbc:IssueDate` |
| TT-92 | 收款日期 | **M / M** | 实际收到付款的日期 | `TaxReport/Payment/cbc:PaidDate` |
| TT-95 | 收款额（含税） | **M / M** | 按税率分别列示，须 EUR | `TaxReport/Payment/PaymentTotal/PaymentSubtotal/cbc:TaxInclusiveAmount` |
| TT-93 | 收款额税率 | **M / M** | 按税率分别列示收款额 | `TaxReport/Payment/PaymentTotal/PaymentSubtotal/cbc:Percent` |

---

### 5. 上报场景填写要点

| 场景 | Entry / Transaction | 关键字段 |
|------|---------------------|---------|
| **B2B 国际销项发票（Flux 10.1）** | INVOICE / B2B | 卖买双方 SIREN(BT-30/47) M;买方地址(BG-8)/BT-55 CM;文档级金额+VAT 分解 M;非 EUR → BT-6+BT-111 |
| **B2B 国际进项发票（Flux 10.1）** | INVOICE / B2B | 同上;**行级明细全部可省**（DGFiP 简化） |
| **B2C 发票上报** | INVOICE / B2C | 买方 NA/填 "B2C";行级带交易类别码(TT-81)+行级税+行级交付日，以便聚合入 10.3 |
| **B2C 交易/POS 汇总（Flux 10.3）** | RECEIPTTRANSACTION / B2C | Entry type=RECEIPTTRANSACTION **M**;行级类别码(TLB1/TPS1…) **M**;行级税与交付日 **M**;单据类型/业务流程/大量文档级字段 NA |
| **上报更正** | 任意 | 传输类型=RECTIFICATION;BG-3 引用被更正单据(BT-25/26) |
| **B2B 发票付款（Flux 10.2）** | Payment type=INVOICE | TaxReport 结构;TT-91 发票号+TT-102 发票日期 M;收款日/含税额/税率 M;币种 EUR;分类 INCOME |
| **B2C 收据付款汇总（Flux 10.4）** | Payment type=RECEIPTTRANSACTION | TaxReport 结构;无发票号/日期;收款日/含税额/税率 M;币种 EUR |

---

### 6. 与开票（e-invoicing）的关键差异速查

| 维度 | e-invoicing（[[FR_STANDARD_FIELDS]]） | e-reporting（本文档） |
|------|--------------------------------------|----------------------|
| 承载结构 | `Invoice` | 发票/交易上报 `Invoice`;付款上报 `TaxReport` |
| 义务口径 | 单一 B2B/B2G | 三列 B2B/B2C/Transaction（付款为 B2B/B2C） |
| `cbc:Note` | BAR/AAB/PMD/PMT 四码强制 | 仅 AAB/TXD/BLU 按 CM;B2C 不要求;无 BAR 强制 |
| Party 标识 | SIRET(0009) 可作主标识 | **不接受 SIRET**，用 SIREN(0002) |
| BT-7 纳税义务发生日 | O（可用） | **NA**（只用 BT-8 码） |
| 行级明细 | 必填 | 进项国际交易可全省;交易汇总只需类别码+税+交付日 |
| 上报元数据 | 无 | Entry type/Transaction type/Report period/分类标识（PUF RestrictedInformation） |

---

### 7. 变更记录参考

**Reporting Invoice v1.18:**
- v1.18（2026-06-12）:BT-1 最大长度回退至 20 字符（35 推迟至约 2026-12）。
- v1.16:BT-47 买方标识 B2B 改 CM→M（Flux 10 只报 B2B 国际，买方总可识别）;BT-7 全口径设为 NA;BT-119 B2B 改 CM→M;新增 Party 标识方案表并**移除 SIRET(0009)**;补全 BT-120/121、BG-20/21、BT-31/48 等条件说明。
- v1.15:进项/进口国际采购上报**行级标签全部可选**（DGFiP 简化）。
- v1.12:B2C/交易空白义务补全，引入 NA;交易上报的发票合计与 VAT 合计由 O 改 M。
- v1.07:义务列拆成 B2B/B2C/Transaction 三列;新增 Entry type/Transaction type/自开票指示。

**Reporting Payment v1.2:**
- v1.2（2026-04-15）:报告周期起止(TT-89/90)由 O 改 CM，跨多日期时必填。
- v1.1:义务列拆成 B2B/B2C 两列。

> 完整变更历史见源文件 `src/test/resources/report/pagero/fr/Best_practice_content_France_Reporting_Invoice_v1.18.xlsx` 与 `..._Reporting_Payment_v1.2.xlsx`（`About` 表 CHANGELOG）。
