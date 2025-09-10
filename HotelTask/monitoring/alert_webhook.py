from flask import Flask, request, jsonify
import subprocess, platform, logging

app = Flask(__name__)
logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)s %(message)s')

def kill_artisan_windows():
    """Kill Laravel artisan serve processes on Windows."""
    killed = []
    try:
        ps_cmd = r'''powershell -Command "Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -and ($_.CommandLine -match 'artisan') } | Select-Object -ExpandProperty ProcessId"'''
        out = subprocess.check_output(ps_cmd, shell=True, universal_newlines=True, stderr=subprocess.STDOUT)
        pids = [line.strip() for line in out.splitlines() if line.strip().isdigit()]
        for pid in pids:
            logging.info(f"Stopping artisan pid {pid}")
            subprocess.run(f"taskkill /PID {pid} /F", shell=True)
            killed.append(pid)

        if not killed:
            logging.warning("No artisan PIDs found, killing all php.exe processes")
            subprocess.run("taskkill /IM php.exe /F", shell=True)
            killed.append("php.exe")

    except subprocess.CalledProcessError as e:
        logging.error("PowerShell error: %s", e.output)

    return killed


def kill_artisan_unix():
    """Kill artisan on Linux/macOS (containers/WSL)."""
    try:
        subprocess.run(["pkill", "-f", "artisan"], check=False)
        return True
    except Exception as e:
        logging.error("pkill failed: %s", e)
        try:
            out = subprocess.check_output("ps aux | grep 'php artisan' | grep -v grep | awk '{print $2}'",
                                          shell=True, universal_newlines=True)
            pids = [x for x in out.split() if x]
            for pid in pids:
                subprocess.run(["kill", "-9", pid])
            return pids
        except Exception as e2:
            logging.error("Fallback kill also failed: %s", e2)
            return []

@app.route("/alert", methods=["POST"])
def alert():
    payload = request.get_json(force=True, silent=True)
    logging.info("Received alert payload: %s", "YES" if payload else "EMPTY")
    if not payload:
        return jsonify({"error": "no json payload"}), 400

    killed = []
    for a in payload.get("alerts", []):
        name = a.get("labels", {}).get("alertname", "")
        status = a.get("status", "")
        logging.info("Alert: %s status=%s", name, status)
        if status == "firing" and name in ("MySQLDown", "RedisDown", "KafkaDown"):
            if platform.system() == "Windows":
                pids = kill_artisan_windows()
                killed.extend(pids)
            else:
                res = kill_artisan_unix()
                killed.append(res)

    return jsonify({"killed": killed}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
