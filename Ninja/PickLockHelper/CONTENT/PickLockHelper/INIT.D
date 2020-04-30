/*
    Code mostly from WoG Member F A W K E S
    Converted to a Patch by Kirides
    Many recommended modifications by WoG Member mud-freak implemented.
*/

const int Ninja_PickLockHelper_pickLockString_Mob = 0;  // Mob identification
var string Ninja_PickLockHelper_pickLockString_Last;    // Last successfully tested picklock string
var string Ninja_PickLockHelper_pickLockString_Current; // Current picklock string

const int Ninja_PickLockHelper_ptrTextView = 0;
const int Ninja_PickLockHelper_ptrTextViewLast = 0;
const int Ninja_PickLockHelper_ptrTextViewLastBg = 0;
const int Ninja_PickLockHelper_ptrTextViewBg = 0;

const int Ninja_PickLockHelper_DisplayIsShown = 0;

var string Ninja_PickLockHelper_Font;

func void Ninja_PickLockHelper_DisplayText(var string text) {
    var zCViewText textView;
    var zCViewText textViewLast;

    if (!Ninja_PickLockHelper_ptrTextView) {

        const string maxText = "________________________________________";
        var int posX; posX = (PS_VMax - Print_ToVirtual(Print_GetStringWidth(maxText, Ninja_PickLockHelper_Font), PS_X)) / 2;

        Ninja_PickLockHelper_ptrTextViewLastBg = ViewPtr_Create(posX, 400, 1, 1);
        ViewPtr_ResizePxl(Ninja_PickLockHelper_ptrTextViewLastBg, Print_GetStringWidth(maxText, Ninja_PickLockHelper_Font), Print_GetFontHeight(Ninja_PickLockHelper_Font));
        ViewPtr_SetTexture(Ninja_PickLockHelper_ptrTextViewLastBg, "DEFAULT.TGA");
        ViewPtr_SetColor(Ninja_PickLockHelper_ptrTextViewLastBg, RGBA(0, 0, 0, 255));
        ViewPtr_SetAlpha(Ninja_PickLockHelper_ptrTextViewLastBg, 128);

        Ninja_PickLockHelper_ptrTextViewBg = ViewPtr_Create(posX, 400, 1, 1);
        ViewPtr_ResizePxl(Ninja_PickLockHelper_ptrTextViewBg, Print_GetStringWidth(maxText, Ninja_PickLockHelper_Font), Print_GetFontHeight(Ninja_PickLockHelper_Font));

        // Previous progress
        
        Ninja_PickLockHelper_ptrTextViewLast = Print_CreateTextPtr(Ninja_PickLockHelper_pickLockString_Last, Ninja_PickLockHelper_Font);
        textViewLast = _^(Ninja_PickLockHelper_ptrTextViewLast);
        textViewLast.posx = 300;
        textViewLast.color = RGBA(255, 255, 255, 128);
        textViewLast.colored = TRUE;
        textViewLast.timed = FALSE;

        // Current progress
        Ninja_PickLockHelper_ptrTextView = Print_CreateTextPtr(text, Ninja_PickLockHelper_Font);
        textView = _^(Ninja_PickLockHelper_ptrTextView);
        textView.posx = 300;
        textView.color = RGBA(96, 255, 96, 255);
        textView.colored = TRUE;
        textView.timed = FALSE;

        ViewPtr_AddTextView(Ninja_PickLockHelper_ptrTextViewLastBg, Ninja_PickLockHelper_ptrTextViewLast);
        ViewPtr_AddTextView(Ninja_PickLockHelper_ptrTextViewBg, Ninja_PickLockHelper_ptrTextView);
    };
    if(!Ninja_PickLockHelper_DisplayIsShown) {
        Ninja_PickLockHelper_DisplayIsShown = 1;
        textViewLast = _^(Ninja_PickLockHelper_ptrTextViewLast);
        textViewLast.text = Ninja_PickLockHelper_pickLockString_Last;

        ViewPtr_Open(Ninja_PickLockHelper_ptrTextViewLastBg);
        ViewPtr_Open(Ninja_PickLockHelper_ptrTextViewBg);
    };
    textView = _^(Ninja_PickLockHelper_ptrTextView);
    textView.text = text;
};

