class_name Visemes



enum VISEME{

    VISEME_SILENT = 0, 





    VISEME_TH = 1, 




    VISEME_SS = 2, 




    VISEME_DD = 3, 



    VISEME_E = 4, 




    VISEME_FF = 5, 



    VISEME_I = 6, 



    VISEME_O = 7, 






    VISEME_PP = 8, 



    VISEME_RR = 9, 




    VISEME_U = 10, 



    VISEME_AA = 11, 





    VISEME_G = 12, 




    VISEME_L = 13, 


    COUNT = 14
}



const VISEME_PHONEME_MAP: = {
    VISEME.VISEME_SILENT: [], 
    VISEME.VISEME_TH: [
        Phonemes.PHONEME.PHONEME_TS, 
    ], 
    VISEME.VISEME_DD: [
        Phonemes.PHONEME.PHONEME_T, 
    ], 
    VISEME.VISEME_E: [
        Phonemes.PHONEME.PHONEME_E, 
    ], 
    VISEME.VISEME_FF: [
        Phonemes.PHONEME.PHONEME_V, 
    ], 
    VISEME.VISEME_I: [
        Phonemes.PHONEME.PHONEME_I, 
    ], 
    VISEME.VISEME_O: [
        Phonemes.PHONEME.PHONEME_O, 
    ], 
    VISEME.VISEME_PP: [
        Phonemes.PHONEME.PHONEME_B, 
    ], 
    VISEME.VISEME_RR: [
        Phonemes.PHONEME.PHONEME_R, 
    ], 
    VISEME.VISEME_SS: [
        Phonemes.PHONEME.PHONEME_S, 
    ], 

    VISEME.VISEME_U: [
        Phonemes.PHONEME.PHONEME_OU, 
    ], 
    VISEME.VISEME_AA: [
        Phonemes.PHONEME.PHONEME_A, 
    ], 
    VISEME.VISEME_G: [
        Phonemes.PHONEME.PHONEME_G, 
    ], 
    VISEME.VISEME_L: [
        Phonemes.PHONEME.PHONEME_L, 
    ], 
}
