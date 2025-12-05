import { EditorState } from "@codemirror/state";
import { oneDark } from "@codemirror/theme-one-dark";
import { EditorView, basicSetup } from "codemirror";
import { elixir } from "codemirror-lang-elixir";
// font sizing follows the CSS variable so media queries can shrink it on wide displays
const editorFontTheme = EditorView.theme({
  ".cm-editor": { fontSize: "var(--editor-font-size)" },
  ".cm-content": { fontSize: "var(--editor-font-size)" },
  ".cm-line": { fontSize: "var(--editor-font-size)" },
});
// ----- local state -----

const state = {
  code: `
# Welcome to the Blendend playground.
# Pick an example to load it, tweak
# and see the preview update.
# Save as a new file with "Filename" + "New"; 
# To the edit the current file use "Update".
alias BlendendPlayground.Palette

draw 800, 800 do
  
  [c1, c2, c3, c4, c5] =
  Palette.palette_by_name("takamo.VanGogh")
  |> Map.get(:colors, [])
  |> Palette.from_hex_list_rgb()
  |> Enum.map(fn {r, g, b} -> rgb(r, g, b) end)
  
  
  grad =
    linear_gradient 150, 150, 360, 360 do
      add_stop(0.0, c1)
      add_stop(0.25, c2)
      add_stop(0.5, c3)
      add_stop(0.75, c4)
      add_stop(1.0, c5)
    end

  translate(200, 200)
  round_rect(40, 40, 420, 320, 28, 28, fill: grad)

  font = load_font("priv/fonts/Alegreya-Regular.otf", 48.0)
  text(font, 80, 215, "Hello, blendend!", fill: rgb(40, 40, 40))
end
  `,
  image: "",
  error: "",
  examples: [],
  filename: "",
  selectedExample: "",
  view: null,
  fontSize: null,

  previewTimeout: null,
  renderId: 0,
};

// DOM refs we fill in at init
const dom = {
  root: null,
  editorHost: null,
  renderButton: null,
  examplesSelect: null,
  fontSizeSelect: null,
  filenameInput: null,
  saveButton: null,
  updateButton: null,
  errorBox: null,
  previewImg: null,
  previewPlaceholder: null,
};

// ----- init -----

function initPlayground() {
  dom.root = document.getElementById("playground-root");
  if (!dom.root) return;

  dom.root.innerHTML = playgroundMarkup();

  cacheDomRefs();
  attachHandlers();
  hydrateFontSize();
  initCodeMirror();
  loadExamples();
  renderBusy();
  renderError();
  renderPreview();

  scheduleRender(true);
}

function playgroundMarkup() {
  return `
    <div class="playground">
      <header class="playground-header">
        <div class="header-row">
          <h1>Blendend Playground</h1>
        </div>

        <div class="playground-toolbar">
          <div class="toolbar-group">
            <label>Examples</label>
            <select data-role="examples-select">
              <option value="">— Select —</option>
            </select>
          </div>

          <div class="toolbar-group">
            <label>Font size</label>
            <select data-role="font-size-select">
              <option value="9px">9px</option>
              <option value="10px">10px</option>
              <option value="11px">11px</option>
              <option value="12px">12px</option>
            </select>
          </div>

          <div class="toolbar-group">
            <label>Filename</label>
            <input
              type="text"
              placeholder="example name"
              data-role="filename-input"
            />
          </div>

          <div class="toolbar-group toolbar-group--buttons">
            <button
              type="button"
              class="playground-button"
              data-action="save"
            >
              New
            </button>
            <button
              type="button"
              class="playground-button"
              data-action="update"
            >
              Update
            </button>
            
          </div>
        </div>
      </header>

      <div class="playground-layout">
        <!-- LEFT: editor -->
        <section class="playground-col playground-col--editor">
          <div class="playground-card">
           

            <div id="editor" class="editor-shell"></div>

            <div class="error-message" data-role="error" style="display:none"></div>
          </div>
        </section>

        <!-- RIGHT: preview -->
        <section class="playground-col playground-col--preview">
          <div class="playground-card">
           

            <div class="preview">
              <img
                data-role="preview-img"
                alt="preview"
                style="display:none"
              />
              <span
                class="preview-placeholder"
                data-role="preview-placeholder"
              >
                No image yet. Start typing or select an example.
              </span>
            </div>
          </div>
        </section>
      </div>
    </div>
  `;
}

