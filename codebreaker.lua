local bot, extension = require("lua-bot-api").configure('YOUR TOKEN HERE')


local function disp_rules()
    local rules="=== CODEBREAK ===\n"
    .."Il gioco consiste nell' indovinare il codice del bot in un numero massimo di tentativi.\n"
    .."Il codice generato dal bot conterrà le cifre da 0 a 9 (incluse) ma mai ripetute; codici validi del bot potrebbero quindi essere:\n"
    .."01234567\n210349\n12547690\nE così via, ovviamente la lunghezza dipende dalla difficoltà\n"
    .."Per iniziare una nuova partita, usa /newgame. \nPer una spiegazione dettagliata dei comandi, usa /commands.\n"
    .."Il gioco viene inizializzato a lv. 4 (codice di 7 cifre, tentativi massimi 15) e la difficoltà varia da lv. 1 ad 8."

    return rules
end

--check if given table contains an element. By key and by value.
local function table_contains(table, element, query)
  if not query then
    query = 'value'
  end

  for k,v in pairs(table) do
    if query == 'value' and v == element then
        return true
    elseif query == 'key' and k == element then
        return true
    end
  end
  return false
end

--check if table entries are equals to given num
local function tableElements(table,num)
    num=tonumber(num)
    local count=0
    for k,v in pairs(table) do
        count = count+1
    end
    
    if (count==num) then
        return true
    else
        return false
    end
end

local function vardumpTable(table)
    for k,v in ipairs(table) do
        print("INDEX: "..k.."\tVALUE: "..v.."\n")
    end
end

--create the sequence
local function generate_sequence(group_id)
    local configs = load_data("./data/breakconfig.json")
    local max_seq = tonumber(configs[tostring(group_id)]["digits"])
    local chars = {}
    while(not tableElements(chars,max_seq)) do
        local digit = math.random(0,9)
        digit = tostring(digit)
        if not table_contains(chars,digit) then
            table.insert(chars,digit)
        end
    end
    
    return chars
end

local function insert_in_code(chars,group_id)
    local configs = load_data("./data/breakconfig.json")
    configs[tostring(group_id)]["code"] = chars
    save_data("./data/breakconfig.json",configs)
end


--trim input string into chars and convert each character into number.
--str must be a string, so check if input sequence is valid before using this!
--output: table converted, populated by integers
local function string_to_table(str,is_spaced)
    local parsed = {}
    local converted = {}
    if is_spaced then
        parsed = stringSplit(str,"%S")
        for k,v in ipairs(parsed) do
            table.insert(converted,tonumber(v))
        end
    else
        parsed = stringSplit(str,"%d")
        for k,v in ipairs(parsed) do
            table.insert(converted,tonumber(v))
        end
    end
    
    return converted
end


--check input digits. tab must be a trimmed input table
local function count_input_digits(groupid,tab)
    local conf = load_data("./data/breakconfig.json")
    local codeDigits = tonumber(conf[tostring(groupid)].digits)
    
    if tableElements(tab,codeDigits) then
        return true
    end
    
    return false
end


local function table_comparator(group_id,tab)
    local configs = load_data("./data/breakconfig.json")
    code = configs[tostring(group_id)]["code"]
    local rRightPlace = 0
    local rWrongPlace = 0
    local results = {}
    for k,v in ipairs(code) do
        v = tonumber(v)
        for i,j in ipairs(tab) do
            if v==j then
                if k==i then
                    rRightPlace = rRightPlace+1
                else
                    rWrongPlace = rWrongPlace+1
                end
            end
        end
    end
    table.insert(results,rRightPlace)
    table.insert(results,rWrongPlace)
    return results
end            
            
        
--add empty json table inside folder data
local function create_configs(group_id)
    local configs = load_data("./data/breakconfig.json")
    group_id = tostring(group_id)
    
    if not configs[group_id] then
        configs[group_id] = {
            code = {},
            humans = 0,
            bot = 0,
            digits = 7,
            max_attempts = 15,
            attempts = 0,
            level = 4
        }
        
        save_data("./data/breakconfig.json",configs)
        return true
    end

    return false
end

--utility
local function incr_bot_points(groupid)
    local configs = load_data("./data/breakconfig.json")
    local points = configs[tostring(groupid)].bot
    points = points + 1
    configs[tostring(groupid)].bot = points
    save_data("./data/breakconfig.json",configs)
end

