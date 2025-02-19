import argparse
import contextlib
import logging
import os
import platform
import shutil
import signal
import subprocess
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Protocol, Optional, AsyncGenerator, runtime_checkable, Callable, Awaitable, Dict, List
import asyncio

#    .----------------.
# ---| QMPClient Mock |---
#    '----------------'

try:
    from qemu.qmp import QMPClient as RealQMPClient
    USE_REAL_QMP = True
except ImportError:
    USE_REAL_QMP = False

def get_qmp_client(dry_run: bool = False):
    """Get appropriate QMP client based on mode"""
    return QMPClient if dry_run or not USE_REAL_QMP else RealQMPClient

class QMPClient:
    """Mock QMP Client base class"""
    def __init__(self, name: str):
        self.name = name
        self._connected = False

    def is_connected(self) -> bool:
        return self._connected

    async def connect(self, socket_path: str) -> None:
        self._connected = True
        print(f"[Mock QMP] Connected to {socket_path}")

    async def disconnect(self) -> None:
        self._connected = False
        print("[Mock QMP] Disconnected")

    async def execute(self, command: str, arguments: dict = None) -> dict:
        print(f"[Mock QMP] Executing: {command} with args: {arguments}")
        return {"status": "running"}

    @property
    async def events(self):
        while False:  # Never yields anything in dry run
            yield {}


#    .----------------.
# ---| Core Protocols |---
#    '----------------'

@runtime_checkable
class MainProtocol(Protocol):
    """Required attributes for process management"""
    async def setup_vm(self) -> bool: ...

    async def run_command(self, command: str, load_snapshot: bool = True) -> tuple[str, str, int]: ...


@runtime_checkable
class QMPProtocol(Protocol):
    """Required attributes for QMP communication"""

    @property
    def qmp(self) -> QMPClient: ...

    @property
    def socket_path(self) -> str: ...

    async def connect_qmp(self) -> bool: ...

    async def execute_qmp(self, command: str, arguments: Optional[dict] = None) -> dict: ...

    def cleanup_qmp_socket(self: MainProtocol) -> bool: ...

@runtime_checkable
class QEMUProtocol(Protocol):
    """Required attributes for QEMU process management"""
    @property
    def qemu_system(self) -> str: ...

    @property
    def qemu_process(self) -> Optional[asyncio.subprocess.Process]: ...

    def build_qemu_command(self, load_snapshot: Optional[str] = None) -> tuple[list[str], str]: ...

    async def start_process(self, load_snapshot: Optional[str] = None) -> bool: ...

    async def stop_process(self) -> None: ...

@runtime_checkable
class SSHProtocol(Protocol):
    @property
    def ssh_port(self) -> int: ...

    @staticmethod
    async def generate_ssh_key() -> bool: ...

    async def wait_for_ssh(self, max_attempts: int = 30, delay: int = 10) -> bool: ...

    async def execute_ssh_command(self, command: str) -> tuple[str, str, int]: ...


@runtime_checkable
class MonitoringProtocol(Protocol):
    async def monitor_output(self, stream: asyncio.StreamReader, name: str) -> None: ...

    async def monitor_log_file(self: QEMUProtocol, log_file: str): ...

    async def check_vm_boot_log(self: QMPProtocol) -> None: ...

    async def check_console_log(self) -> None: ...

@runtime_checkable
class ISOProtocol(Protocol):
    @property
    def custom_iso_path(self) -> Optional[str]: ...

    @staticmethod
    async def create_alpine_overlay() -> str: ...

    async def create_custom_alpine_iso(self, overlay_file: str) -> str: ...

    async def extract_kernel_from_iso(self, iso_path: str) -> str: ...

@runtime_checkable
class SnapshotProtocol(Protocol):
    """Required attributes for snapshot management"""
    @property
    def current_snapshot(self) -> str: ...

    async def list_snapshots(self) -> dict: ...

    async def save_snapshot(self, name: str) -> bool: ...

    async def load_snapshot(self, name: str) -> bool: ...

    async def delete_snapshot(self, name: str) -> bool: ...

    async def snapshot_exists(self, name: str) -> bool: ...

    async def ensure_snapshot(self, name: str, setup_func) -> bool: ...


#    .-----------------------.
# ---| Mixin Implementations |---
#    '-----------------------'

class ProcessManager:
    """Manages QEMU process lifecycle"""

    def __init__(self, pid_file: str = "qemu_pid.txt"):
        self.pid_file = pid_file

    def save_pid(self, pid: int) -> None:
        with open(self.pid_file, 'w') as f:
            f.write(str(pid))

    def read_pid(self) -> Optional[int]:
        try:
            with open(self.pid_file, 'r') as f:
                return int(f.read().strip())
        except (FileNotFoundError, ValueError):
            return None

    def cleanup_existing_process(self) -> None:
        if pid := self.read_pid():
            try:
                os.kill(pid, signal.SIGTERM)
                print(f"[Process]: Terminated existing QEMU process (PID: {pid})")
            except ProcessLookupError:
                pass
            except Exception as e:
                print(f"[Process]: Error terminating process: {e}")
            with contextlib.suppress(FileNotFoundError):
                os.remove(self.pid_file)


class QEMUQMPProtocol(
    QEMUProtocol,
    QMPProtocol,
    MonitoringProtocol,
    Protocol,
):
    """Combined Protocol for use in method annotations"""
    pass

