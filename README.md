# Neovim 配置

个人 Neovim 配置，主要用于 C/C++、Python 开发、调试和算法题练习。使用 `lazy.nvim` 管理插件，包含 LSP、补全、Treesitter、Snacks、DAP、Copilot、LeetCode 和本地竞赛测试浮窗。

仓库：<https://github.com/chengyh-cs/nvim>。配置入口为 `init.lua`；虽然保留了 `lazyvim.json`，当前入口没有加载 LazyVim 发行版。

## 在另一台电脑或服务器上安装

以下命令适用于 macOS / Linux，默认使用 `~/.config/nvim`，也兼容 `XDG_CONFIG_HOME`。Windows 原生环境需要另外调整路径和工具链；可以优先使用 WSL。

### 1. 准备依赖

| 依赖 | 用途 |
| --- | --- |
| Neovim 0.11+ | 当前配置使用 `vim.lsp.config` / `vim.lsp.enable`；本机版本为 0.11.0 |
| Git | 克隆配置、安装插件、多机同步 |
| C/C++ 编译器、Make、CMake | Treesitter 解析器和 Telescope fzf 原生扩展构建；竞赛运行器使用 C++23 |
| Python 3、venv / pip | Python 运行、debugpy 安装 |
| Node.js / npm | Pyright、Copilot 等功能；版本要求以对应插件为准 |
| curl、unzip、tar、gzip | Mason 下载和解压工具 |
| ripgrep、fd | 文件查找与全文搜索 |
| Nerd Font（可选） | 显示图标；通过 SSH 使用时安装在本地终端电脑上 |

macOS（已安装 Homebrew）：

```sh
xcode-select --install  # 尚未安装 Command Line Tools 时执行
brew install neovim git ripgrep fd cmake make node python gcc
```

Ubuntu / Debian：

```sh
sudo apt update
sudo apt install git curl unzip tar gzip build-essential cmake \
  ripgrep fd-find python3 python3-venv python3-pip nodejs npm
```

再单独安装并检查 Neovim 0.11+；系统软件源中的 `neovim` 可能较旧。不要直接覆盖服务器的系统 Node/Python，可以使用个人目录中的版本管理器或虚拟环境。

```sh
nvim --version
git --version
node --version
python3 --version
cmake --version
```

Ubuntu 的 `fd-find` 通常提供 `fdfind` 命令。如果文件搜索提示找不到 `fd`，可以在个人 PATH 目录中建立别名链接：

```sh
mkdir -p "$HOME/.local/bin"
ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
export PATH="$HOME/.local/bin:$PATH"
```

### 2. 备份旧配置，然后克隆

先关闭 Neovim，再执行：

```sh
nvim_config="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
mkdir -p "$(dirname "$nvim_config")"
if [ -e "$nvim_config" ] || [ -L "$nvim_config" ]; then
  mv "$nvim_config" "${nvim_config}.backup.$(date +%Y%m%d-%H%M%S)"
fi
git clone https://github.com/chengyh-cs/nvim.git "$nvim_config"
```

私有仓库需要有读取权限。需要从新机器推送修改时，建议先配置该机器自己的 GitHub SSH key，再将上面的克隆命令换成：

```sh
git clone git@github.com:chengyh-cs/nvim.git "$nvim_config"
```

已有 HTTPS 克隆也可以切换：

```sh
git -C "${XDG_CONFIG_HOME:-$HOME/.config}/nvim" remote set-url origin \
  git@github.com:chengyh-cs/nvim.git
```

### 3. 安装插件并恢复版本

执行 `nvim`，首次启动会下载 `lazy.nvim` 和缺失插件，等待安装结束。然后在 Neovim 内执行：

```vim
:Lazy restore
```

等待完成后重启 Neovim。`lazy-lock.json` 用于恢复仓库记录的插件版本；迁移时优先使用 `restore`。`:Lazy sync` / `:Lazy update` 会更新插件，适合主动升级时使用，并应检查产生的 lockfile 变更。

已经完成首次安装时，也可无界面恢复插件版本：

```sh
nvim --headless "+Lazy! restore" +qa
```

插件版本可由 lockfile 恢复，Mason 工具、Treesitter 解析器和外部系统依赖仍需在每台机器上分别安装，不保证版本完全一致。

