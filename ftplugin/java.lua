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

local lombok_jar = vim.fn.stdpath("data") .. "/mason/packages/jdtls/lombok.jar"

local workspace_name = root_dir:gsub("[/\\:]", "_")
local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/workspace/" .. workspace_name
vim.fn.mkdir(workspace_dir, "p")

local cmd = { jdtls_bin }
if vim.fn.filereadable(lombok_jar) == 1 then
    table.insert(cmd, "--jvm-arg=-javaagent:" .. lombok_jar)
end
-- Give the JDTLS JVM a larger heap to avoid GC thrashing / CPU spikes.
table.insert(cmd, "--jvm-arg=-Xms1g")
table.insert(cmd, "--jvm-arg=-Xmx4g")
vim.list_extend(cmd, { "-data", workspace_dir })

local config = {
    name = "jdtls",
    cmd = cmd,
    root_dir = root_dir,
    capabilities = require("plugins.lsp.utils").capabilities(),
    settings = {
        java = {
            format = {
                comments = {
                    enabled = false,
                },
                settings = {
                    url = vim.fn.stdpath("config") .. "/lang/eclipse-java-formatter.xml",
                    profile = "nvim-jdtls",
                },
            },
            -- "interactive" avoids the automatic Gradle re-sync loop that can
            -- leak Timer threads on large composite builds. Run :lua require("jdtls").update_projects_config()
            -- (or accept the prompt) after changing build files.
            configuration = {
                updateBuildConfiguration = "interactive",
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
    init_options = (function()
        local extendedClientCapabilities = require("jdtls.capabilities")
        extendedClientCapabilities.resolveAdditionalTextEditsSupport = true
        return { extendedClientCapabilities = extendedClientCapabilities }
    end)(),
}

require("jdtls").start_or_attach(config)
