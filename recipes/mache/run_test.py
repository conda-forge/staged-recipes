#!/usr/bin/env python
from mache import MachineInfo, discover_machine

machine = discover_machine()

machinfo = MachineInfo(machine='anvil')
print(machinfo)

machinfo = MachineInfo(machine='unknown')
print(machinfo)