### 4. 安装语言工具并检查

打开一个 `.py`、`.cpp` 或 `.lua` 文件触发 LSP 配置，首次会通过 Mason 安装 `lua_ls`、`pyright`、`clangd`，格式化配置会尝试安装 `stylua`。可执行以下命令查看安装进度和补装工具：

```vim
:Mason
:MasonInstall lua-language-server pyright clangd stylua
:checkhealth
:checkhealth vim.lsp
```

按需安装：

| 功能 | 新机器上的额外准备 |
| --- | --- |
| Python 调试 | `:MasonInstall debugpy`；当前配置使用 `~/.local/share/nvim/mason/packages/debugpy/venv/bin/python`，自定义 `XDG_DATA_HOME` 时需修改 `lua/plugins/debug.lua` |
| C++ 调试 | `:MasonInstall codelldb`；使用 GDB / `cppdbg` 时另外安装对应工具并检查 PATH / `miDebuggerPath` |
| CUDA 调试 | 需要 CUDA Toolkit 的 `cuda-gdb` 及相应运行环境 |
| Git 界面 | 单独安装 `lazygit` |
| 文件管理器 | 单独安装 `yazi` |
| Copilot | 安装满足插件要求的 Node.js，在每台机器执行 `:Copilot setup` 登录 |
| LeetCode | 按插件提示在每台机器登录中国站；题目和缓存保存在数据目录 |
| 远程剪贴板 | `:checkhealth` 检查 clipboard provider；SSH 终端可结合终端的 OSC 52 支持处理 |

## 多台机器之间同步

推荐每次开始修改前先拉取，在一台机器完成、提交并推送后，再到其他机器拉取。

修改后推送：

```sh
cd "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
git pull --ff-only
# 修改配置后，先查看文件和差异
git status --short
git diff
# 按实际修改选择要提交的文件；有 lockfile 变更时也应检查并提交
git add init.lua lua snippets README.md lazy-lock.json
git diff --cached
git commit -m "Update Neovim configuration"
git push origin main
```

在另一台机器更新（先关闭其他 Neovim 实例）：

```sh
cd "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
git status --short  # 确认工作区干净；有本地修改时先提交或 stash
git pull --ff-only
nvim --headless "+Lazy! restore" +qa
```

如果用过 `git stash push -u` 暂存本地修改，拉取后用 `git stash pop` 恢复并处理冲突。`--ff-only` 遇到分叉会停止，需先检查并合并或 rebase，不要用强制推送覆盖其他机器的提交。新增插件、语言服务或解析器后，按安装步骤重新检查 Mason / Treesitter。

## 配置目录与迁移边界

```text
init.lua                 # 基础设置、快捷键、竞赛浮窗、lazy.nvim 入口
lua/core/                # 基础设置、Python 环境、DAP、插件管理
lua/plugins/             # 编辑、LSP、UI、Snacks、调试等插件配置
lua/cp_runner/           # C++ / Python 输入输出测试浮窗
snippets/cpp.json        # C++ 代码片段
lazy-lock.json           # 插件版本记录，需要一并同步
tests/cp_runner.lua      # 竞赛浮窗集成测试
docs/                    # 实施记录
```

只同步配置仓库。插件下载、Mason 工具、账号登录、题目、缓存、日志和编辑器状态在各机器上重新生成；不要直接复制整个 `~/.local/share/nvim` 来替代安装。`.gitignore` 已排除 `.DS_Store`、`.nvimlog`、交换文件和 `.env` 等本机文件。

默认数据目录通常是 `~/.local/share/nvim`。当前 `lua/core/lazynvim.lua` 将管理器自身路径拼为 `stdpath("data") .. "lazy/lazy.nvim"`，因此默认实际位于 `~/.local/share/nvimlazy/lazy.nvim`；普通插件仍由 lazy.nvim 放在其数据目录中。排查下载问题时注意这两个路径的区别。

机器相关设置需要检查：`lua/core/debugger.lua` 保留了 `/usr/bin/gdb` 以及 LHCb / Gaudi 的 `/cvmfs/...` 专用调试配置，只在对应环境下使用；普通 Python / C++ 开发请选择相应的通用调试项。

