let backup_root = $"./config-backup"

mkdir $backup_root

# === VSCode ===
let vscode_dir = $"($backup_root)/code"
mkdir $vscode_dir
cp "C:/Users/Emiliano Garza/AppData/Roaming/Code/User/settings.json" $"($vscode_dir)/settings.json"
cp "C:/Users/Emiliano Garza/AppData/Roaming/Code/User/keybindings.json" $"($vscode_dir)/keybindings.json"
cp --recursive "C:/Users/Emiliano Garza/AppData/Roaming/Code/User/snippets" $"($vscode_dir)/snippets"

# === WezTerm ===
cp --recursive "C:/Users/Emiliano Garza/.config/wezterm/" $backup_root

# === NuShell ===
cp --recursive "C:/Users/Emiliano Garza/AppData/Roaming/nushell/" $backup_root

# === Zed ===
cp --recursive "C:/Users/Emiliano Garza/AppData/Roaming/Zed" $backup_root

# ===============
cd $backup_root

do {
    git add .
    git commit -m $"Backup (date)"
    git push
} catch { |err|
    print $"❌ Error al subir a GitHub: ($err)"
}
