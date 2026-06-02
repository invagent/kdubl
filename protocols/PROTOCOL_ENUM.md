# 协议枚举值（ProtocolEnum）

对应代码：`com.kingdee.enums.ProtocolEnum`

发票上报时通过 `protocol` 字段指定使用哪种协议，系统根据协议值决定转换逻辑和校验规则。

---

## 枚举值列表

| 枚举名 | code | CustomizationID | 适用国家/场景 |
|--------|------|-----------------|-------------|
| `PUF` | `PUF` | `urn:pagero.com:puf:billing:2.0` | 国际（Pagero 通用格式） |
| `PUF_SA` | `PUF_SA` | `urn:pagero.com:puf:billing:2.0` | 沙特（Pagero 通道） |
| `PUF_HU` | `PUF_HU` | `urn:pagero.com:puf:billing:2.0` | 匈牙利（Pagero 通道） |
| `BIS30` | `BIS30` | `urn:cen.eu:en16931:2017#compliant#urn:fdc:peppol.eu:2017:poacc:billing:3.0` | PEPPOL BIS 3.0 通用 |
| `BIS30_DE` | `BIS30_DE` | `urn:cen.eu:en16931:2017#compliant#urn:fdc:peppol.eu:2017:poacc:billing:3.0` | 德国（PEPPOL BIS 3.0） |
| `BIS30_NL` | `BIS30_NL` | `urn:cen.eu:en16931:2017#conformant#urn:fdc:nen.nl:nlcius:v1.0` | 荷兰（NLCIUS） |
| `BIS30_SA` | `BIS30_SA` | `urn:cen.eu:en16931:2017#compliant#urn:fdc:peppol.eu:2017:poacc:billing:3.0` | 沙特（PEPPOL BIS 3.0） |
| `BIS30_HU` | `BIS30_HU` | `urn:cen.eu:en16931:2017#compliant#urn:fdc:peppol.eu:2017:poacc:billing:3.0` | 匈牙利（PEPPOL BIS 3.0） |
| `PINT_SG` | `PINT_SG` | `urn:peppol:pint:billing-1@sg-1` | 新加坡（PINT） |
| `PINT_MY` | `PINT_MY` | `urn:piaozone.com:ubl-2.1-customizations:v1.0` | 马来西亚（PINT MyInvois） |
| `KDUBL` | `KDUBL` | `urn:piaozone.com:ubl-2.1-customizations:v1.0` | 通用 KDUBL |
| `KDUBL_HK` | `KDUBL_HK` | `urn:piaozone.com:ubl-2.1-customizations:v1.0` | 香港 |
| `KDUBL_VN` | `KDUBL_VN` | `urn:piaozone.com:ubl-2.1-customizations:v1.0` | 越南（开票） |
| `KDUBL_VN_REPORT` | `KDUBL_VN_REPORT` | `urn:piaozone.com:ubl-2.1-customizations:v1.0` | 越南（报告票） |
| `KDUBL_TH` | `KDUBL_TH` | `urn:piaozone.com:ubl-2.1-customizations:v1.0` | 泰国 |
| `KDUBL_MO` | `KDUBL_MO` | `urn:piaozone.com:ubl-2.1-customizations:v1.0` | 澳门 |
| `BIS_SG` | `BIS_SG` | `urn:cen.eu:en16931:2017#conformant#urn:fdc:peppol.eu:2017:poacc:billing:international:sg:3.0` | 新加坡（BIS SG 本地化） |
| `BIS_SG_PEPPOL` | `BIS_SG_PEPPOL` | `urn:cen.eu:en16931:2017#conformant#urn:fdc:peppol.eu:2017:poacc:billing:international:sg:3.0` | 新加坡（BIS SG PEPPOL 网络） |
| `NAV_HU` | `NAV_HU` | `urn:nav.gov.hu:osa:3.0` | 匈牙利（NAV RTIR 直连） |
| `SII_ES` | `SII_ES` | `https://www2.agenciatributaria.gob.es/static_files/common/internet/dep/aplicaciones/es/aeat/ssii/fact/ws/SuministroLR.xsd` | 西班牙（SII SOAP 上报） |
| `SII_ES_CSV` | `SII_ES_CSV` | `https://www2.agenciatributaria.gob.es/static_files/common/internet/dep/aplicaciones/es/aeat/ssii/fact/ws/SuministroLR.xsd` | 西班牙（SII CSV 格式上报） |
| `UBL_COMMON_NA` | `UBL-COMMON-NA` | `urn:piaozone.com:ubl-2.1-customizations:v1.0` | 不适用（内部占位协议） |

---

## 按国家/地区分组

| 国家/地区 | 可用协议 code |
|----------|-------------|
| 新加坡 | `PINT_SG`、`BIS_SG`、`BIS_SG_PEPPOL` |
| 马来西亚 | `PINT_MY` |
| 泰国 | `KDUBL_TH` |
| 越南 | `KDUBL_VN`、`KDUBL_VN_REPORT` |
| 香港 | `KDUBL_HK` |
| 澳门 | `KDUBL_MO` |
| 西班牙 | `SII_ES`、`SII_ES_CSV` |
| 匈牙利 | `NAV_HU`、`PUF_HU`、`BIS30_HU` |
| 沙特 | `PUF_SA`、`BIS30_SA` |
| 德国 | `BIS30_DE` |
| 荷兰 | `BIS30_NL` |
| 国际通用 | `PUF`、`BIS30`、`KDUBL` |

---

## 说明

- `CustomizationID` 是 KDUBL XML 中 `cbc:CustomizationID` 字段的值，系统通过此值反向识别协议类型。
- 同一 `CustomizationID` 可对应多个协议（如多个 KDUBL 系协议共用同一 CustomizationID），区分依赖 `protocol` 字段显式指定。
- `UBL_COMMON_NA` 为内部占位协议，不对外开放。
