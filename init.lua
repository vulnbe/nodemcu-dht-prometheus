function startup()
  if file.open("init.lua") == nil then
    print("init.lua deleted")
  else
    print("Running")
    file.close("init.lua")
    dofile("server.lua")
  end
end

-- setup wifi
function setup_wifi(mode, ssid, pass)
  wifi.setmode(mode)

  station_cfg={}
  station_cfg.ssid=ssid
  station_cfg.pwd=pass
  station_cfg.auto=true
  station_cfg.save=false

  wifi.sta.config(station_cfg)
end

--init.lua
wifi.sta.disconnect()

if file.exists("config.lua") then
  print("Loading configration from config.lua")
  dofile("config.lua")
end

setup_wifi((wifi_mode or wifi.AP), (wifi_ssid or "node_esp8266"), (wifi_pass or "_esp8266_"))

print("connecting to wifi...")

local setupTimer = tmr.create()
setupTimer:register(1000, tmr.ALARM_AUTO, function (t) 
  if wifi.sta.getip() == nil then
    print("IP unavaiable, Waiting...")
  else
    t:unregister()
    print("Config done, IP is " .. wifi.sta.getip())
    print("Waiting 10 seconds before startup...")
    tmr.create():alarm(10000, tmr.ALARM_SINGLE, startup)
  end
end)
setupTimer:start()
