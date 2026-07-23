## 法国 (FR) 专用扩展

测试文件位于 `fr/`。

法国走的是 **PUF / Pagero 税务申报（e-reporting / TDR）** 通道，不同于西班牙的 SII 逐张实时报送。法国扩展字段服务于两条链路：

- **Flux 10.1 — 发票申报（Billing）**：在标准发票（`Invoice`）上通过 `cac:AdditionalDocumentReference` 携带上报元数据，逐张（INVOICE）或按日汇总（RECEIPTTRANSACTION）报送。
- **Flux 10.2 / 10.4 — 付款申报（Payment）**：独立的 KDUBL `TaxReport` 文档类型（根元素 `TaxReport`，命名空间 `urn:piaozone.com:kdubl:taxreport:1.0`），上报实际收款事件。

> 与 ES 不同，法国的所有发票级扩展都放在标准 UBL `cac:AdditionalDocumentReference` 中，**不使用 `kdubl:PiaozoneExtension` 扩展块**；行级类别码放在 `cac:Item/cac:AdditionalItemProperty` 中。所有 FR 特有校验仅在 `countryCode=FR` 场景加载（`rules/taxreporting/kdubl/fr/{INVOICE,RECEIPT_TRANSACTION,PAYMENT}/`）。

> **重要：** 所有基于 `cac:AdditionalDocumentReference` 的扩展字段（`TaxReportEntryType`、`TaxReportPeriodStart/End`、`TaxReportTransmissionType`、`TaxReportAuthorityId`、`TaxReportIssuerRef`、`InvoiceContext`），其 `cbc:ID` 必须携带 `schemeName="InvoiceTag"` 属性，用于标识该 ADR 为 KDUBL 扩展标签而非标准 UBL 单据引用。历史 KDUBL 示例文件遗漏了此属性，应逐步补齐。下文示例均已按此规范书写。

---

### 0. 扩展字段总览

#### 0.1 发票申报（Flux 10.1，`Invoice` 文档）

| # | 字段 | 位置 | 必填性 | 对应 PUF |
|---|------|------|--------|---------|
| 1 | `TaxReportEntryType` | `cac:AdditionalDocumentReference` | **M** | `RestrictedInformation[Key='entryType']` |
| 2 | `TaxReportPeriodStart` | `cac:AdditionalDocumentReference` | **M** | `RestrictedInformation[Key='reportPeriodStart']` |
| 3 | `TaxReportPeriodEnd` | `cac:AdditionalDocumentReference` | **M** | `RestrictedInformation[Key='reportPeriodEnd']` |
| 4 | `TaxReportTransmissionType` | `cac:AdditionalDocumentReference` | CM — 更正时必填 | `RestrictedInformation[Key='transmissionType']` |
| 5 | `TaxReportAuthorityId` | `cac:AdditionalDocumentReference` | CM — RECTIFICATION 时必填 | `RestrictedInformation[Key='taxReportId']` |
| 6 | `TaxReportIssuerRef` | `cac:AdditionalDocumentReference` | O | `RestrictedInformation[Key='issuerAssignedReportId']` |
| 7 | `TaxReportLineCategory` | `cac:Item/cac:AdditionalItemProperty` | CM — RECEIPTTRANSACTION 每行必填 | `LineExtension/RestrictedInformation[Key='CategoryCode']` |
| 8 | `InvoiceContext` | `cac:AdditionalDocumentReference` | O | 通道路由用 |

#### 0.2 付款申报（Flux 10.2 / 10.4，`TaxReport` 文档）

| # | 字段 | 位置 | 必填性 | 对应 PUF |
|---|------|------|--------|---------|
| 9 | `ClassificationIdentifier` | `TaxReport/ClassificationIdentifier` | **M** — 法国固定 INCOME | 申报方向 |
| 10 | `Type` | `TaxReport/Type` | O — 默认 ADD | 报送传输类型 |
| 11 | `ReportPeriod` | `TaxReport/ReportPeriod` | **M** | 申报周期 |
| 12 | `DocumentReference` | `TaxReport/cac:DocumentReference/cbc:ID` | CM — REPLACE_PERIOD 时必填 | 被替换报告聚合 ID |

#### 0.3 Party 标识符

| # | 标识 | 位置 | schemeID | 说明 |
|---|------|------|----------|------|
| 13 | VAT / TVA | `PartyTaxScheme/cbc:CompanyID` | 无（TaxScheme/ID=VAT） | `FR` + 2 位校验码 + 9 位 SIREN，Peppol EAS=9957 |
| 14 | SIRET | `PartyIdentification` 或 `PartyLegalEntity/cbc:CompanyID` | `FR:SIRET` | 14 位（9 位 SIREN + 5 位 NIC），ICD/EAS=0009 |
| 15 | SIREN | `TaxReport` 的 `IssuerParty/PartyLegalEntity/cbc:CompanyID` | `0002` | 9 位（付款申报文档使用） |

> **M** = 必填；**CM** = 条件必填；**O** = 可选

---

### 1. 业务流程标识 — ProfileID（销项 / 进项）

**什么时候传：** 每张发票**必填**（`cbc:ProfileID`），法国发票申报和付款申报均要求（校验 `KDUBL-TR-P-FR-001`）。

**传什么：** 区分销项（应收 AR）和进项（应付 AP）两条业务流程：

