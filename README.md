# Digital Combination Lock

A fully modular digital combination lock implemented in SystemVerilog, designed for FPGA or simulation. This project demonstrates finite state machines, input handling, sequence tracking, and visual output.  

## Features

- **8-step combination lock**: progresses through stages LS0–LS7, unlocks to `OPEN`, triggers `ALARM` on wrong input.  
- **Push-button input**: 20 buttons mapped to 5 logical keys.  
- **Sequence tracking**: 8-bit shift register records input for verification.  
- **Visual feedback**:
  - Blue LED indicates sequence progress  
  - Green LED signals unlock  
  - Red LED flashes on incorrect input  
  - 7-segment display shows “SeCuRE”, “OPEN”, or “CALL 911”
  - Decimal Points show current position of key sequence

## Modules

- `top` — integrates all components  
- `fsm` — handles lock state transitions  
- `sequence_sr` — tracks button sequences  
- `keysync` — compresses button inputs  
- `clock_psc` — generates slower strobes for human interaction  
- `display` — drives LEDs and 7-segment output  

## Usage

- Connect push-buttons to `pb[20:0]` and observe `ss0`–`ss7` and LEDs for lock status.  
- Provide a 100 Hz clock (`hz100`) and reset (`reset`) to operate.  

This design highlights **modular hardware design and interactive digital logic**, suitable for both learning and demonstration purposes.