## 常见迁移问题

- **GitHub 克隆失败**：确认仓库权限、网络和代理。HTTPS 不接受账号密码推送，使用凭据管理器中的有效 token 或 SSH key；不要将 token / cookie 写进配置仓库。
- **编译器或 C++23 报错**：竞赛浮窗默认调用 `g++ -std=c++23`。macOS 的 `/usr/bin/g++` 通常是 Apple Clang，若使用 `bits/stdc++.h` 等 GNU 特性，需安装 GNU GCC，并将 `init.lua` 中 `cp_runner.setup` 的 `cpp` 设置为实际 GNU g++ 命令。另一个 `<leader>tc` 终端运行入口在 `lua/plugins/utils.lua` 中独立配置，也需对应调整。
- **Python 环境不对**：启动 Neovim 前先激活 Conda / virtualenv；LSP 和竞赛浮窗优先识别 `CONDA_PREFIX` / `VIRTUAL_ENV`，可用 `:PyrightPythonPath` 检查。`<leader>tp` 终端运行入口直接使用 PATH 中的 `python3`。
- **服务器没有 sudo**：可以在用户目录安装 Neovim、Node、编译工具等，并加入 PATH；Mason 工具也安装在用户数据目录中。仍然需要网络及可用的编译环境。
- **图标方框或 Alt / Command 快捷键无效**：设置终端字体为 Nerd Font，并检查终端的 Option / Alt 转发设置；`<D-...>` 为 macOS Command 键映射，在普通 SSH 终端可能不可用，可使用 Vim 原生命令。

## 验证竞赛测试浮窗

在仓库目录执行，需要 Python 和支持 C++23 的 `g++`：

```sh
nvim --headless -u NONE -i NONE -l tests/cp_runner.lua
```

该测试不加载第三方插件，验证编译运行、错误输出、超时、取消和浮窗交互。完整插件安装和平台兼容情况仍需在目标机器执行 `:checkhealth` 检查。

---

下方保留当前配置的快捷键和日常使用说明。


这份文档根据当前配置文件整理，重点记录快捷键、插件功能和常用工作流。

## 快捷键约定

| 记号 | 含义 |
| --- | --- |
| `<leader>` | 空格键 |
| `<localleader>` | `,` |
| `<C-x>` | `Ctrl + x` |
| `<M-x>` | `Alt/Option + x` |
| `<D-x>` | macOS `Command + x` |
| `<S-x>` | `Shift + x` |

模式说明：`n` 为普通模式，`i` 为插入模式，`v`/`x` 为可视模式，`o` 为 Operator-pending 模式，`t` 为终端模式。

## 基础编辑与窗口

| 快捷键 | 模式 | 功能 |
| --- | --- | --- |
| `<D-z>` | `n`/`i` | 撤销 |
| `<S-H>` | `n`/`x`/`o` | 跳到行首非空字符 |
| `<S-L>` | `n`/`x`/`o` | 跳到行尾 |
| `<M-h>` | `n` | 切换到左侧窗口 |
| `<M-j>` | `n` | 切换到下方窗口 |
| `<M-k>` | `n` | 切换到上方窗口 |
| `<M-l>` | `n` | 切换到右侧窗口 |
| `<Tab>` | `v` | 选中多行增加缩进，并保持选区 |
| `<S-Tab>` | `v` | 选中多行减少缩进，并保持选区 |
| `<Esc>` | `t` | 从终端模式回到普通模式 |

## 快捷键提示

| 快捷键 | 模式 | 功能 |
| --- | --- | --- |
| `<leader>?` | `n` | 显示当前 buffer 的局部快捷键 |
| `<leader>fk` | `n` | 用 Snacks picker 搜索所有快捷键 |

配置中启用了 `which-key.nvim`，按下 `<leader>` 后可以查看可用快捷键提示。

## 文件、Buffer 与项目查找

