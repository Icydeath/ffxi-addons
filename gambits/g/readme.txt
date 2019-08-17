SELECTORS
---------------------
SELF    : The player.

PARTY   : The first party member to satisfy the
          given trigger condition.

CLUSTER : The party member with the most other
          party members within beneficial AoE
          range (9.9') who satisify the given
          trigger condition.

TANK    : The first party member to satisfy
          the given condition whose job
          is either PLD or RUN

MELEE   : The first party member to satisfy
          the given condition whose job
          is: WAR MNK RDM THF DRK BST
              SAM NIN DRG BLU PUP DNC

RANGED  : The first party member to satisfy
          the given condition whose job
          is either RNG or COR

MAGE    : The first party member to satisfy
          the given condition whose job
          is: WHM BLM RDM BRD
              SMN BLU SCH GEO

ENEMY   : The currently targetted enemy.



COMPLEX "SELECTORS"
---------------------
AND : Checks against multiple selectors at once. The
      syntax is different from a regular selector.
      The selector value is "AND", while the trigger 
      is an array of triggers. The (base) trigger argument 
      isn't used, and can/should be left blank. Each child 
      trigger inside the combined triggers array must consist 
      of a valid selector, trigger, and trigger_arg.
      You DO NOT need to use this to make sure you meet
      the conditions to use your desired reaction. Or, you
      don't need to use an "AND" statement to make sure you
      have the 500 TP required to use Curing Waltz III if you
      desire to use it on yourself when you have <= 70% HP.
      A simple {"SELF","HPP <=",70,"JA","Curing Waltz III"}
      is fine. Gambits implicitly checks if you can perform 
      the reaction, so you don't need to do so yourself.



TRIGGERS
---------------------
HPP <=        : Fires if the selectee's HP % is less than
                the provided argument.

HPP >         : Fires if the selectee's HP % is more than
                the provided argument.

MPP <=        : Fires if the selectee's MP % is less than
                the provided argument.

TP >=         : Fires when TP is over the given value.

NOT_STATUS    : Triggered when the selectee lacks the
                provided song buff, status effect, or JA buff.

STATUS        : Triggered when the selectee has the
                specified buff or status effect.

MA_READY      : Fires when the recast timer of the provided
                spell is ready for the player.

JA_READY      : Fires when the recast timer of the provided
                job ability is ready for the player.

NOT_ENGAGED   : Triggered when the player doesn't have their
                weapon drawn.

NOT_ASSISTING : Triggered when the player isn't targetting
                the same mob as the provided party member.

CAN_SC        : Combines with SELF selector. Fires when the enemy 
                has a current skillchain property applied to it 
                that can be used to make the given trigger_arg.
                (Ie: "SELF","CAN_SC","Light" will fire when
                the enemy has Fusion property on it.)

CAN_MB        : Combines with SELF selector. Fires when the enemy
                has an active skillchain effect (ie: MB window)
                applied to it which possesses the element
                stated by trigger_arg.

NO_PET        : Combines with SELF selector. Fires when the player
                does not currently have an active pet.

READYING      : When combined with the ENEMY selector, triggers
                when the targetted mob is readying the stated TP move.

CASTING       : When combined with the ENEMY selector, triggers
                when the targetted mob is casting the stated spell.



REACTIONS
---------------------
ATTACK  : "/lockon, /follow, /a" on the targetted mob.

ASSIST  : "/assist " the player with the given name

MA      : Casts the provided spell on either the target,
          or if called with the PARTY selector, the
          person who satisfied the condition.

JA      : Uses the provided job ability, either on the
          provided target, the satisfying party member
          if called with the PARTY selector, or on 
          yourself in the case of self-abilities.

WS      : Uses provided weaponskill on the targetted mob.

ITEM    : Uses the stated item on yourself, provided you
          have one in your inventory or temp items.


COMPLEX REACTIONS
---------------------

CHAIN   : A complex reaction which allows you to
          force Gambits to use a series of abilities
          in order in response to a trigger.
          Uses slightly different syntax than regular
          reactions. The reaction argument is "CHAIN",
          while the r_arg is an array of arrays.
          Each of these child arrays are the familiar
          regular reaction types like {"JA","Accession"}.


EXAMPLES
--------------
{"SELF","TP >=",1000,"WS","Rudra's Storm"}
- Uses Rudra's Storm right when you can

{"SELF","TP >=",1750,"WS","Rudra's Storm"}
- Holds TP until 1750 before using Rudra's Storm.

{"SELF","NOT_STATUS","Afflatus Solace","JA","Afflatus Solace"}
- Uses Afflatus Solace if it's not currently active.

{"SELF","NOT_STATUS","Haste","MA","Haste"}
- Casts Haste on yourself if you lack it.

{"PARTY","STATUS","Poison","MA","Poisona"}
- Casts Poisona on a party member who suffers from Poison.

{"PARTY","HPP <=",80,"MA","Cure III"}
- Tosses a cure on an injured party member.

{"CLUSTER","HPP <=",80,"MA","Curaga III"}
- Tosses a curaga at a group of injured party members.

{"SELF","STATUS","Paralyzed","ITEM","Remedy"}
- Attempts to use a Remedy on ourself if we're paralyzed.

{"SELF","MPP <=",10,"ITEM","Vile Elixir"}
- Uses a Vile Elixir when we have less than 10% MP.

{"SELF","MA_READY","Aero IV","MA","Aero IV"}
- Casts Aero IV on the target if the spell is up.

{"ENEMY","READYING","Searing Serration","MA","Stun"}
- Casts Stun on the target when it readies Searing Serration.

{"ENEMY","CASTING","Meteor","MA","Silence"}
- Casts Silence on the target when it begins casting Meteor.

{"SELF","CAN_SC","Darkness","WS","Rudra's Storm"}
- Uses Rudra's Storm when the mob has a SC property on it
  which can be used to make Darkness. (Darkness, Gravitation, etc) 

{"SELF","CAN_MB","Lightning","MA","Thunder V"},
- Casts Thunder V on the current target if a skillchain
  which contains the lightning element is active.

{"SELF","NO_PET","","MA","Geo-Regen"}
- Casts Geo-Regen on yourself if you don't have a luopan out.

{"SELF","NO_PET","","MA","Geo-Poison"}
- Casts Geo-Poison on your currently targetted enemy if you 
  don't have a luopan out.

{"SELF","NOT_ASSISTING","Hanatori","ASSIST",""}
- Targets the mob Hanatori has her weapon drawn against

{"SELF","NOT_ENGAGED","","ATTACK",""}
- Will draw weapon, lockon, and /follow the targetted mob.

{"AND",{{"SELF","TP >=",1000},
        {"SELF","HPP >","65"}},
      "","WS","Rudra's Storm"}
- Uses Rudra's Storm, but only when we have more than 65% HP.

{"AND",{{"SELF","CAN_MB","Darkness"},
        {"SELF","MPP <=",50}},
      "","MA","Aspir II"}
- Does a Magic Bursted Aspir II when we're low MP and a
  Darkness magic burst window is open.

{"SELF","NOT_STATUS","Hailstorm","CHAIN",{
                                          {"JA","Perpetuance"},
                                          {"JA","Accession"},
                                          {"MA","Hailstorm"}
                                         }}
- Gives a Perpetuated, Accessioned Hailstorm to party members
  near you when you lack the Hailstorm status.

{"CLUSTER","NOT_STATUS","Regen","CHAIN",{
                                         {"JA","Accession"},
                                         {"MA","Regen IV"}
                                        }}
- Uses Accession to give Regen IV to a cluster of party
  members who lack it. Unlike a "SELF" target, this can
  be used from a distance.