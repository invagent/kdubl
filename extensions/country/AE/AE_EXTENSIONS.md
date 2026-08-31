## 五、United Arab Emirates (AE) 专用扩展

阿联酋电子发票的 KDUBL 扩展设计。测试文件位于 `AE/`（KDUBL 示例，待补）。

阿联酋由联邦税务局（FTA）强制推行连续交易控制（CTC）模式，KDUBL 需在标准 UBL 基础上补充：商品分类、受限信息方、8 位交易类型旗标、税类别 `N` 等阿联酋特有字段。

---

### 5.0 扩展字段总览

| # | 字段 | 承载机制 | 必填性 | 状态 |
|---|------|---------|--------|------|
| 1 | 交易类型旗标（BTAE-02） | `cbc:InvoiceTypeCode/@name`（贷记单 `cbc:CreditNoteTypeCode/@name`） | M | **新增** |
| 2 | TRN 税务登记号 | `PartyTaxScheme/cbc:CompanyID`（TaxScheme/ID=VAT） | M | 复用标准字段 |
| 3 | TIN（参与方标识） | `PartyIdentification/ID @schemeID="PEPPOL"`，值 `0235:{TIN}` | M | 复用既有 PEPPOL 机制 |
| 4 | 法人注册标识（BTAE-15） | `PartyLegalEntity/cbc:CompanyID @schemeID` | CM | 复用标准字段 |
| 5 | 颁发机构（BTAE-12） | `PartyIdentification/cbc:ID @schemeID="AE:LRA"` | CM | 复用标准字段 |
| 6 | 护照签发国（BTAE-18） | `PartyIdentification/cbc:ID @schemeID="AE:PASSPORT_COUNTRY"` | CM | 复用标准字段 |
| 7 | Emirate 酋长国码 | `PostalAddress/cbc:CountrySubentity` | M | 复用标准字段（新增枚举） |
| 8 | 自开票标识 | `cac:AdditionalDocumentReference`（`DocumentType=SelfBilled`） | O | 复用通用 ADR |
| 9 | 业务场景码 | `cac:AdditionalDocumentReference`（`DocumentType=InvoiceContext`） | O | 复用通用 ADR |
| 10 | 贷记单原因码（BTAE-03） | `kdubl:PiaozoneExtension/kdubl:InvoiceDocumentReference/kdubl:DocumentIssuanceReasonCode` | CM（381 必填） | 复用既有扩展（换值集） |
| 11 | FTZ 受益方 TRN（BTAE-01） | `kdubl:PiaozoneExtension/kdubl:RestrictedInformationParty[kdubl:Key=Beneficiary]` | CM（FTZ 必填） | **新增** |
| 12 | 显名代理委托人 TRN（BTAE-14） | `kdubl:PiaozoneExtension/kdubl:RestrictedInformationParty[kdubl:Key=Principle]` | CM（代理必填） | **新增** |
| 13 | 外币计税货币金额 | `kdubl:TaxCurrencyLegalMonetaryTotal` + `kdubl:TaxTotalExtensions` + 行级 `TaxCurrency*` | CM（双币种必填） | 复用 HU 双币种扩展 |
| 14 | 商品分类（G/S/B、HS、SAC） | `cac:CommodityClassification` / `cac:AdditionalItemIdentification` | CM | 复用标准字段（新增枚举） |
| 15 | NatureCode（BTAE-09） | `cac:CommodityClassification/cbc:NatureCode` | CM（AE 类必填） | 复用标准字段（新增枚举） |
| 16 | GTIN | `cac:StandardItemIdentification/cbc:ID @schemeID="0160"` | CM（AE 类必填） | 复用标准字段 |

> **M** = 必填；**CM** = 条件必填；**O** = 可选

---

### 5.1 Party 标识符与 schemeID 枚举

阿联酋参与方标识符沿用 KDUBL「三位置 + schemeID」原则，无需新增扩展字段，只补充 AE 的 schemeID 枚举：

