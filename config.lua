return {
    enableDebug = false,
    effects = {
        -- Muffled voice when underwater
        underWaterHear = {
            active = true,
            id = 0,
            slot = 0,
            name = "underwater_hear_submix",
            default = true,
            effects = {
                [`freq_low`] = 100.0,
                [`freq_hi`] = 450.0,
                [`rm_mod_freq`] = 0.0,
                [`rm_mix`] = 0.0,
                [`fudge`] = 0.0,
                [`o_freq_lo`] = 100.0,
                [`o_freq_hi`] = 450.0,
            }
        },
        -- Muffled voice when speaking underwater
        underWaterTalking = {
            active = true,
            name = "underwater_talking_submix",
            default = true,
            volume = 0.5,
            effects = {
                [`freq_low`] = 100.0,
                [`freq_hi`] = 350.0,
                [`rm_mod_freq`] = 0.0,
                [`rm_mix`] = 0.0,
                [`fudge`] = 0.0,
                [`o_freq_lo`] = 100.0,
                [`o_freq_hi`] = 550.0,
            }
        },
        -- Muffled hearing of those outside the vehicle
        vehicleInside = {
            active = true,
            name = "vehicle_inside_submix",
            default = true,
            volume = 0.1,
            effects = {
                [`freq_low`] = 100.0,
                [`freq_hi`] = 700.0,
                [`rm_mod_freq`] = 1.0,
                [`rm_mix`] = 0.0,
                [`fudge`] = 0.0,
                [`o_freq_lo`] = 100.0,
                [`o_freq_hi`] = 500.0,
            }
        },
        --
        radioDefault = {
            active = true,
            slot = 0,
            name = "radioDefault",
            default = true,
            outputVolumes = {
                1.0 --[[ frontLeftVolume ]],
                0.25 --[[ frontRightVolume ]],
                0.0 --[[ rearLeftVolume ]],
                0.0 --[[ rearRightVolume ]],
                1.0 --[[ channel5Volume ]],
                1.0 --[[ channel6Volume ]]
            },
            effects = {
                [`freq_low`] = 389.0,
                [`freq_hi`] = 3248.0,
                [`rm_mod_freq`] = 0.0,
                [`rm_mix`] = 0.16,
                [`fudge`] = 0.0,
                [`o_freq_lo`] = 348.0,
                [`o_freq_hi`] = 4900.0,
            }
        },
        radioMid = {
            active = true,
            slot = 0,
            name = "radioMid",
            default = true,
            outputVolumes = {
                1.0 --[[ frontLeftVolume ]],
                0.25 --[[ frontRightVolume ]],
                0.0 --[[ rearLeftVolume ]],
                0.0 --[[ rearRightVolume ]],
                1.0 --[[ channel5Volume ]],
                1.0 --[[ channel6Volume ]]
            },
            effects = {
                [`freq_low`] = 389.0,
                [`freq_hi`] = 1748.0,
                [`rm_mod_freq`] = 90.0,
                [`rm_mix`] = 0.25,
                [`fudge`] = 0.0,
                [`o_freq_lo`] = 348.0,
                [`o_freq_hi`] = 4900.0,
            }
        },
        radioFar = {
            active = true,
            slot = 0,
            name = "radioFar",
            default = true,
            outputVolumes = {
                1.0 --[[ frontLeftVolume ]],
                0.25 --[[ frontRightVolume ]],
                0.0 --[[ rearLeftVolume ]],
                0.0 --[[ rearRightVolume ]],
                1.0 --[[ channel5Volume ]],
                1.0 --[[ channel6Volume ]]
            },
            effects = {
                [`freq_low`] = 389.0,
                [`freq_hi`] = 1048.0,
                [`rm_mod_freq`] = 125.0,
                [`rm_mix`] = 0.5,
                [`fudge`] = 0.0,
                [`o_freq_lo`] = 348.0,
                [`o_freq_hi`] = 4900.0,
            }
        },
    },
    radioDistance = {                             -- Max dist 9k
        { dist = 2000, effect = "radioDefault" }, -- Under 2000
        { dist = 5000, effect = "radioMid" },     -- Under 5000
        { dist = 6500, effect = "radioFar" },     -- Under or above 6500
    }
}
