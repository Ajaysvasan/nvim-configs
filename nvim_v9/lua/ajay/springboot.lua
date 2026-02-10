-- lua/ajay/springboot.lua

local M = {}

-- Function to create a new Spring Boot project using Spring Initializr
function M.create_project()
  local project_name = vim.fn.input("Project name: ")
  if project_name == "" then
    vim.notify("Project name cannot be empty", vim.log.levels.ERROR)
    return
  end

  local group_id = vim.fn.input("Group ID (com.example): ", "com.example")
  local artifact_id = vim.fn.input("Artifact ID (" .. project_name .. "): ", project_name)
  local java_version = vim.fn.input("Java version (17/21): ", "17")
  local build_tool = vim.fn.input("Build tool (maven/gradle): ", "maven")
  local dependencies = vim.fn.input("Dependencies (comma-separated, e.g., web,data-jpa,h2): ", "web,devtools")

  -- Construct Spring Initializr URL
  local base_url = "https://start.spring.io/starter.zip"
  local url = string.format(
    "%s?type=%s-project&language=java&bootVersion=3.2.0&groupId=%s&artifactId=%s&name=%s&packageName=%s.%s&javaVersion=%s&dependencies=%s",
    base_url,
    build_tool,
    group_id,
    artifact_id,
    project_name,
    group_id,
    artifact_id,
    java_version,
    dependencies
  )

  -- Download and extract
  local download_cmd = string.format('curl -o /tmp/%s.zip "%s"', project_name, url)
  vim.notify("Downloading Spring Boot project...", vim.log.levels.INFO)

  vim.fn.system(download_cmd)

  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to download project", vim.log.levels.ERROR)
    return
  end

  -- Extract to current directory
  local extract_cmd = string.format("unzip -q /tmp/%s.zip -d ./%s", project_name, project_name)
  vim.fn.system(extract_cmd)

  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to extract project", vim.log.levels.ERROR)
    return
  end

  -- Clean up
  vim.fn.system(string.format("rm /tmp/%s.zip", project_name))

  vim.notify("✓ Spring Boot project created: " .. project_name, vim.log.levels.INFO)
  vim.notify("Run :cd " .. project_name .. " to navigate to the project", vim.log.levels.INFO)
end

-- Function to run Spring Boot application
function M.run_app()
  local build_tool = vim.fn.filereadable("pom.xml") == 1 and "maven" or "gradle"

  if build_tool == "maven" then
    vim.cmd("!./mvnw spring-boot:run")
  else
    vim.cmd("!./gradlew bootRun")
  end
end

-- Function to build project
function M.build_project()
  local build_tool = vim.fn.filereadable("pom.xml") == 1 and "maven" or "gradle"

  if build_tool == "maven" then
    vim.cmd("!./mvnw clean install")
  else
    vim.cmd("!./gradlew build")
  end
end

-- Function to run tests
function M.run_tests()
  local build_tool = vim.fn.filereadable("pom.xml") == 1 and "maven" or "gradle"

  if build_tool == "maven" then
    vim.cmd("!./mvnw test")
  else
    vim.cmd("!./gradlew test")
  end
end

-- Setup user commands
function M.setup()
  vim.api.nvim_create_user_command("SpringBootCreate", M.create_project, {
    desc = "Create new Spring Boot project",
  })
  vim.api.nvim_create_user_command("SpringBootRun", M.run_app, {
    desc = "Run Spring Boot application",
  })
  vim.api.nvim_create_user_command("SpringBootBuild", M.build_project, {
    desc = "Build Spring Boot project",
  })
  vim.api.nvim_create_user_command("SpringBootTest", M.run_tests, {
    desc = "Run Spring Boot tests",
  })

  -- Keymaps for Spring Boot (using <leader>s prefix)
  vim.keymap.set("n", "<leader>sc", M.create_project, { desc = "Spring Boot: Create Project" })
  vim.keymap.set("n", "<leader>sr", M.run_app, { desc = "Spring Boot: Run App" })
  vim.keymap.set("n", "<leader>sb", M.build_project, { desc = "Spring Boot: Build" })
  vim.keymap.set("n", "<leader>st", M.run_tests, { desc = "Spring Boot: Test" })
end

return M
