// Wait for interrupt.
// This will put the processor into a low power state until an interrupt occurs.
pub inline fn wfi() void {
    asm volatile ("wfi");
}

// Wait for event.
// This will put the processor into a low power state until an event occurs.
pub inline fn wfe() void {
    // 6.5.2.22 PFIC System Control Register (PFIC_SCTLR)
    const PFIC_SCTLR: *volatile u32 = @ptrFromInt(0xE000ED10);
    // WFITOWFE. Execute the WFI command as if it were a WFE.
    PFIC_SCTLR.* |= @as(u32, 1 << 3);
    asm volatile ("wfi");
}

// Return the Machine Scratch Register (MSCRATCH)
pub inline fn getMscratch() u32 {
    return asm ("csrr %[out], mscratch"
        : [out] "=r" (-> u32),
    );
}

// Return the Machine Status Register (MSTATUS)
pub inline fn getMstatus() u32 {
    return asm ("csrr %[out], mstatus"
        : [out] "=r" (-> u32),
    );
}

// Return the Machine Exception Program Register (MEPC)
pub inline fn getMepc() u32 {
    return asm ("csrr %[out], mepc"
        : [out] "=r" (-> u32),
    );
}

// Return the Machine Cause Register (MCAUSE)
pub inline fn getMcause() u32 {
    return asm ("csrr %[out], mcause"
        : [out] "=r" (-> u32),
    );
}

// Return the Machine Trap Value Register (MTVAL)
pub inline fn getMtval() u32 {
    return asm ("csrr %[out], mtval"
        : [out] "=r" (-> u32),
    );
}
