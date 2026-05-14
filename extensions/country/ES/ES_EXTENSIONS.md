## 西班牙 (ES) 专用扩展

测试文件位于 `es/`。

---

### 1. 发票系列号 — InvoiceCode

**什么时候传：** 西班牙 VeriFactu 强制要求，有发票系列号时必填。

**传什么：** 发票系列号字符串，不允许包含 `/`。

```xml
<cac:AdditionalDocumentReference>
    <cbc:ID schemeName="InvoiceTag">INV</cbc:ID>
    <cbc:DocumentType>InvoiceCode</cbc:DocumentType>
</cac:AdditionalDocumentReference>
```

> 系统会将其与发票号（`cbc:ID`）拼接为 `INV/20260512001` 上报 SII（`NumSerieFacturaEmisor`）。发票号同样不允许包含 `/`。

---

### 2. 税务制度码 — TaxRegimeCode

**什么时候传：** 每个税率档（`cac:TaxSubtotal`）必填。

**传什么：** 按顺序与 `cac:TaxSubtotal` 一一对应，XSLT 自动按位置匹配，不需要填写 `index` 属性。绝大多数场景填 `01`。

| 值 | 说明 |
|----|------|
| `01` | 普通税制（Régimen general，最常用） |
| `02` | 出口业务（Exportación） |
| `03` | 休达/梅利利亚特殊税（IPSI） |
| `04` | 加那利群岛特殊税（IGIC） |
| `05` | 旅行社特殊方案（Agencias de viajes） |
| `06` | 二手货物/艺术品/古董特殊方案（Bienes usados） |
| `07` | 现金收付制（Criterio de caja） |
| `08` | 与 IPSI/IGIC 相关的业务 |
| `09` | 发票替代简化发票（Facturación de los destinatarios） |
| `10` | 代收代缴（Cobros por cuenta de terceros） |
| `11` | 租赁业务（Arrendamiento de local de negocio） |
| `12` | 非营业性实体（Entidades acogidas a RECC） |
| `13` | 发票对应多个年度（Factura con varias fechas） |
| `14` | 首次交付新建房产（Primera entrega de inmuebles） |
| `15` | 财政代表（Representante fiscal） |
| `16` | 农业/林业/渔业特殊方案（Régimen especial agropecuario） |

```xml
<kdubl:TaxSubtotalExtensions>
    <!-- 顺序与 cac:TaxTotal/cac:TaxSubtotal 一一对应，不需要填写 index 属性 -->
    <kdubl:TaxSubtotalExtension>
        <kdubl:TaxRegimeCode>01</kdubl:TaxRegimeCode>
    </kdubl:TaxSubtotalExtension>
</kdubl:TaxSubtotalExtensions>
```

> 对应 SII `ClaveRegimen`。

---

### 3. 业务类型 — OperationType

**什么时候传：** 买方国家非 ES 时必填。买方国家为 ES 时不需要传。

**传什么：**

| 值 | 说明 |
|----|------|
| `PRODUCT` | 纯货物交易 |
| `SERVICE` | 纯服务交易 |
| `PRODUCT_SERVICE` | 货物与服务混合 |

```xml
<kdubl:OperationType>SERVICE</kdubl:OperationType>
```

> 对应 SII `TipoDesglose` 下的业务分类节点（`Entrega` / `PrestacionServicios`）。

---

### 4. 第三方代开标志 — EmitidaPorTercerosODestinatario

**什么时候传：** 发票由第三方或受票方代开时填 `S`，普通场景不填（默认 `N`）。

**传什么：** `S`（是）/ `N`（否）

```xml
<kdubl:EmitidaPorTercerosODestinatario>S</kdubl:EmitidaPorTercerosODestinatario>
```

> 对应 SII `EmitidaPorTercerosODestinatario`。

---

### 5. 多买方标志 — VariosDestinatarios

**什么时候传：** 发票有多个买方时填 `S`，普通场景不填（默认 `N`）。

**传什么：** `S`（是）/ `N`（否）

```xml
<kdubl:VariosDestinatarios>S</kdubl:VariosDestinatarios>
```

> 对应 SII `VariosDestinatarios`。

---

### 6. 等价附加税 — RecargoEquivalencia

**什么时候传：** 适用等价附加税方案的零售商，在对应税率档填写。税率和税额必须同时填。

