# 🚀 Rocky Linux 9 with Microsoft Entra ID SSH Login

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgokhansalihyenigun%2Frocky-linux-entra-id%2Fmaster%2Fazuredeploy.json)
[![Deploy to Azure US Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgokhansalihyenigun%2Frocky-linux-entra-id%2Fmaster%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fgokhansalihyenigun%2Frocky-linux-entra-id%2Fmaster%2Fazuredeploy.json)

> **Tek tıkla** Microsoft Entra ID (Azure AD) ile SSH authentication, Azure Monitor entegrasyonu ve kapsamlı logging özelliklerine sahip Rocky Linux 9 sanal makinesi deploy edin.

---

## 📋 İçindekiler

- [🎯 Nedir Bu?](#-nedir-bu)
- [✨ Özellikler](#-özellikler)
- [🏗️ Mimari](#️-mimari)
- [🚀 Hızlı Başlangıç](#-hızlı-başlangıç)
- [📊 Deployment Sonrası](#-deployment-sonrası)
- [🔐 Entra ID SSH Nasıl Çalışır?](#-entra-id-ssh-nasıl-çalışır)
- [📈 Monitoring & Logging](#-monitoring--logging)
- [🔧 Parametreler](#-parametreler)
- [💰 Maliyet Tahmini](#-maliyet-tahmini)
- [🛠️ Sorun Giderme](#️-sorun-giderme)
- [📚 Kaynaklar](#-kaynaklar)

---

## 🎯 Nedir Bu?

Bu proje, Azure'da **Rocky Linux 9** sanal makinesi oluşturur ve **Microsoft Entra ID** (eski adıyla Azure Active Directory) ile **SSH authentication** sağlar. Geleneksel SSH key veya password yönetimi yerine, **Azure kullanıcı hesabınızla** direkt SSH bağlantısı kurarsınız.

### 🌟 Ana Avantajlar

| Özellik | Geleneksel SSH | Entra ID SSH |
|---------|----------------|--------------|
| **Authentication** | SSH Key / Password | Azure Account |
| **Key Yönetimi** | Manuel | Otomatik |
| **Merkezi Yönetim** | Yok | Azure RBAC |
| **Audit Trail** | VM logları | Azure + VM logları |
| **MFA Desteği** | Yok | ✅ Var |
| **Conditional Access** | Yok | ✅ Var |

---

## ✨ Özellikler

### 🔐 Güvenlik
- ✅ **Microsoft Entra ID Integration** - Certificate-based SSH authentication
- ✅ **RBAC Entegrasyonu** - Azure rol tabanlı erişim kontrolü
- ✅ **MFA Desteği** - Multi-factor authentication uyumlu
- ✅ **Conditional Access** - Konum, cihaz, risk bazlı politikalar
- ✅ **Managed Identity** - Azure kaynaklarına güvenli erişim
- ✅ **Standard Public IP** - Static IP, güvenli networking

### 📊 Monitoring & Observability
- ✅ **Azure Monitor Agent** - Modern, lightweight monitoring
- ✅ **Log Analytics Workspace** - 30 gün log retention
- ✅ **Data Collection Rules** - Özelleştirilebilir log toplama
- ✅ **Syslog Collection** - SSH, sudo, auth logları
- ✅ **Performance Metrics** - CPU, Memory, Disk metrikleri
- ✅ **KQL Query Support** - Güçlü log analizi

### 🖥️ Platform
- ✅ **Rocky Linux 9.6** - 2032'ye kadar destek
- ✅ **Premium SSD** - Yüksek performans disk
- ✅ **Flexible VM Sizes** - B1s'den D-Series'e kadar
- ✅ **Germany West Central** - Varsayılan bölge

---

## 🏗️ Mimari

### Sistem Mimarisi

```
┌─────────────────────────────────────────────────────────────────┐
│                        Azure Cloud                              │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │           Resource Group: RockyLinuxEntraID               │  │
│  │                                                            │  │
│  │  ┌─────────────────────────────────────────────────────┐ │  │
│  │  │         Virtual Network (10.0.0.0/16)               │ │  │
│  │  │                                                       │ │  │
│  │  │  ┌────────────────────────────────────────────────┐ │ │  │
│  │  │  │    Subnet (10.0.0.0/24)                        │ │ │  │
│  │  │  │                                                  │ │ │  │
│  │  │  │  ┌──────────────────────────────────────────┐  │ │ │  │
│  │  │  │  │   Rocky Linux 9 VM                       │  │ │ │  │
│  │  │  │  │                                            │  │ │ │  │
│  │  │  │  │   📦 Extensions:                          │  │ │ │  │
│  │  │  │  │   ├─ AADSSHLoginForLinux                 │  │ │ │  │
│  │  │  │  │   └─ AzureMonitorLinuxAgent              │  │ │ │  │
│  │  │  │  │                                            │  │ │ │  │
│  │  │  │  │   🔒 Managed Identity: System-Assigned   │  │ │ │  │
│  │  │  │  │   💾 OS Disk: Premium SSD (30GB)         │  │ │ │  │
│  │  │  │  └──────────────────────────────────────────┘  │ │ │  │
│  │  │  │            │                                    │ │ │  │
│  │  │  │            │ Network Interface                 │ │ │  │
│  │  │  └────────────┼────────────────────────────────────┘ │ │  │
│  │  │               │                                      │ │  │
│  │  └───────────────┼──────────────────────────────────────┘ │  │
│  │                  │                                        │  │
│  │      ┌───────────┴──────────┐     ┌─────────────────┐   │  │
│  │      │ Public IP (Static)   │     │ Network NSG     │   │  │
│  │      │ 135.220.44.69        │     │ SSH: 22 (Open)  │   │  │
│  │      └──────────────────────┘     └─────────────────┘   │  │
│  │                                                           │  │
│  │  ┌────────────────────────────────────────────────────┐ │  │
│  │  │  Log Analytics Workspace                           │ │  │
│  │  │  - Syslog (auth, authpriv, sudo)                   │ │  │
│  │  │  - Performance Counters (CPU, Memory, Disk)        │ │  │
│  │  │  - 30-day retention                                 │ │  │
│  │  └────────────────────────────────────────────────────┘ │  │
│  │                                                           │  │
│  │  ┌────────────────────────────────────────────────────┐ │  │
│  │  │  Data Collection Rule (DCR)                        │ │  │
│  │  │  - Defines what logs to collect                    │ │  │
│  │  │  - Routes data to Log Analytics                    │ │  │
│  │  └────────────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │           Microsoft Entra ID (Azure AD)                  │  │
│  │  - User Authentication                                    │  │
│  │  - Role-Based Access Control (RBAC)                      │  │
│  │  - Sign-in Logs                                           │  │
│  │  - Audit Logs                                             │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Entra ID SSH Authentication Akışı

```
┌─────────────┐                                    ┌──────────────┐
│   User PC   │                                    │  Azure VM    │
│             │                                    │ Rocky Linux  │
└──────┬──────┘                                    └──────┬───────┘
       │                                                  │
       │  1. az ssh vm -n myVM -g myRG                   │
       ├─────────────────────────────────────┐           │
       │                                     │           │
       │                      ┌──────────────▼────────┐  │
       │                      │  Azure CLI            │  │
       │                      │  - Checks auth        │  │
       │                      └──────────┬────────────┘  │
       │                                 │               │
       │                    2. Request SSH Certificate   │
       │                                 │               │
       │                      ┌──────────▼────────────┐  │
       │                      │  Microsoft Entra ID   │  │
       │                      │  - Validates user     │  │
       │                      │  - Checks MFA         │  │
       │                      │  - Issues certificate │  │
       │                      └──────────┬────────────┘  │
       │                                 │               │
       │              3. Temporary SSH Certificate       │
       │  ◄──────────────────────────────┘               │
       │                                                 │
       │  4. SSH with Certificate                        │
       ├─────────────────────────────────────────────────►
       │                                                 │
       │                                  ┌──────────────▼─────┐
       │                                  │ AADSSHLoginForLinux│
       │                                  │ Extension          │
       │                                  │ - Validates cert   │
       │                                  │ - Checks RBAC      │
       │                                  └──────────┬─────────┘
       │                                             │
       │  5. Check RBAC Permissions                 │
       │                      ┌─────────────────────▼────┐
       │                      │  Azure RBAC              │
       │                      │  VM Administrator Login  │
       │                      │  or VM User Login        │
       │                      └─────────────────────┬────┘
       │                                            │
       │                      6. Grant/Deny Access  │
       │  ◄─────────────────────────────────────────┘
       │                                                 │
       │  7. Shell Access                                │
       ├─────────────────────────────────────────────────►
       │                                                 │
       │  [user@domain.com@rocky-vm ~]$                 │
       │                                                 │
```

### Monitoring & Logging Akışı

```
┌──────────────────────────────────────────────────────────────┐
│                        Rocky Linux VM                        │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  System Events & Logs                                  │ │
│  │  ├─ /var/log/secure      (SSH, sudo, auth)            │ │
│  │  ├─ /var/log/messages    (System)                     │ │
│  │  ├─ journalctl           (Systemd)                    │ │
│  │  └─ Performance metrics  (CPU, Memory, Disk)          │ │
│  └────────────────────────┬───────────────────────────────┘ │
│                           │                                 │
│  ┌────────────────────────▼───────────────────────────────┐ │
│  │  Azure Monitor Agent (AMA)                             │ │
│  │  - Collects syslog                                     │ │
│  │  - Collects perf counters                              │ │
│  │  - Sends to Log Analytics                              │ │
│  └────────────────────────┬───────────────────────────────┘ │
└───────────────────────────┼─────────────────────────────────┘
                            │
                            │ Secure Transfer
                            │
┌───────────────────────────▼─────────────────────────────────┐
│               Log Analytics Workspace                        │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Syslog Table                                          │ │
│  │  - SSH login attempts (success/failed)                 │ │
│  │  - Sudo command execution                              │ │
│  │  - Authentication events                               │ │
│  │  - Security events                                     │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Performance Table                                     │ │
│  │  - CPU usage                                           │ │
│  │  - Memory usage                                        │ │
│  │  - Disk usage                                          │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  📊 Query with KQL (Kusto Query Language)                   │
│  📈 Create dashboards & workbooks                           │
│  🚨 Set up alerts                                           │
└──────────────────────────────────────────────────────────────┘
                            │
                            │ Query & Visualize
                            │
┌───────────────────────────▼─────────────────────────────────┐
│                   Azure Portal / CLI                         │
│  - Run KQL queries                                          │
│  - View dashboards                                          │
│  - Check alerts                                             │
│  - Download logs                                            │
└──────────────────────────────────────────────────────────────┘
```

---

## 🚀 Hızlı Başlangıç

### Ön Koşullar

- ✅ Azure subscription
- ✅ Azure CLI kurulu (lokal deployment için)
- ✅ Uygun Azure izinleri:
  - VM oluşturma
  - RBAC rol atama
  - Log Analytics workspace oluşturma

### Method 1: Deploy to Azure Button (ÖNERİLEN) 🎯

**En kolay yöntem - tek tıkla deployment!**

1. **Butona tıklayın** ⬆️ (Sayfanın en üstünde)
2. Azure Portal'a yönlendirileceksiniz
3. Parametreleri doldurun:
   - **Resource Group**: Mevcut veya yeni (ör: `RockyLinuxEntraID`)
   - **Region**: `Germany West Central` (önerilen)
   - **VM Name**: `my-rocky-vm`
   - **Admin Username**: `azureuser`
   - **Authentication Type**: `sshPublicKey` veya `password`
   - **Admin Password Or Key**: SSH public key veya güçlü şifre
   - **VM Size**: `Standard_B2s` (varsayılan)
   - **Enable Monitoring**: `true` (önerilen)
4. **Review + Create** → **Create**
5. Deployment 5-10 dakika sürer ☕

### Method 2: Azure CLI

```bash
# 1. Resource group oluştur
az group create \
  --name RockyLinuxEntraID \
  --location germanywestcentral

# 2. Template'i deploy et
az deployment group create \
  --resource-group RockyLinuxEntraID \
  --template-uri https://raw.githubusercontent.com/gokhansalihyenigun/rocky-linux-entra-id/master/azuredeploy.json \
  --parameters \
    vmName=my-rocky-vm \
    adminUsername=azureuser \
    authenticationType=sshPublicKey \
    adminPasswordOrKey="$(cat ~/.ssh/id_rsa.pub)" \
    vmSize=Standard_B2s \
    enableMonitoring=true
```

### Method 3: Azure Portal (Manuel)

1. Azure Portal → **Create a resource**
2. **Template deployment (deploy using custom templates)** ara
3. **Build your own template in the editor**
4. `azuredeploy.json` içeriğini yapıştır
5. **Save** → Parametreleri doldur → **Review + Create**

---

## 📊 Deployment Sonrası

### 1️⃣ RBAC Rol Ataması (ZORUNLU)

Entra ID ile SSH yapabilmek için RBAC rolü atamanız gerekir:

#### Azure Portal:
1. **VM** → **Access control (IAM)**
2. **Add** → **Add role assignment**
3. **Role**: `Virtual Machine Administrator Login` veya `Virtual Machine User Login`
4. **Assign access to**: User, group, or service principal
5. Kullanıcınızı seçin → **Save**

#### Azure CLI:
```bash
# Mevcut kullanıcınız için
az role assignment create \
  --role "Virtual Machine Administrator Login" \
  --assignee $(az account show --query user.name -o tsv) \
  --scope $(az vm show -g RockyLinuxEntraID -n my-rocky-vm --query id -o tsv)

# Başka bir kullanıcı için
az role assignment create \
  --role "Virtual Machine User Login" \
  --assignee "user@company.com" \
  --scope $(az vm show -g RockyLinuxEntraID -n my-rocky-vm --query id -o tsv)
```

#### Rol Farkları:

| Özellik | Administrator Login | User Login |
|---------|---------------------|------------|
| SSH Access | ✅ | ✅ |
| sudo Rights | ✅ | ❌ |
| root Commands | ✅ | ❌ |
| Kullanım | Yöneticiler | Normal kullanıcılar |

### 2️⃣ VM'e Bağlanma

#### Method A: Entra ID ile SSH (ÖNERİLEN)

```bash
# Azure CLI ile (otomatik certificate alır)
az ssh vm -n my-rocky-vm -g RockyLinuxEntraID

# Veya username belirterek
az ssh vm -n my-rocky-vm -g RockyLinuxEntraID --local-user $(az account show --query user.name -o tsv)
```

**Bağlantı başarılı olursa:**
```
[user@domain.com@my-rocky-vm ~]$
```
👆 Kullanıcı adınızda Entra ID email adresi görünür!

#### Method B: Geleneksel SSH

```bash
# Public IP'yi al
az vm show -d -g RockyLinuxEntraID -n my-rocky-vm --query publicIps -o tsv

# SSH bağlantısı
ssh azureuser@<PUBLIC_IP>
```

#### Method C: Azure Cloud Shell

1. [Azure Portal](https://portal.azure.com) → **Cloud Shell** (üst menüde terminal ikonu)
2. **Bash** seç
3. Komut çalıştır:
```bash
az ssh vm -n my-rocky-vm -g RockyLinuxEntraID
```

### 3️⃣ İlk Bağlantı Testi

VM'e bağlandıktan sonra:

```bash
# Kim olduğunu kontrol et
whoami
# Çıktı: user@domain.com  (Entra ID ile)
# veya: azureuser           (Normal SSH ile)

# Sudo yetkini test et
sudo whoami
# Çıktı: root  (Administrator Login role sahipsen)

# Rocky Linux versiyonu
cat /etc/rocky-release
# Çıktı: Rocky Linux release 9.6 (Blue Onyx)

# Sistem bilgisi
uname -a
hostnamectl
```

### 4️⃣ Monitoring Kontrolü

```bash
# Azure Monitor Agent durumu
sudo systemctl status azuremonitoragent

# Log Analytics bağlantısı
sudo cat /var/opt/microsoft/azuremonitoragent/log/mdsd.info

# Data Collection Rule durumu
sudo /opt/microsoft/azuremonitoragent/bin/troubleshooter
```

**Azure Portal'dan:**
1. **VM** → **Insights**
2. **Logs** → KQL query çalıştır:
```kusto
Syslog
| where TimeGenerated > ago(1h)
| where Computer contains "my-rocky-vm"
| take 50
```

---

## 🔐 Entra ID SSH Nasıl Çalışır?

### Geleneksel SSH vs Entra ID SSH

#### Geleneksel SSH:
```
1. SSH key pair oluştur (ssh-keygen)
2. Public key'i VM'e ekle
3. Private key ile bağlan
4. Her VM için ayrı key yönetimi
```

#### Entra ID SSH:
```
1. Azure'a giriş yap (az login)
2. RBAC rolü al
3. Bağlan (az ssh vm)
4. Azure otomatik certificate yönetir
```

### Certificate-Based Authentication

```
┌─────────────────────────────────────────────────────────────┐
│  1. az ssh vm -n myVM -g myRG                               │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  2. Azure CLI → Entra ID                                    │
│     "Bu kullanıcı için SSH certificate ver"                 │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  3. Entra ID Kontroller:                                    │
│     ✓ Kullanıcı geçerli mi?                                 │
│     ✓ MFA gerekli mi? Yapıldı mı?                          │
│     ✓ Conditional Access politikaları OK?                   │
│     ✓ Kullanıcının bu VM'e RBAC yetkisi var mı?            │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  4. Geçici SSH Certificate Üret                             │
│     - Kullanıcı adı: user@domain.com                        │
│     - Geçerlilik: 1 saat                                    │
│     - İmza: Azure tarafından                                │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  5. Certificate ile VM'e SSH                                │
│     ssh -i <certificate> user@domain.com@vm-ip              │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  6. VM'deki AADSSHLoginForLinux Extension:                  │
│     ✓ Certificate geçerli mi?                               │
│     ✓ İmza doğru mu?                                        │
│     ✓ Süresi dolmamış mı?                                   │
│     ✓ RBAC rolüne göre sudo ver/verme                       │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  7. Shell Access Granted! 🎉                                │
│     [user@domain.com@myvm ~]$                               │
└─────────────────────────────────────────────────────────────┘
```

### Güvenlik Avantajları

1. **Merkezi Key Yönetimi**: SSH key'leri Azure yönetir
2. **Automatic Rotation**: Certificate'lar otomatik yenilenir
3. **MFA Enforcement**: Multi-factor authentication zorunlu tutulabilir
4. **Conditional Access**: Konum, cihaz, risk bazlı erişim
5. **Audit Trail**: Tüm girişler Entra ID'de loglanır
6. **Instant Revocation**: Kullanıcı silinirse anında erişim kesilir
7. **No Password/Key Storage**: Local'de hassas data yok

---

## 📈 Monitoring & Logging

### Toplanan Veriler

#### Syslog (Auth & Security):
```
✅ SSH login attempts (successful & failed)
✅ Sudo command execution
✅ Authentication events
✅ System daemon logs
✅ Kernel messages
✅ Cron job execution
```

#### Performance Metrics:
```
✅ CPU usage (%)
✅ Memory available (MB)
✅ Disk used space (%)
✅ Network traffic
✅ Process count
✅ System load
```

### KQL Query Örnekleri

#### 1. SSH Girişlerini Gör
```kusto
Syslog
| where Facility == "authpriv"
| where SyslogMessage contains "Accepted"
| project TimeGenerated, Computer, HostIP, SyslogMessage
| order by TimeGenerated desc
| take 50
```

#### 2. Entra ID Kullanıcıları
```kusto
Syslog
| where SyslogMessage contains "@"  // Email içerenler
| where SyslogMessage contains "Accepted"
| extend User = extract(@"for ([^\s]+)", 1, SyslogMessage)
| project TimeGenerated, User, HostIP
| order by TimeGenerated desc
```

#### 3. Başarısız Login Denemeleri
```kusto
Syslog
| where Facility == "authpriv"
| where SyslogMessage contains "Failed"
| summarize FailedAttempts=count() by HostIP, bin(TimeGenerated, 1h)
| where FailedAttempts > 3
| order by FailedAttempts desc
```

#### 4. Sudo Kullanımı
```kusto
Syslog
| where SyslogMessage contains "sudo"
| where SyslogMessage contains "COMMAND"
| extend User = extract(@"USER=([^\s]+)", 1, SyslogMessage)
| extend Command = extract(@"COMMAND=(.+)", 1, SyslogMessage)
| project TimeGenerated, User, Command
| order by TimeGenerated desc
```

#### 5. CPU Kullanımı (>80%)
```kusto
Perf
| where ObjectName == "Processor"
| where CounterName == "% Processor Time"
| where CounterValue > 80
| project TimeGenerated, Computer, CounterValue
| render timechart
```

### Dashboard Oluşturma

1. **Azure Portal** → **Dashboards** → **New dashboard**
2. **Add tile** → **Markdown**
3. Başlık ekle: "Rocky Linux Monitoring"
4. **Add tile** → **Logs**
5. KQL query'leri ekle
6. **Pin to dashboard**

### Alert Kurma

#### Brute Force Alert:
```kusto
Syslog
| where Facility == "authpriv"
| where SyslogMessage contains "Failed"
| summarize FailedCount = count() by HostIP, bin(TimeGenerated, 5m)
| where FailedCount > 5
```

**Alert Ayarları:**
- Threshold: >= 1
- Evaluation frequency: 5 minutes
- Action: Email notification

---

## 🔧 Parametreler

| Parametre | Tip | Varsayılan | Açıklama |
|-----------|-----|------------|----------|
| `vmName` | string | `rocky-linux-vm` | VM adı (1-15 karakter, alfanumerik ve tire) |
| `adminUsername` | string | `azureuser` | Local admin kullanıcı adı |
| `vmSize` | string | `Standard_B2s` | VM boyutu (B1s, B2s, B4ms, D2s_v3, D4s_v3) |
| `location` | string | `resourceGroup().location` | Azure bölgesi |
| `authenticationType` | string | `sshPublicKey` | Authentication tipi (sshPublicKey/password) |
| `adminPasswordOrKey` | securestring | - | SSH public key veya password (ZORUNLU) |
| `enableMonitoring` | bool | `true` | Azure Monitor & Log Analytics aktif et |
| `workspaceName` | string | `law-{vmName}` | Log Analytics Workspace adı |

### VM Size Seçimi

| Size | vCPU | RAM | Disk | Kullanım Senaryosu | Aylık Maliyet (EUR) |
|------|------|-----|------|-------------------|---------------------|
| `Standard_B1s` | 1 | 1 GB | 4 GB | Test/Dev, minimal iş yükleri | ~7-10 |
| `Standard_B2s` | 2 | 4 GB | 8 GB | **Önerilen**, küçük-orta iş yükleri | ~15-25 |
| `Standard_B4ms` | 4 | 16 GB | 16 GB | Orta iş yükleri, veritabanı | ~60-80 |
| `Standard_D2s_v3` | 2 | 8 GB | 16 GB | Genel amaçlı, performans | ~70-90 |
| `Standard_D4s_v3` | 4 | 16 GB | 32 GB | Yüksek performans | ~140-180 |

---

## 💰 Maliyet Tahmini

### Aylık Tahmini Maliyet (Germany West Central)

#### Minimal Konfigürasyon:
```
VM (Standard_B1s)           : ~€8
Premium SSD (30GB)          : ~€4
Standard Public IP (Static) : ~€3
Log Analytics (5GB/month)   : Ücretsiz (ilk 5GB)
────────────────────────────────────
Toplam                      : ~€15/ay
```

#### Önerilen Konfigürasyon:
```
VM (Standard_B2s)           : ~€20
Premium SSD (30GB)          : ~€4
Standard Public IP (Static) : ~€3
Log Analytics (10GB/month)  : ~€2
Azure Monitor               : Dahil
────────────────────────────────────
Toplam                      : ~€29/ay
```

#### Production Konfigürasyon:
```
VM (Standard_D2s_v3)        : ~€85
Premium SSD (128GB)         : ~€20
Standard Public IP (Static) : ~€3
Log Analytics (50GB/month)  : ~€10
────────────────────────────────────
Toplam                      : ~€118/ay
```

**💡 Maliyet Tasarrufu İpuçları:**
- VM'i kullanmadığınızda `deallocate` yapın
- Dev/Test için `B-Series` burstable VM'ler ideal
- Log retention'ı ihtiyaç kadar tutun
- Scheduled auto-shutdown ayarlayın

---

## 🛠️ Sorun Giderme

### Problem: SSH Bağlantı Hatası

#### Azure CLI Extension Sorunu
```bash
# Hata: PermissionError: [WinError 5] Access is denied
# Çözüm: Administrator PowerShell'de
az extension remove --name support
az extension add --name ssh
```

#### Extension Kurulum Kontrolü
```bash
# VM'deki extension'ları kontrol et
az vm extension list \
  --resource-group RockyLinuxEntraID \
  --vm-name my-rocky-vm \
  --query "[].{Name:name, State:provisioningState}" -o table

# AADSSHLoginForLinux "Succeeded" olmalı
```

#### RBAC Kontrolü
```bash
# Rol atamalarını kontrol et
az role assignment list \
  --scope $(az vm show -g RockyLinuxEntraID -n my-rocky-vm --query id -o tsv) \
  --assignee $(az account show --query user.name -o tsv) \
  -o table
```

### Problem: Monitoring Çalışmıyor

```bash
# VM içinde Azure Monitor Agent kontrolü
sudo systemctl status azuremonitoragent

# Agent log'ları
sudo cat /var/opt/microsoft/azuremonitoragent/log/mdsd.err

# Data Collection Rule kontrolü
az monitor data-collection rule show \
  --resource-group RockyLinuxEntraID \
  --name dcr-my-rocky-vm
```

### Problem: "Permission Denied" (sudo)

```bash
# RBAC rolünü kontrol et
# "VM User Login" → sudo YOK
# "VM Administrator Login" → sudo VAR

# Rolü değiştir:
az role assignment create \
  --role "Virtual Machine Administrator Login" \
  --assignee "user@domain.com" \
  --scope $(az vm show -g RockyLinuxEntraID -n my-rocky-vm --query id -o tsv)
```

### Problem: VM'e Hiç Bağlanamıyorum

#### Alternatif 1: Serial Console
1. Azure Portal → VM → **Support + troubleshooting** → **Serial console**
2. VM içine giriş yap (local user ile)
3. Log'ları kontrol et:
```bash
sudo journalctl -u aad-login -n 100
sudo tail -f /var/log/secure
```

#### Alternatif 2: Boot Diagnostics
1. Azure Portal → VM → **Boot diagnostics**
2. Screenshot ve serial log'a bak
3. Sistem boot oluyor mu kontrol et

#### Alternatif 3: Reset SSH
```bash
# SSH konfigürasyonunu reset et
az vm user update \
  --resource-group RockyLinuxEntraID \
  --name my-rocky-vm \
  --username azureuser \
  --ssh-key-value "$(cat ~/.ssh/id_rsa.pub)"
```

### Detaylı Troubleshooting Rehberi

📖 **[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)** - Kapsamlı sorun giderme rehberi  
📖 **[MONITORING-GUIDE.md](./MONITORING-GUIDE.md)** - Monitoring ve logging detayları

---

## 📚 Kaynaklar

### Official Documentation
- 📘 [Microsoft Entra ID Linux VM Login](https://learn.microsoft.com/en-us/entra/identity/devices/howto-vm-sign-in-azure-ad-linux)
- 📘 [Azure Monitor Agent](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-overview)
- 📘 [Rocky Linux Official Docs](https://docs.rockylinux.org/)
- 📘 [Azure VM Pricing](https://azure.microsoft.com/pricing/details/virtual-machines/linux/)

### Bu Proje
- 🔧 [MONITORING-GUIDE.md](./MONITORING-GUIDE.md) - Monitoring & logging rehberi
- 🔧 [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) - Sorun giderme rehberi
- 🔧 [TEST-RESULTS.md](./TEST-RESULTS.md) - Test sonuçları
- 🔧 [QUICKSTART.md](./QUICKSTART.md) - Hızlı başlangıç

### Community
- 💬 [GitHub Issues](https://github.com/gokhansalihyenigun/rocky-linux-entra-id/issues)
- 💬 [Rocky Linux Forums](https://forums.rockylinux.org/)
- 💬 [Azure Community](https://techcommunity.microsoft.com/t5/azure/ct-p/Azure)

---

## 🤝 Katkıda Bulunma

Katkılar memnuniyetle karşılanır! 

1. Bu repository'yi fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request açın

---

## 📄 Lisans

MIT License - detaylar için [LICENSE](LICENSE) dosyasına bakın.

---

## ⭐ Teşekkürler

Bu template'i kullandıysanız, repository'ye ⭐ vermeyi unutmayın!

---

<div align="center">

**[⬆ Başa Dön](#-rocky-linux-9-with-microsoft-entra-id-ssh-login)**

Made with ❤️ for the Azure & Rocky Linux community

**[Deploy to Azure](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgokhansalihyenigun%2Frocky-linux-entra-id%2Fmaster%2Fazuredeploy.json)** | 
**[GitHub](https://github.com/gokhansalihyenigun/rocky-linux-entra-id)** | 
**[Issues](https://github.com/gokhansalihyenigun/rocky-linux-entra-id/issues)**

</div>