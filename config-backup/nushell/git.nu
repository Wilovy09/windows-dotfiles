# Comando para git add interactivo con fzf
def gadd [] {
    let files = (do -i { git ls-files -m -o --exclude-standard } | lines)
    if ($files | is-empty) {
        echo "No hay archivos modificados para agregar"
        return
    }

    let selected = ($files 
        | fzf 
            --multi 
            --preview "git diff --color=always -- {}" 
            --height "40%" 
            --layout reverse)

    if ($selected | is-empty) {
        echo "No se seleccionaron archivos"
        return
    }

    git add $selected
    echo $"Archivos agregados: ($selected | str join ', ')"
}

# Comando para git checkout de rama con fzf
def gch [] {
    let branches = (git branch | lines | str trim | where { |line| not ($line | str starts-with "*") })
    if ($branches | is-empty) {
        echo "No hay otras ramas disponibles"
        return
    }

    let selected = ($branches 
        | fzf 
            --preview "git show --color=always {}" 
            --height "40%" 
            --layout reverse)

    if ($selected | is-empty) {
        echo "No se seleccionó ninguna rama"
        return
    }

    git checkout $selected
    echo $"Cambiado a rama: ($selected)"
}

# Agregar los comandos al entorno
$env.config = ($env.config | upsert keybindings [
    {
        name: gadd
        modifier: control
        keycode: char_a
        mode: [emacs, vi_normal, vi_insert]
        event: { send: executehostcommand cmd: "gadd" }
    }
    {
        name: gch
        modifier: control
        keycode: char_b
        mode: [emacs, vi_normal, vi_insert]
        event: { send: executehostcommand cmd: "gch" }
    }
])