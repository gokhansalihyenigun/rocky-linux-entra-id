# Rocky Linux 9 VM with Microsoft Entra ID SSH Login

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgokhansalihyenigun%2Frocky-linux-entra-id%2Fmaster%2Fazuredeploy.json)
[![Deploy to Azure US Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgokhansalihyenigun%2Frocky-linux-entra-id%2Fmaster%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fgokhansalihyenigun%2Frocky-linux-entra-id%2Fmaster%2Fazuredeploy.json)

Bu template, Microsoft Entra ID (eski adıyla Azure AD) ile SSH giriş yapabileceğiniz Rocky Linux 9 sanal makinesini Azure'da oluşturur.

## Özellikler

✅ **Rocky Linux 9** - En güncel RHEL compatible dağıtım  
✅ **Microsoft Entra ID SSH Login** - Şifresiz, güvenli giriş  
✅ **Managed Identity** - Azure kaynaklarına güvenli erişim  
✅ **Premium SSD** - Yüksek performans disk  
✅ **Otomatik SSH Key** - Manuel key yönetimi yok  

## Hızlı Başlangıç

1. **Deploy to Azure** butonuna tıklayın ⬆️
2. Resource group seçin veya oluşturun (Önerilen: `germanywestcentral`)
3. VM adını ve kullanıcı adını girin
4. SSH public key'inizi yapıştırın (opsiyonel)
5. **Review + Create** → **Create**

## Deployment Sonrası

VM oluştuktan sonra (yaklaşık 5-10 dakika):

### 1. RBAC Rol Ataması Yapın
```bash
# Mevcut kullanıcınıza admin rolü atayın
az role assignment create \
    --role "Virtual Machine Administrator Login" \
    --assignee $(az account show --query user.name -o tsv) \
    --scope $(az vm show -g YOUR_RESOURCE_GROUP -n YOUR_VM_NAME --query id -o tsv)
```

### 2. VM'e Bağlanın
```bash
# Azure CLI ile Entra ID üzerinden bağlanın
az ssh vm -n YOUR_VM_NAME -g YOUR_RESOURCE_GROUP
```

## Parametreler

| Parametre | Açıklama | Varsayılan |
|-----------|----------|------------|
| `vmName` | Sanal makine adı | `rocky-linux-vm` |
| `adminUsername` | Yönetici kullanıcı adı | `azureuser` |
| `vmSize` | VM boyutu | `Standard_B2s` |
| `authenticationType` | Kimlik doğrulama türü | `sshPublicKey` |
| `adminPasswordOrKey` | SSH key veya şifre | *Required* |

## VM Boyutları

| Boyut | vCPU | RAM | Kullanım |
|-------|------|-----|----------|
| `Standard_B1s` | 1 | 1 GB | Test/Dev |
| `Standard_B2s` | 2 | 4 GB | Küçük iş yükleri |
| `Standard_B4ms` | 4 | 16 GB | Orta iş yükleri |
| `Standard_D2s_v3` | 2 | 8 GB | Genel amaçlı |
| `Standard_D4s_v3` | 4 | 16 GB | Performans odaklı |

## Güvenlik

- **SSH (Port 22)**: Varsayılan olarak açık
- **Entra ID Authentication**: Certificate-based auth
- **Managed Identity**: System-assigned
- **Premium SSD**: Disk şifrelemesi destekli
- **Network Security Group**: Minimal gerekli kurallar
- **Public IP**: Standard SKU (Static)

## Maliyet Tahmini

| VM Boyutu | Aylık Tahmini Maliyet (USD) |
|-----------|----------------------------|
| Standard_B1s | ~$7-10 |
| Standard_B2s | ~$15-25 |
| Standard_B4ms | ~$60-80 |
| Standard_D2s_v3 | ~$70-90 |

*Maliyetler bölgeye göre değişir. Kullanım tabanlı faturalandırma.*

## Sorun Giderme

### SSH Bağlantı Sorunu
```bash
# Extension durumunu kontrol edin
az vm extension show -g YOUR_RG -n YOUR_VM --name AADSSHLoginForLinux

# VM durumunu kontrol edin  
az vm show -g YOUR_RG -n YOUR_VM --show-details

# Debug modunda bağlanmayı deneyin
az ssh vm -n YOUR_VM -g YOUR_RG -- -v
```

### RBAC Sorunu
```bash
# Rol atamalarınızı kontrol edin
az role assignment list --assignee $(az account show --query user.name -o tsv) --scope $(az vm show -g YOUR_RG -n YOUR_VM --query id -o tsv)
```

### Extension Kurulum Sorunu
```bash
# Extension'ı yeniden kur
az vm extension delete -g YOUR_RG --vm-name YOUR_VM -n AADSSHLoginForLinux
az vm extension set --publisher Microsoft.Azure.ActiveDirectory --name AADSSHLoginForLinux -g YOUR_RG --vm-name YOUR_VM
```

## Kaynakları Temizleme

```bash
# Resource group'u silme (tüm kaynaklar silinir)
az group delete --name YOUR_RESOURCE_GROUP --yes --no-wait
```

## Teknik Detaylar

- **Publisher**: `resf` (Red Hat Enterprise Linux clone projects)
- **Image**: `rockylinux-x86_64:9-base:latest`
- **Extension**: `Microsoft.Azure.ActiveDirectory.AADSSHLoginForLinux`
- **Storage**: Premium_LRS (SSD)
- **Network**: Standard Public IP (Static), Standard NSG
- **Recommended Region**: Germany West Central

## Kaynaklar

- [Microsoft Learn - Entra ID Linux VM Login](https://learn.microsoft.com/en-us/entra/identity/devices/howto-vm-sign-in-azure-ad-linux)
- [Rocky Linux Resmi Dokümantasyonu](https://docs.rockylinux.org/)
- [Azure VM Fiyatlandırması](https://azure.microsoft.com/pricing/details/virtual-machines/linux/)

## Katkıda Bulunma

Issues ve pull request'ler memnuniyetle karşılanır! 🚀

## Lisans

MIT License - detaylar için [LICENSE](LICENSE) dosyasına bakın.

---

**⚡ Tek tıkla deploy edin!** ⬆️ Yukarıdaki **Deploy to Azure** butonuna tıklayın.