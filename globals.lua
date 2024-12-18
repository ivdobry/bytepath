default_color = { 222, 222, 222 }
background_color = { 16, 16, 16 }
ammo_color = { 123, 200, 164 }
boost_color = { 76, 195, 217 }
hp_color = { 241, 103, 69 }
skill_point_color = { 255, 198, 93 }
skill_point = 0

attacks = {
    ['Neutral'] = { cooldown = 0.24, ammo = 0, abbreviation = 'N', color = default_color },
    ['Double'] = { cooldown = 0.32, ammo = 2, abbreviation = '2', color = ammo_color },
    ['Triple'] = { cooldown = 0.32, ammo = 3, abbreviation = '3', color = boost_color },
    ['Rapid'] = { cooldown = 0.12, ammo = 1, abbreviation = 'R', color = default_color },
    ['Spread'] = { cooldown = 0.16, ammo = 1, abbreviation = 'RS', color = default_color },
    ['Back'] = { cooldown = 0.32, ammo = 2, abbreviation = 'Ba', color = skill_point_color },
    ['Side'] = { cooldown = 0.32, ammo = 2, abbreviation = 'Si', color = boost_color }
}
