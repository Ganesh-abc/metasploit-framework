FROM debian:bullseye-slim

# Install full vim
RUN apt-get update && apt-get install -y vim-nox && rm -rf /var/lib/apt/lists/*

# Create the victim user
RUN useradd -m victim

# Configure Vim to be vulnerable for our PoC
# We put these in the global vimrc
RUN echo "set modeline" >> /etc/vim/vimrc && \
    echo "set modelineexpr" >> /etc/vim/vimrc

USER victim
WORKDIR /home/victim
CMD ["/bin/bash"]
