var int Ninja_PickLockHelper_pickLockString_Mob;        // Mob identification
var string Ninja_PickLockHelper_pickLockString_Last;    // Last successfully tested picklock string
var string Ninja_PickLockHelper_pickLockString_Current; // Current picklock string

var int Ninja_PickLockHelper_hTextView;
var int Ninja_PickLockHelper_hTextViewLast;
var int Ninja_PickLockHelper_hTextViewLastBg;
var int Ninja_PickLockHelper_hTextViewBg;
var string Ninja_PickLockHelper_Font;

func void Ninja_PickLockHelper_DisplayText(var string text) {
    var zCViewText textView;
    var zCViewText textViewLast;
    
    if(!Ninja_PickLockHelper_hTextView) {
        const string maxText = "________________________________________";
        var int posX; posX = (PS_VMax - Print_ToVirtual(Print_GetStringWidth(maxText, Ninja_PickLockHelper_Font), PS_X)) / 2;

        Ninja_PickLockHelper_hTextViewLastBg = View_Create(posX, 400, 1, 1);
        View_ResizePxl(Ninja_PickLockHelper_hTextViewLastBg, Print_GetStringWidth(maxText, Ninja_PickLockHelper_Font), Print_GetFontHeight(Ninja_PickLockHelper_Font));
        View_SetTexture(Ninja_PickLockHelper_hTextViewLastBg, "Black.tga");
        View_SetAlpha(Ninja_PickLockHelper_hTextViewLastBg, 128);

        Ninja_PickLockHelper_hTextViewBg = View_Create(posX, 400, 1, 1);
        View_ResizePxl(Ninja_PickLockHelper_hTextViewBg, Print_GetStringWidth(maxText, Ninja_PickLockHelper_Font), Print_GetFontHeight(Ninja_PickLockHelper_Font));

        // Previous progress
        Ninja_PickLockHelper_hTextViewLast = Print_CreateText(Ninja_PickLockHelper_pickLockString_Last, Ninja_PickLockHelper_Font);
        textViewLast = Print_GetText(Ninja_PickLockHelper_hTextViewLast);
        textViewLast.posx = 300;
        textViewLast.color = RGBA(255, 255, 255, 128);
        textViewLast.colored = TRUE;
        textViewLast.timed = FALSE;


        // Current progress
        Ninja_PickLockHelper_hTextView = Print_CreateText(text, Ninja_PickLockHelper_Font);
        textView = Print_GetText(Ninja_PickLockHelper_hTextView);
        // textView.color = RGBA(255, 32, 82, 255);
        textView.posx = 300;
        textView.color = RGBA(96, 255, 96, 255);
        textView.colored = TRUE;
        textView.timed = FALSE;

        View_AddTextView(Ninja_PickLockHelper_hTextViewLastBg, MEM_InstToPtr(textViewLast));
        View_AddTextView(Ninja_PickLockHelper_hTextViewBg, MEM_InstToPtr(textView));

        View_Open(Ninja_PickLockHelper_hTextViewLastBg);
        View_Open(Ninja_PickLockHelper_hTextViewBg);
    } else {        
        textView = Print_GetText(Ninja_PickLockHelper_hTextView);
        textView.text = text;
    };
    
    // Print_Ext(150, 400, text, Ninja_PickLockHelper_Font, RGBA(255,32,82,255), 3000);
};

func void Ninja_PickLockHelper_RemoveText() {
    Ninja_PickLockHelper_pickLockString_Current = "";
    if(Ninja_PickLockHelper_hTextView) {
        Print_DeleteText(Ninja_PickLockHelper_hTextView);
        Ninja_PickLockHelper_hTextView = 0;

        Print_DeleteText(Ninja_PickLockHelper_hTextViewLast);
        Ninja_PickLockHelper_hTextViewLast = 0;

        View_Delete(Ninja_PickLockHelper_hTextViewBg);
        Ninja_PickLockHelper_hTextViewBg = 0;

        View_Delete(Ninja_PickLockHelper_hTextViewLastBg);
        Ninja_PickLockHelper_hTextViewLastBg = 0;
    };
};

