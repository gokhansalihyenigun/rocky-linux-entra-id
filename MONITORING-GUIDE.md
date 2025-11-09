# 🔍 Monitoring, Logging & Audit Rehberi

## 📊 Deploy to Azure ile Otomatik Kurulum

Template deploy edildiğinde **otomatik olarak** şunlar kurulur:

### ✅ Dahil Olan Özellikler:

1. **Log Analytics Workspace** 📊
   - 30 gün log retention
   - Tüm sistem ve uygulama logları
   - KQL query desteği

2. **Azure Monitor Agent** 🔧
   - Syslog collection
   - Performance metrics
   - Security events

3. **Dependency Agent** 🔗
   - Network connections
   - Process dependencies
   - Service map

4. **Entra ID Audit Logs** 🔐
   - SSH girişleri
   - RBAC değişiklikleri
   - Authentication events

---

## 🎯 1. AZURE PORTAL'DAN LOGLARı GÖRME

### A. **VM Activity Log** (Kim Ne Yaptı?)

1. **Azure Portal** → Resource Group → VM
2. Sol menüden **"Activity log"**

**Göreceğin Bilgiler:**
- ✅ VM başlatma/durdurma (kim, ne zaman)
- ✅ Extension kurulumu (Entra ID, Monitoring)
- ✅ RBAC rol atamaları (kim, kime, ne yetkisi)
- ✅ Network değişiklikleri
- ✅ Disk işlemleri

**Örnek Query:**
```
Operation: Assign role binding
Initiated by: gokhanlgs@iyziodeme.onmicrosoft.com
Time: 2025-11-09 17:00:00
Role: Virtual Machine Administrator Login
```

### B. **Log Analytics Workspace** (Tüm Loglar)

1. **Azure Portal** → Resource Group → `law-rocky-linux-vm`
2. **Logs** sekmesi
3. **KQL Query** çalıştır:

#### 🔍 SSH Bağlantılarını Gör:
```kusto
Syslog
| where Facility == "authpriv"
| where SyslogMessage contains "Accepted"
| project TimeGenerated, Computer, HostIP, ProcessName, SyslogMessage
| order by TimeGenerated desc
| take 50
```

#### 🔐 Entra ID Kullanıcı Girişleri:
```kusto
Syslog
| where SyslogMessage contains "@"
| where SyslogMessage contains "Accepted"
| extend User = extract(@"for ([^\s]+)", 1, SyslogMessage)
| project TimeGenerated, User, HostIP, SyslogMessage
| order by TimeGenerated desc
```

#### ⚠️ Başarısız Login Denemeleri:
```kusto
Syslog
| where Facility == "authpriv"
| where SyslogMessage contains "Failed"
| summarize FailedAttempts=count() by HostIP, bin(TimeGenerated, 1h)
| where FailedAttempts > 3
| order by FailedAttempts desc
```

#### 🛡️ Sudo Kullanımı:
```kusto
Syslog
| where SyslogMessage contains "sudo"
| where SyslogMessage contains "COMMAND"
| extend User = extract(@"USER=([^\s]+)", 1, SyslogMessage)
| extend Command = extract(@"COMMAND=(.+)", 1, SyslogMessage)
| project TimeGenerated, User, Command
| order by TimeGenerated desc
```

#### 📈 Son 24 Saatte En Çok SSH Yapan:
```kusto
Syslog
| where TimeGenerated > ago(24h)
| where SyslogMessage contains "Accepted"
| extend User = extract(@"for ([^\s]+)", 1, SyslogMessage)
| summarize LoginCount=count() by User
| order by LoginCount desc
```

### C. **Entra ID Sign-in Logs** (Authentication)

1. **Azure Portal** → **Microsoft Entra ID**
2. **Monitoring** → **Sign-in logs**
3. **Filter:**
   - Application: "SSH"
   - User: Kendi email'in
   - Status: Success / Failure

**Göreceğin Detaylar:**
- ✅ Login tarihi ve saati
- ✅ Kaynak IP adresi
- ✅ Device bilgisi
- ✅ MFA kullanıldı mı?
- ✅ Conditional Access politikası
- ✅ Risk level (low/medium/high)

### D. **Entra ID Audit Logs** (RBAC Değişiklikleri)

1. **Azure Portal** → **Microsoft Entra ID**
2. **Monitoring** → **Audit logs**
3. **Filter:**
   - Service: "Core Directory"
   - Category: "RoleManagement"

**Göreceğin Bilgiler:**
- ✅ Kim hangi role atandı
- ✅ Kim atama yaptı
- ✅ Ne zaman yapıldı
- ✅ Hangi VM/kaynak için

---

## 🖥️ 2. VM İÇİNDE (LINUX) LOGLAR

