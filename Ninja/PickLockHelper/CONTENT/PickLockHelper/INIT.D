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


var int pickLockString_Mob;        // Mob identification
var string pickLockString_Last;    // Last successfully tested picklock string
var string pickLockString_Current; // Current picklock string

var int PickLockHelper_hTextView;
var int PickLockHelper_hTextViewLast;
var int PickLockHelper_hTextViewLastBg;
var int PickLockHelper_hTextViewBg;

func void PickLockHelper_DisplayText(var string text) {
    var zCViewText textView;
    var zCViewText textViewLast;
    
    if(!PickLockHelper_hTextView) {
        const string maxText = "________________________________________";
        var int posX; posX = (PS_VMax - Print_ToVirtual(Print_GetStringWidth(maxText, TEXT_FONT_DEFAULT), PS_X)) / 2;

        PickLockHelper_hTextViewLastBg = View_Create(posX, 400, 1, 1);
        View_ResizePxl(PickLockHelper_hTextViewLastBg, Print_GetStringWidth(maxText, TEXT_FONT_DEFAULT), Print_GetFontHeight(TEXT_FONT_DEFAULT));
        View_SetTexture(PickLockHelper_hTextViewLastBg, "Black.tga");
        View_SetAlpha(PickLockHelper_hTextViewLastBg, 128);

        PickLockHelper_hTextViewBg = View_Create(posX, 400, 1, 1);
        View_ResizePxl(PickLockHelper_hTextViewBg, Print_GetStringWidth(maxText, TEXT_FONT_DEFAULT), Print_GetFontHeight(TEXT_FONT_DEFAULT));

        // Previous progress
        PickLockHelper_hTextViewLast = Print_CreateText(pickLockString_Last, TEXT_FONT_DEFAULT);
        textViewLast = Print_GetText(PickLockHelper_hTextViewLast);
        textViewLast.posx = 300;
        textViewLast.color = RGBA(255, 255, 255, 128);
        textViewLast.colored = TRUE;
        textViewLast.timed = FALSE;


        // Current progress
        PickLockHelper_hTextView = Print_CreateText(text, TEXT_FONT_DEFAULT);
        textView = Print_GetText(PickLockHelper_hTextView);
        // textView.color = RGBA(255, 32, 82, 255);
        textView.posx = 300;
        textView.color = RGBA(96, 255, 96, 255);
        textView.colored = TRUE;
        textView.timed = FALSE;

        View_AddTextView(PickLockHelper_hTextViewLastBg, MEM_InstToPtr(textViewLast));
        View_AddTextView(PickLockHelper_hTextViewBg, MEM_InstToPtr(textView));

        View_Open(PickLockHelper_hTextViewLastBg);
        View_Open(PickLockHelper_hTextViewBg);
    } else {        
        textView = Print_GetText(PickLockHelper_hTextView);
        textView.text = text;
    };
    
    // Print_Ext(150, 400, text, TEXT_FONT_DEFAULT, RGBA(255,32,82,255), 3000);
};

func void PickLockHelper_RemoveText() {
    pickLockString_Current = "";
    if(PickLockHelper_hTextView) {
		Print_DeleteText(PickLockHelper_hTextView);
		PickLockHelper_hTextView = 0;

        Print_DeleteText(PickLockHelper_hTextViewLast);
		PickLockHelper_hTextViewLast = 0;

        View_Delete(PickLockHelper_hTextViewBg);
        PickLockHelper_hTextViewBg = 0;

        View_Delete(PickLockHelper_hTextViewLastBg);
        PickLockHelper_hTextViewLastBg = 0;
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
        if(Hlp_StrCmp(ConcatStrings(pickLockString_Current, "L"), pickLockString))
        {
            pickLockString_Current = pickLockString;
        };
    } else if(c == 82) {
        if(Hlp_StrCmp(ConcatStrings(pickLockString_Current, "R"), pickLockString))
        {
            pickLockString_Current = pickLockString;
        };
    };

    // If successfull then remember it :)
    if (STR_Len (pickLockString_Current) > STR_Len (pickLockString_Last))
    {
        pickLockString_Last = pickLockString_Current;
    };
    PickLockHelper_DisplayText(pickLockString_Current);
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
        if (STR_Len(pickLockString_Last) > 0)
        {
            if (pickLockString_Mob != ECX)
            {
                pickLockString_Current = "";
                pickLockString_Last = "";
            };
        };
        
        pickLockString_Mob = ECX;
        
        // Update for lock which was already partially picklocked
        var int currCharCount;
        currCharCount = (mob.bitfield & oCMobLockable_bitfield_pickLockNr) >> 2;

        if (currCharCount > 0)
        {
            pickLockString_Current = STR_Prefix(mob.pickLockStr, currCharCount);
        } else {
            pickLockString_Current = "";
        };

        // Open view
        PickLockHelper_DisplayText(pickLockString_Current);
    };
};

