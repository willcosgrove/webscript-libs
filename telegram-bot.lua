TelegramBot = {}

function TelegramBot:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function TelegramBot:run(request)
  payload = json.parse(request.body)
  if string.match(payload.message.text, "^/%a+") then
    _, _, command, args = string.find(payload.message.text, "/(%a+)%s?(.*)")
    return self[command](args, payload)
  else
    return 200
  end
end