| 标识 | 位置 | schemeID | 说明 |
|------|------|----------|------|
| **TRN 税务登记号** | `PartyTaxScheme/cbc:CompanyID` | 无（`TaxScheme/ID=VAT`） | 15 位，以 `1` 开头、`03` 结尾（如 `100000000000003`） |
| **TIN（参与方标识）** | `PartyIdentification/cbc:ID` | `PEPPOL` | 值格式 `0235:{TIN}`，TIN = TRN 前 10 位（如 `0235:1000000000`） |
| 贸易许可证 | `PartyLegalEntity/cbc:CompanyID` | `AE:TL` | BTAE-15 注册类型（默认） |
| 阿联酋身份证（Emirates ID） | `PartyLegalEntity/cbc:CompanyID` | `AE:EID` | 自然人注册类型 |
| 护照 | `PartyLegalEntity/cbc:CompanyID` | `AE:PASSPORT` | 自然人注册类型 |
| 海关/其他注册号 | `PartyLegalEntity/cbc:CompanyID` | `AE:CD` | 注册类型 |
| 颁发机构（LRA） | `PartyIdentification/cbc:ID` | `AE:LRA` | BTAE-12，如 "Department of Economic Development - Dubai" |
| 护照签发国 | `PartyIdentification/cbc:ID` | `AE:PASSPORT_COUNTRY` | BTAE-18，如 `GB`（仅 AE:PASSPORT 时，替代 LRA） |
| 受限信息方 TRN | `RestrictedInformationParty/cac:PartyIdentification/cbc:ID` | `AE:TRN` | BTAE-01 / BTAE-14，见 §5.5 |

> **TIN 的 KDUBL 写法**：业务侧在 `PartyIdentification/cbc:ID @schemeID="PEPPOL"` 填 `0235:{TIN}`（TIN = TRN 前 10 位）。转换层 `generateEndpointID` 优先级 1 直接解析冒号前为 scheme、冒号后为值，生成 `cbc:EndpointID @schemeID="0235"`，并跳过该 PEPPOL 节点不输出（同新加坡 `0195:UEN` 写法，见 `kdubl-to-bis30.xslt`）。完整 TRN **不得**用作 EndpointID。

**Emirate 酋长国码（`PostalAddress/cbc:CountrySubentity`，BT-39/BT-54）：**

| 码 | 酋长国 |
|----|--------|
| `AUH` | 阿布扎比 Abu Dhabi |
| `DXB` | 迪拜 Dubai |
| `SHJ` | 沙迦 Sharjah |
| `AJM` | 阿治曼 Ajman |
| `UAQ` | 乌姆盖万 Umm Al Quwain |
| `RAK` | 哈伊马角 Ras Al Khaimah |
| `FUJ` | 富查伊拉 Fujairah |

---

### 5.2 税类别枚举（含新增 `N`）

阿联酋 VAT 税类别沿用 KDUBL `TaxCategory/ID`（BT-118 / BT-151）标准字段，但需在现有值集（S/Z/E/AE/K/O/G）基础上**新增 `N`**：

| 码 | 含义 | 税率 | 说明 |
|----|------|------|------|
| `S` | 标准税率 | 5.00% | 精确 5.00 |
| `Z` | 零税率 | 0.00% | 出口 |
| `E` | 免税 | 0.00% | 免税原因码必填 |
| `O` | 不属 VAT 范围 | 0.00% | — |
| `AE` | 逆向征收 | 5.00% | 买方 TRN 必填；行税额=0；NatureCode + GTIN 必填 |
| **`N`（新增）** | **利润差额方案** | 5.00% | 税率 5% 但 TaxAmount=0；BTAE-02 第 3 位须置位（`00100000`） |

> 阿联酋**不使用** `K`（欧盟内部免税）和 `G`（欧盟境外出口免税）这两个欧盟专属值；出口用 `Z` 零税率。