| 值 | 业务方向 | 说明 | 对应 PUF |
|----|---------|------|---------|
| `urn:piaozone.com:profile:bill:v1.0` | 销项 / 应收（AR） | 本方作为卖方开出的发票 | PUF `billing:1.0` |
| `urn:piaozone.com:profile:payable:v1.0` | 进项 / 应付（AP） | 本方作为买方收到的发票 | PUF `purchase:1.0` |

```xml
<!-- 销项发票（本方是卖方） -->
<cbc:ProfileID>urn:piaozone.com:profile:bill:v1.0</cbc:ProfileID>

<!-- 进项发票（本方是买方） -->
<cbc:ProfileID>urn:piaozone.com:profile:payable:v1.0</cbc:ProfileID>
```

> 法国 e-reporting 两个方向都要报送：销项报自己开出的发票（Flux 10.1 INVOICE / RECEIPTTRANSACTION），进项报收到的采购发票（跨境 B2B 采购的自我申报）。`ProfileID` 决定发票走销项还是进项申报链路，只允许上述两个值，其他值报错 `KDUBL-TR-P-FR-001`。付款申报文档（`TaxReport`）不使用此字段，而是通过 `ClassificationIdentifier`（INCOME/EXPENSE）表达方向，法国固定 `INCOME`。

---

### 2. 法国 Party 标识符

法国企业有三种标识符，在不同文档 / 不同位置使用：

#### 2.1 VAT 号（TVA intracommunautaire）

**位置：** `cac:PartyTaxScheme/cbc:CompanyID`，`TaxScheme/ID=VAT`，无需 `@schemeID`。

**格式：** `FR` + 2 位校验码 + 9 位 SIREN，如 `FR68104332184`。Peppol EAS=9957。

```xml
<cac:PartyTaxScheme>
    <cbc:CompanyID>FR68104332184</cbc:CompanyID>
    <cac:TaxScheme>
        <cbc:ID>VAT</cbc:ID>
    </cac:TaxScheme>
</cac:PartyTaxScheme>
```

#### 2.2 SIRET

**位置：** `cac:PartyLegalEntity/cbc:CompanyID`（法人标识），或 `cac:PartyIdentification/cbc:ID`。

**传什么：** 14 位纯数字（9 位 SIREN + 5 位 NIC，标识具体经营场所），`schemeID="FR:SIRET"`。ISO 6523 ICD=0009，Peppol EAS=0009，转 PUF 时映射为 `type=LEGAL`、`schemeID=0009`。

```xml
<cac:PartyLegalEntity>
    <cbc:RegistrationName>Kingdee Test Supplier FR</cbc:RegistrationName>
    <cbc:CompanyID schemeID="FR:SIRET">10433218410018</cbc:CompanyID>
</cac:PartyLegalEntity>
```

#### 2.3 SIREN（仅付款申报文档）

付款申报 `TaxReport` 文档的申报方（`IssuerParty`）使用 9 位 SIREN，`schemeID="0002"`。SIREN 是 SIRET 的前 9 位。

```xml
<cac:IssuerParty>
    <cac:PartyLegalEntity>
        <cbc:RegistrationName>Kingdee Test Supplier FR</cbc:RegistrationName>
        <cbc:CompanyID schemeID="0002">104332184</cbc:CompanyID>
    </cac:PartyLegalEntity>
</cac:IssuerParty>
```

---

### 3. 上报归档类型 — TaxReportEntryType

**什么时候传：** 法国发票申报（Flux 10.1）**必填**（校验 `KDUBL-TR-001`）。

**传什么：**

| 值 | 说明 |
|----|------|
| `INVOICE` | 个单报送：逐张发票（B2B，含国际交易） |
| `RECEIPTTRANSACTION` | B2C POS 聚合报送：按日汇总的收款交易 |

**位置：** 标准 UBL `cac:AdditionalDocumentReference`，`cbc:DocumentType='TaxReportEntryType'`。

```xml
<cac:AdditionalDocumentReference>
    <cbc:ID schemeName="InvoiceTag">INVOICE</cbc:ID>
    <cbc:DocumentType>TaxReportEntryType</cbc:DocumentType>
</cac:AdditionalDocumentReference>
```

> 只允许 `INVOICE` / `RECEIPTTRANSACTION`，其他值报错 `KDUBL-TR-002`。B2C 场景（无买方 `PartyLegalEntity`）应使用 `RECEIPTTRANSACTION`。对应 PUF `puf:RestrictedInformation[puf:Key='entryType']`。

---

### 4. 申报周期 — TaxReportPeriodStart / TaxReportPeriodEnd

**什么时候传：** 法国发票申报**必填**（校验 `KDUBL-TR-003` / `KDUBL-TR-004`），Flux 10.1/10.2/10.4 均要求。

**传什么：** `YYYY-MM-DD` 格式的申报周期起止日期（格式错误报 `KDUBL-TR-005` / `KDUBL-TR-006`）。月度申报时通常为当月第一天和最后一天。

**位置：** 两个独立的 `cac:AdditionalDocumentReference`。

```xml
<cac:AdditionalDocumentReference>
    <cbc:ID schemeName="InvoiceTag">2026-01-01</cbc:ID>
    <cbc:DocumentType>TaxReportPeriodStart</cbc:DocumentType>
</cac:AdditionalDocumentReference>
<cac:AdditionalDocumentReference>
    <cbc:ID schemeName="InvoiceTag">2026-01-31</cbc:ID>
    <cbc:DocumentType>TaxReportPeriodEnd</cbc:DocumentType>
</cac:AdditionalDocumentReference>
```

