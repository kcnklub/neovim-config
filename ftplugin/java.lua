-- Earlier groups take priority over nearer matches of later groups, so a
-- module's build.gradle loses to the project's settings.gradle/gradlew and
-- multi-module projects share one jdtls instance (neotest-java requires this).
local root_dir = vim.fs.root(0, {
    { "settings.gradle", "settings.gradle.kts", "gradlew", "mvnw" },
    { "build.gradle", "build.gradle.kts", "pom.xml" },
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

-- Debug (java-debug-adapter) and test (java-test) extensions, loaded into
-- jdtls as bundles. nvim-jdtls registers the nvim-dap adapter once they load.
local mason_packages = vim.fn.stdpath("data") .. "/mason/packages"
local bundles = vim.fn.glob(
    mason_packages .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
    true,
    true
)
local excluded_test_jars = {
    ["com.microsoft.java.test.runner-jar-with-dependencies.jar"] = true,
    ["jacocoagent.jar"] = true,
}
for _, jar in ipairs(vim.fn.glob(mason_packages .. "/java-test/extension/server/*.jar", true, true)) do
    if not excluded_test_jars[vim.fn.fnamemodify(jar, ":t")] then
        table.insert(bundles, jar)
    end
end

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
    -- The server asks the client which extra bundles to reload via this
    -- command. Bundles are passed once at startup through init_options, so
    -- answer with an empty list to avoid the
    -- "_java.reloadBundles.command not supported on client" error.
    commands = {
        ["_java.reloadBundles.command"] = function()
            return {}
        end,
    },
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
                -- Setting exclusions replaces jdtls' defaults, so the first
                -- four entries restore them. The last entry stops jdtls from
                -- importing eclipse.jdt.ls' own old Gradle test fixtures (e.g.
                -- gradle-4.0), which can't run on modern JDKs.
                exclusions = {
                    "**/node_modules/**",
                    "**/.metadata/**",
                    "**/archetype-resources/**",
                    "**/META-INF/maven/**",
                    "**/org.eclipse.jdt.ls.tests/projects/gradle/**",
                },
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
        return {
            bundles = bundles,
            extendedClientCapabilities = extendedClientCapabilities,
        }
    end)(),
}

require("jdtls").start_or_attach(config)

vim.keymap.set("n", "<leader>ci", function()
    require("jdtls").update_projects_config()
end, { buffer = 0, desc = "Import/Sync Build Config" })

vim.keymap.set("n", "<leader>dT", function()
    require("jdtls").test_class()
end, { buffer = 0, desc = "Debug Test Class" })

vim.keymap.set("n", "<leader>dm", function()
    require("jdtls").test_nearest_method()
end, { buffer = 0, desc = "Debug Nearest Test Method" })