func void Ninja_PickLockHelper_RemoveText() {
    Ninja_PickLockHelper_pickLockString_Current = "";
    if(Ninja_PickLockHelper_ptrTextViewBg) {
        ViewPtr_Close(Ninja_PickLockHelper_ptrTextViewBg);
    };
    if(Ninja_PickLockHelper_ptrTextViewLastBg) {
        ViewPtr_Close(Ninja_PickLockHelper_ptrTextViewLastBg);
    };
    Ninja_PickLockHelper_DisplayIsShown = 0;
};

func void Ninja_PickLockHelper_HOOK_MOBCONTAINER_PICKLOCK() {
    var oCNPC slf;
    slf = _^(MEM_ReadInt(ESP + 4));
    
    // Cancel if it isn't the player
    if(!NPC_IsPlayer(slf)) { return; };

    var oCMobLockable mob;
    mob = _^(ECX);

    var int c;
    c = MEM_ReadInt(ESP + 8);
    
    var string pickLockString;
    
    var int currCharCount;
    currCharCount =(mob.bitfield & oCMobLockable_bitfield_pickLockNr) >> 2;
    
    // Get current picklock string + 1
    currCharCount += 1;
    if(currCharCount > 0)
    {
        pickLockString = STR_Prefix(mob.pickLockStr, currCharCount);
    };

    // Compare players attempt with current picklock string + 1
    if(c == 76) {
        if(Hlp_StrCmp(ConcatStrings(Ninja_PickLockHelper_pickLockString_Current, "L"), pickLockString))
        {
            Ninja_PickLockHelper_pickLockString_Current = pickLockString;
        };
    } else if(c == 82) {
        if(Hlp_StrCmp(ConcatStrings(Ninja_PickLockHelper_pickLockString_Current, "R"), pickLockString))
        {
            Ninja_PickLockHelper_pickLockString_Current = pickLockString;
        };
    };

    // If successfull then remember it :)
    if (STR_Len (Ninja_PickLockHelper_pickLockString_Current) > STR_Len (Ninja_PickLockHelper_pickLockString_Last))
    {
        Ninja_PickLockHelper_pickLockString_Last = Ninja_PickLockHelper_pickLockString_Current;
    };
    Ninja_PickLockHelper_DisplayText(Ninja_PickLockHelper_pickLockString_Current);
};


func void Ninja_PickLockHelper_HOOK_MOBINTER_STARTINTERACTION() {
    var oCNPC slf;
    slf = _^(MEM_ReadInt(ESP + 4));
    
    if (NPC_IsPlayer(slf) && Hlp_Is_oCMobLockable(ECX))
    {
        var oCMobLockable mob;
        mob = _^(ECX);
        
        if (!(mob.bitfield & oCMobLockable_bitfield_locked)) {
            return; // Already unlocked
        };

        // Reset for new mob
        if (STR_Len(Ninja_PickLockHelper_pickLockString_Last) > 0)
        {
            if (Ninja_PickLockHelper_pickLockString_Mob != ECX)
            {
                Ninja_PickLockHelper_pickLockString_Current = "";
                Ninja_PickLockHelper_pickLockString_Last = "";
            };
        };
        
        Ninja_PickLockHelper_pickLockString_Mob = ECX;
        
        // Update for lock which was already partially picklocked
        var int currCharCount;
        currCharCount = (mob.bitfield & oCMobLockable_bitfield_pickLockNr) >> 2;

        if (currCharCount > 0)
        {
            Ninja_PickLockHelper_pickLockString_Current = STR_Prefix(mob.pickLockStr, currCharCount);
        } else {
            Ninja_PickLockHelper_pickLockString_Current = "";
        };

        // Open view
        Ninja_PickLockHelper_DisplayText(Ninja_PickLockHelper_pickLockString_Current);
    };
};

func void Ninja_PickLockHelper_HOOK_MOBINTER_ENDINTERACTION() {
    var oCNPC slf;
    slf = _^(MEM_ReadInt(ESP + 4));
    
    if(NPC_IsPlayer(slf) && Hlp_Is_oCMobLockable(ECX))
    {
        Ninja_PickLockHelper_RemoveText();
    };    
};

