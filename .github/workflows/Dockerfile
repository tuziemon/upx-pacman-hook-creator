FROM archlinux:latest AS compile-image
RUN pacman -Sy --noconfirm && \
    pacman -S git --noconfirm && \
    curl -fsSL https://git.io/shellspec | sh -s -- --yes

FROM archlinux:latest AS runtime-image
COPY --from=compile-image /root/.local /root/.local
RUN pacman -Sy --noconfirm && \
    pacman -S dash zsh diffutils --noconfirm && \
    pacman -Sdd firefox chromium gnome-text-editor --noconfirm && \
    yes | pacman -Scc
ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
