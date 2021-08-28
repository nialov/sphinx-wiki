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

    local cmd_result = vim.fn.system(full_completed_cmd)
    if vim.v.shell_error ~= 0 then error("Task completion report failed.") end
    return cmd_result

end
return M
