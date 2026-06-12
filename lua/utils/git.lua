local M = {}

function M.get_git_user()
	return vim.fn.system("git config user.email"):gsub("\n", "")
end

local function resolve_branch()
	vim.fn.system("git rev-parse --verify develop")
	return vim.v.shell_error == 0 and "develop" or "origin/develop"
end

function M.get_develop_commits(filter_author)
	local branch = resolve_branch()
	local cmd = { "git", "log", branch, "--format=%H|%as|%an|%s" }
	if filter_author then
		local email = M.get_git_user()
		if email ~= "" then
			table.insert(cmd, "--author=" .. email)
		end
	end
	table.insert(cmd, "--not")
	table.insert(cmd, "HEAD")

	local output = vim.fn.system(cmd)
	local commits = {}
	for line in output:gmatch("[^\n]+") do
		local hash, date, author, subject = line:match("^([^|]+)|([^|]+)|([^|]+)|(.+)$")
		if hash then
			table.insert(commits, { hash = hash, date = date, author = author, subject = subject })
		end
	end
	return commits
end

function M.cherry_pick_picker()
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local previewers = require("telescope.previewers")

	local diff_previewer = previewers.new_termopen_previewer({
		get_command = function(entry)
			return { "env", "GIT_EXTERNAL_DIFF=difft", "DFT_DISPLAY=inline", "git", "--no-pager", "show", "--ext-diff", entry.value }
		end,
	})

	local function open(filter_author)
		local commits = M.get_develop_commits(filter_author)
		if #commits == 0 then
			local msg = filter_author and "No commits by you on develop not in current branch"
				or "No commits on develop not in current branch"
			vim.notify(msg, vim.log.levels.INFO)
			return
		end

		local title = filter_author and "Cherry Pick (my commits)  [<C-f> show all]"
			or "Cherry Pick from develop  [<C-f> filter mine]"

		pickers
			.new({}, {
				prompt_title = title,
				previewer = diff_previewer,
				finder = finders.new_table({
					results = commits,
					entry_maker = function(commit)
						local short = commit.hash:sub(1, 7)
						local display = string.format(
							"%-7s %s  %-20s  %s",
							short,
							commit.date,
							commit.author:sub(1, 20),
							commit.subject
						)
						return {
							value = commit.hash,
							display = display,
							ordinal = commit.subject .. " " .. commit.author .. " " .. short,
						}
					end,
				}),
				sorter = conf.generic_sorter({}),
				attach_mappings = function(prompt_bufnr, map)
					actions.select_default:replace(function()
						actions.close(prompt_bufnr)
						local sel = action_state.get_selected_entry()
						if not sel then
							return
						end
						local result = vim.fn.system({ "git", "cherry-pick", sel.value })
						if vim.v.shell_error ~= 0 then
							vim.notify("Cherry-pick failed:\n" .. result, vim.log.levels.ERROR)
						else
							vim.notify("Cherry-picked " .. sel.value:sub(1, 7), vim.log.levels.INFO)
						end
					end)

					local toggle = function()
						actions.close(prompt_bufnr)
						open(not filter_author)
					end
					map("i", "<C-f>", toggle)
					map("n", "<C-f>", toggle)
					return true
				end,
			})
			:find()
	end

	open(false)
end

return M
