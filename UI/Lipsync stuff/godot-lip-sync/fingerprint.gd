extends Resource
class_name LipSyncFingerprint





const BANDS_RANGE: = [
    [120.0, 180.0, 150.0], 
    [122.0, 232.0, 177.0], 
    [148.0, 290.0, 219.0], 
    [186.0, 356.0, 271.0], 
    [236.0, 426.0, 331.0], 
    [292.0, 504.0, 398.0], 
    [356.0, 586.0, 471.0], 
    [428.0, 674.0, 551.0], 
    [504.0, 766.0, 635.0], 
    [586.0, 864.0, 725.0], 
    [674.0, 966.0, 820.0], 
    [766.0, 1072.0, 919.0], 
    [864.0, 1182.0, 1023.0], 
    [966.0, 1296.0, 1131.0], 
    [1072.0, 1416.0, 1244.0], 
    [1182.0, 1538.0, 1360.0], 
    [1298.0, 1662.0, 1480.0], 
    [1416.0, 1792.0, 1604.0], 
    [1538.0, 1924.0, 1731.0], 
    [1662.0, 4000.0, 2831.0], 
]


const BANDS_COUNT: = 20


const SILENCE: = 0.1


@export var description: String = ""


@export var values: Array = [
    0.0, 0.0, 0.0, 0.0, 0.0, 
    0.0, 0.0, 0.0, 0.0, 0.0, 
    0.0, 0.0, 0.0, 0.0, 0.0, 
    0.0, 0.0, 0.0, 0.0, 0.0]



func populate(spectrum: AudioEffectSpectrumAnalyzerInstance):

    var energy_max: = 0.0
    for i in BANDS_COUNT:
        var from_hz: float = BANDS_RANGE[i][0]
        var to_hz: float = BANDS_RANGE[i][1]
        var center_hz: float = BANDS_RANGE[i][2]
        var magnitude: = spectrum.get_magnitude_for_frequency_range(from_hz, to_hz, AudioEffectSpectrumAnalyzerInstance.MAGNITUDE_AVERAGE)
        var e: = magnitude.length() * center_hz
        values[i] = e
        energy_max = max(energy_max, e)


    var energy_scale: = 0.0 if energy_max <= SILENCE else 1.0 / energy_max
    for i in BANDS_COUNT:
        values[i] *= energy_scale





static func deviation(a: Array, b: Array) -> float:

    var sum: = 0.0
    for i in BANDS_COUNT:
        if b == null or a == null:
            return 0.0
        var delta: float = b[i] - a[i]
        sum += delta * delta


    return sqrt(sum)
