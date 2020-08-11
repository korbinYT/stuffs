local args,opts = require("shell").parse(...)
for i=1,#args do
  if i % 2 == 0 then
    local cmd = args[i-1]
    local amount = args[i]
    print("Running \"" .. cmd .. "\" with amount " .. amount)
    os.execute(cmd .. " " .. amount)
  end
end