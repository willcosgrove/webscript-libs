local TelegramBot = {}

function TelegramBot:new(key)
  o = {apiKey = key}
  setmetatable(o, self)
  self.__index = self
  return o
end

function TelegramBot:run(request)
  payload = json.parse(request.body)
  if payload.message.text and string.match(payload.message.text, "^/%a+") then
    _, _, command, args = string.find(payload.message.text, "/(%a+)[@]?%a*%s?(.*)")
    if self[command] then
      return self[command](args, payload)
    else
      return 404
    end
  else
    return 200
  end
end

function TelegramBot:registerWebhook(webhook_url)
  webhook_url = webhook_url or ("https://" .. request.headers["Host"] .. request.path)
  http.request({
    url = "https://api.telegram.org/bot"..self.apiKey.."/setWebhook",
    method = "POST",
    data = {
      url = webhook_url,
    },
  })
  return true
end

return TelegramBot
