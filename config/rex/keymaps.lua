-- Kitty like helpers
rex.bind("cmd+=", "client.font.increase")
rex.bind("cmd+-", "client.font.decrease")
rex.bind("cmd+0", "client.font.reset")

-- Movement
rex.bind("alt+h", "pane.focus.left")
rex.bind("alt+j", "pane.focus.down")
rex.bind("alt+k", "pane.focus.up")
rex.bind("alt+l", "pane.focus.right")

rex.bind("cmd+s", "scratch_float")

rex.bind("cmd+e", "floating_scrollback")
rex.bind("cmd+g", "lazygit_float")
rex.bind("cmd+l", "lazydocker_float")
rex.bind("cmd+b", "gitbutler_float")
rex.bind("cmd+o", "zoxide_float")
