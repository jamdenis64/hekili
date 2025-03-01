-- MonkWindwalker.lua
-- October 2023

if UnitClassBase( "player" ) ~= "MONK" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local strformat = string.format

local spec = Hekili:NewSpecialization( 269 )
local GetSpellCount = C_Spell.GetSpellCastCount

spec:RegisterResource( Enum.PowerType.Energy, {
    crackling_jade_lightning = {
        aura = "crackling_jade_lightning",
        debuff = true,

        last = function ()
            local app = state.debuff.crackling_jade_lightning.applied
            local t = state.query_time

            return app + floor( ( t - app ) / state.haste ) * state.haste
        end,

        stop = function( x )
            return x < class.abilities.crackling_jade_lightning.spendPerSec
        end,

        interval = function () return class.auras.crackling_jade_lightning.tick_time end,
        value = function () return class.abilities.crackling_jade_lightning.spendPerSec end,
    }
} )
spec:RegisterResource( Enum.PowerType.Chi )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Monk
    ancient_arts                  = { 101184, 344359, 2 }, -- Reduces the cooldown of Paralysis by 15 sec and the cooldown of Leg Sweep by 10 sec.
    bounce_back                   = { 101177, 389577, 1 }, -- When a hit deals more than 12% of your maximum health, reduce all damage you take by 40% for 6 sec. This effect cannot occur more than once every 30 seconds.
    bounding_agility              = { 101161, 450520, 1 }, -- Roll and Chi Torpedo travel a small distance further.
    calming_presence              = { 101153, 388664, 1 }, -- Reduces all damage taken by 6%.
    celerity                      = { 101183, 115173, 1 }, -- Reduces the cooldown of Roll by 5 sec and increases its maximum number of charges by 1.
    celestial_determination       = { 101180, 450638, 1 }, -- While your Celestial is active, you cannot be slowed below 90% normal movement speed.
    chi_burst                     = { 102432, 123986, 1 }, -- Hurls a torrent of Chi energy up to 40 yds forward, dealing 23,919 Nature damage to all enemies, and 17,147 healing to the Monk and all allies in its path. Healing and damage reduced beyond 5 targets.
    chi_proficiency               = { 101169, 450426, 2 }, -- Magical damage done increased by 5% and healing done increased by 5%.
    chi_torpedo                   = { 101183, 115008, 1 }, -- Torpedoes you forward a long distance and increases your movement speed by 30% for 10 sec, stacking up to 2 times.
    chi_wave                      = { 102432, 450391, 1 }, -- Every 15 sec, your next Rising Sun Kick or Vivify releases a wave of Chi energy that flows through friends and foes, dealing 1,708 Nature damage or 4,676 healing. Bounces up to 7 times to targets within 25 yards.
    clash                         = { 101154, 324312, 1 }, -- You and the target charge each other, meeting halfway then rooting all targets within 6 yards for 4 sec.
    crashing_momentum             = { 101149, 450335, 1 }, -- Targets you Roll through are snared by 40% for 5 sec.
    dance_of_the_wind             = { 101139, 432181, 1 }, -- Your dodge chance is increased by 10% and an additional 10% every 4 sec until you dodge an attack, stacking up to 9 times.
    diffuse_magic                 = { 101165, 122783, 1 }, -- Reduces magic damage you take by 60% for 6 sec, and transfers all currently active harmful magical effects on you back to their original caster if possible.
    disable                       = { 101149, 116095, 1 }, -- Reduces the target's movement speed by 50% for 15 sec, duration refreshed by your melee attacks.
    elusive_mists                 = { 101144, 388681, 1 }, -- Reduces all damage taken by you and your target while channeling Soothing Mists by 6%.
    energy_transfer               = { 101151, 450631, 1 }, -- Successfully interrupting an enemy reduces the cooldown of Paralysis and Roll by 5 sec.
    escape_from_reality           = { 101176, 394110, 1 }, -- After you use Transcendence: Transfer, you can use Transcendence: Transfer again within 10 sec, ignoring its cooldown.
    expeditious_fortification     = { 101174, 388813, 1 }, -- Fortifying Brew cooldown reduced by 30 sec.
    fast_feet                     = { 101185, 388809, 1 }, -- Rising Sun Kick deals 70% increased damage. Spinning Crane Kick deals 10% additional damage.
    fatal_touch                   = { 101178, 394123, 1 }, -- Touch of Death increases your damage by 5% for 30 sec after being cast and its cooldown is reduced by 90 sec.
    ferocity_of_xuen              = { 101166, 388674, 1 }, -- Increases all damage dealt by 2%.
    flow_of_chi                   = { 101170, 450569, 1 }, -- You gain a bonus effect based on your current health. Above 90% health: Movement speed increased by 5%. This bonus stacks with similar effects. Between 90% and 35% health: Damage taken reduced by 5%. Below 35% health: Healing received increased by 10%.
    fortifying_brew               = { 101173, 115203, 1 }, -- Turns your skin to stone for 15 sec, increasing your current and maximum health by 30%, reducing all damage you take by 30%.
    grace_of_the_crane            = { 101146, 388811, 1 }, -- Increases all healing taken by 6%.
    hasty_provocation             = { 101158, 328670, 1 }, -- Provoked targets move towards you at 50% increased speed.
    healing_winds                 = { 101171, 450560, 1 }, -- Transcendence: Transfer immediately heals you for 10% of your maximum health.
    improved_detox                = { 101089, 388874, 1 }, -- Detox additionally removes all Poison and Disease effects.
    improved_touch_of_death       = { 101140, 322113, 1 }, -- Touch of Death can now be used on targets with less than 15% health remaining, dealing 35% of your maximum health in damage.
    ironshell_brew                = { 101174, 388814, 1 }, -- Increases your maximum health by an additional 10% and your damage taken is reduced by an additional 10% while Fortifying Brew is active.
    jade_walk                     = { 101160, 450553, 1 }, -- While out of combat, your movement speed is increased by 15%.
    lighter_than_air              = { 101168, 449582, 1 }, -- Roll causes you to become lighter than air, allowing you to double jump to dash forward a short distance once within 5 sec, but the cooldown of Roll is increased by 2 sec.
    martial_instincts             = { 101179, 450427, 2 }, -- Increases your Physical damage done by 5% and Avoidance increased by 4%.
    paralysis                     = { 101142, 115078, 1 }, -- Incapacitates the target for 1 min. Limit 1. Damage will cancel the effect.
    peace_and_prosperity          = { 101163, 450448, 1 }, -- Reduces the cooldown of Ring of Peace by 5 sec and Song of Chi-Ji's cast time is reduced by 0.5 sec.
    pressure_points               = { 101141, 450432, 1 }, -- Paralysis now removes all Enrage effects from its target.
    profound_rebuttal             = { 101135, 392910, 1 }, -- Expel Harm's critical healing is increased by 15%.
    quick_footed                  = { 101158, 450503, 1 }, -- The duration of snare effects on you is reduced by 20%.
    ring_of_peace                 = { 101136, 116844, 1 }, -- Form a Ring of Peace at the target location for 5 sec. Enemies that enter will be ejected from the Ring.
    rising_sun_kick               = { 101186, 107428, 1 }, -- Kick upwards, dealing 24,332 Physical damage. Applies Renewing Mist for 6 seconds to an ally within 40 yds
    rushing_reflexes              = { 101154, 450154, 1 }, -- Your heightened reflexes allow you to react swiftly to the presence of enemies, causing you to quickly lunge to the nearest enemy in front of you within 10 yards after you Roll.
    save_them_all                 = { 101157, 389579, 1 }, -- When your healing spells heal an ally whose health is below 35% maximum health, you gain an additional 10% healing for the next 4 sec.
    song_of_chiji                 = { 101136, 198898, 1 }, -- Conjures a cloud of hypnotic mist that slowly travels forward. Enemies touched by the mist fall asleep, Disoriented for 20 sec.
    soothing_mist                 = { 101143, 115175, 1 }, -- Heals the target for 142,174 over 10.5 sec. While channeling, Enveloping Mist and Vivify may be cast instantly on the target. Each heal has a chance to cause a Gust of Mists on the target.
    spear_hand_strike             = { 101152, 116705, 1 }, -- Jabs the target in the throat, interrupting spellcasting and preventing any spell from that school of magic from being cast for 3 sec.
    spirits_essence               = { 101138, 450595, 1 }, -- Transcendence: Transfer snares targets within 10 yds by 70% for 4 sec when cast.
    strength_of_spirit            = { 101135, 387276, 1 }, -- Expel Harm's healing is increased by up to 30%, based on your missing health.
    summon_jade_serpent_statue    = { 101164, 115313, 1 }, -- Summons a Jade Serpent Statue at the target location. When you channel Soothing Mist, the statue will also begin to channel Soothing Mist on your target, healing for 71,087 over 10.5 sec.
    swift_art                     = { 101155, 450622, 1 }, -- Roll removes a snare effect once every 30 sec.
    tiger_tail_sweep              = { 101182, 264348, 1 }, -- Increases the range of Leg Sweep by 4 yds.
    tigers_lust                   = { 101147, 116841, 1 }, -- Increases a friendly target's movement speed by 70% for 6 sec and removes all roots and snares.
    transcendence                 = { 101167, 101643, 1 }, -- Split your body and spirit, leaving your spirit behind for 15 min. Use Transcendence: Transfer to swap locations with your spirit.
    transcendence_linked_spirits  = { 101176, 434774, 1 }, -- Transcendence now tethers your spirit onto an ally for 1 |4hour:hrs;. Use Transcendence: Transfer to teleport to your ally's location.
    vigorous_expulsion            = { 101156, 392900, 1 }, -- Expel Harm's healing increased by 5% and critical strike chance increased by 15%.
    vivacious_vivification        = { 101145, 388812, 1 }, -- Every 10 sec, your next Vivify becomes instant and its healing is increased by 20%.
    winds_reach                   = { 101148, 450514, 1 }, -- The range of Disable is increased by 5 yds. The duration of Crashing Momentum is increased by 3 sec and its snare now reduces movement speed by an additional 20%.
    windwalking                   = { 101175, 157411, 1 }, -- You and your allies within 10 yards have 10% increased movement speed. Stacks with other similar effects.
    yulons_grace                  = { 101165, 414131, 1 }, -- Find resilience in the flow of chi in battle, gaining a magic absorb shield for 1.0% of your max health every 3 sec in combat, stacking up to 10%.

    -- Mistweaver
    awakened_jadefire             = { 101104, 388779, 1 }, -- Your abilities reset Jadefire Stomp 100% more often. While within Jadefire Stomp, your Tiger Palms strike twice, your Blackout Kicks strike an additional 2 targets at 70% effectiveness, and your Spinning Crane Kick heals 3 nearby allies for 90% of the damage done.
    burst_of_life                 = { 101098, 399226, 1 }, -- When Life Cocoon expires, it releases a burst of mist that restores 68,190 health to 3 nearby allies.
    calming_coalescence           = { 101095, 388218, 1 }, -- The absorb amount of Life Cocoon is increased by 80%.
    celestial_harmony             = { 101128, 343655, 1 }, -- While active, Yu'lon and Chi'Ji heal up to 5 nearby targets with Enveloping Breath when you cast Enveloping Mist, healing for 11,560 over 7 sec, and increasing the healing they receive from you by 10%. When activated, Yu'lon and Chi'Ji apply Chi Cocoons to 5 targets within 40 yds, absorbing 77,135 damage for 10 sec.
    chi_harmony                   = { 101121, 448392, 1 }, -- Renewing Mist increases its target's healing received from you by 50% for the first 8 sec of its duration, but cannot jump to a new target during this time.
    chrysalis                     = { 101098, 202424, 1 }, -- Reduces the cooldown of Life Cocoon by 45 sec.
    crane_style                   = { 101097, 446260, 1 }, -- Rising Sun Kick now kicks up a Gust of Mist to heal 2 allies within 40 yds for 13,380. Spinning Crane Kick and Blackout Kick have a chance to kick up a Gust of Mist to heal 1 ally within 40 yds for 13,380.
    dance_of_chiji                = { 101106, 438439, 1 }, -- Your spells and abilities have a chance to make your next Spinning Crane Kick deal an additional 400% damage.
    dancing_mists                 = { 101112, 388701, 1 }, -- Renewing Mist has a 8% chance to immediately spread to an additional target when initially cast or when traveling to a new target.
    deep_clarity                  = { 101122, 446345, 1 }, -- After you fully consume Thunder Focus Tea, your next Vivify triggers Zen Pulse.
    energizing_brew               = { 101130, 422031, 1 }, -- Mana Tea now channels 50% faster and generates 20% more Mana.
    enveloping_mist               = { 101134, 124682, 1 }, -- Wraps the target in healing mists, healing for 35,154 over 7 sec, and increasing healing received from your other spells by 40%. Applies Renewing Mist for 6 seconds to an ally within 40 yds.
    focused_thunder               = { 101115, 197895, 1 }, -- Thunder Focus Tea now empowers your next 2 spells.
    gift_of_the_celestials        = { 101113, 388212, 1 }, -- Reduces the cooldown of Invoke Yul'on, the Jade Serpent by 2 min, but decreases its duration to 12 sec.
    healing_elixir                = { 101109, 122280, 1 }, -- You consume a healing elixir when you drop below 40% health or generate excess healing elixirs, instantly healing you for 15% of your maximum health. You generate 1 healing elixir every 30 sec, stacking up to 2 times.
    invigorating_mists            = { 101110, 274586, 1 }, -- Vivify heals all allies with your Renewing Mist active for 10,515, reduced beyond 5 allies.
    invoke_chiji_the_red_crane    = { 101129, 325197, 1 }, -- Summon an effigy of Chi-Ji for 12 sec that kicks up a Gust of Mist when you Blackout Kick, Rising Sun Kick, or Spinning Crane Kick, healing up to 2 allies for 13,380, and reducing the cost and cast time of your next Enveloping Mist by 33%, stacking. Chi-Ji's presence makes you immune to movement impairing effects.
    invoke_yulon_the_jade_serpent = { 101129, 322118, 1 }, -- Summons an effigy of Yu'lon, the Jade Serpent for 12 sec. Yu'lon will heal injured allies with Soothing Breath, healing the target and up to 2 allies for 16,784 over 7.4 sec. Enveloping Mist costs 50% less mana while Yu'lon is active.
    invokers_delight              = { 101123, 388661, 1 }, -- You gain 20% haste for 8 sec after summoning your Celestial.
    jade_bond                     = { 101113, 388031, 1 }, -- Abilities that activate Gust of Mist reduce the cooldown on Invoke Yul'on, the Jade Serpent by 0.5 sec, and Chi-Ji's Gusts of Mists healing is increased by 60% and Yu'lon's Soothing Breath healing is increased by 500%.
    jade_empowerment              = { 101106, 467316, 1 }, -- Casting Thunder Focus Tea increases your next Crackling Jade Lightning's damage by 800% and causes it to chain to 4 additional enemies.
    jadefire_stomp                = { 101101, 388193, 1 }, -- Strike the ground fiercely to expose a path of jade for 30 sec, dealing 9,151 Nature damage to up to 5 enemies, and restoring 19,247 health to up to 5 allies within 30 yds caught in the path. Your abilities have a 6% chance of resetting the cooldown of Jadefire Stomp while fighting within the path.
    jadefire_teachings            = { 101102, 467293, 1 }, -- After casting Jadefire Stomp or Thunder Focus Tea, Ancient Teachings transfers an additional 140% damage to healing for 15 sec. While Jadefire Teachings is active, your Stamina is increased by 5%.
    legacy_of_wisdom              = { 101118, 404408, 1 }, -- Sheilun's Gift heals 2 additional allies and its cast time is reduced by 0.5 sec.
    life_cocoon                   = { 101096, 116849, 1 }, -- Encases the target in a cocoon of Chi energy for 12 sec, absorbing 308,540 damage and increasing all healing over time received by 50%. Applies Renewing Mist and Enveloping Mist to the target.
    lifecycles                    = { 101130, 197915, 1 }, -- Vivify has a 20% chance to cause your next Rising Sun Kick or Enveloping Mist to generate 1 stack of Mana Tea. Enveloping Mist and Rising Sun Kick have a 20% chance to cause your next Vivify to generate 1 stack of Mana Tea.
    lotus_infusion                = { 101121, 458431, 1 }, -- Allies with Renewing Mist receive 8% more healing from you and Renewing Mist's duration is increased by 2 sec.
    mana_tea                      = { 101132, 115869, 1 }, -- For every 29,360 Mana you spend, you gain 1 stack of Mana Tea, with a chance equal to your critical strike chance to generate 1 extra stack. Mana Tea: Consumes 1 stack of Mana Tea per 0.2 sec to restore 3,600 Mana and reduces the Mana cost of your spells by 30% for 1.00 sec per stack of Mana Tea consumed after drinking. Can be cast while moving, but movement speed is reduced by 40% while channeling.
    mending_proliferation         = { 101125, 388509, 1 }, -- Each time Enveloping Mist heals, its healing bonus has a 50% chance to spread to an injured ally within 30 yds.
    mist_wrap                     = { 101093, 197900, 1 }, -- Increases Enveloping Mist's duration by 1 sec and its healing bonus by 10%.
    mists_of_life                 = { 101099, 388548, 1 }, -- Life Cocoon applies Renewing Mist and Enveloping Mist to the target.
    misty_peaks                   = { 101114, 388682, 2 }, -- Renewing Mist's heal over time effect has a 5.0% chance to apply Enveloping Mist for 2 sec.
    overflowing_mists             = { 101094, 388511, 2 }, -- Your Enveloping Mists heal the target for 2.0% of their maximum health each time they take direct damage.
    peaceful_mending              = { 101116, 388593, 1 }, -- Allies targeted by Soothing Mist receive 40% more healing from your Enveloping Mist and Renewing Mist effects.
    peer_into_peace               = { 101127, 440008, 1 }, -- 5% of your overhealing done onto targets with Soothing Mist is spread to 3 nearby injured allies. Soothing Mist now follows the target of your Enveloping Mist or Vivify and its channel time is increased by 4 sec.
    pool_of_mists                 = { 101127, 173841, 1 }, -- Renewing Mist now has 3 charges and reduces the remaining cooldown of Rising Sun Kick by 1.0 sec. Rising Sun Kick now reduces the remaining cooldown of Renewing Mist by 1.0 sec.
    rapid_diffusion               = { 101111, 388847, 2 }, -- Rising Sun Kick and Enveloping Mist apply Renewing Mist for 6 seconds to an ally within 40 yds.
    refreshing_jade_wind          = { 101093, 457397, 1 }, -- Thunder Focus Tea summons a whirling tornado around you, causing 1,227 healing every 0.66 sec for 6 sec on to up to 5 allies within 10 yards.
    refreshment                   = { 101095, 467270, 1 }, -- Life Cocoon grants up to 5 stacks of Mana Tea and applies 2 stacks of Healing Elixir to its target.
    renewing_mist                 = { 101107, 115151, 1 }, -- Surrounds the target with healing mists, restoring 20,879 health over 22 sec. If Renewing Mist heals a target past maximum health, it will travel to another injured ally within 20 yds.
    resplendent_mist              = { 101126, 388020, 2 }, -- Gust of Mists has a 30% chance to do 100% more healing.
    restoral                      = { 101131, 388615, 1 }, -- Heals all party and raid members within 40 yds for 126,657 and clears them of all harmful Poison and Disease effects. Castable while stunned. Healing reduced beyond 5 targets.
    revival                       = { 101131, 115310, 1 }, -- Heals all party and raid members within 40 yds for 126,657 and clears them of 3 harmful Magic, all Poison, and all Disease effects. Healing reduced beyond 5 targets.
    rising_mist                   = { 101117, 274909, 1 }, -- Rising Sun Kick heals all allies with your Renewing Mist and Enveloping Mist for 2,025, and extends those effects by 4 sec, up to 100% of their original duration.
    rushing_wind_kick             = { 101102, 467307, 1 }, -- Kick up a powerful gust of wind, dealing 25,305 Nature damage in a 25 yd cone to enemies in front of you, split evenly among them. Damage is increased by 6% for each target hit, up to 30%. Grants Rushing Winds for 4 sec, increasing Renewing Mist's healing by 50%.
    secret_infusion               = { 101124, 388491, 2 }, -- After using Thunder Focus Tea, your next spell gives 5% of a stat for 10 sec: Enveloping Mist: Critical strike Renewing Mist: Haste Vivify: Mastery Rising Sun Kick: Versatility Expel Harm: Versatility
    shaohaos_lessons              = { 101119, 400089, 1 }, -- Each time you cast Sheilun's Gift, you learn one of Shaohao's Lessons for up to 30 sec, with the duration based on how many clouds of mist are consumed. Lesson of Doubt: Your spells and abilities deal up to 40% more healing and damage to targets, based on their current health. Lesson of Despair: Your Critical Strike is increased by 30% while above 50% health. Lesson of Fear: Decreases your damage taken by 15% and increases your Haste by 20%. Lesson of Anger: 25% of the damage or healing you deal is duplicated every 4 sec.
    sheiluns_gift                 = { 101120, 399491, 1 }, -- Draws in all nearby clouds of mist, healing the friendly target and up to 2 nearby allies for 10,223 per cloud absorbed. A cloud of mist is generated every 8 sec while in combat.
    tea_of_plenty                 = { 101103, 388517, 1 }, -- Thunder Focus Tea also empowers 2 additional Enveloping Mist, Expel Harm, or Rising Sun Kick at random.
    tea_of_serenity               = { 101103, 393460, 1 }, -- Thunder Focus Tea also empowers 2 additional Renewing Mist, Enveloping Mist, or Vivify at random.
    tear_of_morning               = { 101117, 387991, 1 }, -- Casting Vivify or Enveloping Mist on a target with Renewing Mist has a 10% chance to spread the Renewing Mist to another target. Your Vivify healing through Renewing Mist is increased by 10% and your Enveloping Mist also heals allies with Renewing Mist for 12% of its healing.
    thunder_focus_tea             = { 101133, 116680, 1 }, -- Receive a jolt of energy, empowering your next 2 spells cast: Enveloping Mist: Immediately heals for 26,396 and is instant cast. Renewing Mist: Duration increased by 10 sec. Vivify: No mana cost. Rising Sun Kick: Cooldown reduced by 9 sec. Expel Harm: Transfers 25% additional healing into damage and creates a Chi Cocoon absorbing 102,846 damage.
    unison                        = { 101125, 388477, 1 }, -- Soothing Mist heals a second injured ally within 40 yds for 25% of the amount healed.
    uplifted_spirits              = { 101092, 388551, 1 }, -- Vivify critical strikes and Rising Sun Kicks reduce the remaining cooldown on Revival by 1 sec, and Revival heals targets for 15% of Revival's heal over 10 sec.
    veil_of_pride                 = { 101119, 400053, 1 }, -- Increases Sheilun's Gift cloud of mist generation to every 4 sec.
    yulons_whisper                = { 101100, 388038, 1 }, -- While channeling Mana Tea you exhale the breath of Yu'lon, healing up to 5 allies within 15 yards for 385 every 0.2 sec.
    zen_pulse                     = { 101108, 446326, 1 }, -- Renewing Mist's heal over time has a chance to cause your next Vivify to also trigger a Zen Pulse on its target and all allies with Renewing Mist, healing them for 13,536 increased by 6% per Renewing Mist active, up to 30%.

    -- Shado-Pan
    against_all_odds              = { 101253, 450986, 1 }, -- Flurry Strikes increase your Agility by 1% for 5 sec, stacking up to 20 times.
    efficient_training            = { 101251, 450989, 1 }, -- Energy spenders deal an additional 20% damage. Every 50 Energy spent reduces the cooldown of Storm, Earth, and Fire by 1 sec.
    flurry_strikes                = { 101248, 450615, 1, "shadowpan" }, -- Every 51,338 damage you deal generates a Flurry Charge. For each 240 energy you spend, unleash all Flurry Charges, dealing 4,928 Physical damage per charge.
    high_impact                   = { 101247, 450982, 1 }, -- Enemies who die within 10 sec of being damaged by a Flurry Strike explode, dealing 8,214 physical damage to uncontrolled enemies within 8 yds.
    lead_from_the_front           = { 101254, 450985, 1 }, -- Chi Burst, Chi Wave, and Expel Harm now heal you for 20% of damage dealt.
    martial_precision             = { 101246, 450990, 1 }, -- Your attacks penetrate 12% armor.
    one_versus_many               = { 101250, 450988, 1 }, -- Damage dealt by Fists of Fury and Keg Smash counts as double towards Flurry Charge generation. Fists of Fury damage increased by 15%. Keg Smash damage increased by 35%.
    predictive_training           = { 101245, 450992, 1 }, -- When you dodge or parry an attack, reduce all damage taken by 10% for the next 6 sec.
    pride_of_pandaria             = { 101247, 450979, 1 }, -- Flurry Strikes have 15% additional chance to critically strike.
    protect_and_serve             = { 101254, 450984, 1 }, -- Your Vivify always heals you for an additional 30% of its total value.
    veterans_eye                  = { 101249, 450987, 1 }, -- Striking the same target 5 times within 2 sec grants 1% Haste. Multiple instances of this effect may overlap, stacking up to 10 times.
    vigilant_watch                = { 101244, 450993, 1 }, -- Blackout Kick deals an additional 20% critical damage and increases the damage of your next set of Flurry Strikes by 10%.
    whirling_steel                = { 101245, 450991, 1 }, -- When your health drops below 50%, summon Whirling Steel, increasing your parry chance and avoidance by 15% for 6 sec. This effect can not occur more than once every 180 sec.
    wisdom_of_the_wall            = { 101252, 450994, 1 }, -- Every 10 Flurry Strikes, become infused with the Wisdom of the Wall, gaining one of the following effects for 16 sec. Flurry Strikes deal 13,668 Shadow damage to all uncontrolled enemies within 6 yds.

    -- Conduit of the Celestials
    august_dynasty                = { 101235, 442818, 1 }, -- Casting Jadefire Stomp increases the damage or healing of your next Rising Sun Kick by 30% or Vivify by 50%. This effect can only activate once every 8 sec.
    celestial_conduit             = { 101243, 443028, 1, "conduit_of_the_celestials" }, -- The August Celestials empower you, causing you to radiate 465,318 healing onto up to 5 injured allies and 93,969 Nature damage onto enemies within 20 yds over 3.5 sec, split evenly among them. Healing and damage increased by 6% per target, up to 30%. You may move while channeling, but casting other healing or damaging spells cancels this effect.
    chijis_swiftness              = { 101240, 443566, 1 }, -- Your movement speed is increased by 75% during Celestial Conduit and by 15% for 3 sec after being assisted by any Celestial.
    courage_of_the_white_tiger    = { 101242, 443087, 1 }, -- Tiger Palm and Vivify have a chance to cause Xuen to claw a nearby enemy for 22,588 Physical damage, healing a nearby ally for 200% of the damage done. Invoke Yu'lon, the Jade Serpent or Invoke Chi-Ji, the Red Crane guarantees your next cast activates this effect.
    flight_of_the_red_crane       = { 101234, 443255, 1 }, -- Refreshing Jade Wind and Spinning Crane Kick have a chance to cause Chi-Ji to grant you a stack of Mana Tea and quickly rush to 5 allies, healing each target for 10,575.
    heart_of_the_jade_serpent     = { 101237, 443294, 1 }, -- Consuming 10 stacks of Sheilun's Gift calls upon Yu'lon to decrease the cooldown time of Renewing Mist, Rising Sun Kick, Life Cocoon, and Thunder Focus Tea by 75% for 8 sec.
    inner_compass                 = { 101235, 443571, 1 }, -- You switch between alignments after an August Celestial assists you, increasing a corresponding secondary stat by 2%. Crane Stance: Haste Tiger Stance: Critical Strike Ox Stance: Versatility Serpent Stance: Mastery
    jade_sanctuary                = { 101238, 443059, 1 }, -- You heal for 10% of your maximum health instantly when you activate Celestial Conduit and receive 15% less damage for its duration. This effect lingers for an additional 8 sec after Celestial Conduit ends.
    niuzaos_protection            = { 101238, 442747, 1 }, -- Fortifying Brew grants you an absorb shield for 25% of your maximum health.
    restore_balance               = { 101233, 442719, 1 }, -- Gain Refreshing Jade Wind while Chi-Ji, the Red Crane or Yu'lon, the Jade Serpent is active.
    strength_of_the_black_ox      = { 101241, 443110, 1 }, -- After Xuen assists you, your next Enveloping Mist's cast time is reduced by 50% and causes Niuzao to grant an absorb shield to 5 nearby allies for 3% of your maximum health.
    temple_training               = { 101236, 442743, 1 }, -- The healing of Enveloping Mist and Vivify is increased by 6%.
    unity_within                  = { 101239, 443589, 1 }, -- Celestial Conduit can be recast once during its duration to call upon all of the August Celestials to assist you at 200% effectiveness. Unity Within is automatically cast when Celestial Conduit ends if not used before expiration.
    xuens_guidance                = { 101236, 442687, 1 }, -- Teachings of the Monastery has a 15% chance to refund a charge when consumed. The damage of Tiger Palm is increased by 10%.
    yulons_knowledge              = { 101233, 443625, 1 }, -- Refreshing Jade Wind's duration is increased by 6 sec.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    absolute_serenity = 5642, -- (455945)
    alpha_tiger       = 5551, -- (287503)
    counteract_magic  =  679, -- (353502)
    dematerialize     = 5398, -- (353361)
    eminence          =   70, -- (353584)
    grapple_weapon    = 3732, -- (233759) You fire off a rope spear, grappling the target's weapons and shield, returning them to you for 5 sec.
    healing_sphere    =  683, -- (205234) Coalesces a Healing Sphere out of the mists at the target location after 1.5 sec. If allies walk through it, they consume the sphere, healing themselves for 38,071 and dispelling all harmful periodic magic effects. Maximum of 3 Healing Spheres can be active by the Monk at any given time.
    jadefire_accord   = 5565, -- (406888)
    mighty_ox_kick    = 5539, -- (202370) You perform a Mighty Ox Kick, hurling your enemy a distance behind you.
    peaceweaver       = 5395, -- (353313)
    rodeo             = 5645, -- (355917)
    zen_focus_tea     = 1928, -- (468430)
    zen_spheres       = 5603, -- (410777) Forms a sphere of Hope or Despair above the target. Only one of each sphere can be active at a time.  Sphere of Hope: Heals for 21,150 and increases your healing done to the target by 15%.  Sphere of Despair: Deals 22,588 Nature damage, Target deals 3% less damage, and takes 10% increased damage from all sources.
} )


