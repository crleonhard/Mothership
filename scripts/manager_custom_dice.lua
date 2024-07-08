local roll_types = {
}

function onInit()
  Comm.registerSlashHandler("followon", performRegisterFollowon);
end

function performRegisterFollowon(sFollowonCmd, sParams)
  if sParams == nil then
    return;
  end
  local nStart, nEnd, sCmd, sFollowon, sParamsParam = string.find(sParams, "([^%s]+)%s*([^%s]*)%s*(.*)");

  if sCmd ~= nil then
    if sParamsParam == nil then
      sParamsParam = "";
    end
    register_followon_handler(sCmd, sFollowon, sParamsParam);
  else
    ChatManager.SystemMessage("No command.");
  end
end

function rollRegistered(name)
  if roll_types[name] ~= nil then
    return true;
  else
    return false;
  end
end

function add_roll_type(name, perform_action, result_handler, use_modifiers, targeting, mod_handler, action_icon, total_handler)
  roll_types[name] = { perform_action=perform_action, slash_handler=slash_handler, result_handler=result_handler, mod_handler=mod_handler, followon_handler=nil, total_handler=total_handler };

  Comm.registerSlashHandler(name, processRoll);
  GameSystem.actions[name] = { sIcon = action_icon, bUseModStack = use_modifiers, sTargeting = targeting };
  if targeting ~= "none" then
    table.insert(GameSystem.targetactions, name);
  end
  ActionsManager.registerResultHandler(name, onRoll);
  ActionsManager.registerModHandler(name, onMod);
end

function register_followon_handler(roll_type, followon_type, params)
  local roll_type_record = roll_types[roll_type];
  local followon_type_record = roll_types[followon_type];
 
  if roll_type_record == nil then
    ChatManager.SystemMessage("Roll type is not registered.");
    return;
  end
  
  if followon_type == "" then
    followon_type = nil
  end
  
  roll_type_record.followon_handler = followon_type;
  roll_type_record.followon_params = params;
  ChatManager.SystemMessage("Registered.");
end

function performAction(roll_type, draginfo, rActor, sParams)
  local roll_type_record = roll_types[roll_type];
  if roll_type_record then
    local perform_action = roll_type_record.perform_action;
    if perform_action then
      return perform_action(draginfo, rActor, sParams);
    end
  end
end

function processRollOnTable(draginfo, rActor, sParams)
  return TableManager.processTableRoll("rollon", sParams);
end


function processRoll(sCommand, sParams)
local rActor = nil;
  if User.getCurrentIdentity() then
    rActor = ActorManager.resolveActor("charsheet."..User.getCurrentIdentity());
  end

  if User.isHost() then
    if sParams == "reveal" then
      OptionsManager.setOption("REVL", "on");
      SystemMessage(Interface.getString("message_slashREVLon"));
      return;
    end
    if sParams == "hide" then
      OptionsManager.setOption("REVL", "off");
      ChatManager.SystemMessage(Interface.getString("message_slashREVLoff"));
      return;
    end
  end

  performAction(sCommand, nil, rActor, sParams)  
end

function onMod(rSource, rTarget, rRoll)
  local roll_type_record = roll_types[rRoll.sType];

  if roll_type_record == nil then
    return;
  end
  local mod_handler = roll_type_record.mod_handler;
  if mod_handler ~= nil then
    return mod_handler(rSource, rTarget, rRoll);
  end
  
  return false;
end

function onRoll(rSource, rTarget, rRoll)
  local roll_type_record = roll_types[rRoll.sType];
  if roll_type_record == nil then
    return;
  end
  local result_handler = roll_type_record.result_handler;
  if result_handler ~= nil then
    result_handler(rSource, rTarget, rRoll);
  end
  local followon_action = nil;
  
  if roll_type_record.followon_handler == "rollon" then
    followon_action = processRollOnTable;
  else
    local followon_action_record = roll_types[roll_type_record.followon_handler]
    if followon_action_record ~= nil then
      followon_action = followon_action_record.perform_action;
    end
  end
  if followon_action ~= nil then
    followon_action(nil, rSource, roll_type_record.followon_params);
  end
end

function onDiceTotal( messagedata )
  local roll_type_record = roll_types[messagedata.type];
  if roll_type_record == nil then
    return false;
  end
  if roll_type_record.total_handler == nil then
    return false;
  end
  return roll_type_record.total_handler(messagedata);
end