> 申报周期与发票本身的 `cac:InvoicePeriod`（BT-73/BT-74，服务/交货期）并行存在，语义不同。RECTIFICATION 场景下，周期必须与被替换报告完全一致。对应 PUF `reportPeriodStart` / `reportPeriodEnd`。

---

### 5. 报送传输类型 — TaxReportTransmissionType

**什么时候传：** 更正场景（RECTIFICATION）必填；其余场景可省略（默认 `ORIGINAL`）。

**传什么：**

| 值 | 说明 |
|----|------|
| `ORIGINAL` | 首次原始上报（默认，可不填） |
| `ADD` | 增补报送：在已有报告期内追加数据 |
| `EDIT` | 单条更正：修正某张已上报的发票 |
| `RECTIFICATION` | 整期替换（REPLACE_PERIOD）：替换整个报告期的全部数据 |

**位置：** `cac:AdditionalDocumentReference`，`cbc:DocumentType='TaxReportTransmissionType'`。

```xml
<cac:AdditionalDocumentReference>
    <cbc:ID schemeName="InvoiceTag">RECTIFICATION</cbc:ID>
    <cbc:DocumentType>TaxReportTransmissionType</cbc:DocumentType>
</cac:AdditionalDocumentReference>
```

> 与 `InvoiceTypeCode`（380/381/383）区别：`InvoiceTypeCode` 描述发票文档类型，本字段描述本次向税局的报送行为类型。`RECTIFICATION` 时 `TaxReportAuthorityId` 必填（见第 6 节）。对应 PUF `puf:RestrictedInformation[puf:Key='transmissionType']`。

---

### 6. 税局报告 ID — TaxReportAuthorityId

**什么时候传：** `TransmissionType=RECTIFICATION` 时**必填**（校验 `KDUBL-TR-007`）；首次报送为空。

**传什么：** 被替换报告在税局（DGFIP）/ Pagero 侧的报告 ID（对应 Pagero `thirdPartyReportId`），用于识别本次提交替换哪份历史记录。

**位置：** `cac:AdditionalDocumentReference`，`cbc:DocumentType='TaxReportAuthorityId'`。

```xml
<cac:AdditionalDocumentReference>
    <cbc:ID schemeName="InvoiceTag">000000000000047</cbc:ID>
    <cbc:DocumentType>TaxReportAuthorityId</cbc:DocumentType>
</cac:AdditionalDocumentReference>
```

> 对应 PUF `puf:RestrictedInformation[puf:Key='taxReportId']`。

---

### 7. 发票人报告 ID — TaxReportIssuerRef

**什么时候传：** 可选。建议填写，便于幂等处理和追踪；不填时 Pagero 侧仍可按 senderReference 查询。

**传什么：** 发票人（上报方）自定义的报告 ID，唯一标识一份报送批次。建议格式 `{ouno}-{sourceDocumentId}-{attemptSeq}`。

**位置：** `cac:AdditionalDocumentReference`，`cbc:DocumentType='TaxReportIssuerRef'`。

```xml
<cac:AdditionalDocumentReference>
    <cbc:ID schemeName="InvoiceTag">RPT-FR-2026-001</cbc:ID>
    <cbc:DocumentType>TaxReportIssuerRef</cbc:DocumentType>
</cac:AdditionalDocumentReference>
```

> 对应 PUF `puf:RestrictedInformation[puf:Key='issuerAssignedReportId']`。

---

### 8. 行级交易类别码 — TaxReportLineCategory

**什么时候传：** `TaxReportEntryType=RECEIPTTRANSACTION`（B2C POS 聚合）时，**每个发票行必填**（校验 `KDUBL-TR-008`）；`INVOICE`（B2B 个单）时通常为空。

**传什么：** 法国 TDR（Tenue Des Registres）行级交易类别码。

| 值 | 说明 |
|----|------|
| `TLB1` | 物品交付（应税）Travaux, Livraisons de Biens |
| `TLB2` | 物品交付（免税） |
| `TPS1` | 服务（应税）Travaux, Prestations de Services |
| `TPS2` | 服务（免税） |
| `TNT1` | 非应税交易 Transactions non taxables |
| `TMA1` | 差价税制交易 Transactions soumises à la marge |

**位置：** `cac:InvoiceLine/cac:Item/cac:AdditionalItemProperty`，`cbc:Name='TaxReportLineCategory'`。

```xml
<cac:Item>
    <cbc:Name>B2C</cbc:Name>
    <cac:AdditionalItemProperty>
        <cbc:Name>TaxReportLineCategory</cbc:Name>
        <cbc:Value>TLB1</cbc:Value>
    </cac:AdditionalItemProperty>
</cac:Item>
```

> POS 汇总场景下每个 `InvoiceLine` 对应一个类别，代表该类别当日的汇总交易金额。对应 PUF `InvoiceLine` 下 `puf:LineExtension/puf:RestrictedInformation[puf:Key='CategoryCode']`。

---

### 9. 业务场景码 — InvoiceContext（通用扩展）

**什么时候传：** 可选。用于通道服务路由和规则匹配。**在法国上报（Flux 10.1）中额外承担 PUF `transactionType` 的映射来源**（见下）。