**传什么：** 放在对应 `TaxSubtotalExtension` 内，与 `TaxRegimeCode` 同级。

| 字段 | 说明 |
|------|------|
| `TipoRecargoEquivalencia` | 等价附加税税率（%） |
| `CuotaRecargoEquivalencia` | 等价附加税税额 |

常见税率对应关系：

| VAT 税率 | 等价附加税税率 |
|---------|-------------|
| 21% | 5.2% |
| 10% | 1.4% |
| 4% | 0.5% |

```xml
<kdubl:TaxSubtotalExtension>
    <kdubl:TaxRegimeCode>01</kdubl:TaxRegimeCode>
    <kdubl:TipoRecargoEquivalencia>5.2</kdubl:TipoRecargoEquivalencia>
    <kdubl:CuotaRecargoEquivalencia>52.00</kdubl:CuotaRecargoEquivalencia>
</kdubl:TaxSubtotalExtension>
```

> 对应 SII `TipoRecargoEquivalencia` / `CuotaRecargoEquivalencia`。

---

### 7. 纠正票专用扩展

**什么时候传：** `InvoiceTypeCode @name` 为 R1~R5 时必填。

#### 7.1 纠正票类型

```xml
<cbc:InvoiceTypeCode name="R1">384</cbc:InvoiceTypeCode>
```

| name 值 | 含义 |
|---------|------|
| `R1` | 普通纠正票 |
| `R2` | 简化发票纠正票 |
| `R3` | 代理人开具的纠正票 |
| `R4` | 简化发票代理人纠正票 |
| `R5` | 海关进口纠正票 |

#### 7.2 纠正方法 — CorrectionMethod

**传什么：**

| 值 | 说明 | OriginalTaxableAmount / OriginalTaxAmount |
|----|------|------------------------------------------|
| `S` | 替代法：整单作废，全额重开 | 必填 |
| `I` | 差额法：只记录差异部分 | 不需要 |

#### 7.3 原始发票信息

原始发票号通过标准 UBL `cac:BillingReference` 填写（非扩展字段）：

```xml
<cac:BillingReference>
    <cac:InvoiceDocumentReference>
        <cbc:ID>20260512001</cbc:ID>
        <cbc:IssueDate>2026-05-12</cbc:IssueDate>
    </cac:InvoiceDocumentReference>
</cac:BillingReference>
```

#### 7.4 完整纠正票扩展示例（替代法）

```xml
<kdubl:PiaozoneExtension>
    <kdubl:InvoiceDocumentReference>
        <kdubl:CorrectionMethod>S</kdubl:CorrectionMethod>
        <kdubl:OriginalInvoiceSeries>INV</kdubl:OriginalInvoiceSeries>
        <kdubl:OriginalTaxableAmount currencyID="EUR">1000.00</kdubl:OriginalTaxableAmount>
        <kdubl:OriginalTaxAmount currencyID="EUR">210.00</kdubl:OriginalTaxAmount>
    </kdubl:InvoiceDocumentReference>
    <kdubl:TaxSubtotalExtensions>
        <kdubl:TaxSubtotalExtension>
            <kdubl:TaxRegimeCode>01</kdubl:TaxRegimeCode>
        </kdubl:TaxSubtotalExtension>
    </kdubl:TaxSubtotalExtensions>
</kdubl:PiaozoneExtension>
```

---

### 8. PiaozoneExtension 完整结构示例

普通境内发票（最简场景）：

```xml
<kdubl:PiaozoneExtension>
    <kdubl:TaxSubtotalExtensions>
        <kdubl:TaxSubtotalExtension>
            <kdubl:TaxRegimeCode>01</kdubl:TaxRegimeCode>
        </kdubl:TaxSubtotalExtension>
    </kdubl:TaxSubtotalExtensions>
</kdubl:PiaozoneExtension>
```

境外买方 + 服务：

```xml
<kdubl:PiaozoneExtension>
    <kdubl:TaxSubtotalExtensions>
        <kdubl:TaxSubtotalExtension>
            <kdubl:TaxRegimeCode>01</kdubl:TaxRegimeCode>
        </kdubl:TaxSubtotalExtension>
    </kdubl:TaxSubtotalExtensions>
    <kdubl:OperationType>SERVICE</kdubl:OperationType>
</kdubl:PiaozoneExtension>
```
