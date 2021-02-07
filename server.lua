local pin = 2
local headerOk = "HTTP/1.0 200 OK\r\nServer: NodeMCU on ESP8266\r\nContent-Type: text/plain; version=0.0.4\r\n\r\n"
local headerFail = "HTTP/1.0 500 Internal Server Error\r\nServer: NodeMCU on ESP8266\r\nContent-Type: text/plain; version=0.0.4\r\n\r\n"
local headerTimeout = "HTTP/1.0 504 Gateway Timeout\r\nServer: NodeMCU on ESP8266\r\nContent-Type: text/plain; version=0.0.4\r\n\r\n"

function response()
  status, temp, humi, temp_dec, humi_dec = dht.read(pin)
  if status == dht.OK then
    -- Integer firmware using this example
    print(string.format("DHT Temperature: %.1f; Humidity: %.1f\n",temp,humi))
    local body = "# HELP temperature Hardware monitor for temperature in celsius\n" ..
                 "# TYPE temperature gauge\n" ..
		             string.format("temperature{room=\"%s\"} %.1f\n",room,temp) ..
                 "# HELP humidity Hardware monitor for humidity in %\n" ..
                 "# TYPE humidity gauge\n" ..
                 string.format("humidity{room=\"%s\"} %.1f\n",room,humi)
    return headerOk .. body
  elseif status == dht.ERROR_CHECKSUM then
      print("DHT Checksum error.")
      return headerFail
  elseif status == dht.ERROR_TIMEOUT then
      print("DHT timed out.")
      return headerTimeout
  end
end

srv = net.createServer(net.TCP, 20) -- 20s timeout

if srv then
  srv:listen(80, function(conn)
    conn:on("receive", function(conn, data)
      local resp = response()
    --   print("< "  .. data)
    --   print("> " .. resp)
      conn:send(resp)
      conn:on("sent",function(conn) conn:close() end)
    end)
  end)
end
