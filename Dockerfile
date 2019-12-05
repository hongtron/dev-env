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
      autoconf \
      automake \
      build-essential \
      cmake \
      curl \
      docker \
      docker-compose \
      g++ \
      git  \
      gnupg2 \
      htop \
      iputils-ping \
      jq \
      libevent-dev \
      libncurses5-dev \
      man \
      net-tools \
      netcat-openbsd \
      p7zip-full \
      tmux \
      tzdata \
      unar \
      unzip \
      vim \
      wget \
      zsh

SHELL ["/bin/bash", "-c"]

WORKDIR /root

# install neovim
WORKDIR /root/.local/bin/nvim
RUN curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
RUN chmod u+x nvim.appimage
RUN ./nvim.appimage --appimage-extract

# Install some ruby tooling to facilitate setup
RUN apt-get install -y rubygems ruby-dev

# Dotfiles 😎
WORKDIR /root/dotfiles
RUN gem install rake
COPY dotfiles /root/dotfiles
# don't install nvim plugins yet; the rake task shells out, and we need to
# define a "nvim" function to run the AppImage.
RUN rake scripts:install configs:install docker_env:install
RUN printf "nvim() {\n  /root/.local/bin/nvim/squashfs-root/AppRun \"\$@\"\n}\n" >> ~/.aliases_shared
# source the function we just defined
RUN sed -i 's/bash -c/BASH_ENV=~\/.aliases_shared bash -c/g' /root/dotfiles/Rakefile
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

RUN PATH=/root/.asdf/shims:/root/.asdf/bin:$PATH cargo install xsv
RUN PATH=/root/.asdf/shims:/root/.asdf/bin:$PATH gem install bundler rake pry pry-byebug pry-rescue neovim
RUN PATH=/root/.asdf/shims:/root/.asdf/bin:$PATH asdf reshim

WORKDIR /root
CMD /bin/bash -i -c "tmux-start dev"
