FROM debian:stretch

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
      git  \
      htop \
      iputils-ping \
      jq \
      libncurses5-dev \
      libevent-dev \
      net-tools \
      netcat-openbsd \
      rubygems \
      ruby-dev \
      tmux \
      openjdk-8-jre \
      tzdata \
      wget \
      vim \
      zsh \
      autoconf \
      automake \
      cmake \
      g++ \
      unzip

# debian backports
RUN echo "deb http://ftp.debian.org/debian stretch-backports main" >> /etc/apt/sources.list
RUN apt-get update && apt-get -t stretch-backports install -y \
      tmux \
      neovim \
      gnupg2

RUN chsh -s /usr/bin/zsh

# Install rvm
RUN echo 'export rvm_prefix="$HOME"' > /root/.rvmrc
RUN echo 'export rvm_path="$HOME/.rvm"' >> /root/.rvmrc
RUN gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN curl -sSL https://get.rvm.io | bash -s stable --ruby

# Misc ruby
RUN /bin/bash -c "source /root/.rvm/scripts/rvm && gem install bundler pry pry-byebug pry-rescue neovim"

# Install docker
WORKDIR /usr/local/src
RUN curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh
RUN rm /usr/local/src/get-docker.sh

# Install elixir
WORKDIR /usr/local/src
RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && dpkg -i erlang-solutions_1.0_all.deb && apt-get update
RUN apt-get install -y esl-erlang
RUN apt-get install -y elixir
RUN rm erlang-solutions_1.0_all.deb

# Install docker-compose
RUN curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose

# Dotfiles 😎
COPY dotfiles /root/dotfiles
WORKDIR /root/dotfiles
RUN rake install

WORKDIR /root
CMD /bin/bash -i -c "tmux-start dev"