local function incr_humans_points(groupid)
    local configs = load_data("./data/breakconfig.json")
    local points = configs[tostring(groupid)].humans
    points = points + 1
    configs[tostring(groupid)].humans = points
    save_data("./data/breakconfig.json",configs)
end

local function set_max_attempts(groupid,num)
    local configs = load_data("./data/breakconfig.json")
    configs[tostring(groupid)].max_attempts = num
    save_data("./data/breakconfig.json",configs)
end

local function reset_attempts(groupid)
    local configs = load_data("./data/breakconfig.json")
    configs[tostring(groupid)].attempts = 0
    save_data("./data/breakconfig.json",configs)
end

local function check_attempts(groupid)
    local configs = load_data("./data/breakconfig.json")
    local a1 = configs[tostring(groupid)].attempts
    local a2 = configs[tostring(groupid)].max_attempts
    
    if a1 == a2 then
        return true
    end
    
    return false
end

local function check_is_playing(groupid)
    local configs = load_data("./data/breakconfig.json")
    local a = configs[tostring(groupid)].attempts
    if a == 0 then
        return false
    end
    return true
end

local function set_digits(groupid,num)
    local configs = load_data("./data/breakconfig.json")
    configs[tostring(groupid)].digits = num
    save_data("./data/breakconfig.json",configs)
end

local function get_digits(groupid)
    local configs = load_data("./data/breakconfig.json")
    num = tonumber(configs[tostring(groupid)].digits)
    return num
end

local function incr_attempts(groupid)
    local configs = load_data("./data/breakconfig.json")
    local attempts = configs[tostring(groupid)].attempts
    attempts = attempts + 1
    configs[tostring(groupid)].attempts = attempts
    save_data("./data/breakconfig.json",configs)
end

local function get_game_info(groupid)
    local configs = load_data("./data/breakconfig.json")
    
    if not configs[tostring(groupid)] then
        return "START A NEW GAME BEFORE USING THIS COMMAND"
    end
    
    local bpoints = configs[tostring(groupid)].bot
    local hpoints = configs[tostring(groupid)].humans
    local digits = configs[tostring(groupid)].digits
    local m_attempts = configs[tostring(groupid)].max_attempts
    local attempts = configs[tostring(groupid)].attempts
    local level = configs[tostring(groupid)].level
    
    return "> CURRENT GAME INFOs <\n".."Level: "..level.."\nMax attempts: "..m_attempts.."\nCode digits: "..digits.."\nCurrent attempts: "..attempts.."\n\n> POINTS <\n".."BOT: "..bpoints.."\nHumans: "..hpoints
end

local function get_bot_about()
    local text = "This bot is written by @Seg_fault from LM.\n"
    .."Based on lua-api wrapper from @cosmonawt.\n"
    .."Please feel free to report any bug or suggesting new functions in our group [to be created soon]\n"
    .."This bot does not collect any personal data! it just stores your group ID to let other users play in their groups :)\n"
    .."Group ID is also used to handle the global ranking chart.\n"
    .."I would also like to release source code but it's kinda horrible right now so... one day, maybe :)\n"
    .."Have fun!"
    
    return text
end

local function set_level(groupid,level)
    local configs = load_data("./data/breakconfig.json")
    
    if not configs[tostring(groupid)] then
        return "START A NEW GAME BEFORE USING THIS COMMAND"
    end
    
    local digits = tonumber(configs[tostring(groupid)].digits)
    local max_attempts = tonumber(configs[tostring(groupid)].max_attempts)
    
    if level<1 then
        return "Level range: 1 to 8"
    elseif level>8 then
        return "level range: 1 to 8"
    end
    
    if level == 1 then
        digits = 4
        max_attempts = 10
    elseif level == 2 then
        digits = 5
        max_attempts = 12
    elseif level == 3 then
        digits = 6
        max_attempts = 13
    elseif level == 4 then
        digits = 7
        max_attempts = 15
    elseif level == 5 then
        digits = 8
        max_attempts = 17
    elseif level == 6 then
        digits = 8
        max_attempts = 15
    elseif level == 7 then
        digits = 8
        max_attempts = 13
    elseif level == 8 then
        digits = 8
        max_attempts = 11
    end
    
    configs[tostring(groupid)].digits = digits
    configs[tostring(groupid)].max_attempts = max_attempts
    
    save_data("./data/breakconfig.json",configs)
    
    return "LV. "..level.."\n".."Digits: "..tonumber(configs[tostring(groupid)].digits).."\n".."Max. attempts: "..tonumber(configs[tostring(groupid)].max_attempts)