---

### 5.3 交易类型旗标（BTAE-02）— 新增

**位置：** 直接写在 `cbc:InvoiceTypeCode/@name`（贷记单为 `cbc:CreditNoteTypeCode/@name`），元素文本仍是类型码 380/381。复用 FR（`name="B1"`）与 HU（`name="NORMAL"`）既有的 `@name` 承载约定。

```xml
<cbc:InvoiceTypeCode name="00001000">380</cbc:InvoiceTypeCode>
<cbc:CreditNoteTypeCode name="00000000">381</cbc:CreditNoteTypeCode>
```

8 位旗标字符串，每位对应一种业务场景：

| 位 | 旗标 | 值 | 场景 |
|----|------|-----|------|
| 1 | FTZ | `1XXXXXXX` | 自由贸易区供应 |
| 2 | 视同销售 | `X1XXXXXX` | 无偿供应（赠品/样品超阈值） |
| 3 | 利润差额 | `XX1XXXXX` | Article 43 差额征税 |
| 4 | 汇总发票 | `XXX1XXXX` | 按周期汇总 |
| 5 | 连续供应 | `XXXX1XXX` | 持续供应分期发票 |
| 6 | 显名代理 | `XXXXX1XX` | 代理代委托人开票 |
| 7 | 电商 | `XXXXXX1X` | 电商平台销售 |
| 8 | 出口 | `XXXXXXX1` | 货物/服务出口（零税率） |

| 完整值 | 场景 |
|--------|------|
| `00000000` | 标准（无特殊上下文） |
| `10000000` | 自由贸易区（FTZ） |
| `01000000` | 视同销售 |
| `00100000` | 利润差额方案 |
| `00010000` | 汇总发票 |
| `00001000` | 连续供应 |
| `00000100` | 显名代理 |
| `00000010` | 电商 |
| `00000001` | 出口 |

> 多位可组合（如 FTZ + 电商 = `10000010`）。默认 `00000000`。

---

### 5.4 贷记单原因码（BTAE-03）— 复用既有扩展

**位置：** 复用 `kdubl:PiaozoneExtension/kdubl:InvoiceDocumentReference/kdubl:DocumentIssuanceReasonCode`（与 SA/TH 同一扩展槽），值集换成阿联酋 UN/CEFACT `DL8.61.1.x`。

```xml
<kdubl:InvoiceDocumentReference>
    <kdubl:DocumentIssuanceReasonCode>DL8.61.1.D</kdubl:DocumentIssuanceReasonCode>
    <kdubl:DocumentIssuanceReason>goods or services returned</kdubl:DocumentIssuanceReason>
</kdubl:InvoiceDocumentReference>
```

| 码 | 含义 |
|----|------|
| `DL8.61.1.A` | 供应取消（supply cancelled） |
| `DL8.61.1.B` | 税务处理变更（tax treatment changed） |
| `DL8.61.1.C` | 对价变更（consideration altered） |
| `DL8.61.1.D` | 退货（goods/services returned） |
| `DL8.61.1.E` | 误征税额（tax charged in error） |
| `VD` | 批量折扣（volume discount） |

> 贷记单（`InvoiceTypeCode=381`）必填。

---

### 5.5 受限信息方 — `kdubl:RestrictedInformationParty`（新增）

**用途：** 承载「不作为记账买/卖方、但须上报的第三方 TRN」，UBL 标准无对应位置。

**位置（草案）：** `kdubl:PiaozoneExtension` 下新增 `kdubl:RestrictedInformationParty` 容器，嵌套标准 `cac:PartyIdentification`。

| `kdubl:Key` | 场景 |
|-------------|------|
| `Beneficiary` | 自由贸易区（FTZ）受益方（BTAE-01） |
| `Principle` | 显名代理委托人（BTAE-14） |