**传什么（法国适用枚举）：** 法国上报只使用 `B2B` 和 `B2C` 两个值，其余通用值（`B2G`/`Standard`/`NA`/`Adjustment`/`Replacement`）在法国场景不使用。

| 值 | 法国场景 |
|----|---------|
| `B2B` | B2B 发票（境内开票、跨境 B2Bi 销项 / Bi2B 进项）→ PUF `transactionType=B2B`（缺省值） |
| `B2C` | B2C 发票、B2C POS 交易汇总 → PUF `transactionType=B2C` |

> 付款申报文档（`TaxReport`，Flux 10.2/10.4）不含 `InvoiceContext` 字段。

**位置：** `cac:AdditionalDocumentReference`，`cbc:DocumentType='InvoiceContext'`。

```xml
<cac:AdditionalDocumentReference>
    <cbc:ID schemeName="InvoiceTag">B2B</cbc:ID>
    <cbc:DocumentType>InvoiceContext</cbc:DocumentType>
</cac:AdditionalDocumentReference>
```

**法国上报映射（→ PUF `transactionType`）：** `kdubl-to-puf-billing-fr.xslt` 读取本字段，**当且仅当值为 `B2B` 或 `B2C`** 时映射为 PUF 的交易类型扩展；其他值（`Standard`/`NA` 等）被忽略，不产出该扩展。

| KDUBL | PUF |
|-------|-----|
| `cac:AdditionalDocumentReference[cbc:DocumentType='InvoiceContext']/cbc:ID`（值 `B2B`/`B2C`） | `ext:UBLExtensions/ext:UBLExtension[ExtensionURI='urn:pagero:ExtensionComponent:1.0:PageroExtension:RestrictedInformation']/.../puf:RestrictedInformation[puf:Key='transactionType']/puf:Value` |

```xml
<!-- KDUBL InvoiceContext=B2C  →  PUF transactionType=B2C -->
<puf:RestrictedInformation>
  <puf:Key>transactionType</puf:Key>
  <puf:Value>B2C</puf:Value>
</puf:RestrictedInformation>
```

> PUF `transactionType` 的义务：B2B 上报 O（缺省 B2B），B2C 发票与交易汇总上报 M。详见 [[FR_REPORTING_FIELDS]] §1.1。

---

### 10. 发票申报完整示例

#### 场景一：跨境 B2B 销项发票（Flux 10.1，个单报送）

法国卖方 → 意大利买方，欧盟内交易免税（税类 E）。