class QEMUProcessMixin(QEMUProtocol):
    """QEMU process management functionality"""
    # Combined Protocol for use in method annotations
    class _SelfQMPProtocol(QEMUQMPProtocol, ISOProtocol, Protocol):
        """Combined protocol including both required attributes and mixin methods"""
        _qemu_system: str
        _qemu_process: Optional[asyncio.subprocess.Process]
        _qcow2_path: str
        _kernel_path: Optional[str]
        _custom_iso_path: Optional[str]
        _process_manager: ProcessManager


    def __init__(
            self,
            *,
            qemu_system: str,
            qcow2_path: str,
            kernel_path: Optional[str] = None,
            **kwargs,
    ):
        self._qemu_system = qemu_system
        self._qcow2_path = qcow2_path
        self._kernel_path = kernel_path

        self._process_manager = ProcessManager()
        self._qemu_process: Optional[asyncio.subprocess.Process] = None

    @property
    def qemu_system(self: _SelfQMPProtocol) -> str:
        return self._qemu_system

    @property
    def qemu_process(self: _SelfQMPProtocol) -> Optional[asyncio.subprocess.Process]:
        return self._qemu_process

    def build_qemu_command(self: _SelfQMPProtocol, load_snapshot: Optional[str] = None) -> tuple[list[str], str]:
        """Build QEMU command with proper parameters"""
        if not os.path.exists(self.qemu_system):
            raise FileNotFoundError(f"QEMU executable not found at {self.qemu_system}")

        # Create unique log file for this process
        log_file = f"qemu_console_{os.getpid()}.log"

        socket_dir = os.path.dirname(self.socket_path)
        os.makedirs(socket_dir, exist_ok=True)

        # Base command
        cmd = [
            self.qemu_system,
            "-name", f"QEMU User ({os.path.basename(self.qemu_system)})",
            "-M", "virt,secure=on",
            "-cpu", "cortex-a57",
            "-m", "2048",
            "-nographic",
            # Logging setup
            "-D", log_file,
            "-d", "guest_errors,unimp",
            "-chardev", f"file,id=char0,path={log_file}",
            "-serial", "chardev:char0"
        ]

        # Add kernel if available
        if getattr(self, 'kernel_path', None) and os.path.exists(self._kernel_path):
            cmd.extend([
                "-kernel", self._kernel_path,
                "-append", "console=ttyAMA0 root=/dev/vda3 modules=loop,squashfs,sd-mod,usb-storage,ext4 quiet"
            ])

        # Drive configuration
        cmd.extend([
            "-device", "virtio-blk-pci,drive=hd0,addr=0x3",
            "-drive", f"file={self._qcow2_path},if=none,id=hd0,format=qcow2"
        ])

        # Add ISO if in setup mode
        if not load_snapshot and self.custom_iso_path:
            cmd.extend([
                "-device", "virtio-blk-pci,drive=cd0,addr=0x4",
                "-drive", f"file={self.custom_iso_path},if=none,id=cd0,format=raw,readonly=on"
            ])

        # QMP configuration
        cmd.extend([
            "-qmp", f"unix:{self.socket_path},server,nowait"
        ])

        # Platform-specific acceleration
        if platform.machine() == 'arm64':
            cmd.extend(["-accel", "hvf"])
        else:
            cmd.extend(["-accel", "tcg,thread=single"])

        # Load snapshot if specified
        if load_snapshot:
            cmd.extend(["-loadvm", load_snapshot])

        print(f"[QEMU]: Command: {' '.join(cmd)}")
        return cmd, log_file


    async def start_process(self: _SelfQMPProtocol, load_snapshot: Optional[str] = None) -> bool:
        """Start QEMU process with output monitoring"""
        try:
            # Build command and prepare log file
            cmd, log_file = self.build_qemu_command(load_snapshot)

            # Clean up any existing process or files
            self._process_manager.cleanup_existing_process()
            self.cleanup_qmp_socket()
            if os.path.exists(log_file):
                os.unlink(log_file)

            # Start QEMU process
            print("[QEMU]: Starting process...")
            self._qemu_process = await asyncio.create_subprocess_exec(
                *cmd,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )

            if self.qemu_process.returncode is not None:
                stdout, stderr = await self.qemu_process.communicate()
                print(f"[QEMU] Process failed:\nstdout: {stdout.decode()}\nstderr: {stderr.decode()}")
                return False

            # Save PID and start monitoring
            self._process_manager.save_pid(self.qemu_process.pid)
            print(f"[Process]: QEMU started with PID {self.qemu_process.pid}")

            return True

        except Exception as e:
            print(f"[Process]: Failed to start QEMU: {e}")
            return False

    async def stop_process(self: _SelfQMPProtocol) -> None:
        """Stop QEMU process and cleanup"""
        # Stop QEMU process
        if self.qemu_process:
            try:
                if self.qemu_process.returncode is None:
                    print("[Process]: Terminating QEMU process...")
                    self.qemu_process.terminate()
                    try:
                        await asyncio.wait_for(self.qemu_process.wait(), timeout=5)
                        print("[Process]: QEMU process terminated normally")
                    except asyncio.TimeoutError:
                        print("[Process]: Force killing QEMU process...")
                        self.qemu_process.kill()
                        await self.qemu_process.wait()
                        print("[Process]: QEMU process killed")
                else:
                    print(f"[Process]: QEMU process already exited with code {self.qemu_process.returncode}")
            except Exception as e:
                print(f"[Process]: Error during cleanup: {e}")

        # Cleanup socket
        self.cleanup_qmp_socket()


class QMPControlMixin:
    """QMP communication functionality"""

    class _SelfQMPProtocol(QEMUProtocol, QMPProtocol, Protocol):
        """Combined protocol including both required attributes and mixin methods"""
        _events_task: Optional[asyncio.Task]

        async def wait_qmp_socket(self, timeout: int = 30) -> bool: ...

        async def watch_events(self) -> AsyncGenerator[dict, None]: ...

    def __init__(
            self,
            *,
            socket_path: str = "/tmp/qmp_socket",
            **kwargs,
    ):
        self._socket_path = socket_path

        QMPClientClass = get_qmp_client(dry_run=False)
        self._qmp = QMPClientClass('ARM64 VM')

        self._events_task: Optional[asyncio.Task] = None

    @property
    def qmp(self) -> QMPClient:
        return self._qmp

    @property
    def socket_path(self) -> str:
        return self._socket_path

    def cleanup_qmp_socket(self: _SelfQMPProtocol):
        """Clean up the socket file if it exists"""
        try:
            if os.path.exists(self.socket_path):
                os.unlink(self.socket_path)
                print(f"[Socket]: Removed existing socket file: {self.socket_path}")
        except Exception as e:
            print(f"[Socket]: Error cleaning up socket: {e}")
            
    async def wait_qmp_socket(self: _SelfQMPProtocol, timeout: int = 30) -> bool:
        """Wait for QMP socket to become available"""
        start_time = asyncio.get_event_loop().time()
        while True:
            if os.path.exists(self.socket_path):
                with contextlib.suppress(Exception):
                    # Test if socket is actually ready
                    reader, writer = await asyncio.open_unix_connection(self.socket_path)
                    writer.close()
                    await writer.wait_closed()
                    print("[QMP]: Socket is ready for connection")
                    return True
            elapsed = asyncio.get_event_loop().time() - start_time
            if elapsed >= timeout:
                print(f"[QMP]: Socket timeout after {elapsed:.1f}s")
                return False

            if self.qemu_process and self.qemu_process.returncode is not None:
                print("[QMP]: QEMU process terminated while waiting for socket")
                return False

            await asyncio.sleep(1)
            if int(elapsed) % 5 == 0:
                print(f"[QMP]: Waiting for socket... ({int(elapsed)}s)")

    async def connect_qmp(self: _SelfQMPProtocol) -> bool:
        """Establish QMP connection with retries"""
        for attempt in range(5):
            try:
                if not await self.wait_qmp_socket(timeout=30):
                    raise TimeoutError("Socket not available")

                await self.qmp.connect(self.socket_path)
                print("[QMP]: Connected to socket")

                await asyncio.sleep(1)
                await self.qmp.execute('qmp_capabilities')
                print("[QMP]: Capabilities negotiated")

                # Start event monitoring
                self._events_task = asyncio.create_task(self.watch_events())
                return True

            except Exception as e:
                print(f"[QMP]: Connection attempt {attempt + 1} failed: {e}")
                if attempt < 4:
                    await asyncio.sleep(2 ** attempt)  # Exponential backoff

                if self.qmp.is_connected():
                    await self.qmp.disconnect()

        return False

    async def watch_events(self: _SelfQMPProtocol) -> AsyncGenerator[dict, None]:
        """Watch QMP events with error handling"""
        try:
            async for event in self.qmp.events:
                print(f"[QMP Event]: {event['event']}")
                yield event
        except asyncio.CancelledError:
            print("[QMP]: Event monitoring cancelled")
            return
        except Exception as e:
            print(f"[QMP]: Event monitoring error: {e}")
            return
        finally:
            print("[QMP]: Event monitoring stopped")

    async def execute_qmp(
            self: _SelfQMPProtocol,
            command: str,
            arguments: Optional[dict] = None
    ) -> dict:
        """Execute QMP command with error handling"""
        try:
            if not self.qmp.is_connected():
                print("[QMP]: Not connected, attempting reconnection...")
                if not await self.connect_qmp():
                    raise ConnectionError("Failed to establish QMP connection")

            return await self.qmp.execute(command, arguments or {})
        except Exception as e:
            error_msg = f"QMP command '{command}' failed: {e}"
            print(f"[QMP]: {error_msg}")
            raise RuntimeError(error_msg) from e

    async def check_vm_status(self: _SelfQMPProtocol) -> bool:
        """Check VM status via QMP"""
        try:
            status = await self.execute_qmp('query-status')
            running = status.get('status') == 'running'
            print(f"[QMP]: VM status: {'running' if running else 'not running'}")
            return running
        except Exception as e:
            print(f"[QMP]: Status check failed: {e}")
            return False

    async def cleanup_qmp(self: _SelfQMPProtocol) -> None:
        """Clean up QMP resources"""
        if self._events_task:
            self._events_task.cancel()
            with contextlib.suppress(asyncio.CancelledError):
                await self._events_task

        if self.qmp.is_connected():
            try:
                await self.qmp.execute('quit')
            except Exception as e:
                print(f"[QMP]: Quit command failed: {e}")
            finally:
                await self.qmp.disconnect()


