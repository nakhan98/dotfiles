#!/usr/bin/env python3
"""
Use when wanting to copy/paste from vim on remote tmux session
"""

import subprocess
from time import sleep

PB_COPY = "./remote_pb_copy.sh"
WAIT = 1


def send_to_pb_copy(text):
    subprocess.check_output(PB_COPY, input=text)


def get_tmux_buffer():
    return subprocess.check_output(["tmux", "show-buffer"])


def main():
    text = get_tmux_buffer()
    while True:
        new_text = get_tmux_buffer()
        if text != new_text:
            text = new_text
            send_to_pb_copy(text)
        sleep(WAIT)


if __name__ == "__main__":
    main()
