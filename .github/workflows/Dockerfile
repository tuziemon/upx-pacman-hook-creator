FROM archlinux:latest
RUN pacman -Sy --noconfirm && \
    pacman -S git --noconfirm && \
    curl -fsSL https://git.io/shellspec | sh -s -- --yes && \
    pacman -S firefox chromium diffutils --noconfirm && \
    pacman -S dash zsh --noconfirm && \
    pacman -Scc --noconfirm
