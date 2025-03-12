# File Manager

![File Manager](https://user-images.githubusercontent.com/34917070/169325401-d6fda991-96b1-437c-a1ce-edfd0a6d4cee.png)

## 📌 Sobre o Projeto

O **File Manager** é um aplicativo desenvolvido em **Delphi 12.2** para **Android 11 e 14**, permitindo a navegação por pastas e arquivos no armazenamento do dispositivo.  

✅ **Sem necessidade de componentes adicionais**  
✅ **Interface simples e intuitiva**  
✅ **Totalmente funcional em versões recentes do Android**  

## 🚀 Tecnologias Utilizadas

- **Linguagem:** Object Pascal (Delphi)  
- **Plataforma:** FireMonkey (FMX)  
- **Compatibilidade:** Testado no **Android 11 e 14**  
- **IDE:** Compilado no **Delphi 12.2**  

## 🔐 Permissões Necessárias

Para acessar os arquivos no armazenamento do dispositivo, o aplicativo solicita as seguintes permissões:

### 📁 Permissões de Armazenamento (Android 11+)
A partir do **Android 10 (API 29)**, as permissões de armazenamento foram alteradas para aumentar a privacidade dos usuários. No **Android 11+**, o aplicativo precisa da permissão **MANAGE_EXTERNAL_STORAGE** para acessar todos os arquivos.

Permissões solicitadas:  
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
