import contextlib
import os
import platform
import shutil
import signal
import subprocess
from typing import Protocol, Optional, AsyncGenerator, runtime_checkable
import asyncio
from qemu.qmp import QMPClient


#    .----------------.
# ---| Core Protocols |---
#    '----------------'

@runtime_checkable
class ProcessProtocol(Protocol):
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

    def cleanup_qmp_socket(self: ProcessProtocol) -> bool: ...

@runtime_checkable
class QEMUProtocol(Protocol):
    """Required attributes for QEMU process management"""
    @property
    def qemu_system(self) -> str: ...

    @property
    def qcow2_path(self) -> str: ...

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
    async def monitor_output(self, stream, name): ...

    async def monitor_log_file(self: QEMUProtocol, log_file: str): ...

    async def check_vm_boot_log(self: QMPProtocol) -> None: ...

    async def check_console_log(self) -> None: ...

@runtime_checkable
class ISOProtocol(Protocol):
    @property
    def iso_image(self) -> str: ...

    @property
    def custom_iso_path(self) -> Optional[str]: ...

    @staticmethod
    async def create_alpine_overlay() -> str: ...

    async def create_custom_alpine_iso(self, overlay_file: str) -> str: ...

    async def extract_kernel_from_iso(self, iso_path: str) -> str: ...