end

local function get_bot_commands()
    local text = "=== COMANDI ===\n"
    .."/rules : mostra le regole del gioco\n"
    .."/newgame : inizia una nuova partita\n"
    .."/code [numero] : prova ad inserire il [numero] come codice. Non usare le parentesi quadre!\n"
    .."/info : mostra i dati sulla partita: punti, livello, tentativi correnti ecc.\n"
    .."/level [numero] : imposta il livello [numero]. varia da 1 a 8 estremi inclusi. !NON ANCORA IMPLEMENTATO!\n"
    .."/turns : mostra il numero di turno corrente\n"
    .."/scores : mostra il punteggio del gruppo\n"
    .."/commands : mostra questo messaggio lol\n"
    .."/about : about del bot"
    
    return text
end



extension.onTextReceive = function(msg)
    
    local matches = {msg.text:match('/(code) (%d+)')}
    local matches1 = {msg.text:match('/(level) (%d)')}
    
    if (msg.text=="/rules") then
        local output = disp_rules()
        bot.sendMessage(msg.chat.id,output)
    end
    
    if (msg.text=="/init") then
        if create_configs(msg.chat.id) then
            bot.sendMessage(msg.chat.id,"done :)")
        else
            bot.sendMessage(msg.chat.id,"this group is already added")
        end
    end

    if (msg.text=="/newgame") then
        if create_configs(msg.chat.id) then
            bot.sendMessage(msg.chat.id,"This group is not started. Automatically added and generated a new code.")
        end
        reset_attempts(msg.chat.id)
        insert_in_code(generate_sequence(msg.chat.id),msg.chat.id)
        bot.sendMessage(msg.chat.id,"Sequence initialized.\nLet's start ;)")
    end
    
    if matches[1] == "code" and tonumber(matches[2]) then
        local codeInserted = string_to_table(matches[2],false)
        if count_input_digits(msg.chat.id,codeInserted) then
            if not check_attempts(msg.chat.id) then
                incr_attempts(msg.chat.id)
                local results = table_comparator(msg.chat.id,codeInserted)
                if results[1] == get_digits(msg.chat.id) then
                    bot.sendMessage(msg.chat.id,"> CODE CONFIRMED <\n\nUse /newgame to generate a new code and start new game :)",false,true,false)
                    incr_humans_points(msg.chat.id)
                    reset_attempts(msg.chat.id)
                    insert_in_code(generate_sequence(msg.chat.id),msg.chat.id)
                    return
                end
                local output = "There are:\n"..results[1].." numbers in the right place\n"..results[2].." right numbers in the wrong place"
                bot.sendMessage(msg.chat.id,output,false,true,false)
            else
                bot.sendMessage(msg.chat.id,"> YOU LOSE <",false,true,false)
                incr_bot_points(msg.chat.id)
                reset_attempts(msg.chat.id)
                insert_in_code(generate_sequence(msg.chat.id),msg.chat.id)
            end
        else
            bot.sendMessage(msg.chat.id,"Invalid input!")
        end
    end

    if (msg.text=="/info") then
        local text=get_game_info(msg.chat.id)
        bot.sendMessage(msg.chat.id,text)
    end
    
    if (msg.text=="/turns") then
        local configs = load_data("./data/breakconfig.json")
        local attpts = configs[tostring(msg.chat.id)].attempts
        local m_attempts = configs[tostring(msg.chat.id)].max_attempts
        local output="You are playing turn: "..attpts.."/"..m_attempts
        bot.sendMessage(msg.chat.id,output)
    end
    
    if (msg.text=="/score") then
        local configs = load_data("./data/breakconfig.json")
        local Hpts = configs[tostring(msg.chat.id)].humans
        local Bpts = configs[tostring(msg.chat.id)].bot
        local output = "BOT: "..Bpts.."\nYOU: "..Hpts
        bot.sendMessage(msg.chat.id,output)
    end
    
    if (msg.text=="/about") then
        local output = get_bot_about()
        bot.sendMessage(msg.chat.id,output)
    end
    
    if matches1[1] == "level" and tonumber(matches1[2]) then
        local lvl = tonumber(matches1[2])
        local output = set_level(msg.chat.id,lvl)
        bot.sendMessage(msg.chat.id,output)
    end
            
    if (msg.text == "/commands") then
        local output = get_bot_commands()
        bot.sendMessage(msg.chat.id,output)
    end
        
end

extension.run()