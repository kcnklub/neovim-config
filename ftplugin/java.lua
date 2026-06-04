local root_dir = vim.fs.root(0, {
    "settings.gradle",
    "settings.gradle.kts",
    "build.gradle",
    "build.gradle.kts",
    "gradlew",
    "mvnw",
    ".git",
})

if not root_dir then
    return
end

local jdtls_bin = vim.fn.stdpath("data") .. "/mason/bin/jdtls"
if vim.fn.executable(jdtls_bin) ~= 1 then
    jdtls_bin = "jdtls"
end

local workspace_name = root_dir:gsub("[/\\:]", "_")
local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/workspace/" .. workspace_name
vim.fn.mkdir(workspace_dir, "p")

local config = {
    name = "jdtls",
    cmd = {
        jdtls_bin,
        "-data",
        workspace_dir,
    },
    root_dir = root_dir,
    capabilities = require("plugins.lsp.utils").capabilities(),
    settings = {
        java = {
            configuration = {
                updateBuildConfiguration = "automatic",
            },
            import = {
                gradle = {
                    enabled = true,
                    wrapper = {
                        enabled = true,
                    },
                    offline = {
                        enabled = false,
                    },
                },
            },
            project = {
                importOnFirstTimeStartup = "automatic",
            },
            maven = {
                downloadSources = true,
            },
            eclipse = {
                downloadSources = true,
            },
            references = {
                includeDecompiledSources = true,
            },
            contentProvider = {
                preferred = "fernflower",
            },
        },
    },
    init_options = {
        extendedClientCapabilities = require("jdtls.capabilities"),
    },
}

require("jdtls").start_or_attach(config)
