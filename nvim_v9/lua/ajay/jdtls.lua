-- lua/ajay/jdtls.lua

local M = {}

function M.setup()
  -- Only setup for Java files
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "java",
    callback = function()
      local jdtls_ok, jdtls = pcall(require, "jdtls")
      if not jdtls_ok then
        vim.notify("jdtls not installed", vim.log.levels.WARN)
        return
      end

      -- Paths
      local jdtls_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
      local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
      local workspace_folder = vim.fn.stdpath("data") .. "/workspace/" .. project_name

      -- Ensure workspace folder exists
      vim.fn.mkdir(workspace_folder, "p")

      -- Get capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      if cmp_ok then
        capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
      end

      -- Extended capabilities for jdtls
      local extendedClientCapabilities = jdtls.extendedClientCapabilities
      extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

      -- Bundles for debugging and testing
      local bundles = {}

      -- Function to safely add bundles from Mason packages
      local function add_bundle_jars(package_name, jar_pattern)
        local ok, pkg = pcall(require, "mason-registry")
        if not ok then
          return
        end

        local get_ok, package = pcall(pkg.get_package, package_name)
        if not get_ok then
          return
        end

        local install_ok, install_path = pcall(package.get_install_path, package)
        if not install_ok then
          return
        end

        local jars = vim.split(vim.fn.glob(install_path .. jar_pattern), "\n")
        for _, jar in ipairs(jars) do
          if jar ~= "" then
            table.insert(bundles, jar)
          end
        end
      end

      -- Add bundles for debugging, testing, and Spring Boot
      add_bundle_jars("java-debug-adapter", "/extension/server/com.microsoft.java.debug.plugin-*.jar")
      add_bundle_jars("java-test", "/extension/server/*.jar")
      add_bundle_jars("spring-boot-tools", "/extension/jars/*.jar")

      -- Determine OS config
      local os_config = "config_linux"
      if vim.fn.has("mac") == 1 then
        os_config = "config_mac"
      elseif vim.fn.has("win32") == 1 then
        os_config = "config_win"
      end

      -- Config
      local config = {
        cmd = {
          "java",
          "-Declipse.application=org.eclipse.jdt.ls.core.id1",
          "-Dosgi.bundles.defaultStartLevel=4",
          "-Declipse.product=org.eclipse.jdt.ls.core.product",
          "-Dlog.protocol=true",
          "-Dlog.level=ALL",
          "-Xmx2g", -- Increased memory for Spring Boot projects
          "--add-modules=ALL-SYSTEM",
          "--add-opens",
          "java.base/java.util=ALL-UNNAMED",
          "--add-opens",
          "java.base/java.lang=ALL-UNNAMED",
          "-jar",
          vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"),
          "-configuration",
          jdtls_path .. "/" .. os_config,
          "-data",
          workspace_folder,
        },

        root_dir = require("jdtls.setup").find_root({
          -- Spring Boot markers first
          ".git",
          "mvnw",
          "gradlew",
          "pom.xml",
          "build.gradle",
          "build.gradle.kts",
          "settings.gradle",
          "settings.gradle.kts",
        }),

        settings = {
          java = {
            eclipse = {
              downloadSources = true,
            },
            configuration = {
              updateBuildConfiguration = "interactive",
              -- Add Java runtimes if you have multiple versions
              runtimes = {
                -- Example:
                -- {
                --   name = "JavaSE-17",
                --   path = "/usr/lib/jvm/java-17-openjdk",
                -- },
                -- {
                --   name = "JavaSE-21",
                --   path = "/usr/lib/jvm/java-21-openjdk",
                -- },
              },
            },
            maven = {
              downloadSources = true,
            },
            implementationsCodeLens = {
              enabled = true,
            },
            referencesCodeLens = {
              enabled = true,
            },
            references = {
              includeDecompiledSources = true,
            },
            format = {
              enabled = true,
            },
            signatureHelp = {
              enabled = true,
              description = { enabled = true },
            },
            contentProvider = {
              preferred = "fernflower",
            },
            -- Spring Boot specific settings
            import = {
              gradle = {
                enabled = true,
                wrapper = {
                  enabled = true,
                },
              },
              maven = {
                enabled = true,
              },
            },
            completion = {
              favoriteStaticMembers = {
                -- Spring Boot imports
                "org.springframework.boot.SpringApplication.run",
                "org.springframework.beans.factory.annotation.Autowired",
                "org.springframework.web.bind.annotation.*",
                "org.springframework.data.jpa.repository.*",
                -- JUnit
                "org.junit.jupiter.api.Assertions.*",
                "org.junit.jupiter.api.Assumptions.*",
                "org.mockito.Mockito.*",
                "org.mockito.ArgumentMatchers.*",
                -- Java standard
                "java.util.Objects.requireNonNull",
                "java.util.Objects.requireNonNullElse",
                "java.util.stream.Collectors.*",
              },
              filteredTypes = {
                "com.sun.*",
                "io.micrometer.shaded.*",
                "java.awt.*",
                "jdk.*",
                "sun.*",
              },
              importOrder = {
                "java",
                "javax",
                "org",
                "com",
              },
            },
            sources = {
              organizeImports = {
                starThreshold = 9999,
                staticStarThreshold = 9999,
              },
            },
            codeGeneration = {
              toString = {
                template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
              },
              useBlocks = true,
              hashCodeEquals = {
                useJava7Objects = true,
                useInstanceof = true,
              },
            },
            -- Enable automatic dependency download
            autobuild = {
              enabled = true,
            },
          },
        },

        flags = {
          allow_incremental_sync = true,
          debounce_text_changes = 150,
        },

        init_options = {
          bundles = bundles,
          extendedClientCapabilities = extendedClientCapabilities,
        },

        capabilities = capabilities,

        on_attach = function(client, bufnr)
          -- Enable jdtls-specific features
          pcall(jdtls.setup_dap, { hotcodereplace = "auto" })
          pcall(jdtls.setup.add_commands)

          -- Standard LSP keymaps
          local opts = { noremap = true, silent = true, buffer = bufnr }

          -- Navigation
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)

          -- Code actions
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("v", "<leader>ca", vim.lsp.buf.code_action, opts)

          -- Formatting
          vim.keymap.set("n", "<leader>lf", function()
            vim.lsp.buf.format({ async = true })
          end, opts)

          -- Java-specific keymaps
          vim.keymap.set("n", "<leader>jo", jdtls.organize_imports, { buffer = bufnr, desc = "Organize imports" })

          vim.keymap.set("n", "<leader>jv", jdtls.extract_variable, { buffer = bufnr, desc = "Extract variable" })
          vim.keymap.set(
            "v",
            "<leader>jv",
            [[<ESC><CMD>lua require('jdtls').extract_variable(true)<CR>]],
            { buffer = bufnr, desc = "Extract variable" }
          )

          vim.keymap.set("n", "<leader>jc", jdtls.extract_constant, { buffer = bufnr, desc = "Extract constant" })
          vim.keymap.set(
            "v",
            "<leader>jc",
            [[<ESC><CMD>lua require('jdtls').extract_constant(true)<CR>]],
            { buffer = bufnr, desc = "Extract constant" }
          )

          vim.keymap.set(
            "v",
            "<leader>jm",
            [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]],
            { buffer = bufnr, desc = "Extract method" }
          )

          -- Testing
          vim.keymap.set("n", "<leader>jt", jdtls.test_class, { buffer = bufnr, desc = "Test class" })
          vim.keymap.set("n", "<leader>jn", jdtls.test_nearest_method, { buffer = bufnr, desc = "Test nearest method" })

          vim.notify("✓ JDTLS started for Spring Boot", vim.log.levels.INFO)
        end,
      }

      -- Start jdtls
      jdtls.start_or_attach(config)
    end,
  })
end

return M
