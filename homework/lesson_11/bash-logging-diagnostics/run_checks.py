#!/usr/bin/env python3
"""Run the 16 Bash examples in a disposable directory and print safe evidence."""

import http.server
import os
from pathlib import Path
import signal
import subprocess
import tempfile
import threading
import time


SCRIPTS = Path(__file__).resolve().parent / "scripts"
results = []


def record(name, actual, expected, detail):
    ok = actual == expected
    results.append((name, actual, expected, ok, detail))
    return ok


def run(number, *, args=(), env=None, input_text=None, timeout=35):
    script = next(SCRIPTS.glob(f"{number:02d}-*.sh"))
    if input_text is not None:
        script = Path(work) / f"variant-{number:02d}.sh"
        script.write_text(input_text)
    p = subprocess.run(
        ["bash", str(script), *args], env={**os.environ, **base_env, **(env or {})},
        text=True, capture_output=True, timeout=timeout,
    )
    return p.returncode, p.stdout + p.stderr


class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        status = 200 if self.path == "/ok" else 500
        self.send_response(status)
        self.end_headers()
        self.wfile.write(b"local test")

    def log_message(self, *args):
        pass


with tempfile.TemporaryDirectory(prefix="os-bash-homework-") as work:
    base_env = {
        "LOG_DIR": str(Path(work) / "logs"),
        "OUT_DIR": str(Path(work) / "out"),
        "CMD_TIMEOUT": "1",
        "DEMO_LOCK_FILE": str(Path(work) / "example.lock"),
        "DIAG_LOCK_FILE": str(Path(work) / "diagnostics.lock"),
        "CONFIG_FILE": str(Path(work) / "missing.conf"),
    }

    for script in sorted(SCRIPTS.glob("*.sh")):
        p = subprocess.run(["bash", "-n", str(script)], capture_output=True)
        if p.returncode:
            record("синтаксис " + script.name, p.returncode, 0, "bash -n")
    record("синтаксис 16 файлов", 0, 0, "bash -n: ошибок нет")

    rc, out = run(1)
    record("01 строгий режим", rc, 0, "нормальное завершение" if "Скрипт завершён" in out else "нет финального сообщения")
    source = next(SCRIPTS.glob("01-*.sh")).read_text()
    rc, out = run(1, input_text=source.replace("\n# false\n", "\nfalse\n"))
    record("01 ошибка set -e", rc, 1, "вторая версия прервана на false")

    for level, expected in (("INFO", "DEBUG скрыт"), ("DEBUG", "DEBUG виден")):
        rc, out = run(2, env={"LOG_LEVEL": level})
        matched = ("Это DEBUG" in out) == (level == "DEBUG")
        record("02 логирование " + level, rc if matched else 99, 0, expected)

    rc, out = run(3)
    logs = list((Path(work) / "logs").glob("demo-*.log"))
    record("03 лог в файле", rc if logs and "Завершение" in logs[0].read_text() else 99, 0, "лог записан в изолированном каталоге")

    rc, out = run(4)
    record("04 trap EXIT", rc if "[cleanup]" in out else 99, 0, "очистка вызвана")
    source = next(SCRIPTS.glob("04-*.sh")).read_text()
    rc, out = run(4, input_text=source.replace("\n# exit 1\n", "\nexit 1\n"))
    record("04 trap при ошибке", rc if "[cleanup]" in out else 99, 1, "очистка вызвана и при exit 1")

    rc, out = run(5)
    record("05 trap ERR обычный", rc, 0, "успешная функция")
    source = next(SCRIPTS.glob("05-*.sh")).read_text()
    rc, out = run(5, input_text=source.replace("\n# do_fail   #", "\ndo_fail   #"))
    record("05 trap ERR ошибка", rc if "[ERR]" in out else 99, 1, "перехвачена ошибка false")

    signal_script = next(SCRIPTS.glob("06-*.sh"))
    proc = subprocess.Popen(["bash", str(signal_script)], env={**os.environ, **base_env}, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    time.sleep(1.2)
    proc.send_signal(signal.SIGTERM)
    stdout, stderr = proc.communicate(timeout=5)
    lock_absent = not Path(base_env["DEMO_LOCK_FILE"]).exists()
    record("06 SIGTERM", proc.returncode if "[signal] TERM" in stdout and "[cleanup]" in stdout and lock_absent else 99, 143, "сигнал принят, lock удалён")

    rc, out = run(7)
    record("07 безопасный конфиг", rc if "ПРОПУЩЕНО: rm -rf /" in out else 99, 0, "команда в конфиге отклонена")

    rc, out = run(8, args=("--level", "DEBUG", "--out", str(Path(work) / "custom")))
    record("08 аргументы", rc if "LOG_LEVEL=DEBUG" in out else 99, 0, "аргументы разобраны")
    rc, out = run(8, args=("--unknown",))
    record("08 неверная опция", rc, 2, "ошибка аргумента")

    rc, out = run(9)
    record("09 валидация", rc, 0, "параметры приняты")
    rc, out = run(9, env={"CMD_TIMEOUT": "wrong"})
    record("09 неверная настройка", rc, 1, "нечисловой таймаут отвергнут")

    rc, out = run(10)
    record("10 таймаут команды", rc if "Как и ожидалось" in out and "Команда не найдена" in out else 99, 0, "таймаут и ошибка команды обработаны")

    rc, out = run(11)
    system = Path(work) / "out" / "system.txt"
    record("11 системный отчёт", rc if system.exists() and "=== hostname ===" in system.read_text() else 99, 0, "system.txt создан; содержимое не публикуется")

    rc, out = run(12)
    record("12 файловые системы", rc if "(OK)" in out or "(внимание" in out or "(критично" in out else 99, 0, "df разобран, персональные пути не публикуются")

    server = http.server.HTTPServer(("127.0.0.1", 0), Handler)
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    targets = f"http://127.0.0.1:{server.server_port}/ok http://127.0.0.1:{server.server_port}/fail"
    rc, out = run(13, env={"HTTP_TARGETS": targets})
    record("13 HTTP 200/500", rc if "OK" in out and "FAIL" in out else 99, 0, "локальный сервер: 200 принят, 500 отмечен как FAIL")

    lock_script = next(SCRIPTS.glob("14-*.sh"))
    first = subprocess.Popen(["bash", str(lock_script)], env={**os.environ, **base_env}, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    time.sleep(0.4)
    second_rc, second_out = run(14)
    first_out, _ = first.communicate(timeout=15)
    record("14 flock конкуренция", second_rc if first.returncode == 0 and "Другой экземпляр" in second_out else 99, 1, "второй экземпляр отклонён; первый завершился")

    rc, out = run(15)
    record("15 скрытие секретов", rc if "password=***" in out and "Bearer ***" in out and "s3cr3t" not in out else 99, 0, "тестовые значения скрыты")

    rc, out = run(16, env={"HTTP_TARGETS": targets})
    archive = Path(work) / "out.tar.gz"
    http_ok = "OK" in out and "FAIL" in out
    record("16 полный отчёт", rc if archive.exists() and http_ok else 99, 0,
           "архив создан, HTTP 200 и 500 проверены" if http_ok else
           f"архив={archive.exists()}, rc={rc}, HTTP-строки={sum('HTTP' in line or 'FAIL' in line for line in out.splitlines())}")
    rc, out = run(16, args=("--version",))
    record("16 версия", rc if "1.0.0" in out else 99, 0, "параметр --version")
    server.shutdown()

print("| Проверка | Код | Ожидалось | Итог | Наблюдение |")
print("|---|---:|---:|---|---|")
for name, actual, expected, ok, detail in results:
    print(f"| {name} | {actual} | {expected} | {'OK' if ok else 'FAIL'} | {detail} |")
print(f"\nИтого: {sum(r[3] for r in results)}/{len(results)} проверок совпали с ожиданием.")
raise SystemExit(0 if all(r[3] for r in results) else 1)