```xml
<Invoice
    xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"
    xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
    xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
    xmlns:kdubl="urn:piaozone.com:ubl-2.1-customizations:v1.0">

    <cbc:CustomizationID>urn:piaozone.com:ubl-2.1-customizations:v1.0</cbc:CustomizationID>
    <cbc:ProfileID>urn:piaozone.com:profile:bill:v1.0</cbc:ProfileID>
    <cbc:ID>INV123456</cbc:ID>
    <cbc:IssueDate>2026-01-01</cbc:IssueDate>
    <cbc:InvoiceTypeCode>380</cbc:InvoiceTypeCode>
    <cbc:DocumentCurrencyCode>EUR</cbc:DocumentCurrencyCode>

    <!-- 业务场景码 -->
    <cac:AdditionalDocumentReference>
        <cbc:ID schemeName="InvoiceTag">B2B</cbc:ID>
        <cbc:DocumentType>InvoiceContext</cbc:DocumentType>
    </cac:AdditionalDocumentReference>
    <!-- 上报归档类型：个单 -->
    <cac:AdditionalDocumentReference>
        <cbc:ID schemeName="InvoiceTag">INVOICE</cbc:ID>
        <cbc:DocumentType>TaxReportEntryType</cbc:DocumentType>
    </cac:AdditionalDocumentReference>
    <!-- 发票人报告 ID -->
    <cac:AdditionalDocumentReference>
        <cbc:ID schemeName="InvoiceTag">RPT-FR-2026-001</cbc:ID>
        <cbc:DocumentType>TaxReportIssuerRef</cbc:DocumentType>
    </cac:AdditionalDocumentReference>
    <!-- 报送传输类型：首次 -->
    <cac:AdditionalDocumentReference>
        <cbc:ID schemeName="InvoiceTag">ORIGINAL</cbc:ID>
        <cbc:DocumentType>TaxReportTransmissionType</cbc:DocumentType>
    </cac:AdditionalDocumentReference>
    <!-- 申报周期 -->
    <cac:AdditionalDocumentReference>
        <cbc:ID schemeName="InvoiceTag">2026-01-01</cbc:ID>
        <cbc:DocumentType>TaxReportPeriodStart</cbc:DocumentType>
    </cac:AdditionalDocumentReference>
    <cac:AdditionalDocumentReference>
        <cbc:ID schemeName="InvoiceTag">2026-01-31</cbc:ID>
        <cbc:DocumentType>TaxReportPeriodEnd</cbc:DocumentType>
    </cac:AdditionalDocumentReference>

    <cac:AccountingSupplierParty>
        <cac:Party>
            <cac:PostalAddress>
                <cac:Country><cbc:IdentificationCode>FR</cbc:IdentificationCode></cac:Country>
            </cac:PostalAddress>
            <cac:PartyTaxScheme>
                <cbc:CompanyID>FR68104332184</cbc:CompanyID>
                <cac:TaxScheme><cbc:ID>VAT</cbc:ID></cac:TaxScheme>
            </cac:PartyTaxScheme>
            <cac:PartyLegalEntity>
                <cbc:RegistrationName>Kingdee Test Supplier FR</cbc:RegistrationName>
                <cbc:CompanyID schemeID="FR:SIRET">10433218410018</cbc:CompanyID>
            </cac:PartyLegalEntity>
        </cac:Party>
    </cac:AccountingSupplierParty>

    <cac:AccountingCustomerParty>
        <cac:Party>
            <cac:PostalAddress>
                <cac:Country><cbc:IdentificationCode>IT</cbc:IdentificationCode></cac:Country>
            </cac:PostalAddress>
            <cac:PartyTaxScheme>
                <cbc:CompanyID>IT12345678912</cbc:CompanyID>
                <cac:TaxScheme><cbc:ID>VAT</cbc:ID></cac:TaxScheme>
            </cac:PartyTaxScheme>
            <cac:PartyLegalEntity>
                <cbc:RegistrationName>Buyer Company Name</cbc:RegistrationName>
            </cac:PartyLegalEntity>
        </cac:Party>
    </cac:AccountingCustomerParty>

    <cac:TaxTotal>
        <cbc:TaxAmount currencyID="EUR">0.00</cbc:TaxAmount>
        <cac:TaxSubtotal>
            <cbc:TaxableAmount currencyID="EUR">100.00</cbc:TaxableAmount>
            <cbc:TaxAmount currencyID="EUR">0.00</cbc:TaxAmount>
            <cac:TaxCategory>
                <cbc:ID>E</cbc:ID>
                <cbc:Percent>0</cbc:Percent>
                <cbc:TaxExemptionReasonCode>VATEX-EU-151</cbc:TaxExemptionReasonCode>
                <cbc:TaxExemptionReason>Exonération de TVA selon Art 262 du CGI. Vente dans l'UE</cbc:TaxExemptionReason>
                <cac:TaxScheme><cbc:ID>VAT</cbc:ID></cac:TaxScheme>
            </cac:TaxCategory>
        </cac:TaxSubtotal>
    </cac:TaxTotal>

    <cac:LegalMonetaryTotal>
        <cbc:TaxExclusiveAmount currencyID="EUR">100.00</cbc:TaxExclusiveAmount>
        <cbc:PayableAmount currencyID="EUR">100.00</cbc:PayableAmount>
    </cac:LegalMonetaryTotal>

    <cac:InvoiceLine>
        <cbc:ID>1</cbc:ID>
        <cbc:InvoicedQuantity unitCode="NAR">1</cbc:InvoicedQuantity>
        <cbc:LineExtensionAmount currencyID="EUR">100.00</cbc:LineExtensionAmount>
        <cac:Item>
            <cbc:Name>Item name</cbc:Name>
            <cac:ClassifiedTaxCategory>
                <cbc:ID>E</cbc:ID>
                <cbc:Percent>0</cbc:Percent>
                <cac:TaxScheme><cbc:ID>VAT</cbc:ID></cac:TaxScheme>
            </cac:ClassifiedTaxCategory>
        </cac:Item>
        <cac:Price><cbc:PriceAmount currencyID="EUR">100.00</cbc:PriceAmount></cac:Price>
    </cac:InvoiceLine>
</Invoice>
```

#### 场景二：B2C POS 聚合交易（Flux 10.1，RECEIPTTRANSACTION）

每个 `InvoiceLine` 代表一个交易类别的当日汇总，每行必须带 `TaxReportLineCategory`。