function cacheDomRefs() {
  const root = dom.root;
  dom.editorHost = root.querySelector("#editor");
  dom.examplesSelect = root.querySelector('[data-role="examples-select"]');
  dom.fontSizeSelect = root.querySelector('[data-role="font-size-select"]');
  dom.filenameInput = root.querySelector('[data-role="filename-input"]');
  dom.saveButton = root.querySelector('[data-action="save"]');
  dom.updateButton = root.querySelector('[data-action="update"]');
  dom.errorBox = root.querySelector('[data-role="error"]');
  dom.previewImg = root.querySelector('[data-role="preview-img"]');
  dom.previewPlaceholder = root.querySelector(
    '[data-role="preview-placeholder"]',
  );
}

function attachHandlers() {
  dom.examplesSelect.addEventListener("change", async (e) => {
    const name = e.target.value;
    state.selectedExample = name;
    state.filename = name;
    dom.filenameInput.value = name || "";

    if (!name) return;

    try {
      const res = await fetch(`/examples/${encodeURIComponent(name)}`);
      const data = await res.json();
      if (data.ok) {
        state.code = data.code;
        state.error = "";
        syncEditorToCode();
        renderError();
      } else {
        state.error = data.error || "Could not load example";
        renderError();
      }
    } catch (err) {
      state.error = String(err);
      renderError();
    }
  });

  dom.filenameInput.addEventListener("input", (e) => {
    state.filename = e.target.value;
  });

  dom.saveButton.addEventListener("click", (e) => {
    e.preventDefault();
    saveExample();
  });

  dom.updateButton.addEventListener("click", (e) => {
    e.preventDefault();
    updateExample();
  });

  dom.fontSizeSelect.addEventListener("change", (e) => {
    const size = e.target.value;
    state.fontSize = size;
    applyFontSize();
  });
}

function hydrateFontSize() {
  if (!dom.fontSizeSelect) return;
  const computed = getComputedStyle(document.documentElement).getPropertyValue(
    "--editor-font-size",
  );
  const clean = (computed || "").trim() || "11px";
  state.fontSize = clean;
  dom.fontSizeSelect.value = clean;
  applyFontSize();
}

function applyFontSize() {
  if (!state.fontSize) return;
  document.documentElement.style.setProperty(
    "--editor-font-size",
    state.fontSize,
  );

  // force inline on the editor root to win against any injected defaults
  if (state.view && state.view.dom) {
    state.view.dom.style.fontSize = state.fontSize;
  }
}

// ----- CodeMirror -----

function initCodeMirror() {
  if (!dom.editorHost || state.view) return;


  state.view = new EditorView({
    state: EditorState.create({
      doc: state.code,
      extensions: [
        basicSetup,
        elixir(),
         oneDark,
        editorFontTheme,
        EditorView.updateListener.of((update) => {
          if (update.docChanged) {
            state.code = update.state.doc.toString();
            scheduleRender(false); // auto preview on change
          }
        }),
      ],
    }),
    parent: dom.editorHost,
  });

  applyFontSize(); // ensure the view picks up the current selection immediately
}

function syncEditorToCode() {
  if (!state.view) return;
  const oldDoc = state.view.state.doc.toString();
  if (oldDoc === state.code) return;

  state.view.dispatch({
    changes: { from: 0, to: oldDoc.length, insert: state.code },
  });
}

// ----- server interaction -----

async function loadExamples() {
  try {
    const res = await fetch("/examples");
    const data = await res.json();
    if (data.ok) {
      state.examples = data.examples || [];
      renderExamples();
    }
  } catch (err) {
    console.error("loadExamples failed:", err);
  }
}

