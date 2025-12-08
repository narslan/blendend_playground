import json
import os
import urllib.request
import urllib.parse
import urllib.error
import sublime
import sublime_plugin

PREVIEW_URL = "http://localhost:4711/render"
TIMEOUT = 5
class BlendendPreviewCommand(sublime_plugin.WindowCommand):
    def run(self):
        view = self.window.active_view()
        if not view or not view.file_name():
            sublime.status_message("Blendend preview: no file")
            return
        current_view = view
        path = view.file_name()
        data = urllib.parse.urlencode({"file": path}).encode("utf-8")
        try:
            req = urllib.request.Request(PREVIEW_URL, data=data, method="POST")
            with urllib.request.urlopen(req, timeout=TIMEOUT) as resp:
                body = resp.read().decode("utf-8")
        except urllib.error.HTTPError as e:
            body = e.read().decode("utf-8")
            msg = f"Blendend preview failed: HTTP {e.code} {body}"
            print(msg)
            sublime.status_message(msg)
            return
        except Exception as e:
            msg = f"Blendend preview failed: {e}"
            print(msg)
            sublime.status_message(msg)
            return
        try:
            res = json.loads(body)
        except Exception as e:
            msg = f"Blendend preview parse error: {e}"
            print(msg)
            sublime.status_message(msg)
            return
        if not res.get("ok"):
            msg = f"Blendend preview error: {res.get('error')}"
            print(msg)
            sublime.status_message(msg)
            return
        png = res.get("png")
        if png and os.path.exists(png):
            self.window.open_file(png)
            if current_view:
                sublime.set_timeout(lambda: self.window.focus_view(current_view), 0)
            sublime.status_message(f"Blendend preview updated: {png}")
        else:
            sublime.status_message("Blendend preview: PNG not found")