```xml
<Invoice ...>
    <cbc:CustomizationID>urn:piaozone.com:ubl-2.1-customizations:v1.0</cbc:CustomizationID>
    <cbc:ProfileID>urn:piaozone.com:profile:bill:v1.0</cbc:ProfileID>
    <cbc:ID>POS123456</cbc:ID>
    <cbc:IssueDate>2026-01-02</cbc:IssueDate>
    <cbc:InvoiceTypeCode>380</cbc:InvoiceTypeCode>
    <cbc:DocumentCurrencyCode>EUR</cbc:DocumentCurrencyCode>

    <cac:AdditionalDocumentReference>
        <cbc:ID schemeName="InvoiceTag">B2C</cbc:ID>
        <cbc:DocumentType>InvoiceContext</cbc:DocumentType>
    </cac:AdditionalDocumentReference>
    <!-- 聚合报送 -->
    <cac:AdditionalDocumentReference>
        <cbc:ID schemeName="InvoiceTag">RECEIPTTRANSACTION</cbc:ID>
        <cbc:DocumentType>TaxReportEntryType</cbc:DocumentType>
    </cac:AdditionalDocumentReference>
    <cac:AdditionalDocumentReference>
        <cbc:ID schemeName="InvoiceTag">RPT-FR-POS-20260101-001</cbc:ID>
        <cbc:DocumentType>TaxReportIssuerRef</cbc:DocumentType>
    </cac:AdditionalDocumentReference>
    <cac:AdditionalDocumentReference>
        <cbc:ID schemeName="InvoiceTag">ORIGINAL</cbc:ID>
        <cbc:DocumentType>TaxReportTransmissionType</cbc:DocumentType>
    </cac:AdditionalDocumentReference>
    <!-- POS 汇总的申报周期通常为单日 -->
    <cac:AdditionalDocumentReference>
        <cbc:ID schemeName="InvoiceTag">2026-01-01</cbc:ID>
        <cbc:DocumentType>TaxReportPeriodStart</cbc:DocumentType>
    </cac:AdditionalDocumentReference>
    <cac:AdditionalDocumentReference>
        <cbc:ID schemeName="InvoiceTag">2026-01-01</cbc:ID>
        <cbc:DocumentType>TaxReportPeriodEnd</cbc:DocumentType>
    </cac:AdditionalDocumentReference>

    <!-- 卖方省略；买方为匿名 B2C -->

    <!-- 行 1：TLB1 商品交付（应税 20%），当日商品汇总 -->
    <cac:InvoiceLine>
        <cbc:ID>1</cbc:ID>
        <cbc:LineExtensionAmount currencyID="EUR">100.00</cbc:LineExtensionAmount>
        <cac:TaxTotal>
            <cbc:TaxAmount currencyID="EUR">20.00</cbc:TaxAmount>
            <cac:TaxSubtotal>
                <cbc:TaxableAmount currencyID="EUR">100.00</cbc:TaxableAmount>
                <cbc:TaxAmount currencyID="EUR">20.00</cbc:TaxAmount>
                <cac:TaxCategory>
                    <cbc:ID>S</cbc:ID><cbc:Percent>20</cbc:Percent>
                    <cac:TaxScheme><cbc:ID>VAT</cbc:ID></cac:TaxScheme>
                </cac:TaxCategory>
            </cac:TaxSubtotal>
        </cac:TaxTotal>
        <cac:Item>
            <cbc:Name>B2C</cbc:Name>
            <cac:AdditionalItemProperty>
                <cbc:Name>TaxReportLineCategory</cbc:Name>
                <cbc:Value>TLB1</cbc:Value>
            </cac:AdditionalItemProperty>
        </cac:Item>
    </cac:InvoiceLine>

    <!-- 行 2：TPS1 服务（应税 20%），当日服务汇总 -->
    <cac:InvoiceLine>
        <cbc:ID>2</cbc:ID>
        <cbc:LineExtensionAmount currencyID="EUR">200.00</cbc:LineExtensionAmount>
        <cac:TaxTotal>
            <cbc:TaxAmount currencyID="EUR">40.00</cbc:TaxAmount>
            <cac:TaxSubtotal>
                <cbc:TaxableAmount currencyID="EUR">200.00</cbc:TaxableAmount>
                <cbc:TaxAmount currencyID="EUR">40.00</cbc:TaxAmount>
                <cac:TaxCategory>
                    <cbc:ID>S</cbc:ID><cbc:Percent>20</cbc:Percent>
                    <cac:TaxScheme><cbc:ID>VAT</cbc:ID></cac:TaxScheme>
                </cac:TaxCategory>
            </cac:TaxSubtotal>
        </cac:TaxTotal>
        <cac:Item>
            <cbc:Name>B2C</cbc:Name>
            <cac:AdditionalItemProperty>
                <cbc:Name>TaxReportLineCategory</cbc:Name>
                <cbc:Value>TPS1</cbc:Value>
            </cac:AdditionalItemProperty>
        </cac:Item>
    </cac:InvoiceLine>
</Invoice>
```

#### 场景三：发票申报更正（整期替换，RECTIFICATION）

`TransmissionType=RECTIFICATION` + `TaxReportAuthorityId`（被替换报告的税局 ID）+ 周期必须与被替换报告完全一致。

```xml
<Invoice ...>
    <cbc:ProfileID>urn:piaozone.com:profile:payable:v1.0</cbc:ProfileID>
    <cbc:ID>INV123456</cbc:ID>
    <cbc:IssueDate>2026-02-01</cbc:IssueDate>
    <cbc:InvoiceTypeCode>380</cbc:InvoiceTypeCode>
    <cbc:DocumentCurrencyCode>EUR</cbc:DocumentCurrencyCode>

    <cac:AdditionalDocumentReference>
        <cbc:ID schemeName="InvoiceTag">INVOICE</cbc:ID>
        <cbc:DocumentType>TaxReportEntryType</cbc:DocumentType>
    </cac:AdditionalDocumentReference>
    <cac:AdditionalDocumentReference>
        <cbc:ID schemeName="InvoiceTag">RPT-FR-PURCHASE-2026-RECT-001</cbc:ID>
        <cbc:DocumentType>TaxReportIssuerRef</cbc:DocumentType>
    </cac:AdditionalDocumentReference>
    <!-- 整期替换 -->
    <cac:AdditionalDocumentReference>
        <cbc:ID schemeName="InvoiceTag">RECTIFICATION</cbc:ID>
        <cbc:DocumentType>TaxReportTransmissionType</cbc:DocumentType>
    </cac:AdditionalDocumentReference>
    <!-- 被替换报告的税局报告 ID（RECTIFICATION 必填） -->
    <cac:AdditionalDocumentReference>
        <cbc:ID schemeName="InvoiceTag">000000000000047</cbc:ID>
        <cbc:DocumentType>TaxReportAuthorityId</cbc:DocumentType>
    </cac:AdditionalDocumentReference>
    <!-- 周期必须与被替换报告完全一致 -->
    <cac:AdditionalDocumentReference>
        <cbc:ID schemeName="InvoiceTag">2026-06-21</cbc:ID>
        <cbc:DocumentType>TaxReportPeriodStart</cbc:DocumentType>
    </cac:AdditionalDocumentReference>
    <cac:AdditionalDocumentReference>
        <cbc:ID schemeName="InvoiceTag">2026-06-30</cbc:ID>
        <cbc:DocumentType>TaxReportPeriodEnd</cbc:DocumentType>
    </cac:AdditionalDocumentReference>

    <!-- 被更正的原始发票引用（标准 UBL BT-25） -->
    <cac:BillingReference>
        <cac:InvoiceDocumentReference>
            <cbc:ID>INV-ORIGINAL-001</cbc:ID>
        </cac:InvoiceDocumentReference>
    </cac:BillingReference>

    <!-- Party / TaxTotal / Line 省略 -->
</Invoice>
```

