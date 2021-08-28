M = {}

local task = "task"
local column_config = "rc.report.completed.columns=project,description"
local column_label_config = "rc.report.completed.labels=Project,Description"
local today_config = "end.after:now-24hour"

local full_completed_cmd = string.format("%s %s %s %s completed", task,
                                         column_config, column_label_config,
                                         today_config)

function M.check_task_executable()
    if vim.fn.executable(task) ~= 1 then
        error(string.format(
                  "Could not find executable %s. Cannot report on tasks.", task))
    end
end

function M.report_completed_tasks()

    local cmd_result_tbl = vim.fn.systemlist(full_completed_cmd)
    -- Check if system command errored
    if vim.v.shell_error ~= 0 then error("Task completion report failed.") end
    -- Record if start of wanted lines is found
    local start_found = false
    -- Collect wanted lines to report_table
    local report_table = {}
    for _, value in pairs(cmd_result_tbl) do
        -- First wanted line starts with Project
        if string.find(value, "Project") then start_found = true end
        -- If start has been found then start appending lines to report_table
        if start_found then
            -- Stop appending and iteration if line is empty (end of table)
            if #value == 0 then break end
            -- Append lines to wanted report_table
            table.insert(report_table, value)
        end
    end
    return vim.fn.join(report_table, "\n") .. "\n"

end

return M
