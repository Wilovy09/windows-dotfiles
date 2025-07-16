# prompt.nu
def is_ssh_session [] {
    if 'SSH_CONNECTION' in $env {
        true
    } else if 'SSH_CLIENT' in $env {
        true
    } else if 'SSH_TTY' in $env {
        true
    } else {
        false
    }
}

def custom_path [] {
  if ($nu.os-info.name == "windows") {
    let curr = pwd | str replace -r "C:\\\\Users\\\\[a-zA-Z.]*" "~" | split row "\\"
    return ($curr | reverse | enumerate | each {|p| if $p.index != 0 { str substring 0..1 item } else { $p }} | get item | reverse | str join '/')
    } else {
    let curr = pwd | str replace -r "/home/\\w+" "~" | split row "/"
    return ($curr | reverse | enumerate | each {|p| if $p.index != 0 { str substring 0..1 item } else { $p }} | get item | reverse | str join '/')
  }
}

def is_git_repo [] {
    do --ignore-errors { git rev-parse --is-inside-work-tree } | str trim | $in == "true"
}

def get_git_status [] {
    if not (is_git_repo) {
      return { branch: "", symbols: ""}
    }

    let branch = (do --ignore-errors { git branch --show-current } | str trim)
    let staged = (do --ignore-errors { git diff --staged --name-only } | lines | length)
    let unstaged = (do --ignore-errors { git diff --name-only } | lines | length)
    let untracked = (do --ignore-errors { git ls-files --others --exclude-standard } | lines | length)
    let renamed = (do --ignore-errors { git diff --name-status } | lines | filter { |line| $line starts-with 'R' } | length)
    let deleted = (do --ignore-errors { git diff --name-status } | lines | filter { |line| $line starts-with 'D' } | length)
    let stashed = (do --ignore-errors { git stash list } | lines | length)
    let conflicted = (do --ignore-errors { git diff --name-only --diff-filter=U } | lines | length)
    let ahead_behind = (do --ignore-errors { git rev-list --left-right --count ...@{u} } | str trim | split row " ")
    let ahead = if ($ahead_behind | length) == 2 { ($ahead_behind | get 0 | into int) } else { 0 }
    let behind = if ($ahead_behind | length) == 2 { ($ahead_behind | get 1 | into int) } else { 0 }
    
    mut symbols = []
    if $conflicted > 0 { $symbols = ($symbols | append $"($conflicted)🔪") }
    if $ahead > 0 { $symbols = ($symbols | append $"($ahead)🏎️") }
    if $behind > 0 { $symbols = ($symbols | append $"($behind)🐢") }
    if $staged > 0 { $symbols = ($symbols | append $"($staged)✅") }
    if $unstaged > 0 { $symbols = ($symbols | append $"($unstaged)📝") }
    if $untracked > 0 { $symbols = ($symbols | append $"($untracked)🤷") }
    if $stashed > 0 { $symbols = ($symbols | append $"($stashed)📦") }
    if $renamed > 0 { $symbols = ($symbols | append $"($renamed)🚚") }
    if $deleted > 0 { $symbols = ($symbols | append $"($deleted)🗑️") }

    { branch: $branch, symbols: ($symbols | str join " ") }
}

def prompt [] {
    let git_status = get_git_status
    let status_symbols = $git_status.symbols
    let branch = $git_status.branch
    
    print -n $" (ansi reset)(ansi blue)(custom_path) (ansi reset)(ansi cyan)($branch)(ansi reset) ($status_symbols)"
    # print -n $"\n(ansi { fg: green, attr: b }) (whoami)(ansi reset): (ansi blue)(custom_path) (ansi reset)(ansi cyan)($branch)(ansi reset) ($status_symbols)"
    # print -n $"(ansi reset)(ansi cyan) ($branch)(ansi reset) ($status_symbols)"
}

def prompt_status [indicator_ty: string] {
    let last_status = $env.LAST_EXIT_CODE
    let nonzero = $last_status != 0
    let superuser = if ($nu.os-info.name == "windows") {
      try {
          net session out+err> /dev/null
          true
      } catch {
          false
      }
    } else {
        (id -u) == 0
    }

    let in_nix_shell = "IN_NIX_SHELL" in $env
    let in_distrobox = "DISTROBOX_HOST_HOME" in $env
    let user_char_color = if $superuser {
      "red"
    } else if not $nu.history-enabled {
      "#D485AD"
    } else if $in_nix_shell {
      "#82BCE5"
    } else {
      "normal"
    }

    let user_char = try {
      let name = (uname | get kernel-name)
      if $superuser {
        "☠"
      } else if (is_ssh_session) {
        ""
      } else if not $nu.history-enabled {
        "󰊪"
      } else if $in_nix_shell {
        ""
      } else if $in_distrobox {
        ""
      } else if $name == "Darwin" {
        ""
      } else if ($nu.os-info.name == "windows") {
        ""
      } else {
        ""
      }
    } catch {
      ""
    }

    let std_color = if $last_status != 0 {
      "red"
    } else {
      "blue"
    }

    let indicator = match indicator_ty {
      "vi" => ":", 
      "vn" => ">", 
      "ml" => ":::", 
      _ => "❯", 
    }

    # return $"(ansi { fg: $user_char_color, attr: b }) ($user_char)(ansi reset) (ansi blue)(custom_path)(ansi { fg: $std_color, attr: b })($indicator)"
    return $"(ansi { fg: $user_char_color, attr: b }) ($user_char) (ansi { fg: $std_color, attr: b })($indicator)"
}