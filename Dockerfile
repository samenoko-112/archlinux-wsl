FROM archlinux:base

ARG USERNAME=archuser

# 初期更新とreflectorのインストール
RUN pacman-key --init && \
    pacman-key --populate archlinux && \
    pacman -Sy --noconfirm archlinux-keyring && \
    pacman -Syu --noconfirm && \
    pacman -S --noconfirm reflector

# reflectorを使ってミラーを最適化
RUN reflector --country Japan --age 12 --protocol https,http --sort rate --save /etc/pacman.d/mirrorlist && \
    cat /etc/pacman.d/mirrorlist

# 必要なパッケージのインストール
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm git sudo wget nano go base-devel

# ユーザー作成と設定
RUN useradd -m -G wheel -s /bin/bash ${USERNAME} && \
    passwd -d ${USERNAME} && \
    printf "%%wheel ALL=(ALL) NOPASSWD:ALL\n" | tee -a /etc/sudoers.d/wheel && \
    printf "[user]\ndefault=${USERNAME}\n" | tee /etc/wsl.conf

# ロケールの設定
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen
ENV LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en" \
    LC_ALL="en_US.UTF-8"

USER ${USERNAME}

WORKDIR /home/${USERNAME}
