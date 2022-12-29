FROM archlinux:latest AS compile-image
RUN pacman -Sy --noconfirm && \
    pacman -S git --noconfirm && \
    curl -fsSL https://git.io/shellspec | sh -s -- --yes

FROM archlinux:latest AS runtime-image
COPY --from=compile-image /root/.local /root/.local
RUN pacman -Sy --noconfirm && \
    pacman -S dash zsh diffutils upx --noconfirm && \
    pacman -Sdd firefox chromium --noconfirm && \
    yes | pacman -Scc && \
    sed -i "s/#HookDir/HookDir/" /etc/pacman.conf && \
    sed -i "/HookDir/s/$/ \/opt\/upx-packer\/hooks\//" /etc/pacman.conf
ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