```xml
<kdubl:PiaozoneExtension>
    <kdubl:RestrictedInformationParty>
        <kdubl:Key>Beneficiary</kdubl:Key>
        <cac:PartyIdentification>
            <!-- BTAE-01：FTZ 受益方 TRN，须与记账买方 TRN 不同 -->
            <cbc:ID schemeID="AE:TRN">100000000000777</cbc:ID>
        </cac:PartyIdentification>
    </kdubl:RestrictedInformationParty>
</kdubl:PiaozoneExtension>
```

| 子标签 | 必填 | 含义 |
|--------|------|------|
| `kdubl:Key` | 是 | `Beneficiary` 或 `Principle` |
| `cac:PartyIdentification/cbc:ID` | 是 | 第三方 TRN，`@schemeID="AE:TRN"`（15 位，1 开头 03 结尾） |

> **约束**：`Principle` 的 TRN 必须与卖方 TRN 不同（显名代理的本质是代理他人开票）；`Beneficiary` 的 TRN 必须与记账买方不同（FTZ 受益方 ≠ 会计买方）。

---

### 5.6 自开票标识 — 复用通用 ADR

阿联酋自开票（self-billing）复用已有的**文档级 InvoiceTag ADR**，无需新增：

```xml
<cac:AdditionalDocumentReference>
    <cbc:ID schemeName="InvoiceTag">true</cbc:ID>
    <cbc:DocumentType>SelfBilled</cbc:DocumentType>
</cac:AdditionalDocumentReference>
```

| 值 | 含义 |
|----|------|
| `true` | 买方代开 |
| `false` | 常规（缺省） |

> 自开票在 KDUBL 层仍用类型码 `380`，不引入独立的自开票类型码。

---

### 5.7 外币双币种扩展（USD 开票 / AED 计税）— 复用 HU

阿联酋外币发票（`DocumentCurrencyCode=USD` + `TaxCurrencyCode=AED`）与匈牙利 HUF 双币种**同构**，直接复用 HU 的整套扩展，仅货币码换成 AED：

| 扩展 | 位置 |
|------|------|
| `kdubl:TaxCurrencyLegalMonetaryTotal` | 文档级 |
| `kdubl:TaxTotalExtensions` | 文档级 |
| `kdubl:TaxCurrencyTaxInclusiveLineExtensionAmount` | 行级 |
| `kdubl:TaxCurrencyLineExtensionAmount` | 行级 |
| `kdubl:TaxInclusiveLineExtensionAmount` | 行级 |

配套标准字段（非扩展）：`cbc:TaxCurrencyCode=AED` + `cac:TaxExchangeRate/cbc:CalculationRate`（如 1 USD = 3.6725 AED）+ 文档级双 `cac:TaxTotal`（第一个 USD、第二个 AED）。

> 详见 [HU_EXTENSIONS.md §4.4](../HU/HU_EXTENSIONS.md)。

---

### 5.8 商品分类枚举（标准字段，新增枚举）

商品分类走标准 UBL 节点（非扩展），但需在 KDUBL 补录这些字段及枚举：

| 字段 | XML 位置 | 枚举/说明 |
|------|---------|----------|
| 物品类型（BTAE-13） | `cac:CommodityClassification/cbc:CommodityCode` | `G`=货物 / `S`=服务 / `B`=混合 |
| HS 编码 | `cac:CommodityClassification/cbc:ItemClassificationCode @listID="HS"` | 仅 G/B 必填，如 `8413.70.10` |
| SAC 服务编码 | `cac:AdditionalItemIdentification/cbc:ID @schemeID="SAC"` | 仅 S，如 `9983.11` |
| NatureCode（BTAE-09） | `cac:CommodityClassification/cbc:NatureCode` | 逆向征收（AE 类）必填，如 `DL8.48.8.2` |
| GTIN | `cac:StandardItemIdentification/cbc:ID @schemeID="0160"` | 逆向征收（AE 类）必填 |

