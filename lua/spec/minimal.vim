if !isdirectory('plenary.nvim')
  !git clone https://github.com/nvim-lua/plenary.nvim.git plenary.nvim
  " !git -C plenary.nvim reset --hard 1338bbe8ec6503ca1517059c52364ebf95951458
endif
if !isdirectory('neotest')
  !git clone https://github.com/nvim-neotest/neotest.git neotest
endif
if !isdirectory('nvim-treesitter')
  !git clone https://github.com/nvim-treesitter/nvim-treesitter.git nvim-treesitter
endif

set runtimepath+=plenary.nvim,.
set runtimepath+=neotest,.
set runtimepath+=nvim-treesitter,.
set noswapfile
set noundofile

runtime plugin/plenary.vim
execute("TSInstall ruby")
command Test PlenaryBustedDirectory lua/spec/neotest-rspec {minimal_init = 'lua/spec/minimal.vim'}