@runtime_checkable
class SnapshotProtocol(Protocol):
    """Required attributes for snapshot management"""
    DEFAULT_SNAPSHOT: str
    async def list_snapshots(self) -> str: ...

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
    class _SelfQMPProtocol(QEMUQMPProtocol, Protocol):
        """Combined protocol including both required attributes and mixin methods"""
        _stdout_task: Optional[asyncio.Task]
        _stderr_task: Optional[asyncio.Task]
        _log_monitor: Optional[asyncio.Task]
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
            **kwargs
    ):
        super().__init__(**kwargs)
        self._qemu_system = qemu_system
        self._qcow2_path = qcow2_path
        self._kernel_path = kernel_path

        self._process_manager = ProcessManager()
        self._qemu_process: Optional[asyncio.subprocess.Process] = None
        self._stdout_task: Optional[asyncio.Task] = None
        self._stderr_task: Optional[asyncio.Task] = None

    @property
    def qemu_system(self) -> str:
        return self._qemu_system

    @property
    def qemu_process(self) -> Optional[asyncio.subprocess.Process]:
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
        if not load_snapshot and (iso_to_use := self._custom_iso_path or self.iso_image):
            cmd.extend([
                "-device", "virtio-blk-pci,drive=cd0,addr=0x4",
                "-drive", f"file={iso_to_use},if=none,id=cd0,format=raw,readonly=on"
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

            # Start output monitoring tasks
            self._stdout_task = asyncio.create_task(
                self._monitor_output(self.qemu_process.stdout, "stdout"))
            self._stderr_task = asyncio.create_task(
                self._monitor_output(self.qemu_process.stderr, "stderr"))
            self._log_monitor = asyncio.create_task(
                self.monitor_log_file(log_file))

            return True

        except Exception as e:
            print(f"[Process]: Failed to start QEMU: {e}")
            return False

    async def stop_process(self: _SelfQMPProtocol) -> None:
        """Stop QEMU process and cleanup"""
        # Cancel monitoring tasks
        for task in [self._stdout_task, self._stderr_task, self._log_monitor]:
            if task:
                task.cancel()
                with contextlib.suppress(asyncio.CancelledError):
                    await task
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
            **kwargs
    ):
        super().__init__(**kwargs)

        self._socket_path = socket_path

        self._qmp = QMPClient('ARM64 VM')
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

    def __init__(self):
        super().__init__()
        
    async def monitor_output(self, stream, name):
        """Monitor QEMU output stream"""
        while True:
            line = await stream.readline()
            if not line:
                break
            print(f"[QEMU {name}]: {line.decode().strip()}")

    async def monitor_log_file(self: QEMUProtocol, log_file: str):
        """Monitor the log file for new content"""
        try:
            position = 0
            while True:
                if not os.path.exists(log_file):
                    await asyncio.sleep(1)
                    continue

                with open(log_file, 'r') as f:
                    f.seek(position)
                    if new_content := f.read():
                        print(f"[VM Console]:\n{new_content}")
                    position = f.tell()

                # Check if process is still running
                if self.qemu_process.returncode is not None:
                    break

                await asyncio.sleep(1)
        except Exception as e:
            print(f"[Log Monitor]: Error: {e}")

    async def check_vm_boot_log(self: QMPProtocol):
        """Check the VM console log"""
        try:
            print("[Debug] Checking console log...")
            if os.path.exists("console.log"):
                with open("console.log", "r") as f:
                    log_content = f.read()
                    print("[Console Log]:")
                    print(log_content)

                # Try to get syslog output from guest
                await self.qmp.execute('human-monitor-command',
                                       {'command-line': 'guest-exec cat /var/log/messages'})
        except Exception as e:
            print(f"[Debug] Error reading console log: {e}")

    async def check_console_log(self):
        """Check the console log file"""
        try:
            if os.path.exists("console.log"):
                with open("console.log", "r") as f:
                    if content := f.read():
                        print("[Console Log]:")
                        print(content)
                    else:
                        print("[Console Log]: Empty")
        except Exception as e:
            print(f"[Debug] Error reading console log: {e}")



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
        super().__init__(**kwargs)
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
        super().__init__(**kwargs)
        self._iso_image = iso_image
        self._custom_iso_path = custom_iso_path

    @property
    def iso_image(self) -> str:
        return self._iso_image

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

    class _SelfSnapshotProtocol(SnapshotProtocol, QMPProtocol, Protocol):
        """Combined protocol including snapshot-specific attributes and methods"""

        ...

    def __init__(self, **kwargs, ):
        super().__init__(**kwargs)

    async def list_snapshots(self: _SelfSnapshotProtocol) -> str:
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
            return ""

    async def save_snapshot(self: _SelfSnapshotProtocol, name: str) -> bool:
        """Save VM snapshot"""
        try:
            print(f"[QMP]: Creating snapshot '{name}'...")
            await self.qmp.execute('human-monitor-command',
                                   {'command-line': f'savevm {name}'})
            print("[QMP]: Snapshot created successfully")
            return True
        except Exception as e:
            print(f"[QMP]: Error creating snapshot: {e}")
            return False

    async def load_snapshot(self: _SelfSnapshotProtocol, name: str) -> bool:
        """Load VM snapshot"""
        try:
            print(f"[QMP]: Loading snapshot '{name}'...")
            await self.qmp.execute('human-monitor-command',
                                   {'command-line': f'loadvm {name}'})
            print("[QMP]: Snapshot loaded successfully")
            return True
        except Exception as e:
            print(f"[QMP]: Error loading snapshot: {e}")
            return False

    async def delete_snapshot(self: _SelfSnapshotProtocol, name: str) -> bool:
        """Delete VM snapshot"""
        try:
            print(f"[QMP]: Deleting snapshot '{name}'...")
            await self.qmp.execute('human-monitor-command',
                                   {'command-line': f'delvm {name}'})
            print("[QMP]: Snapshot deleted successfully")
            return True
        except Exception as e:
            print(f"[QMP]: Error deleting snapshot: {e}")
            return False

    async def snapshot_exists(self: _SelfSnapshotProtocol, name: str) -> bool:
        """Check if snapshot exists with better error handling"""
        try:
            print(f"[QMP]: Checking if snapshot '{name}' exists...")
            snapshots = await self.list_snapshots()
            exists = name in snapshots
            print(f"[QMP]: Snapshot '{name}' {'exists' if exists else 'not found'}")
            return exists
        except Exception as e:
            print(f"[QMP]: Error checking snapshot: {e}")
            return False

    async def ensure_snapshot(self: _SelfSnapshotProtocol, name: str, setup_func) -> bool:
        """Ensure snapshot exists, create if necessary"""
        if not await self.snapshot_exists(name):
            print(f"[QMP]: Snapshot '{name}' not found, creating...")
            await setup_func()
            return await self.save_snapshot(name)
        print(f"[QMP]: Snapshot '{name}' already exists")
        return True

    async def verify_snapshot(self: _SelfSnapshotProtocol, name: str) -> bool:
        """Verify snapshot integrity"""
        try:
            # First check if snapshot exists
            if not await self.snapshot_exists(name):
                print(f"[QMP]: Cannot verify non-existent snapshot '{name}'")
                return False

            # Try to load the snapshot
            if not await self.load_snapshot(name):
                print(f"[QMP]: Failed to load snapshot '{name}' during verification")
                return False

            print(f"[QMP]: Successfully verified snapshot '{name}'")
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
        super().__init__(
            qemu_system=qemu_system,
            qcow2_path=qcow2_path,
            socket_path=socket_path,
            iso_image=iso_image,
            ssh_port=ssh_port,
        )

    async def setup_vm(self) -> bool:
        """Setup VM with all components"""
        if not self.iso_image:
            raise ValueError("ISO path is required for setup")

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
            