-- Auras
spec:RegisterAuras( {
    -- Damage received from $@auracaster increased by $w1%.
    acclamation = {
        id = 451433,
        duration = 12.0,
        max_stack = 5,
    },
    blackout_reinforcement = {
        id = 424454,
        duration = 3600,
        max_stack = 1
    },
    bok_proc = {
        id = 116768,
        type = "Magic",
        max_stack = 1,
    },
    bounce_back = {
        id = 390239,
        duration = 4,
        max_stack = 1
    },
    -- Channeling the power of the August Celestials, $?c2[healing $s3 nearby allies.]?c3[damaging nearby enemies.][]$?a443059[; Damage taken reduced by $w2%.][]$?a443566[; Movement speed increased by $w5%.][]
    celestial_conduit = {
        id = 443028,
        duration = 4.0,
        max_stack = 1,
    },
    chi_burst = {
        id = 460490,
        duration = 30,
        max_stack = 2,
    },
    -- Increases the damage done by your next Chi Explosion by $s1%.    Chi Explosion is triggered whenever you use Spinning Crane Kick.
    -- https://wowhead.com/beta/spell=393057
    chi_energy = {
        id = 393057,
        duration = 45,
        max_stack = 30,
        copy = 337571
    },
    -- Talent: Movement speed increased by $w1%.
    -- https://wowhead.com/beta/spell=119085
    chi_torpedo = {
        id = 119085,
        duration = 10,
        max_stack = 2
    },
    chi_wave = { -- TODO: Consider modeling this proc every 15s.
        id = 450380,
        duration = 3600,
        max_stack = 1
    },
    combat_wisdom = {
        id = 129914,
        duration = 3600,
        max_stack = 1
    },
    -- TODO: This is a stub until BrM is implemented.
    counterstrike = {
        duration = 3600,
        max_stack = 1,
    },
    -- Taking $w1 damage every $t1 sec.
    -- https://wowhead.com/beta/spell=117952
    crackling_jade_lightning = {
        id = 117952,
        duration = function() return talent.power_of_the_thunder_king.enabled and 2 or 4 end,
        tick_time = function() return talent.power_of_the_thunder_king.enabled and 0.5 or 1 end,
        type = "Magic",
        max_stack = 1
    },
    -- Your dodge chance is increased by $w1% until you dodge an attack.
    dance_of_the_wind = {
        id = 432180,
        duration = 10.0,
        max_stack = 1,
    },
    -- Talent: Your next Spinning Crane Kick is free and deals an additional $325201s1% damage.
    -- https://wowhead.com/beta/spell=325202
    dance_of_chiji = {
        id = 325202,
        duration = 15,
        max_stack = 2,
        copy = { 286587, "dance_of_chiji_azerite" }
    },
    darting_hurricane = {
        id = 459841,
        duration = 10,
        max_stack = 2
    },
    -- Talent: Spell damage taken reduced by $m1%.
    -- https://wowhead.com/beta/spell=122783
    diffuse_magic = {
        id = 122783,
        duration = 6,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Movement slowed by $w1%. When struck again by Disable, you will be rooted for $116706d.
    -- https://wowhead.com/beta/spell=116095
    disable = {
        id = 116095,
        duration = 15,
        mechanic = "snare",
        max_stack = 1
    },
    disable_root = {
        id = 116706,
        duration = 8,
        max_stack = 1,
    },
    dual_threat = {
        id = 451833,
        duration = 5,
        max_stack = 1
    },
    -- Transcendence: Transfer has no cooldown.; Vivify's healing is increased by $w3% and you're refunded $m2% of the cost when cast on yourself.
    escape_from_reality = {
        id = 343249,
        duration = 10.0,
        max_stack = 1,
        copy = 394112
    },
    exit_strategy = {
        id = 289324,
        duration = 2,
        max_stack = 1
    },
    -- Talent: $?$w1>0[Healing $w1 every $t1 sec.][Suffering $w2 Nature damage every $t2 sec.]
    -- https://wowhead.com/beta/spell=196608
    eye_of_the_tiger = {
        id = 196608,
        duration = 8,
        max_stack = 1
    },
    -- Gathering Yu'lon's energy.
    heart_of_the_jade_serpent = {
        id = 456368,
        duration = 120.0,
        max_stack = 1,
    },
    heart_of_the_jade_serpent_cdr = {
        id = 443421,
        duration = 8,
        max_stack = 1
    },
    heart_of_the_jade_serpent_cdr_celestial = {
        id = 443616,
        duration = 60.0,
        max_stack = 45,
    },
    heart_of_the_jade_serpent_stack_ww = {
        id = 443424,
        duration = 60.0,
        max_stack = 45,
    },
    -- Talent: Fighting on a faeline has a $s2% chance of resetting the cooldown of Faeline Stomp.
    -- https://wowhead.com/beta/spell=388193
    jadefire_stomp = {
        id = 388193,
        duration = 30,
        max_stack = 1,
        copy = { 327104, "faeline_stomp" }
    },
    -- Damage version.
    jadefire_brand = {
        id = 395414,
        duration = 10,
        max_stack = 1,
        copy = { 356773, "fae_exposure", "fae_exposure_damage", "jadefire_brand_damage" }
    },
    jadefire_brand_heal = {
        id = 395413,
        duration = 10,
        max_stack = 1,
        copy = { 356774, "fae_exposure_heal" },
    },
    -- Talent: $w3 damage every $t3 sec. $?s125671[Parrying all attacks.][]
    -- https://wowhead.com/beta/spell=113656
    fists_of_fury = {
        id = 113656,
        duration = function () return 4 * haste end,
        max_stack = 1,
    },
    -- Talent: Stunned.
    -- https://wowhead.com/beta/spell=120086
    fists_of_fury_stun = {
        id = 120086,
        duration = 4,
        mechanic = "stun",
        max_stack = 1
    },
    flying_serpent_kick = {
        name = "Flying Serpent Kick",
        duration = 2,
        generate = function ()
            local cast = rawget( class.abilities.flying_serpent_kick, "lastCast" ) or 0
            local expires = cast + 2

            local fsk = buff.flying_serpent_kick
            fsk.name = "Flying Serpent Kick"

            if expires > query_time then
                fsk.count = 1
                fsk.expires = expires
                fsk.applied = cast
                fsk.caster = "player"
                return
            end
            fsk.count = 0
            fsk.expires = 0
            fsk.applied = 0
            fsk.caster = "nobody"
        end,
    },
    -- Talent: Movement speed reduced by $m2%.
    -- https://wowhead.com/beta/spell=123586
    flying_serpent_kick_snare = {
        id = 123586,
        duration = 4,
        max_stack = 1
    },
    fury_of_xuen_stacks = {
        id = 396167,
        duration = 30,
        max_stack = 100,
        copy = { "fury_of_xuen", 396168, 396167, 287062 }
    },
    fury_of_xuen_buff = {
        id = 287063,
        duration = 8,
        max_stack = 1,
        copy = 396168
    },
    -- $@auracaster's abilities to have a $h% chance to strike for $s1% additional Nature damage.
    gale_force = {
        id = 451582,
        duration = 10.0,
        max_stack = 1,
    },
    hidden_masters_forbidden_touch = {
        id = 213114,
        duration = 5,
        max_stack = 1
    },
    hit_combo = {
        id = 196741,
        duration = 10,
        max_stack = 6,
    },
    invoke_xuen = {
        id = 123904,
        duration = 20, -- 11/1 nerf from 24 to 20.
        max_stack = 1,
        hidden = true,
        copy = "invoke_xuen_the_white_tiger"
    },
    -- Talent: Haste increased by $w1%.
    -- https://wowhead.com/beta/spell=388663
    invokers_delight = {
        id = 388663,
        duration = 20,
        max_stack = 1,
        copy = 338321
    },
    -- Stunned.
    -- https://wowhead.com/beta/spell=119381
    leg_sweep = {
        id = 119381,
        duration = 3,
        mechanic = "stun",
        max_stack = 1
    },
    mark_of_the_crane = {
        id = 228287,
        duration = 15,
        max_stack = 1,
        no_ticks = true
    },
    -- The damage of your next Tiger Palm is increased by $w1%.
    martial_mixture = {
        id = 451457,
        duration = 15.0,
        max_stack = 30,
    },
    -- Haste increased by ${$w1}.1%.
    memory_of_the_monastery = {
        id = 454970,
        duration = 5.0,
        max_stack = 8,
    },
    -- Fists of Fury's damage increased by $s1%.
    momentum_boost = {
        id = 451297,
        duration = 10.0,
        max_stack = 1,
    },
    momentum_boost_speed = {
        id = 451298,
        duration = 8,
        max_stack = 1
    },
    mortal_wounds = {
        id = 115804,
        duration = 10,
        max_stack = 1,
    },
    mystic_touch = {
        id = 113746,
        duration = 3600,
        max_stack = 1,
    },
    -- Reduces the Chi Cost of your abilities by $s1.
    ordered_elements = {
        id = 451462,
        duration = 7.0,
        max_stack = 1,
    },
    -- Talent: Incapacitated.
    -- https://wowhead.com/beta/spell=115078
    paralysis = {
        id = 115078,
        duration = 60,
        mechanic = "incapacitate",
        max_stack = 1
    },
    pressure_point = {
        id = 393053,
        duration = 5,
        max_stack = 1,
        copy = 337482
    },
    -- Taunted. Movement speed increased by $s3%.
    -- https://wowhead.com/beta/spell=116189
    provoke = {
        id = 116189,
        duration = 3,
        mechanic = "taunt",
        max_stack = 1
    },
    -- Talent: Nearby enemies will be knocked out of the Ring of Peace.
    -- https://wowhead.com/beta/spell=116844
    ring_of_peace = {
        id = 116844,
        duration = 5,
        type = "Magic",
        max_stack = 1
    },
    rising_sun_kick = {
        id = 107428,
        duration = 10,
        max_stack = 1,
    },
    -- Talent: Dealing physical damage to nearby enemies every $116847t1 sec.
    -- https://wowhead.com/beta/spell=116847
    rushing_jade_wind = {
        id = 116847,
        duration = function () return 6 * haste end,
        tick_time = 0.75,
        dot = "buff",
        max_stack = 1,
        copy = 443626
    },
    save_them_all = {
        id = 390105,
        duration = 4,
        max_stack = 1
    },
    -- Talent: Healing for $w1 every $t1 sec.
    -- https://wowhead.com/beta/spell=115175
    soothing_mist = {
        id = 115175,
        duration = 8,
        type = "Magic",
        max_stack = 1
    },
    -- $?$w2!=0[Movement speed reduced by $w2%.  ][]Drenched in brew, vulnerable to Breath of Fire.
    -- https://wowhead.com/beta/spell=196733
    special_delivery = {
        id = 196733,
        duration = 15,
        max_stack = 1
    },
    -- Attacking nearby enemies for Physical damage every $101546t1 sec.
    -- https://wowhead.com/beta/spell=101546
    spinning_crane_kick = {
        id = 101546,
        duration = function () return 1.5 * haste end,
        tick_time = function () return 0.5 * haste end,
        max_stack = 1
    },
    -- Talent: Elemental spirits summoned, mirroring all of the Monk's attacks.  The Monk and spirits each do ${100+$m1}% of normal damage and healing.
    -- https://wowhead.com/beta/spell=137639
    storm_earth_and_fire = {
        id = 137639,
        duration = 15,
        max_stack = 1
    },
    -- Talent: Movement speed reduced by $s2%.
    -- https://wowhead.com/beta/spell=392983
    strike_of_the_windlord = {
        id = 392983,
        duration = 6,
        max_stack = 1
    },
    -- Movement slowed by $s1%.
    -- https://wowhead.com/beta/spell=280184
    sweep_the_leg = {
        id = 280184,
        duration = 6,
        max_stack = 1
    },
    tea_of_plenty_rsk = {
        -- Stub until MW is loaded.
    },
    teachings_of_the_monastery = {
        id = 202090,
        duration = 20,
        max_stack = function() return talent.knowledge_of_the_broken_temple.enabled and 8 or 4 end,
    },
    -- Damage of next Crackling Jade Lightning increased by $s1%.  Energy cost of next Crackling Jade Lightning reduced by $s2%.
    -- https://wowhead.com/beta/spell=393039
    the_emperors_capacitor = {
        id = 393039,
        duration = 3600,
        max_stack = 20,
        copy = 337291
    },
    thunderfist = {
        id = 393565,
        duration = 30,
        max_stack = 30
    },
    -- Talent: Moving $s1% faster.
    -- https://wowhead.com/beta/spell=116841
    tigers_lust = {
        id = 116841,
        duration = 6,
        type = "Magic",
        max_stack = 1
    },
    touch_of_death = {
        id = 115080,
        duration = 8,
        max_stack = 1
    },
    touch_of_karma = {
        id = 125174,
        duration = 10,
        max_stack = 1
    },
    -- Talent: Damage dealt to the Monk is redirected to you as Nature damage over $124280d.
    -- https://wowhead.com/beta/spell=122470
    touch_of_karma_debuff = {
        id = 122470,
        duration = 10,
        max_stack = 1
    },
    -- Talent: You left your spirit behind, allowing you to use Transcendence: Transfer to swap with its location.
    -- https://wowhead.com/beta/spell=101643
    transcendence = {
        id = 101643,
        duration = 900,
        max_stack = 1
    },
    transcendence_transfer = {
        id = 119996,
    },
    transfer_the_power = {
        id = 195321,
        duration = 30,
        max_stack = 10
    },
    -- Talent: Your next Vivify is instant.
    -- https://wowhead.com/beta/spell=392883
    vivacious_vivification = {
        id = 392883,
        duration = 3600,
        max_stack = 1
    },
    -- Talent:
    -- https://wowhead.com/beta/spell=196742
    whirling_dragon_punch = {
        id = 196742,
        duration = function () return action.rising_sun_kick.cooldown end,
        max_stack = 1,
    },
    windwalking = {
        id = 166646,
        duration = 3600,
        max_stack = 1,
    },
    wisdom_of_the_wall_flurry = {
        id = 452688,
        duration = 40,
        max_stack = 1
    },
    -- Flying.
    -- https://wowhead.com/beta/spell=125883
    zen_flight = {
        id = 125883,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    zen_pilgrimage = {
        id = 126892,
    },

    -- PvP Talents
    alpha_tiger = {
        id = 287504,
        duration = 8,
        max_stack = 1,
    },
    fortifying_brew = {
        id = 201318,
        duration = 15,
        max_stack = 1,
    },
    grapple_weapon = {
        id = 233759,
        duration = 6,
        max_stack = 1,
    },
    heavyhanded_strikes = {
        id = 201787,
        duration = 2,
        max_stack = 1,
    },
    ride_the_wind = {
        id = 201447,
        duration = 3600,
        max_stack = 1,
    },
    tigereye_brew = {
        id = 247483,
        duration = 20,
        max_stack = 1
    },
    tigereye_brew_stack = {
        id = 248646,
        duration = 120,
        max_stack = 20,
    },
    wind_waker = {
        id = 290500,
        duration = 4,
        max_stack = 1,
    },

    -- Conduit
    coordinated_offensive = {
        id = 336602,
        duration = 15,
        max_stack = 1
    },

    -- Azerite Powers
    recently_challenged = {
        id = 290512,
        duration = 30,
        max_stack = 1
    },
    sunrise_technique = {
        id = 273298,
        duration = 15,
        max_stack = 1
    },
} )



spec:RegisterGear( "tier31", 207243, 207244, 207245, 207246, 207248 )


-- Tier 30
spec:RegisterGear( "tier30", 202509, 202507, 202506, 202505, 202504 )
spec:RegisterAura( "shadowflame_vulnerability", {
    id = 411376,
    duration = 15,
    max_stack = 1
} )


spec:RegisterGear( "tier29", 200360, 200362, 200363, 200364, 200365, 217188, 217190, 217186, 217187, 217189 )
spec:RegisterAuras( {
    kicks_of_flowing_momentum = {
        id = 394944,
        duration = 30,
        max_stack = 2,
    },
    fists_of_flowing_momentum = {
        id = 394949,
        duration = 30,
        max_stack = 3,
    }
} )

spec:RegisterGear( "tier19", 138325, 138328, 138331, 138334, 138337, 138367 )
spec:RegisterGear( "tier20", 147154, 147156, 147152, 147151, 147153, 147155 )
spec:RegisterGear( "tier21", 152145, 152147, 152143, 152142, 152144, 152146 )
spec:RegisterGear( "class", 139731, 139732, 139733, 139734, 139735, 139736, 139737, 139738 )

spec:RegisterGear( "cenedril_reflector_of_hatred", 137019 )
spec:RegisterGear( "cinidaria_the_symbiote", 133976 )
spec:RegisterGear( "drinking_horn_cover", 137097 )
spec:RegisterGear( "firestone_walkers", 137027 )
spec:RegisterGear( "fundamental_observation", 137063 )
spec:RegisterGear( "gai_plins_soothing_sash", 137079 )
spec:RegisterGear( "hidden_masters_forbidden_touch", 137057 )
spec:RegisterGear( "jewel_of_the_lost_abbey", 137044 )
spec:RegisterGear( "katsuos_eclipse", 137029 )
spec:RegisterGear( "march_of_the_legion", 137220 )
spec:RegisterGear( "prydaz_xavarics_magnum_opus", 132444 )
spec:RegisterGear( "salsalabims_lost_tunic", 137016 )
spec:RegisterGear( "sephuzs_secret", 132452 )
spec:RegisterGear( "the_emperors_capacitor", 144239 )

spec:RegisterGear( "soul_of_the_grandmaster", 151643 )
spec:RegisterGear( "stormstouts_last_gasp", 151788 )
spec:RegisterGear( "the_wind_blows", 151811 )


spec:RegisterStateTable( "combos", {
    blackout_kick = true,
    chi_burst = true,
    chi_wave = true,
    crackling_jade_lightning = true,
    expel_harm = true,
    faeline_stomp = true,
    jadefire_stomp = true,
    fists_of_fury = true,
    flying_serpent_kick = true,
    rising_sun_kick = true,
    rushing_jade_wind = true,
    spinning_crane_kick = true,
    strike_of_the_windlord = true,
    tiger_palm = true,
    touch_of_death = true,
    weapons_of_order = true,
    whirling_dragon_punch = true
} )

local prev_combo, actual_combo, virtual_combo

spec:RegisterStateExpr( "last_combo", function () return virtual_combo or actual_combo end )

spec:RegisterStateExpr( "combo_break", function ()
    return this_action == virtual_combo and combos[ virtual_combo ]
end )

spec:RegisterStateExpr( "combo_strike", function ()
    return not combos[ this_action ] or this_action ~= virtual_combo
end )


-- If a Tiger Palm missed, pretend we never cast it.
-- Use RegisterEvent since we're looking outside the state table.
spec:RegisterCombatLogEvent( function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID == state.GUID then
        local ability = class.abilities[ spellID ] and class.abilities[ spellID ].key
        if not ability then return end

        if ability == "tiger_palm" and subtype == "SPELL_MISSED" and not state.talent.hit_combo.enabled then
            if ns.castsAll[1] == "tiger_palm" then ns.castsAll[1] = "none" end
            if ns.castsAll[2] == "tiger_palm" then ns.castsAll[2] = "none" end
            if ns.castsOn[1] == "tiger_palm" then ns.castsOn[1] = "none" end
            actual_combo = "none"

            Hekili:ForceUpdate( "WW_MISSED" )

        elseif subtype == "SPELL_CAST_SUCCESS" and state.combos[ ability ] then
            prev_combo = actual_combo
            actual_combo = ability

        elseif subtype == "SPELL_DAMAGE" and spellID == 148187 then
            -- track the last tick.
            state.buff.rushing_jade_wind.last_tick = GetTime()
        end
    end
end )


local chiSpent = 0

spec:RegisterHook( "spend", function( amt, resource )
    if resource == "chi" and amt > 0 then
        if talent.spiritual_focus.enabled then
            chiSpent = chiSpent + amt
            cooldown.storm_earth_and_fire.expires = max( 0, cooldown.storm_earth_and_fire.expires - floor( chiSpent / 2 ) )
            chiSpent = chiSpent % 2
        end

        if talent.drinking_horn_cover.enabled and buff.storm_earth_and_fire.up then
            buff.storm_earth_and_fire.expires = buff.storm_earth_and_fire.expires + 0.25
        end

        if talent.last_emperors_capacitor.enabled or legendary.last_emperors_capacitor.enabled then
            addStack( "the_emperors_capacitor" )
        end
    end
end )


local noop = function () end

-- local reverse_harm_target




spec:RegisterHook( "runHandler", function( key, noStart )
    if combos[ key ] then
        if last_combo == key then removeBuff( "hit_combo" )
        else
            if talent.hit_combo.enabled then addStack( "hit_combo" ) end
            if azerite.fury_of_xuen.enabled or talent.fury_of_xuen.enabled then addStack( "fury_of_xuen" ) end
            if ( talent.xuens_bond.enabled or conduit.xuens_bond.enabled ) and cooldown.invoke_xuen.remains > 0 then reduceCooldown( "invoke_xuen", 0.2 ) end
            if talent.meridian_strikes.enabled and cooldown.touch_of_death.remains > 0 then reduceCooldown( "touch_of_death", 0.6 ) end
        end
        virtual_combo = key
    end
end )


spec:RegisterStateTable( "healing_sphere", setmetatable( {}, {
    __index = function( t,  k)
        if k == "count" then
            t[ k ] = GetSpellCount( action.expel_harm.id )
            return t[ k ]
        end
    end
} ) )

spec:RegisterHook( "reset_precast", function ()
    rawset( healing_sphere, "count", nil )
    if healing_sphere.count > 0 then
        applyBuff( "gift_of_the_ox", nil, healing_sphere.count )
    end

    chiSpent = 0

    if actual_combo == "tiger_palm" and chi.current < 2 and now - action.tiger_palm.lastCast > 0.2 then
        actual_combo = "none"
    end

    if buff.rushing_jade_wind.up then setCooldown( "rushing_jade_wind", 0 ) end

    if buff.casting.up and buff.casting.v1 == action.spinning_crane_kick.id then
        removeBuff( "casting" )
        -- Spinning Crane Kick buff should be up.
    end

    spinning_crane_kick.count = nil

    virtual_combo = actual_combo or "no_action"
    -- reverse_harm_target = nil

    if buff.weapons_of_order_ww.up then
        state:QueueAuraExpiration( "weapons_of_order_ww", noop, buff.weapons_of_order_ww.expires )
    end
end )

spec:RegisterHook( "IsUsable", function( spell )
    if spell == "touch_of_death" then return end -- rely on priority only.

    -- Allow repeats to happen if your chi has decayed to 0.
    -- TWW priority appears to allow hit_combo breakage for Tiger Palm.
    if talent.hit_combo.enabled and buff.hit_combo.up and spell ~= "tiger_palm" and last_combo == spell then
        return false, "would break hit_combo"
    end
end )


spec:RegisterStateTable( "spinning_crane_kick", setmetatable( { onReset = function( self ) self.count = nil end },
    { __index = function( t, k )
            if k == "count" then
                return max( GetSpellCount( action.spinning_crane_kick.id ), active_dot.mark_of_the_crane )

            elseif k == "modifier" then
                local mod = 1
                -- Windwalker:
                if state.spec.windwalker then
                    -- Mark of the Crane (Cyclone Strikes) + Calculated Strikes (Conduit)
                    mod = mod * ( 1 + ( t.count * ( conduit.calculated_strikes.enabled and 0.28 or 0.18 ) ) )
                end

                -- Crane Vortex (Talent)
                mod = mod * ( 1 + 0.1 * talent.crane_vortex.rank )

                -- Kicks of Flowing Momentum (Tier 29 Buff)
                mod = mod * ( buff.kicks_of_flowing_momentum.up and 1.3 or 1 )

                -- Brewmaster: Counterstrike (Buff)
                mod = mod * ( buff.counterstrike.up and 2 or 1 )

                -- Fast Feet (Talent)
                mod = mod * ( 1 + 0.05 * talent.fast_feet.rank )
                return mod

            elseif k == "max" then
                return spinning_crane_kick.count >= min( cycle_enemies, 5 )

            end
    end } ) )

spec:RegisterStateExpr( "alpha_tiger_ready", function ()
    if not pvptalent.alpha_tiger.enabled then
        return false
    elseif debuff.recently_challenged.down then
        return true
    elseif cycle then return
        active_dot.recently_challenged < active_enemies
    end
    return false
end )

spec:RegisterStateExpr( "alpha_tiger_ready_in", function ()
    if not pvptalent.alpha_tiger.enabled then return 3600 end
    if active_dot.recently_challenged < active_enemies then return 0 end
    return debuff.recently_challenged.remains
end )

spec:RegisterStateFunction( "weapons_of_order", function( c )
    if c and c > 0 then
        return buff.weapons_of_order_ww.up and ( c - 1 ) or c
    end
    return c
end )


spec:RegisterPet( "xuen_the_white_tiger", 63508, "invoke_xuen", 24, "xuen" )

spec:RegisterTotem( "jade_serpent_statue", 620831 )
spec:RegisterTotem( "white_tiger_statue", 125826 )
spec:RegisterTotem( "black_ox_statue", 627607 )


spec:RegisterUnitEvent( "UNIT_POWER_UPDATE", "player", nil, function( event, unit, resource )
    if resource == "CHI" then
        Hekili:ForceUpdate( event, true )
    end
end )


-- Abilities
spec:RegisterAbilities( {
    -- Kick with a blast of Chi energy, dealing $?s137025[${$s1*$<CAP>/$AP}][$s1] Physical damage.$?s261917[    Reduces the cooldown of Rising Sun Kick and Fists of Fury by ${$m3/1000}.1 sec when used.][]$?s387638[    Strikes up to $387638s1 additional$ltarget;targets.][]$?s387625[    $@spelldesc387624][]$?s387046[    Critical hits grant an additional $387046m2 $Lstack:stacks; of Elusive Brawler.][]
    blackout_kick = {
        id = 100784,
        cast = 0,
        cooldown = 3,
        gcd = "spell",
        school = "physical",

        spend = function ()
            if buff.bok_proc.up then return 0 end
            return weapons_of_order( ( level < 17 and 3 or 1 ) - ( buff.ordered_elements.up and 1 or 0 ) )
        end,
        spendType = "chi",

        startsCombat = true,
        texture = 574575,

        cycle = function()
            if cycle_enemies == 1 then return end
        
            if level > 32 and cycle_enemies > active_dot.mark_of_the_crane and active_dot.mark_of_the_crane < 5 and debuff.mark_of_the_crane.up then
                if Hekili.ActiveDebug then Hekili:Debug( "Recommending swap to target missing Mark of the Crane debuff." ) end
                return "mark_of_the_crane"
            end
        end,

        handler = function ()
            if buff.blackout_reinforcement.up then
                removeBuff( "blackout_reinforcement" )
                if set_bonus.tier31_4pc > 0 then
                    reduceCooldown( "fists_of_fury", 3 )
                    reduceCooldown( "rising_sun_kick", 3 )
                    reduceCooldown( "strike_of_the_windlord", 3 )
                    reduceCooldown( "whirling_dragon_punch", 3 )
                end
            end
            if buff.bok_proc.up then
                removeBuff( "bok_proc" )
                if talent.energy_burst.enabled then gain( 1, "chi" ) end
                if set_bonus.tier21_4pc > 0 then gain( 1, "chi" ) end
            end

            if level > 22 then
                reduceCooldown( "rising_sun_kick", ( buff.weapons_of_order.up and 2 or 1 ) + ( buff.ordered_elements.up and 1 or 0 ) )
                reduceCooldown( "fists_of_fury", ( buff.weapons_of_order.up and 2 or 1 ) + ( buff.ordered_elements.up and 1 or 0 ) )
            end

            if buff.teachings_of_the_monastery.up then
                if talent.memory_of_the_monastery.enabled then
                    addStack( "memory_of_the_monastery", nil, buff.teachings_of_the_monastery.stack )
                end
                removeBuff( "teachings_of_the_monastery" )
            end

            if talent.eye_of_the_tiger.enabled then applyDebuff( "target", "eye_of_the_tiger" ) end
            if level > 32 then
                applyDebuff( "target", "mark_of_the_crane" )
                if talent.shadowboxing_treads.enabled then active_dot.mark_of_the_crane = min( active_dot.mark_of_the_crane + 2, active_enemies ) end
            end
            if talent.ordered_elements.enabled then applyBuff( "ordered_elements" ) end
            if talent.transfer_the_power.enabled then addStack( "transfer_the_power" ) end
        end,
    },

    -- $?c2[The August Celestials empower you, causing you to radiate ${$443039s1*$s7} healing onto up to $s3 injured allies and ${$443038s1*$s7} Nature damage onto enemies within $s6 yds over $d, split evenly among them. Healing and damage increased by $s1% per target, up to ${$s1*$s3}%.]?c3[The August Celestials empower you, causing you to radiate ${$443038s1*$s7} Nature damage onto enemies and ${$443039s1*$s7} healing onto up to $s3 injured allies within $443038A2 yds over $d, split evenly among them. Healing and damage increased by $s1% per enemy struck, up to ${$s1*$s3}%.][]; You may move while channeling, but casting other healing or damaging spells cancels this effect.;
    celestial_conduit = {
        id = 443028,
        cast = function() return talent.unity_within.enabled and buff.celestial_conduit.up and 0 or 4.0 end,
        channeled = function() return not talent.unity_within.enabled or not buff.celestial_conduit.up end,
        dual_cast = function() return talent.unity_within.enabled and buff.celestial_conduit.up end,
        cooldown = 90.0,
        gcd = "spell",

        spend = 0.050,
        spendType = 'mana',

        talent = "celestial_conduit",
        startsCombat = false,

        start = function()
            applyBuff( "celestial_conduit" )
        end,

        handler = function()
            -- TODO: do whatever unity_within does.
        end,
    },

    -- Talent: Hurls a torrent of Chi energy up to 40 yds forward, dealing $148135s1 Nature damage to all enemies, and $130654s1 healing to the Monk and all allies in its path. Healing reduced beyond $s1 targets.  $?c1[    Casting Chi Burst does not prevent avoiding attacks.][]$?c3[    Chi Burst generates 1 Chi per enemy target damaged, up to a maximum of $s3.][]
    chi_burst = {
        id = 461404,
        cast = function () return 1 * haste end,
        cooldown = 30,
        gcd = "spell",
        school = "nature",

        talent = "chi_burst",
        startsCombat = false,
        buff = "chi_burst",

        handler = function()
            removeBuff( "chi_burst" )
        end,
    },

    -- Talent: Torpedoes you forward a long distance and increases your movement speed by $119085m1% for $119085d, stacking up to 2 times.
    chi_torpedo = {
        id = 115008,
        cast = 0,
        charges = function () return legendary.roll_out.enabled and 3 or 2 end,
        cooldown = 20,
        recharge = 20,
        gcd = "off",
        school = "physical",

        talent = "chi_torpedo",
        startsCombat = false,

        handler = function ()
            -- trigger chi_torpedo [119085]
            applyBuff( "chi_torpedo" )
        end,
    },

    --[[ Talent: A wave of Chi energy flows through friends and foes, dealing $132467s1 Nature damage or $132463s1 healing. Bounces up to $s1 times to targets within $132466a2 yards.
    chi_wave = {
        id = 115098,
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = "nature",

        talent = "chi_wave",
        startsCombat = false,

        handler = function ()
        end,
    }, ]]

    -- Channel Jade lightning, causing $o1 Nature damage over $117952d to the target$?a154436[, generating 1 Chi each time it deals damage,][] and sometimes knocking back melee attackers.
    crackling_jade_lightning = {
        id = 117952,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function () return 20 * ( 1 - ( buff.the_emperors_capacitor.stack * 0.05 ) ) end,
        spendPerSec = function () return 20 * ( 1 - ( buff.the_emperors_capacitor.stack * 0.05 ) ) end,

        startsCombat = false,

        handler = function ()
            applyBuff( "crackling_jade_lightning" )
            removeBuff( "the_emperors_capacitor" )
        end,
    },

    -- Talent: Removes all Poison and Disease effects from the target.
    detox = {
        id = 218164,
        cast = 0,
        charges = 1,
        cooldown = 8,
        recharge = 8,
        gcd = "spell",
        school = "nature",

        spend = 20,
        spendType = "energy",

        talent = "detox",
        startsCombat = false,

        toggle = "interrupts",
        usable = function () return debuff.dispellable_poison.up or debuff.dispellable_disease.up, "requires dispellable_poison/disease" end,

        handler = function ()
            removeDebuff( "player", "dispellable_poison" )
            removeDebuff( "player", "dispellable_disease" )
        end,nm
    },

    -- Talent: Reduces magic damage you take by $m1% for $d, and transfers all currently active harmful magical effects on you back to their original caster if possible.
    diffuse_magic = {
        id = 122783,
        cast = 0,
        cooldown = 90,
        gcd = "off",
        school = "nature",

        talent = "diffuse_magic",
        startsCombat = false,

        toggle = "interrupts",
        buff = "dispellable_magic",

        handler = function ()
            removeBuff( "dispellable_magic" )
        end,
    },

    -- Talent: Reduces the target's movement speed by $s1% for $d, duration refreshed by your melee attacks.$?s343731[ Targets already snared will be rooted for $116706d instead.][]
    disable = {
        id = 116095,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = 15,
        spendType = "energy",

        talent = "disable",
        startsCombat = true,

        handler = function ()
            if not debuff.disable.up then applyDebuff( "target", "disable" )
            else applyDebuff( "target", "disable_root" ) end
        end,
    },

    -- Expel negative chi from your body, healing for $s1 and dealing $s2% of the amount healed as Nature damage to an enemy within $115129A1 yards.$?s322102[    Draws in the positive chi of all your Healing Spheres to increase the healing of Expel Harm.][]$?s325214[    May be cast during Soothing Mist, and will additionally heal the Soothing Mist target.][]$?s322106[    |cFFFFFFFFGenerates $s3 Chi.]?s342928[    |cFFFFFFFFGenerates ${$s3+$342928s2} Chi.][]
    expel_harm = {
        id = 322101,
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = "nature",

        spend = 15,
        spendType = "energy",

        startsCombat = false,
        notalent = "combat_wisdom",

        handler = function ()
            gain( ( healing_sphere.count * stat.attack_power ) + stat.spell_power * ( 1 + stat.versatility_atk_mod ), "health" )
            removeBuff( "gift_of_the_ox" )
            healing_sphere.count = 0

            -- gain( pvptalent.reverse_harm.enabled and 2 or 1, "chi" )
        end,
    },

    -- Talent: Strike the ground fiercely to expose a faeline for $d, dealing $388207s1 Nature damage to up to 5 enemies, and restores $388207s2 health to up to 5 allies within $388207a1 yds caught in the faeline. $?a137024[Up to 5 allies]?a137025[Up to 5 enemies][Stagger is $s3% more effective for $347480d against enemies] caught in the faeline$?a137023[]?a137024[ are healed with an Essence Font bolt][ suffer an additional $388201s1 damage].    Your abilities have a $s2% chance of resetting the cooldown of Faeline Stomp while fighting on a faeline.
    jadefire_stomp = {
        id = function() return talent.jadefire_stomp.enabled and 388193 or 327104 end,
        cast = 0,
        -- charges = 1,
        cooldown = function() return state.spec.mistweaver and 15 or 30 end,
        -- recharge = 30,
        gcd = "spell",
        school = "nature",

        spend = 0.04,
        spendType = "mana",

        startsCombat = true,
        notalent = "jadefire_fists",

        cycle = function() if talent.jadefire_harmony.enabled then return "jadefire_brand" end end,

        handler = function ()
            applyBuff( "jadefire_stomp" )

            if state.spec.brewmaster then
                applyDebuff( "target", "breath_of_fire" )
                active_dot.breath_of_fire = active_enemies
            end

            if state.spec.mistweaver then
                if talent.ancient_concordance.enabled then applyBuff( "ancient_concordance" ) end
                if talent.ancient_teachings.enabled then applyBuff( "ancient_teachings" ) end
                if talent.awakened_jadefire.enabled then applyBuff( "awakened_jadefire" ) end
                if talent.jadefire_teachings.enabled then applyBuff( "jadefire_teachings" ) end
            end

            if talent.jadefire_harmony.enabled or legendary.fae_exposure.enabled then applyDebuff( "target", "jadefire_brand" ) end
        end,

        copy = { 388193, 327104, "faeline_stomp" }
    },

    -- Talent: Pummels all targets in front of you, dealing ${5*$117418s1} Physical damage to your primary target and ${5*$117418s1*$s6/100} damage to all other enemies over $113656d. Deals reduced damage beyond $s1 targets. Can be channeled while moving.
    fists_of_fury = {
        id = 113656,
        cast = 4,
        channeled = true,
        cooldown = 24,
        gcd = "spell",
        school = "physical",

        spend = function ()
            return weapons_of_order( buff.ordered_elements.up and 2 or 3 )
        end,
        spendType = "chi",

        tick_time = function () return haste end,

        start = function ()
            removeBuff( "fists_of_flowing_momentum" )
            removeBuff( "transfer_the_power" )

            if buff.fury_of_xuen.stack >= 50 then
                applyBuff( "fury_of_xuen_buff" )
                summonPet( "xuen", 10 )
                removeBuff( "fury_of_xuen" )
            end

            if talent.whirling_dragon_punch.enabled and cooldown.rising_sun_kick.remains > 0 then
                applyBuff( "whirling_dragon_punch", min( cooldown.fists_of_fury.remains, cooldown.rising_sun_kick.remains ) )
            end

            if pvptalent.turbo_fists.enabled then
                applyDebuff( "target", "heavyhanded_strikes", action.fists_of_fury.cast_time + 2 )
            end

            if legendary.pressure_release.enabled then
                -- TODO: How much to generate?  Do we need to queue it?  Special buff generator?
            end

            if set_bonus.tier29_2pc > 0 then applyBuff( "kicks_of_flowing_momentum", nil, set_bonus.tier29_4pc > 0 and 3 or 2 ) end
            if set_bonus.tier30_4pc > 0 then
                applyDebuff( "target", "shadowflame_vulnerability" )
                active_dot.shadowflame_vulnerability = active_enemies
            end
        end,

        tick = function ()
            if legendary.jade_ignition.enabled then
                addStack( "chi_energy", nil, active_enemies )
            end
        end,

        finish = function ()
            if talent.jadefire_fists.enabled and query_time - action.fists_of_fury.lastCast > 25 then class.abilities.jadefire_stomp.handler() end
            if talent.momentum_boost.enabled then applyBuff( "momentum_boost" ) end
            if talent.xuens_battlegear.enabled or legendary.xuens_battlegear.enabled then applyBuff( "pressure_point" ) end
        end,
    },

    -- Talent: Soar forward through the air at high speed for $d.     If used again while active, you will land, dealing $123586s1 damage to all enemies within $123586A1 yards and reducing movement speed by $123586s2% for $123586d.
    flying_serpent_kick = {
        id = 101545,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "physical",

        talent = "flying_serpent_kick",
        startsCombat = false,

        -- Sync to the GCD even though it's not really on it.
        readyTime = function()
            return gcd.remains
        end,

        handler = function ()
            if buff.flying_serpent_kick.up then
                removeBuff( "flying_serpent_kick" )
            else
                applyBuff( "flying_serpent_kick" )
                setCooldown( "global_cooldown", 2 )
            end
        end,
    },

    -- Talent: Turns your skin to stone for $120954d$?a388917[, increasing your current and maximum health by $<health>%][]$?s322960[, increasing the effectiveness of Stagger by $322960s1%][]$?a388917[, reducing all damage you take by $<damage>%][]$?a388814[, increasing your armor by $388814s2% and dodge chance by $388814s1%][].
    fortifying_brew = {
        id = 115203,
        cast = 0,
        cooldown = function()
            if state.spec.brewmaster then return talent.expeditious_fortification.enabled and 240 or 360 end
            return talent.expeditious_fortification.enabled and 90 or 120
        end,
        gcd = "off",
        school = "physical",

        talent = "fortifying_brew",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "fortifying_brew" )
            if conduit.fortifying_ingredients.enabled then applyBuff( "fortifying_ingredients" ) end
        end,
    },


    grapple_weapon = {
        id = 233759,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        pvptalent = "grapple_weapon",

        startsCombat = true,
        texture = 132343,

        handler = function ()
            applyDebuff( "target", "grapple_weapon" )
        end,
    },

    -- Talent: Summons an effigy of Xuen, the White Tiger for $d. Xuen attacks your primary target, and strikes 3 enemies within $123996A1 yards every $123999t1 sec with Tiger Lightning for $123996s1 Nature damage.$?s323999[    Every $323999s1 sec, Xuen strikes your enemies with Empowered Tiger Lightning dealing $323999s2% of the damage you have dealt to those targets in the last $323999s1 sec.][]
    invoke_xuen = {
        id = 123904,
        cast = 0,
        cooldown = 120,
        gcd = "spell",
        school = "nature",

        talent = "invoke_xuen",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            summonPet( "xuen_the_white_tiger", 24 )
            applyBuff( "invoke_xuen" )

            if talent.invokers_delight.enabled or legendary.invokers_delight.enabled then
                if buff.invokers_delight.down then stat.haste = stat.haste + 0.2 end
                applyBuff( "invokers_delight" )
            end

            if talent.summon_white_tiger_statue.enabled then
                summonTotem( "white_tiger_statue", nil, 10 )
            end
        end,

        copy = "invoke_xuen_the_white_tiger"
    },

    -- Knocks down all enemies within $A1 yards, stunning them for $d.
    leg_sweep = {
        id = 119381,
        cast = 0,
        cooldown = function() return 60 - 10 * talent.tiger_tail_sweep.rank end,
        gcd = "spell",
        school = "physical",

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "leg_sweep" )
            active_dot.leg_sweep = active_enemies
            if conduit.dizzying_tumble.enabled then applyDebuff( "target", "dizzying_tumble" ) end
        end,
    },

    -- Talent: Incapacitates the target for $d. Limit 1. Damage will cancel the effect.
    paralysis = {
        id = 115078,
        cast = 0,
        cooldown = function() return talent.improved_paralysis.enabled and 30 or 45 end,
        gcd = "spell",
        school = "physical",

        spend = 20,
        spendType = "energy",

        talent = "paralysis",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "paralysis" )
        end,
    },

    -- Taunts the target to attack you$?s328670[ and causes them to move toward you at $116189m3% increased speed.][.]$?s115315[    This ability can be targeted on your Statue of the Black Ox, causing the same effect on all enemies within  $118635A1 yards of the statue.][]
    provoke = {
        id = 115546,
        cast = 0,
        cooldown = 8,
        gcd = "off",
        school = "physical",

        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "provoke" )
        end,
    },

    -- Talent: Form a Ring of Peace at the target location for $d. Enemies that enter will be ejected from the Ring.
    ring_of_peace = {
        id = 116844,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        school = "nature",

        talent = "ring_of_peace",
        startsCombat = false,

        handler = function ()
        end,
    },

    -- Talent: Kick upwards, dealing $?s137025[${$185099s1*$<CAP>/$AP}][$185099s1] Physical damage$?s128595[, and reducing the effectiveness of healing on the target for $115804d][].$?a388847[    Applies Renewing Mist for $388847s1 seconds to an ally within $388847r yds][]
    rising_sun_kick = {
        id = 107428,
        cast = 0,
        cooldown = function ()
            return ( ( buff.tea_of_plenty_rsk.up and 1 or 10 ) - ( talent.brawlers_intensity.enabled and 1 or 0 ) ) * haste
        end,
        gcd = "spell",
        school = "physical",

        spend = function ()
            return weapons_of_order( buff.ordered_elements.up and 1 or 2 )
        end,
        spendType = "chi",

        talent = "rising_sun_kick",
        startsCombat = true,

        cycle = function()
            if cycle_enemies == 1 then return end
        
            if level > 32 and cycle_enemies > active_dot.mark_of_the_crane and active_dot.mark_of_the_crane < 5 and debuff.mark_of_the_crane.up then
                if Hekili.ActiveDebug then Hekili:Debug( "Recommending swap to target missing Mark of the Crane debuff." ) end
                return "mark_of_the_crane"
            end
        end,

        handler = function ()
            applyDebuff( "target", "rising_sun_kick" )
            removeStack( "tea_of_plenty_rsk" )
            removeBuff( "chi_wave" )

            if buff.kicks_of_flowing_momentum.up then
                removeStack( "kicks_of_flowing_momentum" )
                if set_bonus.tier29_4pc > 0 then addStack( "fists_of_flowing_momentum" ) end
            end

            if talent.acclamation.enabled then applyDebuff( "target", "acclamation", nil, debuff.acclamation.stack + 1 ) end

            if level > 32 then applyDebuff( "target", "mark_of_the_crane" ) end

            if talent.ordered_elements.enabled and buff.storm_earth_and_fire.up then applyBuff( "ordered_elements" ) end

            if talent.transfer_the_power.enabled then addStack( "transfer_the_power" ) end

            if talent.whirling_dragon_punch.enabled and cooldown.fists_of_fury.remains > 0 then
                applyBuff( "whirling_dragon_punch", min( cooldown.fists_of_fury.remains, cooldown.rising_sun_kick.remains ) )
            end

            if azerite.sunrise_technique.enabled then applyDebuff( "target", "sunrise_technique" ) end

            if buff.weapons_of_order.up then
                applyBuff( "weapons_of_order_ww" )
                state:QueueAuraExpiration( "weapons_of_order_ww", noop, buff.weapons_of_order_ww.expires )
            end
        end,
    },

    -- Roll a short distance.
    roll = {
        id = 109132,
        cast = 0,
        charges = function ()
            local n = 1 + ( talent.celerity.enabled and 1 or 0 ) + ( legendary.roll_out.enabled and 1 or 0 )
            if n > 1 then return n end
            return nil
        end,
        cooldown = function () return talent.celerity.enabled and 15 or 20 end,
        recharge = function () return talent.celerity.enabled and 15 or 20 end,
        gcd = "off",
        school = "physical",

        startsCombat = false,
        notalent = "chi_torpedo",

        handler = function ()
            if azerite.exit_strategy.enabled then applyBuff( "exit_strategy" ) end
        end,
    },

    --[[ Talent: Summons a whirling tornado around you, causing ${(1+$d/$t1)*$148187s1} Physical damage over $d to all enemies within $107270A1 yards. Deals reduced damage beyond $s1 targets.
    rushing_jade_wind = {
        id = 116847,
        cast = 0,
        cooldown = function ()
            local x = 6 * haste
            if buff.serenity.up then x = max( 0, x - ( buff.serenity.remains / 2 ) ) end
            return x
        end,
        gcd = "spell",
        school = "nature",

        spend = function() return weapons_of_order( buff.ordered_elements.up and 1 or 0 ) end,
        spendType = "chi",

        talent = "rushing_jade_wind",
        startsCombat = false,

        handler = function ()
            applyBuff( "rushing_jade_wind" )
            if talent.transfer_the_power.enabled then addStack( "transfer_the_power" ) end
        end,
    }, ]]

    --[[ Talent: Enter an elevated state of mental and physical serenity for $?s115069[$s1 sec][$d]. While in this state, you deal $s2% increased damage and healing, and all Chi consumers are free and cool down $s4% more quickly.
    serenity = {
        id = 152173,
        cast = 0,
        cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 90 end,
        gcd = "off",
        school = "physical",

        talent = "serenity",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "serenity" )
            setCooldown( "fists_of_fury", cooldown.fists_of_fury.remains - ( cooldown.fists_of_fury.remains / 2 ) )
            setCooldown( "rising_sun_kick", cooldown.rising_sun_kick.remains - ( cooldown.rising_sun_kick.remains / 2 ) )
            setCooldown( "rushing_jade_wind", cooldown.rushing_jade_wind.remains - ( cooldown.rushing_jade_wind.remains / 2 ) )
            if conduit.coordinated_offensive.enabled then applyBuff( "coordinated_offensive" ) end
        end,
    }, ]]

    -- Talent: Heals the target for $o1 over $d.  While channeling, Enveloping Mist$?s227344[, Surging Mist,][]$?s124081[, Zen Pulse,][] and Vivify may be cast instantly on the target.$?s117907[    Each heal has a chance to cause a Gust of Mists on the target.][]$?s388477[    Soothing Mist heals a second injured ally within $388478A2 yds for $388477s1% of the amount healed.][]
    soothing_mist = {
        id = 115175,
        cast = 8,
        channeled = true,
        hasteCD = true,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        talent = "soothing_mist",
        startsCombat = false,

        handler = function ()
            applyBuff( "soothing_mist" )
        end,
    },

    -- Talent: Jabs the target in the throat, interrupting spellcasting and preventing any spell from that school of magic from being cast for $d.
    spear_hand_strike = {
        id = 116705,
        cast = 0,
        cooldown = 15,
        gcd = "off",
        school = "physical",

        talent = "spear_hand_strike",
        startsCombat = true,

        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
        end,
    },

    -- Spin while kicking in the air, dealing $?s137025[${4*$107270s1*$<CAP>/$AP}][${4*$107270s1}] Physical damage over $d to all enemies within $107270A1 yds. Deals reduced damage beyond $s1 targets.$?a220357[    Spinning Crane Kick's damage is increased by $220358s1% for each unique target you've struck in the last $220358d with Tiger Palm, Blackout Kick, or Rising Sun Kick. Stacks up to $228287i times.][]
    spinning_crane_kick = {
        id = 101546,
        cast = 1.5,
        channeled = true,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = function () return buff.dance_of_chiji.up and 0 or weapons_of_order( buff.ordered_elements.up and 1 or 2 ) end,
        spendType = "chi",

        startsCombat = true,

        usable = function ()
            if settings.check_sck_range and not action.fists_of_fury.in_range then return false, "target is out of range" end
            return true
        end,

        handler = function ()
            removeBuff( "chi_energy" )
            if buff.dance_of_chiji.up then
                if set_bonus.tier31_2pc > 0 then applyBuff( "blackout_reinforcement" ) end
                if talent.sequenced_strikes.enabled then applyBuff( "bok_proc" ) end
                removeStack( "dance_of_chiji" )
            end

            if buff.kicks_of_flowing_momentum.up then
                removeStack( "kicks_of_flowing_momentum" )
                if set_bonus.tier29_4pc > 0 then addStack( "fists_of_flowing_momentum" ) end
            end

            applyBuff( "spinning_crane_kick" )

            if talent.transfer_the_power.enabled then addStack( "transfer_the_power" ) end
        end,
    },

    -- Talent: Split into 3 elemental spirits for $d, each spirit dealing ${100+$m1}% of normal damage and healing.    You directly control the Storm spirit, while Earth and Fire spirits mimic your attacks on nearby enemies.    While active, casting Storm, Earth, and Fire again will cause the spirits to fixate on your target.
    storm_earth_and_fire = {
        id = 137639,
        cast = 0,
        charges = 2,
        cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 90 end,
        recharge = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 90 end,
        icd = 1,
        gcd = "off",
        school = "nature",

        talent = "storm_earth_and_fire",
        startsCombat = false,
        nobuff = "storm_earth_and_fire",

        toggle = function ()
            if settings.sef_one_charge then
                if cooldown.storm_earth_and_fire.true_time_to_max_charges > gcd.max then return "cooldowns" end
                return
            end
            return "cooldowns"
        end,

        handler = function ()
            -- trigger storm_earth_and_fire_fixate [221771]
            applyBuff( "storm_earth_and_fire" )
            if talent.ordered_elements.enabled then
                setCooldown( "rising_sun_kick", 0 )
                gain( 2, "chi" )
            end
        end,

        bind = "storm_earth_and_fire_fixate"
    },


    storm_earth_and_fire_fixate = {
        id = 221771,
        known = 137639,
        cast = 0,
        cooldown = 0,
        icd = 1,
        gcd = "spell",

        startsCombat = true,
        texture = 236188,

        buff = "storm_earth_and_fire",

        usable = function ()
            if buff.storm_earth_and_fire.down then return false, "spirits are not active" end
            return action.storm_earth_and_fire_fixate.lastCast < action.storm_earth_and_fire.lastCast, "spirits are already fixated"
        end,

        bind = "storm_earth_and_fire",
    },

    -- Talent: Strike with both fists at all enemies in front of you, dealing ${$395519s1+$395521s1} damage and reducing movement speed by $s2% for $d.
    strike_of_the_windlord = {
        id = 392983,
        cast = 0,
        cooldown = function() return 40 - ( 10 * talent.communion_with_wind.rank ) end,
        gcd = "spell",
        school = "physical",

        spend = function() return buff.ordered_elements.up and 1 or 2 end,
        spendType = "chi",

        talent = "strike_of_the_windlord",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "strike_of_the_windlord" )
            if talent.darting_hurricane.enabled then addStack( "darting_hurricane", nil, 2 ) end
            if talent.gale_force.enabled then applyDebuff( "target", "gale_force" ) end
            if talent.rushing_jade_wind.enabled then
                applyDebuff( "target", "mark_of_the_crane" )
                active_dot.mark_of_the_crane = true_active_enemies
                applyBuff( "rushing_jade_wind" )
            end
            if talent.thunderfist.enabled then addStack( "thunderfist", nil, 4 + ( true_active_enemies - 1 ) ) end
        end,
    },

    -- Strike with the palm of your hand, dealing $s1 Physical damage.$?a137384[    Tiger Palm has an $137384m1% chance to make your next Blackout Kick cost no Chi.][]$?a137023[    Reduces the remaining cooldown on your Brews by $s3 sec.][]$?a129914[    |cFFFFFFFFGenerates 3 Chi.]?a137025[    |cFFFFFFFFGenerates $s2 Chi.][]
    tiger_palm = {
        id = 100780,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = function() return talent.inner_peace.enabled and 55 or 60 end,
        spendType = "energy",

        startsCombat = true,

        cycle = "mark_of_the_crane",

        handler = function ()
            gain( 2, "chi" )
            removeBuff( "martial_mixture" )
            removeStack( "darting_hurricane" )

            if buff.combat_wisdom.up then
                class.abilities.expel_harm.handler()
                removeBuff( "combat_wisdom" )
            end

            if level > 32 then applyDebuff( "target", "mark_of_the_crane" ) end

            if talent.eye_of_the_tiger.enabled then
                applyDebuff( "target", "eye_of_the_tiger" )
                applyBuff( "eye_of_the_tiger" )
            end

            if talent.teachings_of_the_monastery.enabled then addStack( "teachings_of_the_monastery" ) end

            if pvptalent.alpha_tiger.enabled and debuff.recently_challenged.down then
                if buff.alpha_tiger.down then
                    stat.haste = stat.haste + 0.10
                    applyBuff( "alpha_tiger" )
                    applyDebuff( "target", "recently_challenged" )
                end
            end

            if buff.darting_hurricane.up then
                setCooldown( "global_cooldown", cooldown.global_cooldown.remains * 0.75 )
                removeStack( "darting_hurricane" )
            end
        end,
    },


    tigereye_brew = {
        id = 247483,
        cast = 0,
        cooldown = 1,
        gcd = "spell",

        startsCombat = false,
        texture = 613399,

        buff = "tigereye_brew_stack",
        pvptalent = "tigereye_brew",

        handler = function ()
            applyBuff( "tigereye_brew", 2 * min( 10, buff.tigereye_brew_stack.stack ) )
            removeStack( "tigereye_brew_stack", min( 10, buff.tigereye_brew_stack.stack ) )
        end,
    },

    -- Talent: Increases a friendly target's movement speed by $s1% for $d and removes all roots and snares.
    tigers_lust = {
        id = 116841,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "physical",

        talent = "tigers_lust",
        startsCombat = false,

        handler = function ()
            applyBuff( "tigers_lust" )
        end,
    },

    -- You exploit the enemy target's weakest point, instantly killing $?s322113[creatures if they have less health than you.][them.    Only usable on creatures that have less health than you]$?s322113[ Deals damage equal to $s3% of your maximum health against players and stronger creatures under $s2% health.][.]$?s325095[    Reduces delayed Stagger damage by $325095s1% of damage dealt.]?s325215[    Spawns $325215s1 Chi Spheres, granting 1 Chi when you walk through them.]?s344360[    Increases the Monk's Physical damage by $344361s1% for $344361d.][]
    touch_of_death = {
        id = 322109,
        cast = 0,
        cooldown = function () return 180 - ( 45 * talent.fatal_touch.rank ) end,
        gcd = "spell",
        school = "physical",

        startsCombat = true,

        toggle = "cooldowns",
        cycle = "touch_of_death",

        -- Non-players can be executed as soon as their current health is below player's max health.
        -- All targets can be executed under 15%, however only at 35% damage.
        usable = function ()
            return ( talent.improved_touch_of_death.enabled and target.health.pct < 15 ) or ( target.class == "npc" and target.health_current < health.max ), "requires low health target"
        end,

        handler = function ()
            applyDebuff( "target", "touch_of_death" )
        end,
    },

    -- Talent: Absorbs all damage taken for $d, up to $s3% of your maximum health, and redirects $s4% of that amount to the enemy target as Nature damage over $124280d.
    touch_of_karma = {
        id = 122470,
        cast = 0,
        cooldown = 90,
        gcd = "off",
        school = "physical",

        startsCombat = true,
        toggle = "defensives",

        usable = function ()
            return incoming_damage_3s >= health.max * ( settings.tok_damage or 20 ) / 100, "incoming damage not sufficient (" .. ( settings.tok_damage or 20 ) .. "% / 3 sec) to use"
        end,

        handler = function ()
            applyBuff( "touch_of_karma" )
            applyDebuff( "target", "touch_of_karma_debuff" )
        end,
    },

    -- Talent: Split your body and spirit, leaving your spirit behind for $d. Use Transcendence: Transfer to swap locations with your spirit.
    transcendence = {
        id = function() return talent.transcendence_linked_spirits.enabled and 434763 or 101643 end,
        known = 101643,
        cast = 0,
        cooldown = 10,
        gcd = "spell",
        school = "nature",

        talent = "transcendence",
        startsCombat = false,

        handler = function ()
            applyBuff( talent.transcendence_linked_spirits.enabled and "transcendence_tethered" or "transcendence" )
        end,

        copy = { 101643, 434763 }
    },


    transcendence_transfer = {
        id = 119996,
        cast = 0,
        cooldown = function () return buff.escape_from_reality.up and 0 or 45 end,
        gcd = "spell",

        startsCombat = false,
        texture = 237585,

        buff = function()
            return talent.transcendence_linked_spirits.enabled and "transcendence_tethered" or "transcendence"
        end,

        handler = function ()
            if buff.escape_from_reality.up then removeBuff( "escape_from_reality" )
            elseif talent.escape_from_reality.enabled or legendary.escape_from_reality.enabled then
                applyBuff( "escape_from_reality" )
            end
            if talent.healing_winds.enabled then gain( 0.15 * health.max, "health" ) end
            if talent.spirits_essence.enabled then applyDebuff( "target", "spirits_essence" ) end
        end,
    },

    -- Causes a surge of invigorating mists, healing the target for $s1$?s274586[ and all allies with your Renewing Mist active for $s2][].
    vivify = {
        id = 116670,
        cast = function() return buff.vivacious_vivification.up and 0 or 1.5 end,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function() return buff.vivacious_vivification.up and 2 or 8 end,
        spendType = "energy",

        startsCombat = false,

        handler = function ()
            removeBuff( "vivacious_vivification" )
            removeBuff( "chi_wave" )
        end,
    },

    -- Talent: Performs a devastating whirling upward strike, dealing ${3*$158221s1} damage to all nearby enemies. Only usable while both Fists of Fury and Rising Sun Kick are on cooldown.
    whirling_dragon_punch = {
        id = 152175,
        cast = 0,
        cooldown = function() return talent.revolving_whirl.enabled and 19 or 24 end,
        gcd = "spell",
        school = "physical",

        talent = "whirling_dragon_punch",
        startsCombat = false,

        usable = function ()
            if settings.check_wdp_range and not action.fists_of_fury.in_range then return false, "target is out of range" end
            return cooldown.fists_of_fury.remains > 0 and cooldown.rising_sun_kick.remains > 0, "requires fists_of_fury and rising_sun_kick on cooldown"
        end,

        handler = function ()
            if talent.knowledge_of_the_broken_temple.enabled then addStack( "teachings_of_the_monastery", nil, 4 ) end
            if talent.revolving_whirl.enabled then addStack( "dance_of_chiji" ) end
        end,
    },

    -- You fly through the air at a quick speed on a meditative cloud.
    zen_flight = {
        id = 125883,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        startsCombat = false,

        handler = function ()
            applyBuff( "zen_flight" )
        end,
    },
} )

