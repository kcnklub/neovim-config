local M = {}

--- Resolve the target directory for a new file.
--- When nvim-tree is the focused window, use the node under the cursor.
--- Otherwise use the current buffer's directory (or cwd as fallback).
local function resolve_dir()
    if vim.bo.filetype == "NvimTree" then
        local ok, api = pcall(require, "nvim-tree.api")
        if ok then
            local node = api.tree.get_node_under_cursor()
            if node then
                if node.type == "directory" then
                    return node.absolute_path
                else
                    return vim.fs.dirname(node.absolute_path)
                end
            end
        end
    end

    local buf_name = vim.api.nvim_buf_get_name(0)
    if buf_name ~= "" then
        return vim.fs.dirname(buf_name)
    end
    return vim.fn.getcwd()
end

--- Derive the Java package from an absolute directory path.
--- Handles src/main/java, src/test/java, src/androidTest/java, etc.
--- Returns an empty string for the default package (src root itself).
local function derive_package(dir)
    -- Match anything under src/<anything>/java/...
    local sub = dir:match("/src/[^/]+/java/(.+)$")
    if sub then
        return (sub:gsub("/", "."))
    end

    -- Fallback: take everything after the last /java/ segment
    local fallback = dir:match("/java/(.+)$")
    if fallback then
        return (fallback:gsub("/", "."))
    end

    -- Dir IS the java source root (ends with /java)
    if dir:match("/java$") then
        return ""
    end

    return nil
end

--- Build the file lines for the given kind, name, and package.
local function build_lines(kind, name, pkg)
    local lines = {}

    if pkg and pkg ~= "" then
        lines[#lines + 1] = "package " .. pkg .. ";"
        lines[#lines + 1] = ""
    end

    if kind == "class" then
        lines[#lines + 1] = "public class " .. name .. " {"
    elseif kind == "interface" then
        lines[#lines + 1] = "public interface " .. name .. " {"
    elseif kind == "enum" then
        lines[#lines + 1] = "public enum " .. name .. " {"
    elseif kind == "record" then
        lines[#lines + 1] = "public record " .. name .. "() {"
    end

    lines[#lines + 1] = ""
    lines[#lines + 1] = "}"

    return lines
end

--- Create a new Java file with a correct package declaration and skeleton body.
--- Prompts for the class name via vim.ui.input and the kind via vim.ui.select
--- (rendered as a telescope popup when telescope-ui-select is installed).
function M.new_class()
    local dir = resolve_dir()

    local pkg = derive_package(dir)
    if pkg == nil then
        vim.notify(
            "Could not derive Java package from path:\n" .. dir .. "\nFile will be created without a package declaration.",
            vim.log.levels.WARN,
            { title = "New Java File" }
        )
        pkg = ""
    end

    vim.ui.input({ prompt = "Java name: " }, function(name)
        if not name or name == "" then
            return
        end

        -- Strip .java suffix if the user typed it
        name = name:gsub("%.java$", "")

        local path = dir .. "/" .. name .. ".java"

        if vim.loop.fs_stat(path) then
            vim.notify(
                "File already exists: " .. path,
                vim.log.levels.ERROR,
                { title = "New Java File" }
            )
            return
        end

        vim.ui.select(
            { "class", "interface", "enum", "record" },
            { prompt = "Kind:" },
            function(kind)
                if not kind then
                    return
                end

                local lines = build_lines(kind, name, pkg)

                -- Ensure the directory exists
                vim.fn.mkdir(dir, "p")

                local ok, err = pcall(vim.fn.writefile, lines, path)
                if not ok then
                    vim.notify(
                        "Failed to write file: " .. tostring(err),
                        vim.log.levels.ERROR,
                        { title = "New Java File" }
                    )
                    return
                end

                vim.cmd.edit(path)

                -- Place cursor on the blank body line (after the opening brace)
                local body_line = pkg ~= "" and 4 or 2
                vim.api.nvim_win_set_cursor(0, { body_line, 0 })
            end
        )
    end)
end

--- Create a JUnit 5 test class for the Java file in the current buffer.
--- Mirrors the source path under src/test/java, appends "Test" to the class name,
--- and opens the file (or jumps to it if it already exists).
function M.new_test()
    local src_path = vim.api.nvim_buf_get_name(0)
    if src_path == "" or not src_path:match("%.java$") then
        vim.notify("Not in a Java source file", vim.log.levels.ERROR, { title = "New Java Test" })
        return
    end

    -- Extract: project_root, source-set name, package path, and class name
    -- e.g. /proj/src/main/java/com/example/Foo.java
    --       prefix=  /proj  ss=main  rel= com/example/Foo
    local prefix, _, rel = src_path:match("^(.+)/src/([^/]+)/java/(.+)%.java$")
    if not prefix then
        vim.notify(
            "Could not determine source set from:\n" .. src_path,
            vim.log.levels.ERROR,
            { title = "New Java Test" }
        )
        return
    end

    -- rel is e.g. "com/example/Foo" or just "Foo" for the default package
    local class_name = rel:match("([^/]+)$")
    local pkg_rel = rel:match("^(.+)/[^/]+$")  -- "com/example", or nil for default package
    local pkg = pkg_rel and pkg_rel:gsub("/", ".") or ""

    local test_name = class_name .. "Test"
    local test_dir = prefix .. "/src/test/java" .. (pkg_rel and ("/" .. pkg_rel) or "")
    local test_path = test_dir .. "/" .. test_name .. ".java"

    -- If the test already exists, just jump to it
    if vim.loop.fs_stat(test_path) then
        vim.cmd.edit(test_path)
        return
    end

    local lines = {}
    if pkg ~= "" then
        lines[#lines + 1] = "package " .. pkg .. ";"
        lines[#lines + 1] = ""
        lines[#lines + 1] = "import org.junit.jupiter.api.Test;"
        lines[#lines + 1] = ""
        lines[#lines + 1] = "import static org.junit.jupiter.api.Assertions.*;"
        lines[#lines + 1] = ""
    end
    lines[#lines + 1] = "class " .. test_name .. " {"
    lines[#lines + 1] = ""
    lines[#lines + 1] = "    @Test"
    lines[#lines + 1] = "    void test() {"
    lines[#lines + 1] = ""
    lines[#lines + 1] = "    }"
    lines[#lines + 1] = ""
    lines[#lines + 1] = "}"

    vim.fn.mkdir(test_dir, "p")

    local ok, err = pcall(vim.fn.writefile, lines, test_path)
    if not ok then
        vim.notify(
            "Failed to write test file: " .. tostring(err),
            vim.log.levels.ERROR,
            { title = "New Java Test" }
        )
        return
    end

    vim.cmd.edit(test_path)

    -- Place cursor inside void test() body
    local body_line = pkg ~= "" and 11 or 4
    vim.api.nvim_win_set_cursor(0, { body_line, 0 })
end

return M
