@tool
class_name LipSyncTraining
extends Resource



const MAX_DEVIATION: = 1000.0





@export var training: Dictionary




@export var weights: Dictionary




func match_phonemes(fingerprint: Array, matches: Array):

    matches.resize(Phonemes.PHONEME.COUNT)


    for phoneme in Phonemes.PHONEME.COUNT:

        if not phoneme in training:
            matches[phoneme] = MAX_DEVIATION
            continue


        var min_deviation: = MAX_DEVIATION
        for pattern in training[phoneme]:
            var deviation = LipSyncFingerprint.deviation(fingerprint, pattern)
            min_deviation = min(deviation, min_deviation)


        matches[phoneme] = min_deviation



func match_visemes(fingerprint: Array, matches: Array):

    matches.resize(Visemes.VISEME.COUNT)


    for viseme in Visemes.VISEME.COUNT:
        var min_deviation: = MAX_DEVIATION


        for phoneme in Visemes.VISEME_PHONEME_MAP[viseme]:

            if not phoneme in training:
                continue


            for pattern in training[phoneme]:
                var deviation = LipSyncFingerprint.deviation(fingerprint, pattern)
                min_deviation = min(deviation, min_deviation)


        var weight: = 0.001
        if viseme in weights:
            weight = weights[viseme]


        weight = remap(min_deviation, 0.0, weight, 1.0, 0.0)
        weight = clamp(weight, 0.0, 1.0)


        matches[viseme] = weight
