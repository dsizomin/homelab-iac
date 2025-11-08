#!/bin/sh
# download and install neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
chmod u+x nvim-linux-x86_64.appimage
./nvim-linux-x86_64.appimage --appimage-extract
rm nvim-linux-x86_64.appimage
mv squashfs-root /opt/nvim
ln -s /opt/nvim/AppRun /usr/bin/nvim
# configure opkssh
opkssh add ${username} ${opkssh_subject} ${opkssh_issuer}
# user setup
su - ${username} -c "git clone https://github.com/dsizomin/dotfiles ~/.dotfiles"
# setup dotfiles
su - ${username} -c 'ln -sf ~/.dotfiles/zsh/.zshrc ~/.zshrc'
su - ${username} -c 'ln -sf ~/.dotfiles/tmux/.tmux.conf ~/.tmux.conf'
su - ${username} -c 'mkdir -p ~/.config'
su - ${username} -c 'ln -sf ~/.dotfiles/nvim ~/.config/nvim'
su - ${username} -c 'ln -sf ~/.config/nvim/lua/slim ~/.config/nvim/lua/plugins'
# setup NVM, NodeJS
su - ${username} -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash'
su - ${username} -c 'export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && nvm install --lts && nvm use --lts'
# Start and enable qemu-guest-agent
systemctl enable qemu-guest-agent
systemctl start qemu-guest-agent
