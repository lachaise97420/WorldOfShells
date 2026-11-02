pkill -f 'qs -c MacShell' 2>/dev/null || true
pkill -f 'qs -c nucleus-shell' 2>/dev/null || true
pkill -f 'qs -c nandoroid' 2>/dev/null || true
pkill -f 'qs -c sekaipop' 2>/dev/null || true
pkill -f 'qs -c twinshell' 2>/dev/null || true
pkill -f 'qs -c qsdots' 2>/dev/null || true
pkill -f 'qs -c asaki' 2>/dev/null || true
pkill -f 'qs -c materialui' 2>/dev/null || true
pkill -f 'qs -c vantage' 2>/dev/null || true
pkill -f 'qs -c ukishima' 2>/dev/null || true
pkill -f 'qs -c lucid' 2>/dev/null || true
pkill -f 'qs -c nothingshell' 2>/dev/null || true
pkill -f 'qs -c nibras' 2>/dev/null || true
pkill -f 'qs -c impasto' 2>/dev/null || true
dms kill 2>/dev/null || true
pkill -f 'dms run' 2>/dev/null || true
pkill -f 'discord_voice_bridge.py' 2>/dev/null || true
systemctl --user stop ryoku-shell.service 2>/dev/null || true
ps -eo pid,args | awk '/qs -c shell/ && !/awk/ {print $1}' | xargs -r kill 2>/dev/null || true
sleep 0.5
nohup qs -c materialui </dev/null >/tmp/opencode/materialui.log 2>&1 &
disown
echo "activated"