/// Hooked G_PickLock to reset Ninja_PickLockHelper_pickLockString_Current on success or broken lockpick
func void Ninja_PickLockHelper_G_PickLock(var int bSuccess, var int bBrokenOpen) {
    PassArgumentI(bSuccess);
    PassArgumentI(bBrokenOpen);
    ContinueCall();
    
    var zCViewText textView;
    var zCViewText textViewLast;
    if (bSuccess && bBrokenOpen) {
        Ninja_PickLockHelper_RemoveText();
    } else if(!bSuccess) {
        textView = _^(Ninja_PickLockHelper_ptrTextView);
        textViewLast = _^(Ninja_PickLockHelper_ptrTextViewLast);

        Ninja_PickLockHelper_pickLockString_Current = "";
        textView.text = Ninja_PickLockHelper_pickLockString_Current;
        textViewLast.text = Ninja_PickLockHelper_pickLockString_Last;
    };
};

func void Ninja_PickLockHelper_Init_Internal() {
    //00682990  .text     Debug data           ?PickLock@oCMobLockable@@MAEHPAVoCNpc@@D@Z
    const int oCMobLockable__PickLock_G1 = 6826384;
    //0x00724800 protected: virtual int __thiscall oCMobLockable::PickLock(class oCNpc *,char)
    const int oCMobLockable__PickLock_G2 = 7489536;

    //0067FFD0  .text     Debug data           ?EndInteraction@oCMobInter@@UAEXPAVoCNPC@@H@Z
    const int oCMobInter__EndInteraction_G1 = 6815696;
    //0x00721950 public: virtual void __thiscall oCMobInter::EndInteraction(class oCNpc *,int)
    const int oCMobInter__EndInteraction_G2 = 7477584;

    //00680250  .text     Debug data           ?StopInteraction@oCMobInter@@UAEXPAVoCNPC@@@Z
    const int oCMobInter__StopInteraction_G1 = 6816336;
    //0x00721C20 public: virtual void __thiscall oCMobInter::StopInteraction(class oCNpc *)
    const int oCMobInter__StopInteraction_G2 = 7478304;

    //0067FCA0  .text     Debug data           ?StartInteraction@oCMobInter@@MAEXPAVoCNPC@@@Z
    const int oCMobInter__StartInteraction_G1 = 6814880;
    //0x00721580 protected: virtual void __thiscall oCMobInter::StartInteraction(class oCNpc *)
    const int oCMobInter__StartInteraction_G2 = 7476608;

    // Check if function even exists before anything
    if (MEM_FindParserSymbol("G_PickLock") != -1) {
        LeGo_MergeFlags(LeGo_Interface | LeGo_View); // https://lego.worldofplayers.de/?Interface
        
        HookEngine(MEMINT_SwitchG1G2(oCMobInter__StartInteraction_G1, oCMobInter__StartInteraction_G2), 6, "Ninja_PickLockHelper_HOOK_MOBINTER_STARTINTERACTION");
        HookEngine(MEMINT_SwitchG1G2(oCMobInter__EndInteraction_G1  , oCMobInter__EndInteraction_G2  ), 6, "Ninja_PickLockHelper_HOOK_MOBINTER_ENDINTERACTION"  );
        HookEngine(MEMINT_SwitchG1G2(oCMobInter__StopInteraction_G1 , oCMobInter__StopInteraction_G2 ), 6, "Ninja_PickLockHelper_HOOK_MOBINTER_ENDINTERACTION"  );

        if(MEMINT_SwitchG1G2(1, 0)) {
            Ninja_PickLockHelper_Font = "FONT_OLD_10_WHITE.TGA";
            HookEngine(oCMobLockable__PickLock_G1, 13, "Ninja_PickLockHelper_HOOK_MOBCONTAINER_PICKLOCK");
        } else {
            Ninja_PickLockHelper_Font = "FONT_OLD_10_WHITE.TGA";
            HookEngine(oCMobLockable__PickLock_G2, 6, "Ninja_PickLockHelper_HOOK_MOBCONTAINER_PICKLOCK");
        };
        HookDaedalusFuncS("G_PickLock", "Ninja_PickLockHelper_G_PickLock");
        MEM_Info("PickLockHelper 1.3 was initialized successfully.");
    } else {
         // Warning without stack trace
        MEM_SendToSpy(zERR_TYPE_WARN, "PickLockHelper 1.3 failed to initialize. Symbol 'G_PickLock' not found.");
    };
};
