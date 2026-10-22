return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		image = {
			enabled = true,
			formats = {
				"png", "jpg", "jpeg", "gif", "bmp", "webp", "tiff", "heic", "avif",
				"mp4", "mov", "avi", "mkv", "webm", "pdf", "icns",
				"svg",
			},
			doc = {
				max_width = math.huge, -- placement already clamps to the window width
				max_height = 60,
			},
		},
	},
	config = function(_, opts)
		require("snacks").setup(opts)

		-- ImageMagick's built-in SVG renderer can't resolve fonts here, so render
		-- SVGs with rsvg-convert instead. snacks has no public hook for this, so
		-- register the step in its private `commands` table.
		if vim.fn.executable("rsvg-convert") == 1 then
			local function upvalue(fn, name)
				for i = 1, math.huge do
					local n, v = debug.getupvalue(fn, i)
					if not n then return end
					if n == name then return v end
				end
			end
			local Convert = upvalue(require("snacks.image.convert").convert, "Convert")
			local commands = Convert and upvalue(Convert._resolve, "commands")
			if commands then
				commands.svg = {
					ft = "png",
					cmd = { { cmd = "rsvg-convert", args = { "--zoom", 2, "-f", "png", "-o", "{file}", "{src}" } } },
				}
			end
		end
	end,
}