---

### 11. 付款申报文档 — KDUBL TaxReport（Flux 10.2 / 10.4）

付款申报**不是发票扩展**，而是独立的 KDUBL 文档类型：

- **根元素：** `TaxReport`
- **命名空间：** `urn:piaozone.com:kdubl:taxreport:1.0`
- **对应 PUF：** `urn:pagero.com:puf:taxreport:1.0`
- **适用：** Flux 10.2（B2B 发票付款）+ Flux 10.4（B2C POS 聚合付款）

#### 11.1 文档级字段

| 字段 | XPath | 必填性 | 说明 |
|------|-------|--------|------|
| `CustomizationID` | `cbc:CustomizationID` | M | 固定 `urn:piaozone.com:kdubl:taxreport:1.0` |
| `ProfileID` | `cbc:ProfileID` | M | 固定 `urn:piaozone.com:profile:taxreport:v1.0` |
| `ID` | `cbc:ID` | M | 报告唯一 ID，如 `PAY-2026-001`（幂等去重） |
| `IssueDate` | `cbc:IssueDate` | M | 报告开单日期 |
| `ClassificationIdentifier` | `ClassificationIdentifier` | M | 申报方向，法国固定 `INCOME` |
| `Type` | `Type` | O | 传输类型，默认 `ADD`；可选 `EDIT` / `REPLACE_PERIOD` |
| `ReportPeriod` | `ReportPeriod/cbc:StartDate` + `cbc:EndDate` | M | 申报周期 |
| `IssuerParty` | `cac:IssuerParty` | M | 申报方（SIREN，schemeID=0002） |
| `DocumentReference` | `cac:DocumentReference/cbc:ID` | CM | REPLACE_PERIOD 时填被替换报告的 Pagero 聚合 ID |

#### 11.2 Payment 子文档字段（1..n）

| 字段 | XPath | 必填性 | 说明 |
|------|-------|--------|------|
| `DocumentCurrencyCode` | `Payment/cbc:DocumentCurrencyCode` | M | 法国固定 `EUR` |
| `PaymentDataType` | `Payment/ReferencedDocument/PaymentDataType` | M | `INVOICE`（B2B）/ `RECEIPTTRANSACTION`（B2C） |
| 发票号 | `Payment/ReferencedDocument/cbc:ID` | CM | `PaymentDataType=INVOICE` 时必填 |
| 发票开票日期 | `Payment/ReferencedDocument/cbc:IssueDate` | CM | `PaymentDataType=INVOICE` 时必填 |
| `PaidDate` | `Payment/cbc:PaidDate` | M | 实际收款日期 |
| `PaymentSubtotal` | `Payment/PaymentTotal/PaymentSubtotal` | M | 按税率分项（`TaxInclusiveAmount` + `Percent`），法国按 20%/10%/5.5%/0% 分档 |

#### 11.3 付款申报示例（销项，含 B2B 发票付款 + B2C POS 汇总）

```xml
<TaxReport xmlns="urn:piaozone.com:kdubl:taxreport:1.0"
           xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
           xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2">

    <cbc:CustomizationID>urn:piaozone.com:kdubl:taxreport:1.0</cbc:CustomizationID>
    <cbc:ProfileID>urn:piaozone.com:profile:taxreport:v1.0</cbc:ProfileID>
    <cbc:ID>PAY-2026-001</cbc:ID>
    <cbc:IssueDate>2026-02-05</cbc:IssueDate>
    <ClassificationIdentifier>INCOME</ClassificationIdentifier>
    <ReportPeriod>
        <cbc:StartDate>2026-01-01</cbc:StartDate>
        <cbc:EndDate>2026-01-31</cbc:EndDate>
    </ReportPeriod>
    <cac:IssuerParty>
        <cac:PartyLegalEntity>
            <cbc:RegistrationName>Kingdee Test Supplier FR</cbc:RegistrationName>
            <cbc:CompanyID schemeID="0002">104332184</cbc:CompanyID>
        </cac:PartyLegalEntity>
    </cac:IssuerParty>

    <!-- B2B 发票付款（Flux 10.2），混合税率 20% + 5.5% -->
    <Payment>
        <cbc:DocumentCurrencyCode>EUR</cbc:DocumentCurrencyCode>
        <ReferencedDocument>
            <PaymentDataType>INVOICE</PaymentDataType>
            <cbc:ID>FAC-2025-00842</cbc:ID>
            <cbc:IssueDate>2025-12-15</cbc:IssueDate>
        </ReferencedDocument>
        <cbc:PaidDate>2026-01-10</cbc:PaidDate>
        <PaymentTotal>
            <PaymentSubtotal>
                <cbc:TaxInclusiveAmount currencyID="EUR">1200.00</cbc:TaxInclusiveAmount>
                <cbc:Percent>20</cbc:Percent>
            </PaymentSubtotal>
            <PaymentSubtotal>
                <cbc:TaxInclusiveAmount currencyID="EUR">316.50</cbc:TaxInclusiveAmount>
                <cbc:Percent>5.5</cbc:Percent>
            </PaymentSubtotal>
        </PaymentTotal>
    </Payment>

    <!-- B2C POS 汇总付款（Flux 10.4），无发票引用，多税率 -->
    <Payment>
        <cbc:DocumentCurrencyCode>EUR</cbc:DocumentCurrencyCode>
        <ReferencedDocument>
            <PaymentDataType>RECEIPTTRANSACTION</PaymentDataType>
        </ReferencedDocument>
        <cbc:PaidDate>2026-01-08</cbc:PaidDate>
        <PaymentTotal>
            <PaymentSubtotal>
                <cbc:TaxInclusiveAmount currencyID="EUR">840.00</cbc:TaxInclusiveAmount>
                <cbc:Percent>20</cbc:Percent>
            </PaymentSubtotal>
            <PaymentSubtotal>
                <cbc:TaxInclusiveAmount currencyID="EUR">275.00</cbc:TaxInclusiveAmount>
                <cbc:Percent>10</cbc:Percent>
            </PaymentSubtotal>
        </PaymentTotal>
    </Payment>
</TaxReport>
```

