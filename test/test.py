import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    # Test cases
    test_cases = [
        (0b00000000, 0b00000000),  # 0 + 0 = 0
        (0b00000001, 0b00000001),  # 1 + 1 = 2
        (0b00001111, 0b00001111),  # 15 + 15 = 30
        (0b11111111, 0b00000001),  # 255 + 1 = 256 (Cout = 1)
        (0b11110000, 0b00001111),  # 240 + 15 = 255
    ]

    for A, B in test_cases:
        dut.ui_in.value = A
        dut.uio_in.value = B
        await ClockCycles(dut.clk, 1)  # Wait for the result

        expected_sum = (A + B) & 0xFF  # 8-bit sum
        expected_cout = (A + B) >> 8   # Carry-out

        assert dut.uo_out.value == expected_sum, f"Sum mismatch: {dut.uo_out.value} != {expected_sum}"
        assert dut.uio_out.value == expected_cout, f"Cout mismatch: {dut.uio_out.value} != {expected_cout}"

        dut._log.info(f"Test {A} + {B}: Sum = {dut.uo_out.value}, Cout = {dut.uio_out.value}")

    dut._log.info("All tests passed!")