VM'e SSH ile girdikten sonra:

### A. **SSH Bağlantı Geçmişi**

```bash
# Son SSH girişleri (tüm kullanıcılar)
sudo last -a

# Şu an bağlı olanlar
who -a

# Detaylı SSH log
sudo journalctl -u sshd -n 100

# Son 24 saatteki girişler
sudo journalctl -u sshd --since "24 hours ago"

# Sadece Entra ID kullanıcıları
sudo grep "Accepted" /var/log/secure | grep "@"
```

### B. **Sudo Kullanım Logları**

```bash
# Kim sudo kullandı?
sudo journalctl _COMM=sudo -n 50

# Detaylı sudo logları
sudo grep sudo /var/log/secure | tail -50

# Belirli bir kullanıcının sudo geçmişi
sudo grep "gokhanlgs@" /var/log/secure | grep sudo
```

### C. **Entra ID Extension Logları**

```bash
# AAD Login servis durumu
sudo systemctl status aad-login

# Extension logları
sudo journalctl -u aad-login -n 100

# Entra ID authentication detayları
sudo journalctl | grep -i "aad\|azure\|certificate"
```

### D. **Güvenlik Olayları**

```bash
# Başarısız login denemeleri
sudo grep "Failed" /var/log/secure | tail -20

# SSH bruteforce denemeleri
sudo grep "Invalid user" /var/log/secure | tail -20

# Port scan denemeleri
sudo journalctl -u sshd | grep "Connection closed"
```

### E. **Sistem Performans Logları**

```bash
# CPU ve Memory kullanımı
top -b -n 1 | head -20

# Disk kullanımı
df -h

# Network bağlantıları
sudo ss -tunapl | grep ESTABLISHED

# Son sistem hataları
sudo journalctl -p err -n 50
```

---

## 📊 3. HAZIR MONITORING SCRIPT

VM'e bu script'i kopyala ve çalıştır:

```bash
#!/bin/bash
# audit-report.sh - Comprehensive VM audit report

echo "================================"
echo "VM AUDIT REPORT"
echo "Generated: $(date)"
echo "================================"

echo -e "\n[1] SSH LOGIN HISTORY (Last 20)"
echo "--------------------------------"
sudo last -a | head -20

echo -e "\n[2] CURRENTLY CONNECTED USERS"
echo "--------------------------------"
who -a

echo -e "\n[3] ENTRA ID USER LOGINS (Last 10)"
echo "--------------------------------"
sudo grep "Accepted" /var/log/secure | grep "@" | tail -10

echo -e "\n[4] FAILED LOGIN ATTEMPTS (Last 10)"
echo "--------------------------------"
sudo grep "Failed" /var/log/secure | tail -10

echo -e "\n[5] SUDO USAGE (Last 10)"
echo "--------------------------------"
sudo journalctl _COMM=sudo -n 10 --no-pager

echo -e "\n[6] SYSTEM RESOURCE USAGE"
echo "--------------------------------"
echo "CPU & Memory:"
top -b -n 1 | head -5
echo -e "\nDisk:"
df -h /
echo -e "\nNetwork:"
sudo ss -tunapl | grep ESTABLISHED | wc -l
echo "Active connections"

echo -e "\n[7] RECENT SYSTEM ERRORS"
echo "--------------------------------"
sudo journalctl -p err --since "24 hours ago" -n 5 --no-pager

echo -e "\n================================"
echo "END OF REPORT"
echo "================================"
```

**Kullanım:**
```bash
# Script'i oluştur
vi audit-report.sh
# (yukarıdaki içeriği yapıştır)

# Çalıştırılabilir yap
chmod +x audit-report.sh

# Çalıştır
sudo ./audit-report.sh

# Veya otomatik scheduled task yap (günlük)
sudo crontab -e
# Ekle: 0 0 * * * /home/azureuser/audit-report.sh > /var/log/daily-audit.log
```

---

## 🔐 4. RBAC YÖNETİMİ (Kim Ne Yapabilir?)

### Mevcut Yetkileri Listele

**Azure Portal:**
1. VM → **Access control (IAM)**
2. **Role assignments** sekmesi
3. Filtrele: "Virtual Machine" rolleri

**Azure CLI:**
```bash
# VM'deki tüm rol atamaları
az role assignment list \
  --scope "/subscriptions/21ff83dc-f6ed-435e-894d-26ad8446dfec/resourceGroups/AzureADLinuxVM/providers/Microsoft.Compute/virtualMachines/rocky-de-vm" \
  --query "[].{User:principalName, Role:roleDefinitionName, AssignedBy:createdBy}" \
  -o table
```

### Yeni Kullanıcı Ekle