```xml
<cac:Item>
    <cbc:Name>Industrial pump</cbc:Name>
    <cac:CommodityClassification>
        <cbc:CommodityCode>G</cbc:CommodityCode>
        <cbc:ItemClassificationCode listID="HS">8413.70.10</cbc:ItemClassificationCode>
    </cac:CommodityClassification>
    <cac:ClassifiedTaxCategory>
        <cbc:ID>S</cbc:ID>
        <cbc:Percent>5.00</cbc:Percent>
        <cac:TaxScheme><cbc:ID>VAT</cbc:ID></cac:TaxScheme>
    </cac:ClassifiedTaxCategory>
</cac:Item>
```

---

### 5.9 完整示例（标准发票）

```xml
<Invoice xmlns="urn:piaozone:ExtensionComponent:1.0"
         xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
         xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
         xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2"
         xmlns:kdubl="urn:piaozone:ExtensionComponent:1.0">

    <cbc:CustomizationID>urn:piaozone.com:ubl-2.1-customizations:v1.0</cbc:CustomizationID>
    <cbc:ProfileID>urn:piaozone.com:profile:bill:v1.0</cbc:ProfileID>
    <cbc:ID>INV-AE-2026-00001</cbc:ID>
    <cbc:IssueDate>2026-04-04</cbc:IssueDate>
    <cbc:InvoiceTypeCode name="00000000">380</cbc:InvoiceTypeCode>
    <cbc:DocumentCurrencyCode>AED</cbc:DocumentCurrencyCode>

    <!-- 自开票标识（复用通用 ADR） -->
    <cac:AdditionalDocumentReference>
        <cbc:ID schemeName="InvoiceTag">false</cbc:ID>
        <cbc:DocumentType>SelfBilled</cbc:DocumentType>
    </cac:AdditionalDocumentReference>

    <cac:AccountingSupplierParty>
        <cac:Party>
            <cac:PartyIdentification>
                <!-- Peppol 参与方标识（TIN = TRN 前 10 位），值格式 0235:TIN -->
                <cbc:ID schemeID="PEPPOL">0235:1000000000</cbc:ID>
            </cac:PartyIdentification>
            <cac:PartyIdentification>
                <cbc:ID schemeID="AE:LRA">Department of Economic Development - Dubai</cbc:ID>
            </cac:PartyIdentification>
            <cac:PostalAddress>
                <cbc:StreetName>Sheikh Zayed Road, Office 1201</cbc:StreetName>
                <cbc:CityName>Dubai</cbc:CityName>
                <cbc:CountrySubentity>DXB</cbc:CountrySubentity>
                <cac:Country><cbc:IdentificationCode>AE</cbc:IdentificationCode></cac:Country>
            </cac:PostalAddress>
            <cac:PartyTaxScheme>
                <!-- TRN 15 位 -->
                <cbc:CompanyID>100000000000003</cbc:CompanyID>
                <cac:TaxScheme><cbc:ID>VAT</cbc:ID></cac:TaxScheme>
            </cac:PartyTaxScheme>
            <cac:PartyLegalEntity>
                <cbc:RegistrationName>Acme Trading LLC</cbc:RegistrationName>
                <!-- 贸易许可证 -->
                <cbc:CompanyID schemeID="AE:TL">CN-1234567</cbc:CompanyID>
            </cac:PartyLegalEntity>
        </cac:Party>
    </cac:AccountingSupplierParty>

    <!-- 买方省略（同构） -->

    <cac:TaxTotal>
        <cbc:TaxAmount currencyID="AED">50.00</cbc:TaxAmount>
        <cac:TaxSubtotal>
            <cbc:TaxableAmount currencyID="AED">1000.00</cbc:TaxableAmount>
            <cbc:TaxAmount currencyID="AED">50.00</cbc:TaxAmount>
            <cac:TaxCategory>
                <cbc:ID>S</cbc:ID>
                <cbc:Percent>5.00</cbc:Percent>
                <cac:TaxScheme><cbc:ID>VAT</cbc:ID></cac:TaxScheme>
            </cac:TaxCategory>
        </cac:TaxSubtotal>
    </cac:TaxTotal>

    <cac:LegalMonetaryTotal>
        <cbc:TaxExclusiveAmount currencyID="AED">1000.00</cbc:TaxExclusiveAmount>
        <cbc:TaxInclusiveAmount currencyID="AED">1050.00</cbc:TaxInclusiveAmount>
        <cbc:PayableAmount currencyID="AED">1050.00</cbc:PayableAmount>
    </cac:LegalMonetaryTotal>

    <cac:InvoiceLine>
        <cbc:ID>1</cbc:ID>
        <cbc:InvoicedQuantity unitCode="EA">10</cbc:InvoicedQuantity>
        <cbc:LineExtensionAmount currencyID="AED">1000.00</cbc:LineExtensionAmount>
        <cac:Item>
            <cbc:Name>Industrial pump</cbc:Name>
            <cac:CommodityClassification>
                <cbc:CommodityCode>G</cbc:CommodityCode>
                <cbc:ItemClassificationCode listID="HS">8413.70.10</cbc:ItemClassificationCode>
            </cac:CommodityClassification>
            <cac:ClassifiedTaxCategory>
                <cbc:ID>S</cbc:ID>
                <cbc:Percent>5.00</cbc:Percent>
                <cac:TaxScheme><cbc:ID>VAT</cbc:ID></cac:TaxScheme>
            </cac:ClassifiedTaxCategory>
        </cac:Item>
        <cac:Price>
            <cbc:PriceAmount currencyID="AED">100.00</cbc:PriceAmount>
        </cac:Price>
    </cac:InvoiceLine>
</Invoice>
```