| 快捷键 | 模式 | 功能 |
| --- | --- | --- |
| `<leader>ff` | `n` | 智能查找文件 |
| `<leader>fF` | `n` | 智能查找文件，包含 ignored 文件 |
| `<leader>fo` | `n` | 打开最近文件 |
| `<leader><leader>` | `n` | 查看并切换已打开 buffer |
| `<leader>fc` | `n` | 查找 Neovim 配置文件 |
| `<leader>fp` | `n` | 查找项目 |
| `<leader>fh` | `n` | 查找帮助文档 |
| `<leader>fL` | `n` | 查看 Snacks picker 布局 |
| `<leader>fm` | `n` | 查找 marks |
| `<leader>fn` | `n` | 查看通知历史 |
| `<leader>fj` | `n` | 查找 jump list |
| `<leader>f/` | `n` | 查找搜索历史 |
| `<leader>fa` | `n` | 查找 autocmd |
| `<leader>fi` | `n` | 查找 icons |
| `<leader>fH` | `n` | 查看 highlight groups |
| `<leader>fb` | `n` | 查找 Git branches |

Snacks picker 内部：

| 快捷键 | 模式 | 功能 |
| --- | --- | --- |
| `<C-j>` | picker 输入/列表 | 下移一项 |
| `<C-k>` | picker 输入/列表 | 上移一项 |

## 全局搜索与替换

| 快捷键 | 模式 | 功能 |
| --- | --- | --- |
| `<leader>fw` | `n` | 全局 grep 搜索 |
| `<leader>fW` | `n`/`x` | 搜索光标下单词或选中内容 |
| `<leader>sr` | `n`/`v` | 打开 grug-far 查找替换；会按当前文件扩展名预填过滤条件 |

## 注释、格式化与跳转

| 快捷键 | 模式 | 功能 |
| --- | --- | --- |
| `<leader>/` | `n` | 注释/取消注释当前行 |
| `<leader>/` | `v` | 注释/取消注释选区 |
| `<leader>lf` | `n` | LSP/none-ls 格式化当前 buffer |
| `<leader>jj` | `n`/`x`/`o` | Flash 快速跳转 |
| `s` | `n`/`x`/`o` | 已禁用原生 `s`，避免和 surround 操作冲突 |

## 多光标编辑

| 快捷键 | 模式 | 功能 |
| --- | --- | --- |
| `<C-n>` | `n`/`v` | 为下一个匹配项添加光标 |
| `<leader>s` | `n`/`v` | 跳过下一个匹配项 |
| `<leader>N` | `n`/`v` | 为上一个匹配项添加光标 |
| `<leader>S` | `n`/`v` | 跳过上一个匹配项 |
| `<leader>A` | `n`/`v` | 为所有匹配项添加光标 |
| `<Left>` | `n`/`v` | 移到下一个多光标 |
| `<Right>` | `n`/`v` | 移到上一个多光标 |
| `<C-LeftMouse>` | `n` | 鼠标位置添加/处理光标 |
| `<C-q>` | `n`/`v` | 切换当前光标 |
| `<leader>gv` | `n` | 恢复上一次多光标 |
| `I` | `v` | 对选区内多光标执行行首插入 |
| `A` | `v` | 对选区内多光标执行行尾追加 |
| `M` | `v` | 根据选区匹配创建多光标 |
| `<C-i>` | `n`/`v` | 多光标向前跳转 |
| `<C-o>` | `n`/`v` | 多光标向后跳转 |
| `<Esc>` | `n` | 多光标存在时清除光标；否则清除搜索高亮 |

## LSP 与诊断

| 快捷键 | 模式 | 功能 |
| --- | --- | --- |
| `<leader>lr` | `n` | Lspsaga 重命名 |
| `<leader>ld` | `n` | 跳转到定义 |
| `<leader>lh` | `n` | 查看 hover 文档 |
| `<leader>lR` | `n` | Lspsaga finder，查看引用/定义等信息 |
| `<leader>ln` | `n` | 跳到下一个诊断 |
| `<leader>lp` | `n` | 跳到上一个诊断 |
| `<leader>le` | `n` | 浮窗显示当前行诊断 |
| `<leader>ls` | `n` | 查看当前 buffer 符号；优先使用 LSP symbols，失败时回退到 Treesitter |
| `<leader>fs` | `n` | 查看当前 buffer 符号 |
| `<leader>fS` | `n` | 查看 workspace symbols |
| `<leader>fd` | `n` | 查看诊断列表 |
| `<leader>fT` | `n` | 查找 TODO/FIX/FIXME/HACK/NOTE 注释 |