**Administrator (sudo yetkisi):**
```bash
az role assignment create \
  --role "Virtual Machine Administrator Login" \
  --assignee "admin@company.com" \
  --scope "/subscriptions/SUBSCRIPTION_ID/resourceGroups/RESOURCE_GROUP/providers/Microsoft.Compute/virtualMachines/VM_NAME"
```

**Normal User (sudo yok):**
```bash
az role assignment create \
  --role "Virtual Machine User Login" \
  --assignee "user@company.com" \
  --scope "/subscriptions/SUBSCRIPTION_ID/resourceGroups/RESOURCE_GROUP/providers/Microsoft.Compute/virtualMachines/VM_NAME"
```

### Yetkiyi Kaldır

```bash
az role assignment delete \
  --role "Virtual Machine User Login" \
  --assignee "user@company.com" \
  --scope "/subscriptions/SUBSCRIPTION_ID/resourceGroups/RESOURCE_GROUP/providers/Microsoft.Compute/virtualMachines/VM_NAME"
```

---

## 📈 5. AZURE MONITOR WORKBOOKS (DASHBOARD)

### Hazır Dashboard Oluştur

1. **Azure Portal** → **Monitor** → **Workbooks**
2. **+ New** → **Empty**
3. **+ Add** → **Add query**
4. Bu query'yi ekle:

```kusto
// VM Activity Overview
let TimeRange = ago(24h);
Syslog
| where TimeGenerated > TimeRange
| summarize 
    TotalEvents = count(),
    SSHLogins = countif(SyslogMessage contains "Accepted"),
    FailedLogins = countif(SyslogMessage contains "Failed"),
    SudoCommands = countif(SyslogMessage contains "sudo")
| project 
    TimeRange = "Last 24 Hours",
    TotalEvents,
    SSHLogins,
    FailedLogins,
    SudoCommands
```

### Grafikler Ekle

**SSH Login Timeline:**
```kusto
Syslog
| where TimeGenerated > ago(7d)
| where SyslogMessage contains "Accepted"
| summarize LoginCount = count() by bin(TimeGenerated, 1h)
| render timechart
```

**Top SSH Users:**
```kusto
Syslog
| where TimeGenerated > ago(7d)
| where SyslogMessage contains "Accepted"
| extend User = extract(@"for ([^\s]+)", 1, SyslogMessage)
| summarize LoginCount = count() by User
| order by LoginCount desc
| render barchart
```

---

## 🚨 6. ALERTLER KURMA

### Brute Force Alert

1. **Azure Portal** → **Monitor** → **Alerts**
2. **+ Create** → **Alert rule**
3. **Scope**: Log Analytics Workspace
4. **Condition**:
```kusto
Syslog
| where Facility == "authpriv"
| where SyslogMessage contains "Failed"
| summarize FailedCount = count() by HostIP, bin(TimeGenerated, 5m)
| where FailedCount > 5
```
5. **Alert threshold**: >= 1
6. **Action**: Email notification

### Entra ID Suspicious Login Alert

```kusto
Syslog
| where SyslogMessage contains "Accepted"
| extend User = extract(@"for ([^\s]+)", 1, SyslogMessage)
| extend SourceIP = extract(@"from ([0-9.]+)", 1, SyslogMessage)
| where User contains "@"
| summarize Countries = dcount(SourceIP) by User, bin(TimeGenerated, 1h)
| where Countries > 2  // Farklı IP'lerden giriş
```

---

## 📝 7. LOG RETENTION POLİTİKASI

### Log Analytics Workspace

- **Default**: 30 gün (ücretsiz)
- **Artırılabilir**: 730 güne kadar (ücretli)

**Değiştirme:**
1. **Log Analytics Workspace** → **Usage and estimated costs**
2. **Data retention** → Slider ile ayarla

### Archive Storage

Eski logları ucuz storage'a taşı:
```bash
# Azure Portal → Log Analytics → Export
# Destination: Storage Account
# Schedule: Daily
```

---

## ✅ ÖZET: Deploy Sonrası Ne Hazır Geliyor?

| Özellik | Durum | Erişim |
|---------|-------|--------|
| **Log Analytics Workspace** | ✅ Kurulu | Azure Portal |
| **Azure Monitor Agent** | ✅ Kurulu | Otomatik çalışıyor |
| **SSH Login Logs** | ✅ Aktif | /var/log/secure |
| **Sudo Logs** | ✅ Aktif | journalctl |
| **Entra ID Sign-in Logs** | ✅ Aktif | Entra ID Portal |
| **Activity Logs** | ✅ Aktif | VM → Activity log |
| **Performance Metrics** | ✅ Aktif | VM → Metrics |
| **KQL Queries** | ✅ Kullanılabilir | Log Analytics |

**Tek tıkla deploy et, tüm monitoring hazır gelsin!** 🚀