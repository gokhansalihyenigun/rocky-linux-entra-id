# Azure CLI Permission Hatası Çözümleri

## 🔴 Sorun
```
PermissionError: [WinError 5] Access is denied: 
'C:\Users\gsy\.azure\cliextensions\support\support-2.0.1.dist-info'
```

## ✅ Çözüm Yöntemleri

### Yöntem 1: Administrator PowerShell (ÖNERİLEN)

1. **PowerShell'i Administrator olarak aç**
   - Windows tuşuna bas
   - "PowerShell" yaz
   - Sağ tıkla → "Run as administrator"

2. **Extension'ları temizle**
```powershell
# Support extension'ını kaldır
az extension remove --name support

# SSH extension'ını yükle (veya güncelle)
az extension add --name ssh --upgrade
```

3. **VM'e bağlan**
```powershell
cd D:\Downloads\entraidloginrockylinux
az ssh vm -n rocky-de-vm -g AzureADLinuxVM
```

---

### Yöntem 2: Manuel Temizleme

1. **VS Code veya tüm terminal'leri kapat**

2. **File Explorer'da git**
```
C:\Users\gsy\.azure\cliextensions\support
```

3. **Klasörü sil**
   - Sağ tıkla → Delete
   - Eğer silinmezse, bilgisayarı yeniden başlat

4. **Tekrar dene**
```powershell
az extension add --name ssh
az ssh vm -n rocky-de-vm -g AzureADLinuxVM
```

---

### Yöntem 3: Normal SSH Kullan (HEMEN ÇALIŞIR)

PuTTY ile veya Windows Terminal ile:

```powershell
ssh azureuser@4.185.222.205
# Şifre: RockyDE2025!@#
```

✅ Bu yöntem Azure CLI gerektirmez, hemen çalışır!

---

### Yöntem 4: Azure Cloud Shell (AZURE CLI YOK)

1. **Azure Portal'a git**: https://portal.azure.com
2. **Cloud Shell'i aç** (üst menüde terminal ikonu)
3. **Bash seç**
4. **Komutları çalıştır**:
```bash
az ssh vm -n rocky-de-vm -g AzureADLinuxVM
```

✅ Cloud Shell'de extension sorunları olmaz!

---

### Yöntem 5: VS Code Remote SSH

1. **VS Code'da Azure extension kur**
2. **Azure hesabına giriş yap**
3. **Virtual Machines bul**
4. **rocky-de-vm → Connect → SSH**

✅ GUI ile kolay, extension problemi yok!

---

## 🎯 Hızlı Tavsiye

**Şu an için en kolay**: Normal SSH kullan!

```powershell
# Windows PowerShell veya Terminal
ssh azureuser@4.185.222.205
```

Şifre: `RockyDE2025!@#`

Bu şekilde:
- ✅ Hemen bağlanırsın
- ✅ Azure CLI sorunu bypass edilir
- ✅ VM'e girip test edebilirsin

**Entra ID'yi daha sonra test edersin** (Administrator PowerShell ile extension temizledikten sonra).

---

## 📝 Not

Entra ID SSH güzel bir özellik ama:
- Azure CLI extension gerektiriyor
- Certificate-based çalışıyor
- Bazen permission sorunları oluyor

**Normal SSH** ise:
- Klasik yöntem
- Her zaman çalışır
- Şifre veya SSH key ile

Her ikisi de güvenli, sadece authentication yöntemi farklı! 🚀