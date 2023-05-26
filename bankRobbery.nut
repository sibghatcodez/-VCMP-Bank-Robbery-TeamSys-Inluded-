// -> I received a complaint about my previous code having numerous bugs. Therefore, I have made several changes to enhance its readability and ensure it is error-free.
//Tested, 101% working! <:D

//Add this in your class
Team = false;
 Partner = "";
 Requested = false;

 AtAmmu = false;
 BombBought = false;
 InsideLocker = false;



//Add this in onScriptLoad

insideBank <- CreateCheckpoint(null, 0, true, Vector(-937.568, -351.482, 17.8038), ARGB(255,255,255,255),2)// Banklocker entrance.
outsideBank <- CreateCheckpoint(null, 0, true, Vector(-939.012, -351.882, 7.22692), ARGB(255,255,255,255),2)// Banklocker exit.
bankBomb <- CreateCheckpoint(null, 0, true, Vector(-676.604, 1206.94, 11.1082), ARGB(255,255,16,0),1)// Bank bomb.
bankPickup <- CreatePickup( 410, 1, 0, Vector(-948.597, -344.569, 7.22694), 255, true ); //Bank robbery pickup.


BankRobbed <- true;
BankGettingRobbed <- false;
BankRobTime <- 1800;
BankTime <- 0;




//onPlayerCommand Function

function onPlayerCommand( player, cmd, text )
{
  switch(cmd) {

    case "bankrob":
    BankRobTimeLeft(player);
    break;
   
    case "team":
    if(!stats[player.ID].Team) MessagePlayer("-> You're not in any team. Use /teamup.",player);
    else {
      MessagePlayer("You: "+player.Name+" | Teammate: "+stats[player.ID].Partner,player);
    }
    break;

    case "teamup":
    if(!text) MessagePlayer("-> /teamup <Target Player>",player);
    else if(stats[player.ID].Team) MessagePlayer("-> You're already in team with "+stats[player.ID].Partner+". Use /leave.",player);
    else {
    local plr = FindPlayer(text);
    if(!plr) MessagePlayer("-> Target Player is offline.",player);
    else if (plr.ID == player.ID) MessagePlayer("-> You can't teamup with yourself.",player);
    else {
      MessagePlayer(">> Team invitation sent to "+plr.Name,player);
      MessagePlayer(">> Team invitation recieved from "+player.Name,plr);
      MessagePlayer(">> /accept to join his team.",plr);
      stats[plr.ID].Requested = true;
      stats[plr.ID].Partner = player.Name;
      print(plr.Name+"|"+stats[plr.ID].Partner);
      Invitation <- NewTimer("InviteExpired",30000,1,plr.ID);
    }
  }
    break;

    case "accept":
    if(!stats[player.ID].Requested) MessagePlayer("-> You have not recieved any team invitation.",player);
    else {
      local plr = FindPlayer(stats[player.ID].Partner);
      print(stats[player.ID].Partner);
      stats[player.ID].Team = true;
      stats[player.ID].Requested = false;
     
      stats[plr.ID].Team = true;
      stats[plr.ID].Partner = player.Name;

      MessagePlayer(">> You're now in team with "+stats[player.ID].Partner,player);
      MessagePlayer(">> You're now in team with "+player.Name,plr);

      teamedUp <- NewTimer("TeamInfo",1000,0,player.ID,plr.ID);
    }
    break;

  case "tc":
  case "teamchat":
  if(!stats[player.ID].Team) MessagePlayer("-> You are not in any team. /teamup with someone.",player);
  else if(!text) MessagePlayer("/teamchat text",player);
  else {
    local plr = FindPlayer(stats[player.ID].Partner);
    MessagePlayer(player.Name+" said: [#ffffff]"+text+"",player);
    MessagePlayer(player.Name+" said: [#ffffff]"+text+"",plr);
  }
  break;

    case "leave":
  if(!stats[player.ID].Team) MessagePlayer("-> You are not in any team. /teamup with someone.",player);
  else {
    local plr = FindPlayer(stats[player.ID].Partner);
    MessagePlayer(">> You're no longer teaming-up with "+plr.Name,player);
    MessagePlayer(">> "+player.Name+" is no longer teaming-up with you.",plr);

      stats[player.ID].Team = false;
      stats[player.ID].Partner = "";

      stats[plr.ID].Team = false;
      stats[plr.ID].Partner = "";
  }
  break;

  case "buybomb":
  if(!stats[player.ID].Team) MessagePlayer("-> You are not in any team. /teamup with someone.",player);
  else if(!stats[player.ID].AtAmmu) MessagePlayer("-> You must be at ammunation to use this command.",player);
  else if(stats[player.ID].BombBought) MessagePlayer("-> You already have a bomb.",player);
  else {
  stats[player.ID].BombBought = true;
  local plr = FindPlayer(stats[player.ID].Partner);
  MessagePlayer(">> Bomb purchased successfully.",player);
  MessagePlayer(">> Your teammate: "+player.Name+" has bought the bomb.",plr);
  }
  break;

  case "usebomb":
  if(!stats[player.ID].BombBought) MessagePlayer("-> You don't have bomb.",player);
  else if(!stats[player.ID].Team) MessagePlayer("-> You are not in any team. /teamup with someone.",player);
  else if(stats[player.ID].InsideLocker == false) MessagePlayer("-> You must be inside the banklocker.",player);
  else if(BankRobTime > 0) BankRobTimeLeft(player);
  else {
  local plr = FindPlayer(stats[player.ID].Partner);
  stats[player.ID].BombBought = false;
  MessagePlayer(">> You have planted the bomb.",player);
  MessagePlayer(">> It will explode in next 5 seconds.",player);
  MessagePlayer(">> Your teammate: "+player.Name+" has planted the bomb.",plr);
  NewTimer( "LoadDoor", 40000, 1 );
  NewTimer( "DoorExplode", 5000, 1 );
  cta <- CreateObject( 380, 1, Vector( -945.589, -343.758, 7.46694), 255 );
  }
  break;
  }
}