相关命令：

| 命令 | 功能 |
| --- | --- |
| `:PyrightPythonPath` | 显示当前 pyright 使用的 Python 解释器路径 |

当前 LSP 配置会自动启用 `lua_ls`、`pyright`、`clangd`。Python 会优先使用 `CONDA_PREFIX` 或 `VIRTUAL_ENV` 中的解释器。

## 补全与 Copilot

| 快捷键 | 模式 | 功能 |
| --- | --- | --- |
| `<Tab>` / `<S-Tab>` | `i`/命令行 | `blink.cmp` 使用 `super-tab` 预设，用于补全菜单选择、确认和 snippet 跳转 |
| `<C-j>` | `i` | 接受 GitHub Copilot 建议 |

补全源包括路径、snippets、buffer 和 LSP；命令行中 `/` 使用 buffer 补全，`:` 使用 cmdline 补全。

## 终端、运行与 Git

| 快捷键 | 模式 | 功能 |
| --- | --- | --- |
| `<C-\>` | `n`/`i` | ToggleTerm 默认终端开关 |
| `<leader>tf` | `n` | 打开浮动终端 |
| `<leader>tv` | `n` | 打开右侧垂直终端 |
| `<leader>th` | `n` | 打开底部水平终端 |
| `<leader>tc` | `n` | 保存并编译运行当前 C++ 文件，使用 `g++ -std=c++23` |
| `<leader>tp` | `n` | 保存并运行当前 Python 文件，使用 `python3` |
| `<leader>ti` | `n` | 打开竞赛测试浮窗，左侧输入、右侧输出，支持 `.cpp` / `.py` |
| `<leader>gg` | `n` | 在浮动终端中打开 lazygit |
| `<leader>lg` | `n` | 用 Snacks lazygit 打开当前文件所在 Git root |
| `<leader>yy` | `n`/`v` | 打开 yazi 文件管理器 |
| `q` | lazygit 终端普通模式 | 关闭 lazygit 终端窗口 |

### 竞赛测试浮窗

1. 打开已命名的 `.cpp` 或 `.py` 源文件，按 `<leader>ti`（依次按空格、`t`、`i`），也可以执行 `:CPTest`。
2. 在左侧输入或粘贴完整测试用例，包括题目要求的测试组数 `t`。支持多行输入。
3. 按 `Ctrl+r`，插件会保存源文件并运行，右侧显示输出；修改左侧输入后可以再次运行。

插件严格按文件后缀识别语言，其他后缀直接报错。`.cpp` 默认通过 `g++ -std=c++23 -O2 -Wall -Wextra` 编译后运行，编译产物放在临时目录并在任务结束后清理；`.py` 直接使用当前 Conda / virtualenv 环境的解释器，未激活环境时从 PATH 查找 Python。运行目录为源文件所在目录。

| 浮窗内快捷键 | 模式 | 功能 |
| --- | --- | --- |
| `Ctrl+r` | 普通 / 插入 | 保存源文件并运行；已有任务时停止旧任务并重新运行 |
| `Tab` / `Shift+Tab` | 普通 / 插入 | 切换输入与输出栏，切换后进入普通模式；在输入栏按 `i` 继续编辑 |
| `Ctrl+c` | 普通 / 插入 | 停止当前编译或运行 |
| `q` / `Esc` | 普通 | 关闭浮窗并返回源文件；插入模式先按 `Esc` 回普通模式 |

右侧输出只读，可以使用 Vim 移动、选择和复制操作；长行不折行，可用 `zl` / `zh` 横向滚动。stderr 单独标注，标题显示退出码或错误状态与耗时（运行耗时不含 C++ 编译）。输入按源文件在本次 Neovim 会话中保留，退出 Neovim 后不保留。空输入直接发送 EOF；非空输入自动补一个换行并发送 EOF。这是一次性标准输入测试，不用于交互题。

默认运行超时 5 秒、编译超时 30 秒、每个阶段的输出上限 1 MiB。可以在 `init.lua` 中修改现有的 `setup` 调用，例如：

