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
      git  \
      htop \
      iputils-ping \
      jq \
      libncurses5-dev \
      libevent-dev \
      net-tools \
      netcat-openbsd \
      python3 \
      rubygems \
      ruby-dev \
      tmux \
      openjdk-11-jdk \
      tzdata \
      wget \
      vim \
      zsh \
      autoconf \
      automake \
      cmake \
      g++ \
      unzip \
      python3 \
      python3-pip \
      elixir \
      docker \
      docker-compose \
      gnupg2

# install neovim
RUN apt-get install -y \
      libtool \
      libtool-bin \
      pkg-config \
      gettext
RUN pip3 install --user neovim jedi mistune psutil setproctitle
WORKDIR /usr/local/src
RUN git clone --depth 1 https://github.com/neovim/neovim.git
WORKDIR /usr/local/src/neovim

RUN git fetch --depth 1 origin tag v0.3.7
RUN git reset --hard v0.3.7

RUN make CMAKE_BUILD_TYPE=Release
RUN make install
RUN rm -rf /usr/local/src/neovim

RUN chsh -s /usr/bin/zsh

# Install rvm
RUN echo 'export rvm_prefix="$HOME"' > /root/.rvmrc
RUN echo 'export rvm_path="$HOME/.rvm"' >> /root/.rvmrc
RUN gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN curl -sSL https://get.rvm.io | bash -s stable --ruby

# Misc ruby
RUN /bin/bash -c "source /root/.rvm/scripts/rvm && gem install bundler pry pry-byebug pry-rescue neovim"

# Dotfiles 😎
COPY dotfiles /root/dotfiles
WORKDIR /root/dotfiles
RUN rake install

WORKDIR /root
CMD /bin/bash -i -c "tmux-start dev"
