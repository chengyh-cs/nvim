local M = {}

local python_root_markers = {
	"pyproject.toml",
	"setup.py",
	"setup.cfg",
	"requirements.txt",
	"Pipfile",
	"pyrightconfig.json",
	".git",
}

local function is_executable(path)
	return path ~= nil and path ~= "" and vim.fn.executable(path) == 1
end

local function get_python_from_env(env_name)
	local prefix = vim.env[env_name]
	if not prefix or prefix == "" then
		return nil
	end

	local python_path = prefix .. "/bin/python"
	if is_executable(python_path) then
		return python_path
	end

	return nil
end

function M.get_python_path()
	local python_path = get_python_from_env("CONDA_PREFIX") or get_python_from_env("VIRTUAL_ENV")
	if python_path then
		return python_path
	end

	for _, executable in ipairs({ "python", "python3" }) do
		python_path = vim.fn.exepath(executable)
		if python_path ~= "" then
			return python_path
		end
	end

	return nil
end

function M.get_python_root(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()

	local root = vim.fs.root(bufnr, python_root_markers)
	if root then
		return root
	end

	local filename = vim.api.nvim_buf_get_name(bufnr)
	if filename == "" then
		return vim.uv.cwd()
	end

	return vim.fs.dirname(filename)
end

function M.apply_python_path(config)
	local python_path = M.get_python_path()
	if not python_path then
		return nil
	end

	config.settings = config.settings or {}
	config.settings.python = vim.tbl_deep_extend("force", config.settings.python or {}, {
		pythonPath = python_path,
	})

	return python_path
end

function M.sync_python_client(client)
	local python_path = M.get_python_path()
	local settings = client.settings or client.config.settings
	if not python_path and not settings then
		return nil
	end

	client.settings = client.settings or {}
	client.settings.python = vim.tbl_deep_extend("force", client.settings.python or {}, python_path and {
		pythonPath = python_path,
	} or {})

	if python_path then
		client.config.settings = vim.tbl_deep_extend("force", client.config.settings or {}, {
			python = {
				pythonPath = python_path,
			},
		})
	end

	client:notify("workspace/didChangeConfiguration", {
		settings = client.settings,
	})
	return python_path
end

function M.get_client_python_path(client)
	if not client then
		return nil
	end

	local runtime_settings = client.settings and client.settings.python or nil
	if runtime_settings and runtime_settings.pythonPath then
		return runtime_settings.pythonPath
	end

	local config_settings = client.config.settings and client.config.settings.python or nil
	if config_settings and config_settings.pythonPath then
		return config_settings.pythonPath
	end

	return nil
end

return M
