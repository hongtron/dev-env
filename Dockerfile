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
RUN apt-get update && apt-get install -y \
      build-essential \
      curl \
      man \
      git  \
      htop \
      iputils-ping \
      jq \
      libncurses5-dev \
      libevent-dev \
      net-tools \
      netcat-openbsd \
      tzdata \
      wget \
      vim \
      zsh \
      autoconf \
      automake \
      cmake \
      g++ \
      unzip \
      docker \
      docker-compose \
      gnupg2 \
      unar \
      p7zip-full

SHELL ["/bin/bash", "-c"]

WORKDIR /root

# install neovim
WORKDIR /root/.local/bin
RUN curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
RUN chmod u+x nvim.appimage

# Install some ruby tooling to facilitate setup
RUN apt-get install -y rubygems ruby-dev

# Dotfiles 😎
WORKDIR /root/dotfiles
RUN gem install rake
COPY dotfiles /root/dotfiles
# don't install nvim plugins yet; the rake task shells out, and we need to
# alias "nvim" to run the AppImage. (The rake task passes the "interactive"
# flag to bash, so it will pick up the alias.)
RUN rake scripts:install configs:install docker_env:install
RUN echo 'alias nvim="/root/.local/bin/nvim.appimage --appimage-extract-and-run"' >> ~/.aliases_shared
RUN rake plugins:install

# Remove these, since we're going to rely on asdf for actual ruby stuff
RUN apt-get remove -y rubygems ruby-dev

# asdf
WORKDIR /root
COPY tool-versions /root/.tool-versions
RUN apt-get install -y \
      libssl-dev \
      libreadline-dev \
      zlib1g-dev
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.5
RUN echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bashrc
RUN echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc
RUN echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.zshrc
RUN echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.zshrc
RUN /root/.asdf/bin/asdf plugin-add tmux
RUN /root/.asdf/bin/asdf plugin-add ruby
RUN /root/.asdf/bin/asdf plugin-add python
RUN /root/.asdf/bin/asdf plugin-add rust
RUN /root/.asdf/bin/asdf plugin-add java
RUN /root/.asdf/bin/asdf plugin-add elixir
RUN /root/.asdf/bin/asdf install

RUN source /root/.asdf/installs/rust/1.38.0/env && rustup default stable

# Add interactive flag so we can use asdf-installed tools
SHELL ["/bin/bash", "-i", "-c"]
RUN cargo install xsv
RUN gem install bundler rake pry pry-byebug pry-rescue neovim

SHELL ["/bin/bash", "-c"]
WORKDIR /root
CMD /bin/bash -i -c "tmux-start dev"