spec:RegisterRanges( "fists_of_fury", "strike_of_the_windlord" , "tiger_palm", "touch_of_karma", "crackling_jade_lightning" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 2,
    cycle = false,

    nameplates = true,
    nameplateRange = 10,
    rangeFilter = false,

    damage = true,
    damageExpiration = 8,

    potion = "potion_of_spectral_agility",

    package = "Windwalker",

    strict = false
} )

spec:RegisterSetting( "allow_fsk", false, {
    name = strformat( "Use %s", Hekili:GetSpellLinkWithTexture( spec.abilities.flying_serpent_kick.id ) ),
    desc = strformat( "If unchecked, %s will not be recommended despite generally being used as a filler ability.\n\n"
        .. "Unchecking this option is the same as disabling the ability via |cFFFFD100Abilities|r > |cFFFFD100|W%s|w|r > |cFFFFD100|W%s|w|r > |cFFFFD100Disable|r.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.flying_serpent_kick.id ), spec.name, spec.abilities.flying_serpent_kick.name ),
    type = "toggle",
    width = "full",
    get = function () return not Hekili.DB.profile.specs[ 269 ].abilities.flying_serpent_kick.disabled end,
    set = function ( _, val )
        Hekili.DB.profile.specs[ 269 ].abilities.flying_serpent_kick.disabled = not val
    end,
} )

--[[ Deprecated.
spec:RegisterSetting( "optimize_reverse_harm", false, {
    name = "Optimize |T627486:0|t Reverse Harm",
    desc = "If checked, |T627486:0|t Reverse Harm's caption will show the recommended target's name.",
    type = "toggle",
    width = "full",
} ) ]]

spec:RegisterSetting( "sef_one_charge", false, {
    name = strformat( "%s: Reserve 1 Charge for Cooldowns Toggle", Hekili:GetSpellLinkWithTexture( spec.abilities.storm_earth_and_fire.id ) ),
    desc = strformat( "If checked, %s can be recommended while Cooldowns are disabled, as long as you will retain 1 remaining charge.\n\n"
        .. "If |W%s's|w |cFFFFD100Required Toggle|r is changed from |cFF00B4FFDefault|r, this feature is disabled.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.storm_earth_and_fire.id ), spec.abilities.storm_earth_and_fire.name ),
    type = "toggle",
    width = "full",
} )

spec:RegisterSetting( "tok_damage", 1, {
    name = strformat( "%s: Required Incoming Damage", Hekili:GetSpellLinkWithTexture( spec.abilities.touch_of_karma.id ) ),
    desc = strformat( "If set above zero, %s will only be recommended if you have taken this percentage of your maximum health in damage in the past 3 seconds.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.touch_of_karma.id ) ),
    type = "range",
    min = 0,
    max = 99,
    step = 0.1,
    width = "full",
} )

spec:RegisterSetting( "check_wdp_range", false, {
    name = strformat( "%s: Check Range", Hekili:GetSpellLinkWithTexture( spec.abilities.whirling_dragon_punch.id ) ),
    desc = strformat( "If checked, %s will not be recommended if your target is outside your %s range.", Hekili:GetSpellLinkWithTexture( spec.abilities.whirling_dragon_punch.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.fists_of_fury.id ) ),
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "check_sck_range", false, {
    name = strformat( "%s: Check Range", Hekili:GetSpellLinkWithTexture( spec.abilities.spinning_crane_kick.id ) ),
    desc = strformat( "If checked, %s will not be recommended if your target is outside your %s range.", Hekili:GetSpellLinkWithTexture( spec.abilities.spinning_crane_kick.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.fists_of_fury.id ) ),
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "use_diffuse", false, {
    name = strformat( "%s: Self-Dispel", Hekili:GetSpellLinkWithTexture( spec.abilities.diffuse_magic.id ) ),
    desc = function()
        local m = strformat( "If checked, %s may be recommended when when you have a dispellable magic debuff.", Hekili:GetSpellLinkWithTexture( spec.abilities.diffuse_magic.id ) )

        local t = class.abilities.diffuse_magic.toggle
        if t then
            local active = Hekili.DB.profile.toggles[ t ].value
            m = m .. "\n\n" .. ( active and "|cFF00FF00" or "|cFFFF0000" ) .. "Requires " .. t:gsub("^%l", string.upper) .. " Toggle|r"
        end

        return m
    end,
    type = "toggle",
    width = "full"
} )


spec:RegisterPack( "Windwalker", 20240928.2, [[Hekili:T3ZIUnoYr(Tm4a0iLBShlklppozbC3EjyNfxYTy9EypGdru0uusmMIuHKA84ad9TFv38vZU7Q7MpKFKDqaY4vKSQQRQ66z)yX4f)6IBw5K6T4VyDH1Lx8jRpE(yRl(WKpT4M0h27T4M9oU35Sb(JqNDW))V5hU6ENG78Ijp6HGiNveqKeDi2fE82009jF(9VFJF62d3EUB0U3N4V7qGtQFuOBSZ6uY)T77Vni623NU17(47H30p897JJw7h4L8(Fo27xC8xb)XVy)NJcVZUcJNt(0f3C7b)G0VeU4w5u(hbQzVNl8ZxbdIT(Rw5L9UEjWhtE3ZU4tNz9XpFC5n(7(HJlpSNaM3DCPZQvXEjjWV)h)thx6NKCWd(NWZ2aJ8Jl)AY5hxcuqYXF64pvcMlbW8)EWl84Y1(FJ9jxmgGi5nS4qu1l9XZMCb8W)9GGO7pU8x934fFC5p7eS74Y0OJlVn2Z5UJl)r)0Jl)HOD3c)us0oVu)DEjSaX6tkWG1u4H)IxGZ3oUmAVxibfrhst8xbdPO1awIiJ41(B2MwhQ409hoZ6k4H)6wae)MdaWFJkdxCtGFsAcvJYBTZHGuB3apNV6b)YFHQO5f6CBG3Qf)hlUXXLOrS4My)e)Wn2jhcTVZ39Uf34(a8r2PoXB8aybF3nUX(PEX(oej)61NVNiJoe7zVpYpm98d7pUCai7a49vpByaUZhyplNDC5L0h4gffSk6(WZxtio7O12Rpe)W5XE7C8dHxCo8IzkhX(7ZOjRZGpTGcsbfjeApzVFyiH6bf7qVc6VKADjYm7K0y)78OKcL8x5e66rid3T()n)ZtsH5xhxE9XLwshha5nrctbOQjiuvkrpYEpOgXsmdpUKi838afKtNsrwQtGhWcHrb5l8CC9ophGhx(4J1(IRUG(fVr9hnkNLZnWHH657iAGNr)BaGLJxkpjfGcOaTHkEaRc27IcDsak)Hc(Zm9VjGa783gG7WscnBqyF7H4K0kknBSqH5Tr3zdMFCPQsKH9B08TJQ95rXR8I9wz7f4Td(MKsW8mtczpxN6)GCjcWGNus2WuSVEEM8RGpFpyfoaWt27ucv5Vuf4hvFoOlqHjP(ob2UrHRo4Nw9MZQPrGnIkO1Psu0Yj(cMYwpN40ck7V5SYZoXlgSacwLwfZYO1)22L0n97uOLdg(8DjgSR0WviKKpX(sYe7YzZrhC3sORvEoPBzNWdV5uetacSzbJOjPrX7SjJ5T2oHRSx7h7vYJnv4wBA23aNGj23c4RUnK3O8nkK3(HFnc8WNadZaIROc(mbczEOgK7KYMvJz8u5SWRm2BtjBbOZ9Ezez2WDl8eBQX0ZZmktPb6uJktSzMr9jXhKPvsj4MQqvWfeCTjF09bKrxTP4cICZji5y9JiyfyuXbeU6QyNnrH27pe6UT3X(NW8blvhLf95AFBG)XEDumR7kLAFzA3zMNdIIwfCijT0SHjw0g0sRlYzaJVOvs99r3dQQ(HRpKaVDnTn2rfconpQTwHvPr8mdnINXybIDBa42hIQvoXOp6cWw9hle4YiNmzEUIuYwhqYFB03iCGuig9vjm(LrOCSG10o5PY8jy4jk4RK3L(r1TYQ7DgOm6ZzkI(0kdbnqkDz7NQsnKoVW9(qM5zztrTLAEMnw(XtRXqwhCio(HCV0giNq9OgdmkQGIo7LALGe6VOYgqBE727fhbMtCDGSN9bxTfmAcb(j5rpKtWzZCY5rqo0HqqdGAD4McAhHWX841Z5OGGDmpsYZfraPzX4Eor8BNgzttvygGUnURYYB4pqNeoqRyvU5KPvJS79twfTRuh0jiWodwQYJezqJ5qK3GSSVfZD2RkgM8XMfMJQ(qvK1tc8l25mIQPxwFcHQAHRSSuvlkKGj(g2aw0EOGzTYbSBXMXgnWHCyAXihZm5DrFIf9f9WQxqhcZ(e6O(YIaRYPU7cJUhWYMshl3gdokaNeGv4G6X6zId8gfqIfMB9(rvhbPO(xBdsXs0oNxLbQVgfN69nLmP5OohSW8P(cXwhcvJ5q1qQgPyadnOUrgoGXM7H5lgDUNiTRVMrgoFDEHOPeKCMBlakYybZfljimsjlaQoA3(fIz7rqYHaN4GhGC(CpKa8zY3inO5sGT1jggbpOosllmx39k)DydzXLLDqQw1OcyAIfWsqjuusfiqoVAsFfkGUcD2gRvfttlAbG0baFud1smdVSELPnaHOqRClfyn2ROaFyOoBhIcoz2IgZY0uvGz1AQi8mmNIMpmnBcctOusAwHCUbMIkMpvbdnY(4o6GtPMTOSdHiUITQXv6D1ly8eENdTLSY1DGKWTPFyLntvtXjuaMjD1HgQOdhyKIbAsiSsEl81M0lZtFrqZdmOLlsvpi2hUXjcI(J2I2fkAyAnLkEQNp5fGSUQC6IqZsuY8gX1u0F07o)a)pFC5FoAL)AFYRqAsT7wpx(Mu7dXXEC5drhoU8E)GaiYf4xjRJGZsJoBp1RLF4XLRoeUXlImFEyEV1d3e4DMxOB0HWusJQjDBF05zCNIwkd60nPDY1gdJlARRG(LKMkJ7XRQdesddL(rinyHgbHjs2sY77nU9jTRPFVXTFVXTTTXTtyDbRSXTyHBORVkynQ6nQT6WAZqy0OmBh(qB4Ohv4Bi7KbmSQnXI6QH60Ah8IOJ0LrHj0g(0xeTMU31sWJQSOeIoVEA(AzaSYBxvkENW1n71WUIkNhJv2Htz7FXsFVRLXDETqLqDzOPMrzTtR(RQOE3iJr8m8PeNMLRN8SMmMRRjzjHgE3wPBbEK3UzcMA2Qj8KwK2Mn0AulO7bf3lFc1nX9(2gBBmMevPvR2HmtDtnRZlMO8X7tKX)Xt5kcqVLF0gDBwxe12aqt7DhI(cMJPNRjXnV5XDTX4iHYB0itofH2o7EWwYhyzM782X0N1QxxwANyVlVNZgu1RSgKJevrTKxe6UBTIvyU9fUxcjHsjlaaK04mQI8iEATQL7gYQYQox4u5JPB94(jXXKqlDBFqt6LmyjmzE7eE(JYeTPSgAwZi7x6TmJqC8Un0XkLVMC02BkzdI5QgejE)DW5UlalzEyuwMT655RaqMuZo9wSK2DEDk2D0v3jvNqOZTcP03pDyVymZ1NT0V36124dxO1R8oF2A2Itvx5PLBahDnYMQObRMla0z9DqV3u4PSXeW3j4AbdmPJRwi1CBtBb8hyPx0wa3uR99FlGB8kOrjDCkAb8L4M)KvL1ERfW5n5CHKoCYAaMqQGkbLT4crpc8ya2aqz59EoXG92WcFEuxoim(9rz)BTML(ZrftRRjgmUK)m5Nx3PG2AzRRk7WuaW)uQ4wGncMxM4XWf(Qdq4Wtj)vWb4Fw7eK4Xnq)JuaCC5p)LJl9xFCPZxD8dk(Qy7S99(wNeBVVbmIqNa79(uLeoSxdO)pjae)1y)W7iAvvZkj5aN9Fyt2T0z7z6CCKw86PInEPgW)VPRsaLGLi0DjjuVqOAkLkQz8B5RkkglohxErnYKzDkKk2pdjy7sPyRKmKGngQ3ioxiOtcYLkQIpEBrzZpKpfTfCX8aGKnrO0gidX5wIPuXEhuJW(pZM(dQIX(ra(EOX0MGi9A6kCLHAkwhfGuKqp4R1fjAhJzMLNn7mVIwvYpaF5(zllD3h4JYwSTnCX(irvzQHAcCN8aPs6Ib(qCgnbUMQ8XSYuQTsviC4EyH889faIzR(cdwzfDzXDya4nX3pF8cVIx4gCgVMFn8k)AUkCrWgLk7QwneTCxu08snjnuV2HC5Xk7kFljzqCOQ2lcFFB(3RBZ)60PtAAG3gGfXBcOK)iTAW1NpRVWGSUoZjGNVn07O6lHkvAj0xOJNlbVc2KZYhqnETkl3QGKIcXqo68gv4kNyFazEqhoCeEk7V6t6Am56I90Fr46475fekdlWTx87fCS08nzJj)sBDGODdBxmz6kKbuF5FVOWIitbrp5aAkEKzbJ1w8Pjed0ZpaTRPnPNgB6iefRHbmNi9iFucOikNieeMtGwrqAkMAZ3aBnBS8YOLtkzhYPC0vHHHuUqn0FY2oUyErEo3cR91bAOUSHBTwTBTtEHgPJJUN8npOnDwVg8cC)5IP(19(U1WsAGqh4RyezDATq(prOAwK6FzqV17(Ig51q)EFA2R)9BxvnFp9l7J7OdmDv6YS(SIxq5wSYeQTS7qBAl(sURzJrLDkf1oRMzBnFhFRRgQ9EdDfw)b1KzYd2VpAOBvVFmTtaL0vE)D35eFxHZfkBhq6AiO7TeWum)KRKzKulZCDw1LgXxXYIPQ2nlTFgRcLLgUsSHT5HkBxubVT0VxDbq96jkFVjl16ac)LziTOEJvEdtzh5dg5AMI2v2kZXxulUlKADAuFUQQ5j5VKek0yjB)njfQJeEWd9KIWqvhbG5kKoUUbo7OhO7L(cnr2p4yTDJ2ij(wgyaykvHMxUP2yIwyq96LDrD)vZkpMTKlSjVRS13r7gEAkQn4grUPk0I5jk85uNpLsF9Rtwtvekr2qSUcuBeu2(YSqme2nGs(zTZzwFiiaycUBjCE7Qz3hfoa1m)ZV2qJOPXh8SzTKkFOHkpglqHQBFZmMKD1KwEj7eDBfvKUIWS3j1Nko2SjZTNBxQy0h0GjtwzSoOq6YWdnvRUaPd7Z5yiUuSq9Dk)qh)oN4Do1JfnLzDkjjMgXfAZptQI9XLFjFR8DCjWUirU8fk)j72Z4DWqIEBsq4KLxfg(jfdIZlU(rCcaAgueS3F4F8pGbbKJmNnqTRUS6SqvZu5SyPTDzA0HSywdlYghkIGXl(W(uQgbDz9To2zdrGlesn2Poso3ddms86uV5Czc8ZthFozDWDibiyaDL(glESL0hRMPL9ogj1gQGsObLHrhCHrzuiUZRM0RqMYis35e67AVj23BnmwZ2zJkZ647CvmU64lyYH0ZbIEMu5v6gFY7biuAcRvvbL02feR2r6JnG0TQi9v)nN4dGj89(bboLnYZlG0gV1bKzKPQw)KDqf55qUAcZHrUMTwaOf85wi7o7v(GrPWe5lFZNil89M59CER0frWRwb8KlKpaXxcPVoew7EyfWEacWpbSHt7tMYk89AvMjmot5x40MwJkfRwv3E(yNlJalU7YufJKIovRjCzPreNs3QheQZr6(XilIkFYY7yTNBQTtIRxiPFZpqYv6WoMYpH)o5Ry4VcPjqE1YBYUf3CVtmPsRjlUHEnRbWikof0KJG4IFB9f58BpUm27VFa08xLDdXbrnFinANtk5hG0Mc3aj5D8N(V8dHhn5ZK1(EiGs6JFB5eVYffmapYj7NKNuWWG3y44Vn65aMSTqHdOY6UY3HkpuNkhQvvYKdMIL480dXpjhIvNIuCqu84LIhIJTKdsjDALd2k6fRasqKyClyroeGSCgFAb(LYbE9cfXbB5vrsa0iQhOlUnoSODrWjGWpC6glikM9aOTgJOZZF5lWR6JD5m8pHiazoS6thdoSz2rPHPOUxnFyHmjKD5ZWbDzRSgbWImbSpuA)icBr(sxIN1OEbozkY4x7tCybBPrjaEK529QiMEF)2)I4jiQNDmuHjiwsldBNdMcHZlaqeryla4XFssCXv7m132OyIrSC1xKv1geSzKfIuTtHv)ecZoQ99DOI4pGpnwoiJLLlp0rClCAHEhskO)H4vNuoaIXZUKedska9GNCSO0FcITAmIyOpgvi(B6bqBH4jh5K5JdhAoR)eqgILGNaPJ1PlBk0Oh5pTU4Go6P5LPiOJMLF1s3NUSxXIR9KKiagY6Pebovbt3FX(MdqeXzlaOQOwFB)eYAz7kElF4LcNsq8duelqYA9dVILIJOfESGWnfwdNCOaDnEQH7wUWGBg)fjtLEkKL(lpiLAdDiKnei2dsjLWVN4VVMHosSNNwO3hUMEoO7x4qxQfPATcUxSk132nonJBMJRPEzu3PsP8ecZogpZPbQ9Fs(9perYxn)dlppzKdxHJBgdHEV0MVtjSrIs7fpSpn5AD6s1AmwQw9zFkgJm7(0102txaayfbQJ9C5zOxWNKSPXqwpLnnwNt7i33crFPxNfyHyVSJ2gWkWqRdxAccZOfauAes5lkX(jvvfRCX3YhAJ21cQaNGhN5lNY6l1Ys8iFLyAkqTuduHhBeqF5rPc1EUpOumG(7ekvWWsFqPya93juksqINu7ncHw0hChmG2jUZRhkfjUQtQCumO6(G9Gc1oXFEDqRKaji7FZ9XrRPB3tY)Xo)es0PqWdh2ZeGXgsut(Uhl29dKld(Jl)sA2hrxe(78GuiaYkDRd8ZEav(ab2zNs6KRtE3GdRiBYvpFqKh)zGaihz1)F0DG6xs92L8xFhDNN6UL9TDcFOcRhxggra(32hqodycQG7QSlS(usOrfi9F74sG2Zrt(b9pWg)ReGUI9NSyWC21HF5ikhKPfVkLBq)PWd7U1lloRGOuGF(fAezKF4tzBkwYoPLCiKtc4ISvfOS5InDqY5L7DH)1RFpr6atb29oYEw4A8TJarQL)9WxjCds8o)1xNTfjKE3tC8N(xiB2xkLXaMS7wcY3s)eKnSZGHVrC27JpQz3dn6Xhj7XNb12FpZUEYfuAb9EDGL8kUHiY4neDzMB5H3rV1iUMEPrqbzTB1bwWWFaXNbUsnlY3MFPnO)RQwfBVJW4DtVEmL17VZB2Kb13v3ZTgWCSfn)c9qVwzEfrWLCiaWihckydLxGc6XzzZUQJV8eYKOrqXIWTHGEeXul3AOIJPD9uZbv2ESrcqgd6SeTVhFKHbD9fp(iHpo)dp(yHgTqZNgXZJBa5a)34dSzwKPWfcOEzJ3xszNxOmlyqrYEzNqAd1m5TIbPWH9ObVrLzdPZ)TMAarJSv41zNskK5353eG8g5ELh8g5(vvpmh8gT8YHYXhOnkfFJg0KTs48jxiLtlNrlBhB)7gwY4lKYt0UvWjmi1BC9zwnJahJqGwYjqSTJDlKCNAwp2itoRp)ph3J2K6ltsSK2lmE8eLmtRxUmtRxOmZkAUmAicrxUTQFxT9GCM3DtocahmSg3z(4lhKfvs9F2YcCL2eIEWqiSMzthuid57UonSNztgbVhZo8UsMxwK5rYh5kibzSISyT4cC6AigmAuRelc54TQ)TdqJ)ktT6Xh5JOJrSIFu71ag(qoey94Jspe9Q4A8C5b0H30ruPbeSVkHX8Pz)ZKbzDHy2uGRu(NcSoi7Q6h1DOI6cIq6SrwdfSYxzmqPc2UWn1DGzHZybWnKkjWoMUaVm5rGWEUSbSa(FsJoJ4Px2SXJyOCt)ORnAYl7HlNeYxGhoUgLqMbJDqYbHFmmNxwVlM5SevhzCJY1FNKPGogtnUn8fqmzgSXuFZNhOGRMpcvRPqa9W2RpkymYcXUz9ZMnA(EqcFqcVfNrg0ea)rV78d8)8XL)5Ov(R9PLolI0JopYzs(psoHJ)bIX5Jlb60f(2hIouuEQnWVU3X9UZsJoBp9mmNu8Rvhc34frowrg(vsb6iJVaVZ8cDJoeMsYAmXFxYiMegRQJHwhDexjxzINe6GR(zcsfcRvAJ(dNyGNtgldhic78Xb7nMwfAyQHH2XWWmZ7ZNoDqzOwLRhScJ)ZV6IbVr8XeNDvdDAvE258TZitIU2klQmDNU9Z09wL3SFL2oyBqEHbQQtn8I09fwkFelVDgembajndRb0iAaeP424Zy7LmXsGEh8nlNplJwZI(Q2PNdMksT7wpS3sYz3Tmnkk9i7c06AlJigdrtnvpkoD5UxBMB9PbAsiEkgriWWrhPyvxWqHCPADvuNv2qyIevU)dqzvEISOdmEtoYgxCOVCbhYO9FVQB0onCDADpZrb3sSRmgCUFFaQsfmbqWThWavkAOpu8AhcHJjDOQITDkgtyexTZhFZMMWyPJAIOmLGAwflI6hvrsUATuxyKQzpLj0gdYDC(4PL8T6bloQ1ScDUAYms9Xc2HKL5fQ1cK7ZnCQyl(9628XFQUF1C6bDfrIrv1M8XtkTlAHA0vUTwMR1OzxNFLg9hMmqQWltdu1nYgvL8Q(03anV2(eGYM3wyvPp9bzq0HYTKPZ(lQ1KEKBGCtG07ywwGpfvTHzvGk20ZgsGpfZlKmw6bYHT5RqiydveFSskh1WB9RDhfjXGSUIln0ZVIG7tLf8q6nsBHye5YMQZO1JuD5K6mlgAK7lsrmWgPJkJ1uIRTIYsXKgu)mSmkJPMiP5rqrTBktKTNi8H4ZtKfhv1CSXYcOAKg5B)qZ60HOLaMjR(gi1vplVhStPkpwgMlAmyfx8v0qXBQ90YVUlAI6mXuwsOE3qcE9keqD7udzKJe2lVdMzt0nppVGvwND5XLPyfSYLUsz6uOp1TCp7sDXcDPcQOn(zuv9doVksS6vI6FFv0UQkEu3KzNlLxJbSo14x4f4diSSHgAVuSDxfNXy0)E2Lufn6bvrv2adUv64AQ6y5l(pHfJRjw60ToLgW3f2SMTQRRAcsyJRlwjXRScdLcfZPafOY4QW1FOSbv4ktdP68xdvdjpQY6newVvGbnE2ANLAzLBYpFPFwQEu7kgRtQ1MIfHLtSc0AwGs68VD9h57YnXKpEUtQy2gR3EkREmFRHvYdBGA)PUWUvEaEHvG1tviIToIWoxakofKPguPw(qTBRjNxtd6NavbfLsUBgCZQHfULnHJr9rzligRbfPBCrt)An1HUrG70B2)YY8LuFsxQOdrnXzv)PWCkqsBlv6lNzZ9dLCclFU56VnPiFgPRpFYaDR0mf07tyf)pn8ON8IPRaq98K3(OrhQIeRLLzTLYXN7IW3sYwN6xRQdVHt)6hZEOAr6QgVOMsdvWnMs4lTDxKEOiP7fqxg33Vl1qFCrf0fXvsQKqb9XkwoMrPIcxX4XL(IA3rJ1iJVxc7Vxc7)jTe2z63AkFT05IyMEKvQq1lIXCLcE6fHoelHUVPhNc8yqvmrgQ180vNDtfcDRg79JmcPWB(VsQVSPS6mFr6R7lcgoHvVMcFZcvqN)L5tuyZttIxZhRRP1ssYotdsE4uukXGvK)GoY6KxR7UlsAqyRTPUbDK66jfMlpH6fOcMMoTp3oHCDjChdL57RUUAn3U4PUbeMAtJM1Sq1s1xa0Nrf(MvL7MswCXwPKkpTZR(qbta5gtkxLg7(u6GUvtTjUPAM56H6NJX9qUaTfQpmxGVnnsxPMpoPsnZlf)PZOzhDM2w(Jz1(40nSBWK8wy7Pz8AdA9HQkeksFZfPpH7ulzfoSk7eHxxE(5QNNQSRapFsbU6k63JLXplj0ww74wmX55UUXzJxSvTGVHRsb8A807wAojvSwIwv313X5jAQmDDDWUAjQDvK2mjdkc6E1O552a24lTHr1IEXnohs3gfV4MB839dlsH)3I))p]] )