func void Ninja_PickLockHelper_HOOK_MOBINTER_ENDINTERACTION()
{
    var oCNPC slf;
    slf = _^(MEM_ReadInt(ESP + 4));
    
    if(NPC_IsPlayer(slf) && Hlp_Is_oCMobLockable(ECX))
    {
		PickLockHelper_RemoveText();
    };    
};

func void Ninja_PickLockHelper_HOOK_MOBINTER_STOPINTERACTION()
{
    var oCNPC slf;
    slf = _^(MEM_ReadInt(ESP + 4));
    
    if(NPC_IsPlayer(slf) && Hlp_Is_oCMobLockable(ECX))
    {
        PickLockHelper_RemoveText();
    };
};

/// Hooked G_PickLock to reset pickLockString_Current on success or broken lockpick
func void Ninja_PickLockHelper_G_PickLock(var int bSuccess, var int bBrokenOpen) {
    PassArgumentI(bSuccess);
    PassArgumentI(bBrokenOpen);
    ContinueCall();
    
    var zCViewText textView;
    var zCViewText textViewLast;
    if (bSuccess && bBrokenOpen) {
        PickLockHelper_RemoveText();
    } else if(!bSuccess) {
        textView = Print_GetText(PickLockHelper_hTextView);
        textViewLast = Print_GetText(PickLockHelper_hTextViewLast);

        pickLockString_Current = "";
        textView.text = pickLockString_Current;
        textViewLast.text = pickLockString_Last;
    };
};

/// Init-function called by Ninja
func void PickLockHelper_Init() {
	// Initialize Ikarus
	MEM_InitAll();
	LeGo_MergeFlags(LeGo_Interface | LeGo_PrintS | LeGo_AI_Function | LeGo_PermMem | LeGo_Anim8 | LeGo_View); // https://lego.worldofplayers.de/?Interface
	
	HookEngine(MEMINT_SwitchG1G2(oCMobInter__StartInteraction_G1, oCMobInter__StartInteraction_G2), 6, "Ninja_PickLockHelper_HOOK_MOBINTER_STARTINTERACTION");
	HookEngine(MEMINT_SwitchG1G2(oCMobInter__EndInteraction_G1  , oCMobInter__EndInteraction_G2  ), 6, "Ninja_PickLockHelper_HOOK_MOBINTER_ENDINTERACTION"  );
	HookEngine(MEMINT_SwitchG1G2(oCMobInter__StopInteraction_G1 , oCMobInter__StopInteraction_G2 ), 6, "Ninja_PickLockHelper_HOOK_MOBINTER_STOPINTERACTION" );

	if(MEMINT_SwitchG1G2(1, 0)) {
		HookEngine(oCMobLockable__PickLock_G1, 13, "Ninja_PickLockHelper_HOOK_MOBCONTAINER_PICKLOCK");
	} else {
		HookEngine(oCMobLockable__PickLock_G2, 6, "Ninja_PickLockHelper_HOOK_MOBCONTAINER_PICKLOCK");
	};
    HookDaedalusFuncS("G_PickLock", "Ninja_PickLockHelper_G_PickLock");
    MEM_Info("PickLockHelper was initialized successfully.");
};