function renderExamples() {
  if (!dom.examplesSelect) return;

  const select = dom.examplesSelect;
  const current = state.selectedExample || "";

  select.innerHTML = '<option value="">— Select —</option>';

  state.examples.forEach((name) => {
    const opt = document.createElement("option");
    opt.value = name;
    opt.textContent = name;
    if (name === current) {
      opt.selected = true;
    }
    select.appendChild(opt);
  });
}

async function saveExample() {
  const name = (state.filename || "").trim();
  if (!name) {
    state.error = "Please enter a filename.";
    renderError();
    return;
  }

  try {
    const res = await fetch("/examples/save", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ name, code: state.code }),
    });
    const data = await res.json();
    if (data.ok) {
      state.error = "";
      state.selectedExample = name;
      state.examples = data.examples || [];
      renderExamples();
      renderError();
    } else if (data.error === "already_exists") {
      state.error = `Example "${name}" already exists (use Update).`;
      renderError();
    } else {
      state.error = data.error || "Save failed";
      renderError();
    }
  } catch (err) {
    state.error = String(err);
    renderError();
  }
}

async function updateExample() {
  const name = (state.filename || "").trim();
  if (!name) {
    state.error = "Please enter a filename.";
    renderError();
    return;
  }

  try {
    const res = await fetch("/examples/update", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ name, code: state.code }),
    });
    const data = await res.json();
    if (data.ok) {
      state.error = "";
      state.selectedExample = name;
      state.examples = data.examples || [];
      renderExamples();
      renderError();
    } else if (data.error === "not_found") {
      state.error = `Example "${name}" does not exist (use New first).`;
      renderError();
    } else {
      state.error = data.error || "Update failed";
      renderError();
    }
  } catch (err) {
    state.error = String(err);
    renderError();
  }
}

async function renderImage() {
  const myId = ++state.renderId;
  const code = state.code;

  try {
    const res = await fetch("/render", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ code }),
    });

    const data = await res.json();

    // If a newer render was requested, ignore this result
    if (myId !== state.renderId) {
      return;
    }

    if (data.ok) {
      state.image = data.image;
      state.error = "";
    } else {
      state.image = "";
      state.error = data.error || "Render failed";
    }

    renderPreview();
    renderError();
  } catch (err) {
    if (myId !== state.renderId) {
      return;
    }

    state.image = "";
    state.error = String(err);
    renderPreview();
    renderError();
  }
}

// ----- UI helpers -----

function renderBusy() {
  if (!dom.renderButton) return;
  dom.renderButton.disabled = state.busy;
  dom.renderButton.textContent = state.busy ? "Rendering…" : "Render";
}

function renderError() {
  if (!dom.errorBox) return;
  if (state.error) {
    dom.errorBox.style.display = "block";
    dom.errorBox.textContent = state.error;
  } else {
    dom.errorBox.style.display = "none";
    dom.errorBox.textContent = "";
  }
}

function renderPreview() {
  if (!dom.previewImg || !dom.previewPlaceholder) return;

  if (state.image) {
    dom.previewImg.src = state.image;
    dom.previewImg.style.display = "block";
    dom.previewPlaceholder.style.display = "none";
  } else {
    dom.previewImg.style.display = "none";
    dom.previewPlaceholder.style.display = "inline";
  }
}

document.addEventListener("keydown", (e) => {
  if ((e.ctrlKey || e.metaKey) && e.key === "Enter") {
    e.preventDefault();
    renderImage();
  }
});

function scheduleRender(immediate = false) {
  if (state.previewTimeout) {
    clearTimeout(state.previewTimeout);
    state.previewTimeout = null;
  }

  if (immediate) {
    renderImage();
  } else {
    state.previewTimeout = setTimeout(() => {
      renderImage();
    }, 400);
  }
}

// ----- boot -----

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", initPlayground);
} else {
  initPlayground();
}
