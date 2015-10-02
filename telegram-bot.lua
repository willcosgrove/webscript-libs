local TelegramBot = {}

function TelegramBot:new(key)
  o = {apiKey = key}
  setmetatable(o, self)
  self.__index = self
  return o
end

function TelegramBot:run(request)
  payload = json.parse(request.body)
  state = json.parse(storage[payload.message.chat.id] or "{}")
  if payload.message.group_chat_created and self.onGroupChatCreated then
    reply, newState = self.onGroupChatCreated(self, payload, state)
    newState = newState or state
    storage[payload.message.chat.id] = json.stringify(newState)
    return reply
  elseif payload.message.text and string.match(payload.message.text, "^/%a+") then
    _, _, command, args = string.find(payload.message.text, "/(%a+)[@]?%a*%s?(.*)")
    if self[command] then
      reply, newState = self[command](self, args, payload, state)
    else
      return 404
    end
    newState = newState or state
    storage[payload.message.chat.id] = json.stringify(newState)
    return reply
  else
    if self.catchall then
      reply, newState = self.catchall(self, args, payload, state)
      newState = newState or state
      storage[payload.message.chat.id] = json.stringify(newState)
      return reply
    else
      return 404
    end
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

function TelegramBot:sendMessage(message)
  local response = http.request({
    url = "https://api.telegram.org/bot"..self.apiKey.."/sendMessage",
    method = "POST",
    data = json.stringify(message),
    headers = {["Content-Type"] = "application/json"},
  })

  return json.parse(response.content)
end

return TelegramBot
