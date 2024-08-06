return {
    enableDebug = true,
    underWaterHear = {
        id = 0,
        slot = 0,
        name = "underwater_hear_submix",
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
    -- Underwater talking
    underWaterTalking = {
        name = "underwater_talking_submix",
        effects = {
            [`freq_low`] = 100.0,
            [`freq_hi`] = 650.0,
            [`rm_mod_freq`] = 0.0,
            [`rm_mix`] = 0.0,
            [`fudge`] = 0.0,
            [`o_freq_lo`] = 100.0,
            [`o_freq_hi`] = 650.0,
        }
    },
}
