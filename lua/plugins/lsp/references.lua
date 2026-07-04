local M = {}

-- Paths that identify a Java test class. Path-based: standard Maven/Gradle
-- test source set. Chosen over name-based (*Test.java) to avoid hiding
-- production classes that legitimately contain "Test" in their name.
local JAVA_TEST_PATTERNS = { "/src/test/" }

--- Go to references. In Java buffers, exclude test classes by default.
--- @param include_tests boolean|nil  when true, show everything (no filtering)
function M.references(include_tests)
    local opts = {}
    if not include_tests and vim.bo.filetype == "java" then
        opts.file_ignore_patterns = JAVA_TEST_PATTERNS
    end
    require("telescope.builtin").lsp_references(opts)
end

return M
