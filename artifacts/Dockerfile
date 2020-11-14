# vi: ft=Dockerfile

FROM debian:buster

# Locales
ENV LANG=en_US.UTF-8

RUN apt-get update && apt-get install -y locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
RUN locale-gen en_US.UTF-8

# Colors and italics for tmux
COPY xterm-256color-italic.terminfo /root
RUN tic /root/xterm-256color-italic.terminfo
ENV TERM=xterm-256color-italic

# Common packages
RUN apt-get update
RUN apt-get install -y autoconf automake build-essential cmake curl docker docker-compose git gnupg2 htop iputils-ping jq libevent-dev libncurses5-dev man net-tools netcat-openbsd p7zip-full tzdata unar unzip vim wget zsh
SHELL ["/bin/bash", "-c"]

WORKDIR /root

# install neovim
WORKDIR /root/.local/bin/nvim
RUN curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
RUN chmod u+x nvim.appimage
RUN ./nvim.appimage --appimage-extract

# asdf
WORKDIR /root
COPY tool-versions /root/.tool-versions

RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.0
RUN echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bashrc
RUN echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc




RUN apt-get install -y byacc
RUN apt-get install -y pkg-config
RUN /root/.asdf/bin/asdf plugin-add tmux

RUN PATH=/root/.asdf/bin:$PATH asdf install tmux 3.1a


RUN apt-get install -y libffi-dev
RUN apt-get install -y liblzma-dev
RUN apt-get install -y libncurses5-dev
RUN apt-get install -y libncursesw5-dev
RUN apt-get install -y libreadline-dev
RUN apt-get install -y libsqlite3-dev
RUN apt-get install -y libssl-dev
RUN apt-get install -y llvm
RUN apt-get install -y python-openssl
RUN apt-get install -y tk-dev
RUN apt-get install -y xz-utils
RUN apt-get install -y zlib1g-dev
RUN /root/.asdf/bin/asdf plugin-add python

RUN PATH=/root/.asdf/bin:$PATH asdf install python 3.8.2
RUN PATH=/root/.asdf/bin:$PATH asdf install python 2.7.16

RUN /root/.asdf/bin/asdf plugin-add ruby

RUN PATH=/root/.asdf/bin:$PATH asdf install ruby 2.7.1

RUN /root/.asdf/bin/asdf plugin-add rust

RUN PATH=/root/.asdf/bin:$PATH asdf install rust 1.43.0

RUN /root/.asdf/bin/asdf plugin-add java

RUN PATH=/root/.asdf/bin:$PATH asdf install java adopt-openjdk-13.0.2+8

RUN /root/.asdf/bin/asdf plugin-add nodejs
RUN /bin/bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring

RUN PATH=/root/.asdf/bin:$PATH asdf install nodejs 14.1.0

RUN /root/.asdf/bin/asdf plugin-add yarn

RUN PATH=/root/.asdf/bin:$PATH asdf install yarn 1.22.4


RUN PATH=/root/.asdf/shims:/root/.asdf/bin:$PATH pip3 install pynvim

RUN PATH=/root/.asdf/shims:/root/.asdf/bin:$PATH gem install bundler
RUN PATH=/root/.asdf/shims:/root/.asdf/bin:$PATH gem install rake
RUN PATH=/root/.asdf/shims:/root/.asdf/bin:$PATH gem install pry
RUN PATH=/root/.asdf/shims:/root/.asdf/bin:$PATH gem install pry-byebug
RUN PATH=/root/.asdf/shims:/root/.asdf/bin:$PATH gem install pry-rescue
RUN PATH=/root/.asdf/shims:/root/.asdf/bin:$PATH gem install neovim

RUN PATH=/root/.asdf/shims:/root/.asdf/bin:$PATH asdf reshim

# Dotfiles 😎
WORKDIR /root/dotfiles
COPY dotfiles /root/dotfiles
# don't install nvim plugins yet; the rake task shells out, and we need to
# define a "nvim" function to run the AppImage.
RUN PATH=/root/.asdf/shims:/root/.asdf/bin:$PATH rake scripts:install configs:install docker_env:install
# now that aliases_shared has been installed, we can define the "nvim"
# function.
RUN printf "nvim() {\n  /root/.local/bin/nvim/squashfs-root/AppRun \"\$@\"\n}\n" >> ~/.aliases_shared
# update commands in rake task to source the function we just defined
RUN sed -i 's/bash -c/BASH_ENV=~\/.aliases_shared bash -c/g' /root/dotfiles/Rakefile
RUN PATH=/root/.asdf/shims:/root/.asdf/bin:$PATH rake plugins:install

RUN echo . $HOME/.asdf/asdf.sh >> ~/.aliases_shared
RUN /bin/zsh -c 'printf "fpath=(${HOME}/.asdf/completions ${fpath})\nautoload -Uz compinit\ncompinit" >> ~/.zshrc'

WORKDIR /root
CMD /bin/bash -i -c "tmux-start dev"
