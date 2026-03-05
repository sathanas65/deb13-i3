#!/usr/bin/env python3
import i3ipc

i3 = i3ipc.Connection()

def on_focus(i3, e):
    for con in i3.get_tree().leaves():
        if con.focused:
            i3.command(f'[con_id={con.id}] border pixel 4')
        else:
            i3.command(f'[con_id={con.id}] border pixel 0')

i3.on('window::focus', on_focus)
i3.main()
