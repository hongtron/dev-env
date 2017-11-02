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
      iputils-ping \
      jq \
      libncurses5-dev \
      libevent-dev \
      net-tools \
      netcat-openbsd \
      rubygems \
      ruby-dev \
      tmux \
      tzdata \
      wget \
      vim \
      zsh 

RUN chsh -s /usr/bin/zsh

# Install tmux
WORKDIR /usr/local/src
RUN wget https://github.com/tmux/tmux/releases/download/2.5/tmux-2.5.tar.gz
RUN tar xzvf tmux-2.5.tar.gz
WORKDIR /usr/local/src/tmux-2.5
RUN ./configure
RUN make 
RUN make install
RUN rm -rf /usr/local/src/tmux*

# Dotfiles 😎
WORKDIR /usr/local/src
RUN curl -L https://api.github.com/repos/hongtron/dotfiles/tarball/master > dotfiles.tar.gz
RUN tar xzvf dotfiles.tar.gz
RUN ls | grep hongtron-dotfiles | xargs -I % mv % dotfiles
WORKDIR /usr/local/src/dotfiles
RUN rake install

# Install neovim v0.2.0
RUN apt-get install -y \
      autoconf \
      automake \
      cmake \
      g++ \
      libtool \
      libtool-bin \
      pkg-config \
      python3 \
      python3-pip \
      unzip
RUN pip3 install --upgrade pip &&\ 
    pip3 install --user neovim jedi mistune psutil setproctitle
WORKDIR /usr/local/src
RUN git clone --depth 1 https://github.com/neovim/neovim.git
WORKDIR /usr/local/src/neovim
RUN git fetch --depth 1 origin tag v0.2.0
RUN git reset --hard v0.2.0
RUN make CMAKE_BUILD_TYPE=Release
RUN make install
RUN rm -rf /usr/local/src/neovim
RUN gem install neovim

# Mirror vim dotfiles to neovim
COPY init.vim /root/.config/nvim/init.vim

# Install rvm
RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import -
RUN curl -sSL https://get.rvm.io | bash -s stable

# Misc ruby
ENV BUNDLE_PATH /root/gems
ENV BUNDLE_HOME /root/gems
ENV GEM_HOME /root/gems
ENV GEM_PATH /root/gems
ENV PATH /root/gems/bin:$PATH
RUN gem install bundler pry pry-byebug pry-rescue

WORKDIR /root