---

### 5.10 校验规则速查（待落地）

| 规则 | 说明 |
|------|------|
| TRN 格式 | 15 位数字，以 `1` 开头、`03` 结尾 |
| 税率精确性 | `S` 税率必须精确 5.00 |
| 逆向征收（`AE` 类） | 买方 TRN 必填；行税额=0；NatureCode + GTIN 必填 |
| 利润差额（`N` 类） | 税率 5% 但 TaxAmount=0；BTAE-02 第 3 位置位 |
| 贷记单（381） | BTAE-03 原因码必填 |
| FTZ（BTAE-02 第 1 位） | `RestrictedInformationParty[Key=Beneficiary]` 必填 |
| 显名代理（BTAE-02 第 6 位） | `RestrictedInformationParty[Key=Principle]` 必填，且 TRN ≠ 卖方 TRN |
| 出口（BTAE-02 第 8 位） | 税类别 `Z`；`cac:Delivery` 块必填 |
| 电商（BTAE-02 第 7 位） | `cac:Delivery` 块必填 |
| 服务行（`S`） | 不携带 HS 码（仅 `CommodityCode`）；SAC 编码必填 |

---

### 5.11 待完善项

1. **受限信息方结构（§5.5）**：草案 `kdubl:RestrictedInformationParty` 结构待定稿；需确认是否复用一个容器支持多个 `kdubl:Key`。
2. **贷记原因码槽位（§5.4）**：确认复用 `kdubl:DocumentIssuanceReasonCode` 是否满足，或需单独新增 `kdubl:BillingReferenceExtension`。
3. **补充 KDUBL 示例文件**：`examples/country/AE/` 下尚缺各场景 KDUBL XML（标准/贷记/双币种/FTZ/代理/电商/出口等），待扩展定稿后补齐。
4. **同步 `kdubl-invoice-fields.yml`**：待本扩展定稿后回填——新增扩展 `RestrictedInformationParty`；`cbc:InvoiceTypeCode/@name` 的 BTAE-02 值集（八位旗标）；枚举（税类别 `N`、Emirate 码、schemeID 集含 PEPPOL/TIN）。