class MonitoringMixin:
    """SSH functionality"""

    class _SelfMonitoringProtocol(
        MonitoringProtocol,
        QEMUProtocol,
        QMPProtocol,
        Protocol
    ):
        """Combined protocol including monitoring-specific attributes and methods"""
        _stdout_task: Optional[asyncio.Task]
        _stderr_task: Optional[asyncio.Task]
        _log_monitor_task: Optional[asyncio.Task]

    def __init__(self, **kwargs):
        self._stdout_task: Optional[asyncio.Task] = None
        self._stderr_task: Optional[asyncio.Task] = None
        self._log_monitor_task: Optional[asyncio.Task] = None

    async def start_monitoring(self: _SelfMonitoringProtocol) -> None:
        """Start all monitoring tasks"""
        if self.qemu_process:
            self._stdout_task = asyncio.create_task(
                self.monitor_output(self.qemu_process.stdout, "stdout")
            )
            self._stderr_task = asyncio.create_task(
                self.monitor_output(self.qemu_process.stderr, "stderr")
            )

    async def stop_monitoring(self) -> None:
        """Stop all monitoring tasks"""
        for task in [self._stdout_task, self._stderr_task, self._log_monitor_task]:
            if task:
                task.cancel()
                with contextlib.suppress(asyncio.CancelledError):
                    await task

    async def monitor_output(self, stream: asyncio.StreamReader, name: str) -> None:
        """Monitor QEMU output stream with improved error handling"""
        try:
            print(f"[Monitor]: Starting {name} monitoring...")
            while True:
                line = await stream.readline()
                if not line:
                    print(f"[Monitor]: {name} stream ended")
                    break
                print(f"[QEMU {name}]: {line.decode().strip()}")
        except asyncio.CancelledError:
            print(f"[Monitor]: {name} monitoring cancelled")
            raise
        except Exception as e:
            print(f"[Monitor]: Error monitoring {name}: {e}")
        finally:
            print(f"[Monitor]: {name} monitoring stopped")


    async def monitor_log_file(self: _SelfMonitoringProtocol, log_file: str) -> None:
        """Monitor QEMU log file with improved error handling"""
        try:
            print(f"[Monitor]: Starting log file monitoring: {log_file}")
            position = 0
            while True:
                # Check if process is still running
                if self.qemu_process.returncode is not None:
                    print("[Monitor]: QEMU process ended, stopping log monitoring")
                    break

                if not os.path.exists(log_file):
                    await asyncio.sleep(1)
                    continue

                try:
                    with open(log_file, 'r') as f:
                        f.seek(position)
                        if content := f.read():
                            print(f"[VM Console]:\n{content}")
                        position = f.tell()
                except FileNotFoundError:
                    print(f"[Monitor]: Log file not found: {log_file}")
                    break
                except IOError as e:
                    print(f"[Monitor]: Error reading log file: {e}")
                    await asyncio.sleep(5)  # Back off on errors
                    continue

                await asyncio.sleep(1)

        except asyncio.CancelledError:
            print("[Monitor]: Log monitoring cancelled")
            raise
        except Exception as e:
            print(f"[Monitor]: Log monitoring error: {e}")
        finally:
            print("[Monitor]: Log monitoring stopped")

    async def check_vm_boot_log(self: _SelfMonitoringProtocol) -> None:
        """Check VM boot log with enhanced error handling and QMP integration"""
        try:
            print("[Monitor]: Checking VM boot log...")

            # Check console log file
            if os.path.exists("console.log"):
                try:
                    with open("console.log", "r") as f:
                        log_content = f.read()
                        print("[Console Log]:")
                        print(log_content)
                except IOError as e:
                    print(f"[Monitor]: Error reading console log: {e}")

            # Try to get syslog from guest via QMP
            try:
                print("[Monitor]: Requesting guest syslog via QMP...")
                response = await self.execute_qmp(
                    'human-monitor-command',
                    {'command-line': 'guest-exec cat /var/log/messages'}
                )
                if response:
                    print("[Guest Syslog]:")
                    print(response)
            except Exception as e:
                print(f"[Monitor]: Failed to get guest syslog: {e}")

        except Exception as e:
            print(f"[Monitor]: Boot log check failed: {e}")

    async def check_console_log(self) -> None:
        """Check console log file with improved error handling"""
        try:
            if not os.path.exists("console.log"):
                print("[Monitor]: Console log file not found")
                return

            try:
                with open("console.log", "r") as f:
                    if content := f.read():
                        print("[Console Log]:")
                        print(content)
                    else:
                        print("[Console Log]: File is empty")
            except IOError as e:
                print(f"[Monitor]: Error reading console log: {e}")

        except Exception as e:
            print(f"[Monitor]: Console log check failed: {e}")