```lua
require("cp_runner").setup({
    cpp = "g++", -- 可改为实际安装的 GNU g++ 路径或 clang++
    cpp_flags = { "-std=c++23", "-O2", "-Wall", "-Wextra" },
    -- python = "/path/to/python3", -- 留空时自动检测环境
    timeout = 5000,
    compile_timeout = 30000,
    output_limit = 1024 * 1024,
})
```

需要 Neovim 0.10+，以及相应语言的编译器或解释器。模块位于 `lua/cp_runner/`，无需安装第三方插件。回归测试：`nvim --headless -u NONE -i NONE -l tests/cp_runner.lua`。

## Buffer 管理

| 快捷键 | 模式 | 功能 |
| --- | --- | --- |
| `<leader>bc` | `n` | 删除当前 buffer |
| `<leader>bC` | `n` | 删除其他 buffer |

## 折叠

| 快捷键 | 模式 | 功能 |
| --- | --- | --- |
| `K` | `n` | 如果光标下有折叠内容则预览折叠行，否则调用 LSP hover |
| `zM` | `n` | 关闭所有折叠 |
| `zR` | `n` | 打开所有折叠 |
| `zm` | `n` | 增加折叠程度；支持数字前缀 |
| `zr` | `n` | 减少折叠程度；支持数字前缀 |
| `zS` | `n` | 将当前 buffer 的 foldlevel 设置为数字前缀，例如 `2zS` |
| `zE` / `zx` / `zX` | `n` | 已禁用，避免和 nvim-ufo 冲突 |

## 调试 DAP

| 快捷键 | 模式 | 功能 |
| --- | --- | --- |
| `<leader>du` | `n` | 切换 DAP UI |
| `<leader>ds` | `n` | 开始/继续调试 |
| `<F1>` | `n` | 开始/继续调试 |
| `<leader>di` | `n` | Step Into |
| `<F2>` | `n` | Step Into |
| `<leader>do` | `n` | Step Over |
| `<F3>` | `n` | Step Over |
| `<leader>dO` | `n` | Step Out |
| `<F4>` | `n` | Step Out |
| `<leader>dq` | `n` | 关闭当前调试 session |
| `<leader>dQ` | `n` | 终止调试 session |
| `<leader>dr` | `n` | 重启当前 frame |
| `<F5>` | `n` | 重启当前 frame |
| `<leader>dc` | `n` | 运行到光标处 |
| `<leader>dR` | `n` | 切换 DAP REPL |
| `<leader>dh` | `n` | 查看调试 hover 信息 |
| `<leader>db` | `n` | 切换断点 |
| `<leader>dB` | `n` | 设置条件断点 |
| `<leader>dD` | `n` | 清除所有断点 |

已配置的调试类型包括 C++/CUDA、Python，以及部分基于 `cppdbg`/GDB 的 Python 项目调试配置。

## LeetCode 与代码片段

| 功能 | 说明 |
| --- | --- |
| LeetCode | 启用 `leetcode.nvim`，默认语言为 `python3`，使用中国站 `leetcode.cn` 和题目翻译，picker 使用 Telescope |
| C++ snippet `#cf` | 生成包含多测试用例 `solve()` 的竞赛模板 |
| C++ snippet `#cpp` | 生成基础 C++ 模板 |

## 自动功能与界面

| 功能 | 说明 |
| --- | --- |
| 行号 | 开启绝对行号和相对行号 |
| 缩进 | 使用空格缩进，`tabstop=4`，`softtabstop=4` |
| 搜索 | `ignorecase` + `smartcase`：输入大写时大小写敏感，否则大小写不敏感 |
| 自动读取 | 文件外部变化时自动读取 |
| 分屏 | 新水平分屏默认在下方，新垂直分屏默认在右侧 |
| Treesitter | 启用 Lua、C/C++、Python、Markdown、LaTeX 等解析器高亮 |
| Markdown | 启用 `render-markdown.nvim`，并关闭 LaTeX 渲染 |
| 主题 | 使用 `catppuccin-mocha`，浮窗背景透明 |
| 状态栏 | 使用 lualine，显示分支、diff、诊断、文件名、文件大小、编码、文件类型和位置 |
| 自动清理 | 保存前自动删除行尾空格 |
| 剪贴板 | yank 内容同步到系统剪贴板，并高亮复制范围 |