func void Ninja_PickLockHelper_HOOK_MOBCONTAINER_PICKLOCK()
{
    var oCNPC slf;
    slf = _^(MEM_ReadInt(ESP + 4));
    
    // Cancel if it isn't the player
    if(!NPC_IsPlayer(slf)) { return; };

    var oCMobLockable mob;
    mob = _^(ECX);

    var int c;
    c = MEM_ReadInt(ESP + 8);
    
    var string Ninja_PickLockHelper_pickLockString;
    
    var int currCharCount;
    currCharCount =(mob.bitfield & oCMobLockable_bitfield_pickLockNr) >> 2;
    
    // Get current picklock string + 1
    currCharCount += 1;
    if(currCharCount > 0)
    {
        Ninja_PickLockHelper_pickLockString = STR_Prefix(mob.pickLockStr, currCharCount);
    };

    // Compare players attempt with current picklock string + 1
    if(c == 76) {
        if(Hlp_StrCmp(ConcatStrings(Ninja_PickLockHelper_pickLockString_Current, "L"), Ninja_PickLockHelper_pickLockString))
        {
            Ninja_PickLockHelper_pickLockString_Current = Ninja_PickLockHelper_pickLockString;
        };
    } else if(c == 82) {
        if(Hlp_StrCmp(ConcatStrings(Ninja_PickLockHelper_pickLockString_Current, "R"), Ninja_PickLockHelper_pickLockString))
        {
            Ninja_PickLockHelper_pickLockString_Current = Ninja_PickLockHelper_pickLockString;
        };
    };

    // If successfull then remember it :)
    if (STR_Len (Ninja_PickLockHelper_pickLockString_Current) > STR_Len (Ninja_PickLockHelper_pickLockString_Last))
    {
        Ninja_PickLockHelper_pickLockString_Last = Ninja_PickLockHelper_pickLockString_Current;
    };
    Ninja_PickLockHelper_DisplayText(Ninja_PickLockHelper_pickLockString_Current);
};


func void Ninja_PickLockHelper_HOOK_MOBINTER_STARTINTERACTION()
{
    var oCNPC slf;
    slf = _^(MEM_ReadInt(ESP + 4));
    
    if (NPC_IsPlayer(slf) && Hlp_Is_oCMobLockable(ECX))
    {
        var oCMobLockable mob;
        mob = _^(ECX);
        
        if (!(mob.bitfield & oCMobLockable_bitfield_locked)) {
            return; // Already unlocked
        }

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

func void Ninja_PickLockHelper_HOOK_MOBINTER_ENDINTERACTION()
{
    var oCNPC slf;
    slf = _^(MEM_ReadInt(ESP + 4));
    
    if(NPC_IsPlayer(slf) && Hlp_Is_oCMobLockable(ECX))
    {
        Ninja_PickLockHelper_RemoveText();
    };    
};

func void Ninja_PickLockHelper_HOOK_MOBINTER_STOPINTERACTION()
{
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
        textView = Print_GetText(Ninja_PickLockHelper_hTextView);
        textViewLast = Print_GetText(Ninja_PickLockHelper_hTextViewLast);

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

    LeGo_MergeFlags(LeGo_Interface | LeGo_View); // https://lego.worldofplayers.de/?Interface
    
    HookEngine(MEMINT_SwitchG1G2(oCMobInter__StartInteraction_G1, oCMobInter__StartInteraction_G2), 6, "Ninja_PickLockHelper_HOOK_MOBINTER_STARTINTERACTION");
    HookEngine(MEMINT_SwitchG1G2(oCMobInter__EndInteraction_G1  , oCMobInter__EndInteraction_G2  ), 6, "Ninja_PickLockHelper_HOOK_MOBINTER_ENDINTERACTION"  );
    HookEngine(MEMINT_SwitchG1G2(oCMobInter__StopInteraction_G1 , oCMobInter__StopInteraction_G2 ), 6, "Ninja_PickLockHelper_HOOK_MOBINTER_STOPINTERACTION" );

    if(MEMINT_SwitchG1G2(1, 0)) {
        Ninja_PickLockHelper_Font = "FONT_OLD_10_WHITE.TGA";
        HookEngine(oCMobLockable__PickLock_G1, 13, "Ninja_PickLockHelper_HOOK_MOBCONTAINER_PICKLOCK");
    } else {
        Ninja_PickLockHelper_Font = TEXT_FONT_DEFAULT;
        HookEngine(oCMobLockable__PickLock_G2, 6, "Ninja_PickLockHelper_HOOK_MOBCONTAINER_PICKLOCK");
    };
    HookDaedalusFuncS("G_PickLock", "Ninja_PickLockHelper_G_PickLock");
    MEM_Info("PickLockHelper was initialized successfully.");
};
