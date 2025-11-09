# GitHub Repository Kurulum Rehberi

Bu rehber, Rocky Linux Entra ID template'ini GitHub'da nasıl yayınlayacağınızı açıklar.

## 1. GitHub Repository Oluşturma

1. GitHub'a gidin ve yeni repository oluşturun
2. Repository adı: `rocky-linux-entra-id`
3. Public olarak işaretleyin
4. README.md eklemeyin (zaten var)
5. **Create repository**

## 2. Dosyaları GitHub'a Yükleme

### PowerShell ile:
```powershell
cd "d:\Downloads\entraidloginrockylinux"

# Git repository initialize et
git init

# Dosyaları stage et
git add .

# İlk commit
git commit -m "Initial commit: Rocky Linux 9 VM with Entra ID SSH login template"

# GitHub repository'yi remote olarak ekle (YOUR_USERNAME yerine GitHub kullanıcı adınızı yazın)
git remote add origin https://github.com/YOUR_USERNAME/rocky-linux-entra-id.git

# Main branch olarak push et
git branch -M main
git push -u origin main
```

### Alternatif: GitHub CLI ile:
```powershell
# GitHub CLI kuruluysa
gh repo create rocky-linux-entra-id --public
git remote add origin https://github.com/YOUR_USERNAME/rocky-linux-entra-id.git
git push -u origin main
```

## 3. README Dosyasını Güncelleme

Repository oluştuktan sonra `README-GITHUB.md` dosyasındaki URL'leri güncelleyin:

```markdown
# Şu satırlardaki YOUR_USERNAME'i değiştirin:
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FYOUR_USERNAME%2Frocky-linux-entra-id%2Fmain%2Fazuredeploy.json)
```

Örnek:
```markdown
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmehmetali%2Frocky-linux-entra-id%2Fmain%2Fazuredeploy.json)
```

## 4. Final Adımlar

1. `README-GITHUB.md` dosyasını `README.md` olarak rename edin
2. Değişiklikleri commit ve push edin:

```powershell
# README dosyasını rename et
mv README-GITHUB.md README.md

# Değişiklikleri commit et
git add .
git commit -m "Update README with correct GitHub URLs"
git push
```

## 5. Deploy to Azure Butonu Test Etme

Repository hazır olduktan sonra:

1. README.md dosyasındaki **Deploy to Azure** butonuna tıklayın
2. Azure Portal'da template açılacak
3. Parametreleri doldurun ve deploy edin
4. Çalışıyor mu test edin!

## 6. Repository Özellikleri

### Önerilen Settings:
- **Topics**: `azure`, `rocky-linux`, `entra-id`, `ssh`, `arm-template`, `linux-vm`
- **Description**: "🚀 One-click deploy Rocky Linux 9 VM with Microsoft Entra ID SSH login on Azure"
- **Website**: Template'in preview URL'ini ekleyebilirsiniz

### Branch Protection (Opsiyonel):
- Main branch için protection rule ekleyin
- Require pull request reviews
- Dismiss stale reviews

## 7. Örnek Repository URL'leri

Template hazır olduktan sonra şu URL'ler çalışacak:

- **Deploy to Azure**: `https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FYOUR_USERNAME%2Frocky-linux-entra-id%2Fmain%2Fazuredeploy.json`
- **Raw Template**: `https://raw.githubusercontent.com/YOUR_USERNAME/rocky-linux-entra-id/main/azuredeploy.json`
- **Visualize**: ARM Visualizer ile template'i görselleştirme

## Başarı! 🎉

Repository hazır! Artık herkes tek tıkla Rocky Linux 9 VM'ini Entra ID ile deploy edebilir.