#### 11.4 付款申报更正（REPLACE_PERIOD）

`Type=REPLACE_PERIOD` + `cac:DocumentReference/cbc:ID`（被替换报告的 Pagero 聚合 ID）+ 周期必须与被替换报告完全一致。整期替换会用本次提交的全部 `Payment` 记录覆盖原报告期。

```xml
<TaxReport ...>
    <cbc:CustomizationID>urn:piaozone.com:kdubl:taxreport:1.0</cbc:CustomizationID>
    <cbc:ProfileID>urn:piaozone.com:profile:taxreport:v1.0</cbc:ProfileID>
    <cbc:ID>PAY-2026-001-RECT</cbc:ID>
    <cbc:IssueDate>2026-02-10</cbc:IssueDate>
    <ClassificationIdentifier>INCOME</ClassificationIdentifier>
    <!-- 整期替换 -->
    <Type>REPLACE_PERIOD</Type>
    <!-- 必须与被替换报告的申报周期完全一致 -->
    <ReportPeriod>
        <cbc:StartDate>2026-01-01</cbc:StartDate>
        <cbc:EndDate>2026-01-31</cbc:EndDate>
    </ReportPeriod>
    <cac:IssuerParty>
        <cac:PartyLegalEntity>
            <cbc:RegistrationName>Kingdee Test Supplier FR</cbc:RegistrationName>
            <cbc:CompanyID schemeID="0002">104332184</cbc:CompanyID>
        </cac:PartyLegalEntity>
    </cac:IssuerParty>
    <!-- 被替换报告的 Pagero 聚合 ID（REPLACE_PERIOD 必填） -->
    <cac:DocumentReference>
        <cbc:ID>51234882</cbc:ID>
    </cac:DocumentReference>

    <!-- 更正后的完整付款记录（覆盖原报告期全部数据） -->
    <Payment>
        <cbc:DocumentCurrencyCode>EUR</cbc:DocumentCurrencyCode>
        <ReferencedDocument>
            <PaymentDataType>INVOICE</PaymentDataType>
            <cbc:ID>FAC-2025-00842</cbc:ID>
            <cbc:IssueDate>2025-12-15</cbc:IssueDate>
        </ReferencedDocument>
        <cbc:PaidDate>2026-01-10</cbc:PaidDate>
        <PaymentTotal>
            <PaymentSubtotal>
                <cbc:TaxInclusiveAmount currencyID="EUR">1440.00</cbc:TaxInclusiveAmount>
                <cbc:Percent>20</cbc:Percent>
            </PaymentSubtotal>
            <PaymentSubtotal>
                <cbc:TaxInclusiveAmount currencyID="EUR">316.50</cbc:TaxInclusiveAmount>
                <cbc:Percent>5.5</cbc:Percent>
            </PaymentSubtotal>
        </PaymentTotal>
    </Payment>
</TaxReport>
```

---

### 12. 校验规则速查

法国特有校验加载于 `rules/taxreporting/kdubl/fr/{INVOICE,RECEIPT_TRANSACTION,PAYMENT}/`：

| 规则 ID | 说明 |
|---------|------|
| `KDUBL-TR-P-FR-001` | ProfileID 必须为 bill（AR）或 payable（AP） |
| `KDUBL-TR-001` | TaxReportEntryType 必填 |
| `KDUBL-TR-002` | TaxReportEntryType 只允许 INVOICE / RECEIPTTRANSACTION |
| `KDUBL-TR-003` / `004` | TaxReportPeriodStart / End 必填 |
| `KDUBL-TR-005` / `006` | TaxReportPeriodStart / End 必须为 YYYY-MM-DD |
| `KDUBL-TR-007` | TransmissionType=RECTIFICATION 时 TaxReportAuthorityId 必填 |
| `KDUBL-TR-008` | EntryType=RECEIPTTRANSACTION 时每行 TaxReportLineCategory 必填 |