class SSHControlMixin(SSHProtocol):
    """SSH functionality"""

    class _SelfSSHProtocol(
        SSHProtocol,
        MonitoringProtocol,
        QMPProtocol,
        Protocol
    ):
        _ssh_port: int

    def __init__(
            self,
            *,
            ssh_port: int = 10022,
            **kwargs,
    ):
        self._ssh_port = ssh_port

    @property
    def ssh_port(self) -> int:
        return self._ssh_port

    @staticmethod
    async def generate_ssh_key() -> bool:
        """Generate SSH key if it doesn't exist"""
        ssh_key_path = "/Users/runner/.ssh/id_rsa"
        ssh_dir = os.path.dirname(ssh_key_path)

        try:
            # Create .ssh directory if it doesn't exist
            os.makedirs(ssh_dir, mode=0o700, exist_ok=True)

            if not os.path.exists(ssh_key_path):
                print("[SSH]: Generating new SSH key...")
                keygen_cmd = [
                    "ssh-keygen",
                    "-t", "rsa",
                    "-N", "",  # No passphrase
                    "-f", ssh_key_path
                ]
                process = await asyncio.create_subprocess_exec(
                    *keygen_cmd,
                    stdout=asyncio.subprocess.PIPE,
                    stderr=asyncio.subprocess.PIPE
                )
                stdout, stderr = await process.communicate()
                if process.returncode != 0:
                    print(f"[SSH]: Key generation failed: {stderr.decode()}")
                    return False
                print(f"[SSH]: Key generation output: {stdout.decode()}")

                # Set correct permissions
                os.chmod(ssh_key_path, 0o600)
                os.chmod(f"{ssh_key_path}.pub", 0o644)

            return True
        except Exception as e:
            print(f"[SSH]: Error during key generation: {e}")
            return False

    async def wait_for_ssh(self: _SelfSSHProtocol, max_attempts: int = 30, delay: int = 10) -> bool:
        """Wait for SSH with original working functionality"""
        print("[SSH]: Waiting for SSH service to become available...")

        # Ensure SSH key exists
        if not (await self.generate_ssh_key()):
            print("[SSH]: Failed to generate SSH key")
            return False

        for attempt in range(max_attempts):
            try:
                # Check VM status
                print(f"\n[Debug] Checking VM status (attempt {attempt + 1})...")
                await self.check_console_log()
                await self.check_vm_boot_log()

                # Try to connect with netcat first to check if port is open
                nc_cmd = [
                    "nc", "-zv", "-w", "5", "localhost", str(self.ssh_port)
                ]
                process = await asyncio.create_subprocess_exec(
                    *nc_cmd,
                    stdout=asyncio.subprocess.PIPE,
                    stderr=asyncio.subprocess.PIPE
                )
                stdout, stderr = await process.communicate()
                if process.returncode != 0:
                    print(f"[SSH]: Port {self.ssh_port} not ready (attempt {attempt + 1}/{max_attempts})")
                    await asyncio.sleep(delay)
                    continue

                # Try a test SSH connection
                test_cmd = [
                    "ssh",
                    "-p", str(self.ssh_port),
                    "-i", "/Users/runner/.ssh/id_rsa",
                    "-o", "StrictHostKeyChecking=no",
                    "-o", "UserKnownHostsFile=/dev/null",
                    "-o", "ConnectTimeout=5",
                    "-o", "BatchMode=yes",
                    "root@localhost",
                    "set -x; ps aux | grep sshd; netstat -tln; cat /var/log/messages | grep sshd || true"
                ]

                process = await asyncio.create_subprocess_exec(
                    *test_cmd,
                    stdout=asyncio.subprocess.PIPE,
                    stderr=asyncio.subprocess.PIPE
                )
                stdout, stderr = await process.communicate()

                if process.returncode == 0:
                    print("[SSH]: Service is now available")
                    return True

                print(f"[SSH]: Service not ready (attempt {attempt + 1}/{max_attempts})")
                print(f"[SSH]: stderr: {stderr.decode()}")
                await self.check_vm_boot_log()

            except Exception as e:
                print(f"[SSH]: Connection attempt {attempt + 1} failed: {e}")

            await asyncio.sleep(delay)

        return False

    async def execute_ssh_command(self: _SelfSSHProtocol, command: str) -> tuple[str, str, int]:
        """Execute command via SSH with original working functionality"""
        print("[DEBUG] Checking QEMU network info...")
        try:
            netinfo = await self.qmp.execute('human-monitor-command',
                                             {'command-line': 'info network'})
            print(f"[DEBUG] QEMU network info: {netinfo}")
        except Exception as e:
            print(f"[DEBUG] QEMU network info error: {e}")

        # Ensure SSH key exists
        ssh_key_path = "/Users/runner/.ssh/id_rsa"
        if not os.path.exists(ssh_key_path):
            await self.generate_ssh_key()

        # Try connecting multiple times
        for attempt in range(3):
            try:
                # Test SSH connection first
                test_cmd = [
                    "ssh",
                    "-p", str(self.ssh_port),
                    "-i", ssh_key_path,
                    "-o", "StrictHostKeyChecking=no",
                    "-o", "UserKnownHostsFile=/dev/null",
                    "-o", "ConnectTimeout=10",
                    "root@localhost",
                    "echo test"
                ]

                process = await asyncio.create_subprocess_exec(
                    *test_cmd,
                    stdout=asyncio.subprocess.PIPE,
                    stderr=asyncio.subprocess.PIPE
                )
                stdout, stderr = await process.communicate()
                if process.returncode == 0:
                    break
            except Exception as e:
                print(f"[SSH]: Connection attempt {attempt + 1} failed: {e}")
            await asyncio.sleep(10)

        # Execute actual command
        ssh_cmd = [
            "ssh",
            "-p", str(self.ssh_port),
            "-i", ssh_key_path,
            "-o", "StrictHostKeyChecking=no",
            "-o", "UserKnownHostsFile=/dev/null",
            "root@localhost",
            command
        ]

        print(f"[Command]: Executing via SSH: {command}")
        try:
            process = await asyncio.create_subprocess_exec(
                *ssh_cmd,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            stdout, stderr = await process.communicate()
            return stdout.decode(), stderr.decode(), process.returncode
        except Exception as e:
            print(f"[Command]: SSH Error: {e}")
            return "", str(e), 1


class AlpineISOBuilderMixin(ISOProtocol):
    """Alpine ISO customization functionality"""
    class _SelfISOProtocol(ISOProtocol, Protocol):
        _iso_image: Optional[str]
        _custom_iso_path: Optional[str]

    def __init__(
            self,
            *,
            iso_image: str,
            custom_iso_path: Optional[str] = None,
            **kwargs,
    ):
        self._iso_image = iso_image
        self._custom_iso_path = custom_iso_path

    @property
    def custom_iso_path(self) -> Optional[str]:
        return self._custom_iso_path

    @staticmethod
    async def create_alpine_overlay() -> str:
        """Create Alpine overlay with automation scripts"""
        ovl_dir = "ovl"
        os.makedirs(f"{ovl_dir}/etc/runlevels/default", exist_ok=True)
        os.makedirs(f"{ovl_dir}/etc/local.d", exist_ok=True)
        os.makedirs(f"{ovl_dir}/etc/apk", exist_ok=True)
        os.makedirs(f"{ovl_dir}/etc/auto-setup-alpine", exist_ok=True)

        # Enable default boot services
        open(f"{ovl_dir}/etc/.default_boot_services", 'w').close()

        # Enable local service
        if not os.path.exists(f"{ovl_dir}/etc/runlevels/default/local"):
            os.symlink("/etc/init.d/local", f"{ovl_dir}/etc/runlevels/default/local")

        # Create APK repositories file
        with open(f"{ovl_dir}/etc/apk/repositories", 'w') as f:
            f.write("""
/media/cdrom/apks
https://dl-cdn.alpinelinux.org/alpine/latest-stable/main
https://dl-cdn.alpinelinux.org/alpine/latest-stable/community
""")

        # Create setup script
        with open(f"{ovl_dir}/etc/local.d/auto-setup-alpine.start", 'w') as f:
            f.write("""#!/bin/sh
set -ex

# Setup system logging
echo "[Setup] Configuring system logging..."
apk add syslog-ng
rc-update add syslog-ng boot
/etc/init.d/syslog-ng start

# Setup SSH and Conda
apk update
apk add openssh openrc
rc-update add sshd
mkdir -p /run/openrc
touch /run/openrc/softlevel
echo 'root:alpine' | chpasswd
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
echo 'Port 22' >> /etc/ssh/sshd_config
echo 'ListenAddress 0.0.0.0' >> /etc/ssh/sshd_config
mkdir -p /root/.ssh
chmod 700 /root/.ssh

echo "[Setup] Starting SSH service..."
/etc/init.d/sshd start
ps aux | grep sshd
netstat -tln

# Log network status
echo "[Setup] Network status:"
ip addr
ip route
cat /etc/resolv.conf

# Monitor SSH logs
echo "[Setup] SSH logs:"
tail -f /var/log/messages | grep sshd &

# Get and install Miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh -O /tmp/miniconda.sh
chmod +x /tmp/miniconda.sh
/tmp/miniconda.sh -b -p /root/miniconda
echo 'export PATH=/root/miniconda/bin:$PATH' >> /root/.bashrc

# Run only once
rm -f /etc/local.d/auto-setup-alpine.start
rm -f /etc/runlevels/default/local

timeout 300 setup-alpine -ef /etc/auto-setup-alpine/answers
rm -rf /etc/auto-setup-alpine
""")
        os.chmod(f"{ovl_dir}/etc/local.d/auto-setup-alpine.start", 0o755)

        # Create answers file
        with open(f"{ovl_dir}/etc/auto-setup-alpine/answers", 'w') as f:
            f.write("""
KEYMAPOPTS=none
HOSTNAMEOPTS=alpine
DEVDOPTS=mdev
INTERFACESOPTS="auto lo
iface lo inet loopback
auto eth0
iface eth0 inet dhcp"
TIMEZONEOPTS=none
PROXYOPTS=none
APKREPOSOPTS="-1"
SSHDOPTS=openssh
NTPOPTS=none
DISKOPTS=none
LBUOPTS=none
APKCACHEOPTS=none
""")

        # Create overlay tarball
        subprocess.run(["tar", "-czf", "alpine.apkovl.tar.gz", "-C", ovl_dir, "."], check=True)

        return "alpine.apkovl.tar.gz"

    async def create_custom_alpine_iso(self, overlay_file: str) -> str:
        """Create custom Alpine ISO with overlay"""
        # Create mount point
        mount_point = "./alpine-mount"
        work_dir = "./alpine-work"
        device = None

        try:
            # Mount original ISO
            os.makedirs(mount_point, exist_ok=True)
            os.makedirs(work_dir, exist_ok=True)

            attach_output = subprocess.run(
                ["hdiutil", "attach", "-nomount", self._iso_image],
                check=True,
                capture_output=True,
                text=True
            ).stdout.splitlines()
            device = attach_output[0].split()[0]  # First line, first column (/dev/disk2)

            if not device:
                raise RuntimeError("Failed to find HFS partition in hdiutil output")
            print(f"[DEBUG] Attached ISO to device: {device}")

            subprocess.run([
                "mount",
                "-t", "cd9660",
                "-o", "ro",
                device,
                mount_point,
            ], check=True)

            # Copy contents to work dir
            for item in os.listdir(mount_point):
                src = os.path.join(mount_point, item)
                dst = os.path.join(work_dir, item)
                if os.path.isdir(src):
                    shutil.copytree(src, dst, dirs_exist_ok=True)
                    # Make copied directory and contents writable
                    for root, dirs, files in os.walk(dst):
                        for d in dirs:
                            os.chmod(os.path.join(root, d), 0o755)
                        for f in files:
                            os.chmod(os.path.join(root, f), 0o644)
                else:
                    shutil.copy2(src, dst)
                    os.chmod(dst, 0o644)

            # Add overlay file
            shutil.copy2(overlay_file, os.path.join(work_dir, "alpine.apkovl.tar.gz"))

            # Create new ISO
            self._custom_iso_path = self._custom_iso_path or "custom-alpine.iso"
            subprocess.run([
                "hdiutil", "makehybrid",
                "-o", self._custom_iso_path,
                "-hfs", "-joliet", "-iso", "-udf",
                "-default-volume-name", "ALPINE",
                work_dir
            ], check=True)

            subprocess.run(["umount", mount_point], check=True)

            return self._custom_iso_path

        finally:
            # Cleanup
            subprocess.run(["hdiutil", "detach", device], check=False)
            if os.path.exists(work_dir):
                shutil.rmtree(work_dir, ignore_errors=True)

    async def extract_kernel_from_iso(self, iso_path: str) -> str:
        """Extract kernel from Alpine ISO"""
        try:
            print("[Setup]: Extracting kernel from ISO...")
            mount_point = "./iso-mount"
            os.makedirs(mount_point, exist_ok=True)

            # Mount the ISO
            device = None
            try:
                # Attach ISO
                attach_output = subprocess.run(
                    ["hdiutil", "attach", "-nomount", iso_path],
                    check=True, capture_output=True, text=True
                ).stdout.splitlines()
                device = attach_output[0].split()[0]
                print(f"[Setup]: Attached ISO to device: {device}")

                # Mount the ISO
                subprocess.run([
                    "mount", "-t", "cd9660", "-o", "ro",
                    device, mount_point
                ], check=True)

                # Find and copy the kernel
                kernel_path = os.path.join(mount_point, "boot/vmlinuz-virt")
                if not os.path.exists(kernel_path):
                    raise FileNotFoundError("Kernel not found in ISO")

                # Copy kernel to local directory
                local_kernel = "vmlinuz-virt"
                shutil.copy2(kernel_path, local_kernel)

                print(f"[Setup]: Extracted kernel to {local_kernel}")
                return os.path.abspath(local_kernel)

            finally:
                # Cleanup
                with contextlib.suppress(Exception):
                    subprocess.run(["umount", mount_point], check=False)
                if device:
                    subprocess.run(["hdiutil", "detach", device], check=False)
                with contextlib.suppress(Exception):
                    os.rmdir(mount_point)
        except Exception as e:
            print(f"[Setup]: Failed to extract kernel: {e}")
            raise


class SnapshotManagementMixin(SnapshotProtocol):
    """Snapshot management functionality"""

    # Define the default snapshot as a class variable
    DEFAULT_SNAPSHOT: str = "conda"

    class _SelfSnapshotProtocol(SnapshotProtocol, QMPProtocol, Protocol):
        """Combined protocol including snapshot-specific attributes and methods"""
        DEFAULT_SNAPSHOT: str
        _current_snapshot: Optional[str]

    def __init__(self, **kwargs):
        self._current_snapshot: Optional[str] = None

    @property
    def current_snapshot(self) -> Optional[str]:
        """Get the name of the currently loaded snapshot"""
        return self._current_snapshot

    async def list_snapshots(self: _SelfSnapshotProtocol) -> dict:
        """List all available snapshots in the VM"""
        try:
            print("[QMP]: Getting snapshot list...")
            response = await self.qmp.execute('human-monitor-command',
                                            {'command-line': 'info snapshots'})
            print("[QMP]: Available snapshots:")
            print(response)
            return response
        except Exception as e:
            print(f"[QMP]: Error listing snapshots: {e}")
            return {}

    async def save_snapshot(self: _SelfSnapshotProtocol, name: Optional[str] = None) -> bool:
        """Save VM snapshot, using DEFAULT_SNAPSHOT if no name provided"""
        snapshot_name = name or self.DEFAULT_SNAPSHOT
        try:
            print(f"[QMP]: Creating snapshot '{snapshot_name}'...")
            await self.qmp.execute('human-monitor-command',
                                 {'command-line': f'savevm {snapshot_name}'})
            print("[QMP]: Snapshot created successfully")
            self._current_snapshot = snapshot_name
            return True
        except Exception as e:
            print(f"[QMP]: Error creating snapshot: {e}")
            return False

    async def load_snapshot(self: _SelfSnapshotProtocol, name: Optional[str] = None) -> bool:
        """Load VM snapshot, using DEFAULT_SNAPSHOT if no name provided"""
        snapshot_name = name or self.DEFAULT_SNAPSHOT
        try:
            print(f"[QMP]: Loading snapshot '{snapshot_name}'...")
            await self.qmp.execute('human-monitor-command',
                                 {'command-line': f'loadvm {snapshot_name}'})
            print("[QMP]: Snapshot loaded successfully")
            self._current_snapshot = snapshot_name
            return True
        except Exception as e:
            print(f"[QMP]: Error loading snapshot: {e}")
            return False

    async def delete_snapshot(self: _SelfSnapshotProtocol, name: Optional[str] = None) -> bool:
        """Delete VM snapshot, using DEFAULT_SNAPSHOT if no name provided"""
        snapshot_name = name or self.DEFAULT_SNAPSHOT
        try:
            print(f"[QMP]: Deleting snapshot '{snapshot_name}'...")
            await self.qmp.execute('human-monitor-command',
                                 {'command-line': f'delvm {snapshot_name}'})
            print("[QMP]: Snapshot deleted successfully")
            if self._current_snapshot == snapshot_name:
                self._current_snapshot = None
            return True
        except Exception as e:
            print(f"[QMP]: Error deleting snapshot: {e}")
            return False

    async def snapshot_exists(self: _SelfSnapshotProtocol, name: Optional[str] = None) -> bool:
        """Check if snapshot exists, using DEFAULT_SNAPSHOT if no name provided"""
        snapshot_name = name or self.DEFAULT_SNAPSHOT
        try:
            print(f"[QMP]: Checking if snapshot '{snapshot_name}' exists...")
            snapshots = await self.list_snapshots()
            exists = snapshot_name in snapshots
            print(f"[QMP]: Snapshot '{snapshot_name}' {'exists' if exists else 'not found'}")
            return exists
        except Exception as e:
            print(f"[QMP]: Error checking snapshot: {e}")
            return False

    async def ensure_snapshot(
        self: _SelfSnapshotProtocol,
        name: Optional[str] = None,
        setup_func: Optional[Callable[[], Awaitable[bool]]] = None
    ) -> bool:
        """Ensure snapshot exists, create if necessary using setup_func"""
        snapshot_name = name or self.DEFAULT_SNAPSHOT
        try:
            if not await self.snapshot_exists(snapshot_name):
                print(f"[QMP]: Snapshot '{snapshot_name}' not found, creating...")
                if setup_func and not await setup_func():
                    raise RuntimeError("Setup function failed")
                return await self.save_snapshot(snapshot_name)
            print(f"[QMP]: Snapshot '{snapshot_name}' already exists")
            return True
        except Exception as e:
            print(f"[QMP]: Error ensuring snapshot: {e}")
            return False

    async def verify_snapshot(self: _SelfSnapshotProtocol, name: Optional[str] = None) -> bool:
        """Verify snapshot integrity, using DEFAULT_SNAPSHOT if no name provided"""
        snapshot_name = name or self.DEFAULT_SNAPSHOT
        try:
            # First check if snapshot exists
            if not await self.snapshot_exists(snapshot_name):
                print(f"[QMP]: Cannot verify non-existent snapshot '{snapshot_name}'")
                return False

            # Try to load the snapshot
            if not await self.load_snapshot(snapshot_name):
                print(f"[QMP]: Failed to load snapshot '{snapshot_name}' during verification")
                return False

            print(f"[QMP]: Successfully verified snapshot '{snapshot_name}'")
            return True

        except Exception as e:
            print(f"[QMP]: Error during snapshot verification: {e}")
            return False
        
#    .-------------------.
# ---| Main Runner Class |---
#    '-------------------'

class ARM64Runner(
    AlpineISOBuilderMixin,
    SnapshotManagementMixin,
    MonitoringMixin,
    SSHControlMixin,
    QMPControlMixin,
    QEMUProcessMixin,
):
    """QEMU ARM64 Runner implementation"""
    DEFAULT_SNAPSHOT = "conda"

    def __init__(
            self,
            qemu_system: str,
            qcow2_path: str,
            socket_path: str,
            iso_image: Optional[str] = None,
            ssh_port: int = 10022,
    ):
        QEMUProcessMixin.__init__(
            self,
            qemu_system=qemu_system,
            qcow2_path=qcow2_path,
            kernel_path=None,
        )
        QMPControlMixin.__init__(self, socket_path=socket_path,)
        SSHControlMixin.__init__(self, ssh_port=ssh_port,)
        MonitoringMixin.__init__(self)
        SnapshotManagementMixin.__init__(self)
        AlpineISOBuilderMixin.__init__(self, iso_image=iso_image, custom_iso_path=None,)

        self.DEFAULT_SNAPSHOT = "conda"
        self._verify_initialization()
        
    def _verify_initialization(self) -> None:
        """Verify that all required attributes are properly initialized"""
        required_attrs = {
            '_qemu_system': 'QEMU system path',
            '_qcow2_path': 'QCOW2 image path',
            '_kernel_path': 'Kernel path',
            '_qemu_process': 'QEMU process',
            '_stdout_task': 'Stdout monitoring task',
            '_stderr_task': 'Stderr monitoring task',
            '_socket_path': 'QMP socket path',
            '_ssh_port': 'SSH port',
            '_iso_image': 'ISO image path',
        }

        if missing := [
            f"{attr} ({description})"
            for attr, description in required_attrs.items()
            if not hasattr(self, attr)
        ]:
            raise AttributeError(
                "Runner initialization incomplete. Missing attributes:\n" +
                "\n".join(f"- {attr}" for attr in missing)
            )

    async def setup_vm(self) -> bool:
        """Setup VM with all components"""
        try:
            # Create custom Alpine ISO with overlay
            print("[Setup]: Creating Alpine overlay...")
            overlay = await self.create_alpine_overlay()

            print("[Setup]: Creating custom Alpine ISO...")
            await self.create_custom_alpine_iso(overlay)

            # Extract kernel from custom ISO
            print("[Setup]: Extracting kernel from custom ISO...")
            kernel_path =await self.extract_kernel_from_iso(self.custom_iso_path)
            print(f"[Setup]: Using kernel from custom ISO: {kernel_path}")

            # Start VM with custom ISO
            print("[Setup]: Starting VM with custom ISO...")
            if not await self.start_process():
                raise RuntimeError("Failed to start VM")

            # Wait for system to boot and stabilize
            print("[Setup]: Waiting for system initialization...")
            await asyncio.sleep(60)  # Give more time for initial boot

            # Check VM status
            print("[Setup]: Checking system status...")
            await self.check_vm_status()

            # Wait for SSH service
            print("[Setup]: Waiting for SSH service...")
            if not await self.wait_for_ssh():
                raise RuntimeError("Failed to establish SSH connection")

            # Verify SSH connection
            print("[Setup]: Verifying SSH connection...")
            stdout, stderr, returncode = await self.execute_ssh_command("echo '[SSH] connection established'")
            if returncode != 0:
                print(f"[Setup]: SSH stderr: {stderr}")
                raise RuntimeError(f"SSH verification failed: {stderr}")
            print(f"[Setup]: SSH test output: {stdout.strip()}")

            # Eject CDROM before creating snapshot
            print("[Setup]: Ejecting CDROM...")
            await self.qmp.execute('human-monitor-command',
                                 {'command-line': 'eject -f cd0'})

            # Create initial snapshot
            print("[Setup]: Creating snapshot...")
            if not await self.save_snapshot(self.DEFAULT_SNAPSHOT):
                raise RuntimeError("Failed to create snapshot")

            print("[Setup]: Stopping VM to verify snapshot...")
            await self.stop_process()
            await asyncio.sleep(5)  # Wait for cleanup

            # Verify snapshot by loading it
            print("[Setup]: Verifying snapshot by loading it...")
            if not await self.start_process(load_snapshot=self.DEFAULT_SNAPSHOT):
                raise RuntimeError("Failed to verify snapshot - unable to load it")

            # Verify SSH still works after snapshot load
            print("[Setup]: Verifying SSH connection after snapshot...")
            stdout, stderr, returncode = await self.execute_ssh_command("echo '[SSH] snapshot verified'")
            if returncode != 0:
                raise RuntimeError(f"Post-snapshot SSH verification failed: {stderr}")
            print(f"[Setup]: Post-snapshot test: {stdout.strip()}")

            print("[Setup]: Setup completed successfully")
            return True

        except Exception as e:
            print(f"[Setup]: Failed: {e}")
            if self.qemu_process:
                try:
                    stdout, stderr = await self.qemu_process.communicate()
                    print(f"[Setup] QEMU stdout: {stdout.decode()}")
                    print(f"[Setup] QEMU stderr: {stderr.decode()}")
                except Exception as comm_error:
                    print(f"[Setup] Failed to get QEMU output: {comm_error}")
            return False
        finally:
            await self.stop_process()

    async def run_command(self, command: str, load_snapshot: bool = True) -> tuple[str, str, int]:
        """Run command in VM"""
        try:
            # First check if snapshot exists
            print("[Command]: Verifying snapshot...")
            exists = await self.snapshot_exists(self.DEFAULT_SNAPSHOT)
            if not exists:
                raise RuntimeError(f"Snapshot '{self.DEFAULT_SNAPSHOT}' not found")

            # Start VM with snapshot
            print(f"[Command]: Starting VM to execute: {command}")
            if not await self.start_process(load_snapshot=self.DEFAULT_SNAPSHOT if load_snapshot else None):
                raise RuntimeError("Failed to start VM")

            # Wait for system to be ready
            print("[Command]: Waiting for system to be ready...")
            await asyncio.sleep(20)

            # Execute command via SSH
            stdout, stderr, returncode = await self.execute_ssh_command(command)
            return stdout, stderr, returncode

        except Exception as e:
            print(f"[Command]: Failed: {e}")
            return "", str(e), 1
        finally:
            await self.stop_process()


#    .---------------------.
# ---| DryRun Runner Class |---
#    '---------------------'

@dataclass
class DryRunState:
    """Track the state of the dry run simulation"""
    vm_running: bool = False
    current_snapshot: Optional[str] = None
    snapshots: Dict[str, datetime] = field(default_factory=dict)
    qmp_connected: bool = False
    ssh_available: bool = False
    iso_created: bool = False
    kernel_extracted: bool = False
    logs: List[str] = field(default_factory=list)


def get_imports(dry_run: bool = False):
    """Get required imports based on dry run mode"""
    imports = {
        'asyncio': __import__('asyncio'),
        'os': __import__('os'),
        'platform': __import__('platform'),
        'shutil': __import__('shutil'),
        'signal': __import__('signal'),
        'subprocess': __import__('subprocess'),
        'contextlib': __import__('contextlib'),
        'typing': __import__('typing'),
    }

    if not dry_run:
        try:
            from qemu.qmp import QMPClient
            imports['QMPClient'] = QMPClient
        except ImportError:
            raise ImportError("QMP client required for non-dry-run mode")
    else:
        # Mock QMPClient for dry run
        class MockQMPClient:
            def __init__(self, name: str):
                self.name = name
                self._connected = False

            def is_connected(self) -> bool:
                return self._connected

            async def connect(self, socket_path: str) -> None:
                self._connected = True
                print(f"[Mock QMP] Connected to {socket_path}")

            async def disconnect(self) -> None:
                self._connected = False
                print("[Mock QMP] Disconnected")

            async def execute(self, command: str, arguments: dict = None) -> dict:
                print(f"[Mock QMP] Executing: {command} with args: {arguments}")
                return {"status": "running"}

            @property
            async def events(self):
                while False:  # Never yields anything in dry run
                    yield {}

        imports['QMPClient'] = MockQMPClient

    return imports


class DryRunOnlyRunner:
    """Minimal runner implementation for dry run mode"""
    # Match the default snapshot name from the main runner
    DEFAULT_SNAPSHOT = "conda"

    def __init__(
            self,
            qemu_system: str,
            qcow2_path: str,
            socket_path: str,
            iso_image: Optional[str] = None,
            ssh_port: int = 10022
    ):
        # Basic configuration
        self.qemu_system = qemu_system
        self.qcow2_path = qcow2_path
        self.socket_path = socket_path
        self.iso_image = iso_image
        self.ssh_port = ssh_port

        # State tracking
        self.state = DryRunState()
        self._setup_logging()

        # Create mock QMP client
        self.qmp = QMPClient("DryRun")  # Using the mock QMPClient defined at the top

    def _setup_logging(self):
        """Setup logging for dry run mode"""
        self.logger = logging.getLogger('DryRun')
        self.logger.setLevel(logging.INFO)
        handler = logging.StreamHandler()
        handler.setFormatter(
            logging.Formatter('[%(levelname)s] %(message)s')
        )
        self.logger.addHandler(handler)

    async def _simulate_delay(self, operation: str, duration: float = 1.0):
        """Simulate operation delay"""
        self.logger.info(f"Simulating {operation} delay ({duration}s)...")
        await asyncio.sleep(duration)

    async def setup_vm(self) -> bool:
        """Simulate VM setup"""
        try:
            self.logger.info("=== Starting VM Setup (Dry Run) ===")

            # Simulate ISO creation
            self.logger.info("Creating Alpine overlay...")
            await self._simulate_delay("overlay creation")
            self.state.iso_created = True

            # Simulate kernel extraction
            self.logger.info("Extracting kernel...")
            await self._simulate_delay("kernel extraction")
            self.state.kernel_extracted = True

            # Simulate VM startup
            self.logger.info("Starting VM...")
            await self._simulate_delay("VM startup", 2.0)
            self.state.vm_running = True

            # Simulate SSH availability
            self.logger.info("Waiting for SSH...")
            await self._simulate_delay("SSH initialization", 3.0)
            self.state.ssh_available = True

            # Simulate snapshot creation
            self.logger.info(f"Creating snapshot '{self.DEFAULT_SNAPSHOT}'...")
            await self._simulate_delay("snapshot creation")
            self.state.snapshots[self.DEFAULT_SNAPSHOT] = datetime.now()
            self.state.current_snapshot = self.DEFAULT_SNAPSHOT

            self.logger.info("=== VM Setup Complete (Dry Run) ===")
            return True

        except Exception as e:
            self.logger.error(f"Setup failed: {e}")
            return False

    async def run_command(
            self,
            command: str,
            load_snapshot: bool = True
    ) -> tuple[str, str, int]:
        """Simulate command execution"""
        try:
            self.logger.info("=== Starting Command Execution (Dry Run) ===")

            # Verify snapshot
            if load_snapshot:
                if self.DEFAULT_SNAPSHOT not in self.state.snapshots:
                    raise RuntimeError(f"Snapshot '{self.DEFAULT_SNAPSHOT}' not found")
                self.logger.info(f"Loading snapshot '{self.DEFAULT_SNAPSHOT}'...")
                await self._simulate_delay("snapshot loading")
                self.state.current_snapshot = self.DEFAULT_SNAPSHOT

            # Simulate VM startup
            self.logger.info("Starting VM...")
            await self._simulate_delay("VM startup", 2.0)
            self.state.vm_running = True

            # Simulate command execution
            self.logger.info(f"Executing command: {command}")
            await self._simulate_delay("command execution")

            stdout = f"[Dry Run] Simulated output for: {command}"
            stderr = ""
            returncode = 0

            self.logger.info("=== Command Execution Complete (Dry Run) ===")
            return stdout, stderr, returncode

        except Exception as e:
            self.logger.error(f"Command execution failed: {e}")
            return "", str(e), 1

    async def verify_configuration(self) -> dict:
        """Verify the runner configuration and return status"""
        required_paths = {
            'QEMU System': Path(self.qemu_system),
            'QCOW2 Image': Path(self.qcow2_path),
            'ISO Image': Path(self.iso_image) if self.iso_image else None,
            'Socket Path': Path(self.socket_path).parent,
        }

        return {
            'paths': {
                name: {
                    'path': str(path),
                    'exists': path.exists() if path else False,
                    'is_file': path.is_file() if path else False,
                    'is_dir': path.is_dir() if path else False,
                }
                for name, path in required_paths.items()
                if path is not None
            },
            'network': {
                'ssh_port': self.ssh_port,
                'port_available': self._check_port_available(self.ssh_port),
            },
            'state': {
                'vm_running': self.state.vm_running,
                'current_snapshot': self.state.current_snapshot,
                'snapshots': [
                    {'name': name, 'created': str(timestamp)}
                    for name, timestamp in self.state.snapshots.items()
                ],
                'qmp_connected': self.state.qmp_connected,
                'ssh_available': self.state.ssh_available,
            }
        }

    def _check_port_available(self, port: int) -> bool:
        """Check if a port is available"""
        import socket
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            try:
                s.bind(('localhost', port))
                return True
            except OSError:
                return False

#    .------.
# ---| Main |---
#    '------'

async def test_dry_run(runner: DryRunOnlyRunner):
    """Test the dry run functionality"""
    # Verify configuration
    config = await runner.verify_configuration()
    print("\nConfiguration Status:")
    print(f"Paths checked: {len(config['paths'])}")
    print(f"SSH port {config['network']['ssh_port']} " +
          ("available" if config['network']['port_available'] else "in use"))

    # Test VM setup
    print("\nTesting VM setup...")
    if await runner.setup_vm():
        print("VM setup successful")
    else:
        print("VM setup failed")

    # Test command execution
    print("\nTesting command execution...")
    stdout, stderr, rc = await runner.run_command("echo 'test'")
    print(f"Command output: {stdout}")
    print(f"Return code: {rc}")

async def main():
    parser = argparse.ArgumentParser(description="QEMU ARM64 Runner with Conda")
    parser.add_argument("--qemu-system", required=True, help="qemu-system-aarch64 binary path")
    parser.add_argument("--cdrom", help="Path to ISO image")
    parser.add_argument("--drive", required=True, help="Path to QEMU QCOW2 disk image")
    parser.add_argument("--socket", default="./qmp.sock", help="Path for QMP socket")
    parser.add_argument("--ssh-port", type=int, default=10022, help="Port for NIC socket")
    parser.add_argument("--setup", action="store_true", help="Perform initial setup and create snapshot")
    parser.add_argument("--run", help="Command to execute in the VM")
    parser.add_argument("--load-snapshot", default=None, help="Load snapshot from file")
    parser.add_argument("--dry-run", action="store_true", help="Enable dry run mode")

    args = parser.parse_args()

    if args.dry_run:
        runner = DryRunOnlyRunner(
            qemu_system=args.qemu_system,
            qcow2_path=args.drive,
            socket_path=args.socket,
            iso_image=args.cdrom,
            ssh_port=args.ssh_port
        )
        await test_dry_run(runner)
        return

    if not os.path.exists(args.qemu_system):
        raise FileNotFoundError(f"QEMU executable not found at {args.qemu_system}")

    runner = ARM64Runner(
        qemu_system=args.qemu_system,
        iso_image=args.cdrom,
        qcow2_path=args.drive,
        socket_path=args.socket,
        ssh_port=args.ssh_port,
    )

    if args.setup:
        print("Performing initial setup...")
        await runner.setup_vm()
    elif args.run:
        print(f"Executing command: {args.run}")
        stdout, stderr, returncode = await runner.run_command(
            args.run,
            load_snapshot=args.load_snapshot or ARM64Runner.DEFAULT_SNAPSHOT)
        print("Command output:")
        print(stdout)
        if stderr:
            print("Errors:")
            print(stderr)
        print(f"Return code: {returncode}")
    else:
        print("No action specified. Use --setup/--run")

if __name__ == "__main__":
    asyncio.run(main())

