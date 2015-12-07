gpio.mode(4, gpio.OUTPUT)
gpio.mode(3, gpio.INPUT)
gpio.mode(3, gpio.INT)
ip = wifi.sta.getip()
print(ip)
kettle = 0;

function kettle_on()
    gpio.write(4, gpio.HIGH);
    off_alarm();
    kettle = 1;
    end

function kettle_off()
    gpio.write(4, gpio.LOW);
    print("Turning alarm off");
    tmr.stop(1);
    kettle = 0;
    end

function off_alarm()
    print("Turning alarm on.")
    tmr.alarm(1, 2400000, 0, function() gpio.write(4, gpio.LOW); print("Turning off") kettle = 0; end);
    end

function button(level)
  if (level == 0 and kettle == 0 and debounce == 0) then
     kettle_on();
     debounce = 1;
  end
  if (level == 0 and kettle == 1 and debounce == 0) then
     kettle_off();
     debounce = 1;
  end
  if level == 1 then
     debounce = 0;
     end
end    

gpio.trig(3, "both", button)

srv=net.createServer(net.TCP) 
srv:listen(80,function(conn) 
    conn:on("receive", function(client,request)
        local buf = "";
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then 
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP"); 
        end
        local _GET = {}
        if (vars ~= nil)then 
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do 
                _GET[k] = v 
            end
        end
        local _1,_0 = "",""
        if(_GET.coffee == "1")then
              _on = " selected=true";
              conn:send("HTTP/1.0 200 OK\r\n\n");
              conn:send("OK");
              print("On request recieved.");
              kettle_on();
        elseif(_GET.coffee == "0")then
              _off = " selected=\"true\"";
              conn:send("HTTP/1.1 200 OK\r\n\n");
              conn:send("OK");
              print("Off request recieved.");
              kettle_off();
        end
        client:close();
        collectgarbage();
    end)
end)
