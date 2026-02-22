#include <filesystem>
#include <iostream>
#include <shlobj.h>
#include <shlwapi.h>
#include <string>
#include <vector>
#include <windows.h>


namespace fs = std::filesystem;

bool IsAdmin() {
  BOOL isAdmin = FALSE;
  PSID adminGroup = NULL;
  SID_IDENTIFIER_AUTHORITY ntAuthority = SECURITY_NT_AUTHORITY;
  if (AllocateAndInitializeSid(&ntAuthority, 2, SECURITY_BUILTIN_DOMAIN_RID,
                               DOMAIN_ALIAS_RID_ADMINS, 0, 0, 0, 0, 0, 0,
                               &adminGroup)) {
    CheckTokenMembership(NULL, adminGroup, &isAdmin);
    FreeSid(adminGroup);
  }
  return isAdmin;
}

void Elevate() {
  char path[MAX_PATH];
  GetModuleFileNameA(NULL, path, MAX_PATH);
  SHELLEXECUTEINFOA sei = {sizeof(sei)};
  sei.lpVerb = "runas";
  sei.lpFile = path;
  sei.hwnd = NULL;
  sei.nShow = SW_NORMAL;
  if (!ShellExecuteExA(&sei)) {
    DWORD dwError = GetLastError();
    if (dwError == ERROR_CANCELLED) {
      std::cout << "Elevation was refused by the user." << std::endl;
    }
  }
}

bool AddToPath(const std::string &newPath) {
  HKEY hKey;
  const char *regPath =
      "System\\CurrentControlSet\\Control\\Session Manager\\Environment";
  if (RegOpenKeyExA(HKEY_LOCAL_MACHINE, regPath, 0, KEY_READ | KEY_WRITE,
                    &hKey) == ERROR_SUCCESS) {
    char currentPath[32767];
    DWORD size = sizeof(currentPath);
    if (RegQueryValueExA(hKey, "Path", NULL, NULL, (LPBYTE)currentPath,
                         &size) == ERROR_SUCCESS) {
      std::string pathStr = currentPath;
      if (pathStr.find(newPath) == std::string::npos) {
        pathStr += ";" + newPath;
        if (RegSetValueExA(hKey, "Path", 0, REG_EXPAND_SZ,
                           (LPBYTE)pathStr.c_str(),
                           (DWORD)pathStr.length() + 1) == ERROR_SUCCESS) {
          SendMessageTimeoutA(HWND_BROADCAST, WM_SETTINGCHANGE, 0,
                              (LPARAM) "Environment", SMTO_ABORTIFHUNG, 5000,
                              NULL);
          RegCloseKey(hKey);
          return true;
        }
      } else {
        RegCloseKey(hKey);
        return true; // Already in path
      }
    }
    RegCloseKey(hKey);
  }
  return false;
}

int main() {
  std::cout << "--- ZEGA Sapphire Installer ---" << std::endl;

  if (!IsAdmin()) {
    std::cout << "Requesting Administrative Privileges..." << std::endl;
    Elevate();
    return 0;
  }

  try {
    fs::path installPath = "C:\\Program Files\\ZEGA\\Sapphire";
    std::cout << "Target Directory: " << installPath.string() << std::endl;

    if (!fs::exists(installPath)) {
      std::cout << "Creating directory..." << std::endl;
      fs::create_directories(installPath);
    }

    std::vector<std::string> files = {"Sapphire.exe", "Sapphire_Compiler.dll",
                                      "Sapphire_VM.dll"};
    for (const auto &file : files) {
      if (fs::exists(file)) {
        std::cout << "Deploying " << file << "..." << std::endl;
        fs::copy_file(file, installPath / file,
                      fs::copy_options::overwrite_existing);
      } else {
        std::cerr << "Warning: " << file << " not found in current directory!"
                  << std::endl;
      }
    }

    std::cout << "Updating System PATH..." << std::endl;
    if (AddToPath(installPath.string())) {
      std::cout << "Environment variables updated." << std::endl;
    } else {
      std::cerr << "Failed to update System PATH." << std::endl;
    }

    std::cout << "\033[32mInstallation Complete\033[0m" << std::endl;
  } catch (const std::exception &e) {
    std::cerr << "Installation failed: " << e.what() << std::endl;
    return 1;
  }

  return 0;
}
