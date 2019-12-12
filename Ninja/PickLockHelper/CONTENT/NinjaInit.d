/// Init-function called by Ninja
func void Ninja_PickLockHelper_Init() {
	// Initialize Ikarus
	MEM_InitAll();
	Ninja_PickLockHelper_Init_Internal();
};
