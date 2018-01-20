FROM ubuntu:latest

MAINTAINER Moore Huang<moore@moorehy.com>

# 替换为中科大软件源
RUN sed -i 's|archive.ubuntu.com|mirrors.ustc.edu.cn|g' /etc/apt/sources.list && \
    sed -i 's|security.ubuntu.com|mirrors.ustc.edu.cn|g' /etc/apt/sources.list

# 安装软件&扩展
RUN apt-get update --fix-missing && apt-get install -y \
        openssl openssh-server landscape-common sudo \
        --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# 配置SSHD
RUN mkdir /var/run/sshd \
    && sed -ri 's/#?PasswordAuthentication yes/PasswordAuthentication no/g' \
        /etc/ssh/sshd_config

# 创建非Root用户
RUN adduser --disabled-password --gecos "" --quiet dev \
    && echo 'dev:dev' | chpasswd \
    && usermod -a -G adm,sudo dev

# 配置sudo用户组无需输入密码，并设置默认ROOT密码
RUN sed -ri 's/%sudo\tALL=\(ALL:ALL\) ALL/%sudo\tALL=\(ALL:ALL\) NOPASSWD: ALL/g' \
        /etc/sudoers \
    && echo 'root:whosyourdaddy' | chpasswd

# 设置工作路径
WORKDIR /root

# 设置开放端口
EXPOSE 22

# 启动命令
CMD [ \
    "/usr/sbin/sshd", "-D" \
]
