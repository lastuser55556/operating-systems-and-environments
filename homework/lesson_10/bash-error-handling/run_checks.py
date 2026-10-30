#!/usr/bin/env python3
"""Check the twelve Bash homework scripts and print reproducible results."""
import os
from pathlib import Path
import shutil
import signal
import subprocess
import tempfile
import time

root = Path(__file__).resolve().parent
scripts = sorted((root / "scripts").glob("*.sh"))
BASH = shutil.which("bash")
checks = []


def run(n, *args, env=None):
    return subprocess.run([BASH, str(scripts[n-1]), *map(str, args)],
                          text=True, capture_output=True,
                          env={**os.environ, **(env or {})}, timeout=35)


def check(label, process, expected, marker):
    output = process.stdout + process.stderr
    passed = process.returncode == expected and marker in output
    checks.append((label, process.returncode, expected, passed))


with tempfile.TemporaryDirectory(prefix="bash-errors-") as tmp:
    existing = Path(tmp) / "exists.txt"
    existing.write_text("example")
    missing = Path(tmp) / "missing.txt"

    for s in scripts:
        p = subprocess.run(["bash", "-n", str(s)])
        assert p.returncode == 0, f"Синтаксис: {s.name}"
    checks.append(("12 файлов: bash -n", 0, 0, True))

    check("01 test и код возврата", run(1), 0, "Код возврата test: 0")
    check("02 два аргумента", run(2, existing, 42), 0, "OK")
    check("02 аргументов мало", run(2, existing), 1, "Использование")
    check("02 аргумент не число", run(2, existing, "wrong"), 2, "должен быть")
    check("03 set -e", run(3), 1, "")
    p = run(3)
    checks.append(("03 строка после false пропущена", p.returncode, 1,
                   "не должна появиться" not in p.stdout))
    check("04 set -u и EXIT", run(4), 1, "Переменная не задана")
    check("05 значения по умолчанию", run(5), 0, "Гость")
    check("05 пустое имя", run(5), 0, "Незнакомец")
    check("05 обязательное имя", run(5, "--required"), 1, "Имя обязательно")

    check("06 EXIT обычный", run(6, env={"SLEEP_SECONDS": "0"}), 0, "Убрано")
    p = subprocess.Popen(["bash", str(scripts[5])], start_new_session=True,
                         text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    time.sleep(.3)
    os.killpg(p.pid, signal.SIGTERM)
    stdout, stderr = p.communicate(timeout=5)
    checks.append(("06 SIGTERM", p.returncode, 143,
                   p.returncode == 143 and "Убрано" in stdout and
                   not Path(stdout.splitlines()[0].split(": ", 1)[1]).exists()))
    p = subprocess.Popen(["bash", str(scripts[5])], start_new_session=True,
                         text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    time.sleep(.3)
    os.killpg(p.pid, signal.SIGINT)
    stdout, stderr = p.communicate(timeout=5)
    checks.append(("06 SIGINT", p.returncode, 130,
                   p.returncode == 130 and "Убрано" in stdout and
                   not Path(stdout.splitlines()[0].split(": ", 1)[1]).exists()))

    check("07 читаемый файл", run(7, existing), 0, "Файл читается")
    check("07 отсутствующий файл", run(7, missing), 1, "ОШИБКА: нет доступа")
    available = all(subprocess.run(["bash", "-c", f"command -v {dep}"],
                                   capture_output=True).returncode == 0
                    for dep in ("git", "curl", "jq"))
    check("08 системные зависимости", run(8), 0 if available else 127,
          "Все зависимости" if available else "Отсутствуют зависимости")
    mock_bin = Path(tmp) / "bin"
    mock_bin.mkdir()
    for dep in ("git", "curl"):
        (mock_bin / dep).touch(mode=0o755)
        (mock_bin / dep).chmod(0o755)
    check("08 отсутствует jq", run(8, env={"PATH": str(mock_bin)}), 127, "jq")

    check("09 все файлы есть", run(9, existing), 0, "OK:")
    check("09 один файл отсутствует", run(9, existing, missing), 1, "MISSING:")
    p = run(10)
    checks.append(("10 трассировка multiply", p.returncode, 0,
                   "multiply:" in p.stderr and "42" in p.stdout))
    p = run(11)
    checks.append(("11 два деления", p.returncode, 0,
                   "Код первого вызова: 0" in p.stdout and
                   "Код второго вызова: 1" in p.stdout))
    check("12 точечное игнорирование", run(12), 0, "Успешная команда выполнена")

print("| Проверка | Код | Ожидалось | Результат |")
print("|---|---:|---:|---|")
for label, rc, expected, passed in checks:
    print(f"| {label} | {rc} | {expected} | {'OK' if passed else 'FAIL'} |")
print(f"\nИтого: {sum(c[3] for c in checks)}/{len(checks)} проверок прошли.")
raise SystemExit(0 if all(c[3] for c in checks) else 1)