//Custom functions
function Random( min, max ) // incase you don't have the random(a,b) function
{
    if ( min < max )
    return rand() % (max - min + 1) + min.tointeger();
    else if ( min > max )
    return rand() % (min - max + 1) + max.tointeger();
    else if ( min == max )
    return min.tointeger();
}

function InviteExpired(plrID){
  local plr = FindPlayer(plrID);
  if(stats[plr.ID].Requested) stats[plr.ID].Requested = false;
  else if (!plr) Invitation.Delete();
}

function TeamCheck(player){
  if(stats[player.ID].Team) {
  local plr = FindPlayer(stats[player.ID].Partner);

    MessagePlayer(">> "+player.Name+" is no longer teaming-up with you.",plr);

    stats[plr.ID].Team = false;
    stats[plr.ID].Partner = "";
  } else return false;
}


function TeamInfo(player,plr){
  local player = FindPlayer(player), plr = FindPlayer(plr);

  if(player && plr && stats[player.ID].Team && stats[plr.ID].Team && !BankGettingRobbed) {
      Announce("Teammate: ~g~"+plr.Name+" ~h~| Distance: ~g~"+DistanceFromPoint( player.Pos.x, player.Pos.y , plr.Pos.x, plr.Pos.y )+"",player,1);
      Announce("Teammate: ~g~"+plr.Name+" ~h~| Distance: ~g~"+DistanceFromPoint( player.Pos.x, player.Pos.y , plr.Pos.x, plr.Pos.y )+"",plr,1);
  } else if (BankGettingRobbed) {
      local plr = FindPlayer(stats[player.ID].Partner);
      Announce("Robbing Bank: ~g~"+BankTime+"",player,1);
      Announce("Robbing Bank: ~g~"+BankTime+"",plr,1);
  }
  else teamedUp.Delete();
}


function DoorExplode() {
  cta.Delete();
  HideMapObject(4578, -945.596, -342.627, 7.58308);
  CreateExplosion( 1, 7, -945.596, -342.627, 7.58308, -1, true );
}
function LoadDoor() {
  CreateObject( 4578, 1, -945.596, -342.627, 7.58308, 255 );
}
function BankRobTimeLeft(player) {
  local time = BankRobTime;
  local mins = floor(time / 60);
  local sec = time % 60;
  return MessagePlayer((BankRobTime > 0) ? ">> Bank can be robbed after: " + mins + " minutes " + sec + " seconds." : ">> The bank can be robbed now.",player);
}
function BankRobbery(player, plr)
{
local player = FindPlayer(player), plr = FindPlayer(plr);

if(BankTime > 0){
    BankTime--;
    player.PlaySound(370);
    plr.PlaySound(370);
    player.IsFrozen = true;
    player.IsFrozen = true;
}
else {
    local cash_1 = Random(30000,40000), cash_2 = Random(30000,40000);
    Message(">> "+player.Name +" has robbed "+(cash_1 + cash_2)+" from International Bank.");

    player.Cash += cash_1; plr.Cash += cash_2,
    player.PlaySound(470); plr.PlaySound(470);
    player.IsFrozen = false; plr.IsFrozen = false;

    BankRobbed = true;
    BankGettingRobbed = false;
    BankRobTime = 1800;
}
}




//onTimeChange Function

function onTimeChange(oldHour, oldMin, newHour, newMin) {
  if(BankRobTime > 0) BankRobTime--;
}




//CheckPoint Enter and Exit
    function onCheckpointEntered(player, checkpoint )
{
    if (checkpoint.ID == 0) {
        player.Pos = Vector(-934.266, -348.206, 7.22692);
        player.PlaySound(465);
        stats[player.ID].InsideLocker = true;
    }
    if (checkpoint.ID == 1) {
        player.Pos = Vector(-934.265, -351.009, 17.8038);
        player.PlaySound(465);
        stats[player.ID].InsideLocker = false;
    }
    if (checkpoint.ID == 2) {
        player.PlaySound(465);
        player.Immunity = 255;
        stats[player.ID].AtAmmu = true;
    }
}
function onCheckpointExited( player, checkpoint )
{
    if (checkpoint.ID == 2) {
        player.Immunity = 0;
        stats[player.ID].AtAmmu = false;
    }
}





//Add this onPickupPickedUp
if( pickup.Model == 410  )
    {
      if(!stats[player.ID].Team) MessagePlayer("-> You are not in any team. /teamup with someone.",player);
      else if (BankGettingRobbed == true) return false;
      else if(BankRobTime > 0) BankRobTimeLeft(player);
      else {
          local plr = FindPlayer(stats[player.ID].Partner); 
          if ( DistanceFromPoint( player.Pos.x, player.Pos.y , plr.Pos.x, plr.Pos.y ) > 3 ) MessagePlayer(">> Your teammate must be near to you.", player );
      else if(BankRobTime == 0 && stats[player.ID].Team)
      {
          BankGettingRobbed = true;
          NewTimer("BankRobbery",1000,11,player.ID, plr.ID);
          BankTime = 10;
          pickup.RespawnTime = 60000;
      }
    }
  }
