function renderSwatches(payload) {
  return fetch("/swatches/render", {
    method: "POST",
    headers: {"content-type": "application/json"},
    body: JSON.stringify(payload)
  })
    .then((r) => r.json())
    .then(({image}) => image)
    .catch((err) => {
      console.error(err);
      return null;
    });
}

const root = document.getElementById("swatches-root");

function init() {
  if (!root) return;

  root.innerHTML = `
    <div class="sw-controls">
      <div class="sw-field">
        <label>Source</label>
        <select id="sw-source"></select>
      </div>
      <div class="sw-field">
        <label>Palette</label>
        <select id="sw-scheme"></select>
      </div>
    </div>
    <div class="sw-output">
      <img id="sw-preview" />
    </div>
  `;

  const previewEl = document.getElementById("sw-preview");
  const sourceEl = document.getElementById("sw-source");
  const schemeEl = document.getElementById("sw-scheme");

  fetch("/swatches/palettes")
    .then((r) => r.json())
    .then(({ sources = [], palettes = {} }) => {
      if (!sources || sources.length === 0) return;

      sources.forEach((src) => {
        const opt = document.createElement("option");
        opt.value = src;
        opt.textContent = src;
        sourceEl.appendChild(opt);
      });

      sourceEl.onchange = () => {
        populateSchemes(palettes, sourceEl.value, schemeEl, previewEl);
        loadScheme(previewEl, schemeEl.value, sourceEl.value);
      };

      populateSchemes(palettes, sources[0], schemeEl, previewEl);
      loadScheme(previewEl, schemeEl.value, sourceEl.value);
    })
    .catch((err) => console.error(err));
}

function populateSchemes(palettes, source, schemeEl, previewEl) {
  schemeEl.innerHTML = "";
  const names = palettes[source] || [];
  names.forEach((name) => {
    const opt = document.createElement("option");
    opt.value = name;
    opt.textContent = name;
    schemeEl.appendChild(opt);
  });
  if (names.length > 0) {
    schemeEl.value = names[0];
    schemeEl.onchange = () => loadScheme(previewEl, schemeEl.value, source);
  }
}

function loadScheme(previewEl, name, source) {
  if (!name) return;
  const qs = source ? `?source=${encodeURIComponent(source)}` : "";
  fetch(`/swatches/palette/${encodeURIComponent(name)}${qs}`)
    .then((r) => r.json())
    .then(({ values, colors, name: schemeName, source: schemeSource }) => {
      render(previewEl, schemeName, schemeSource || source);
    })
    .catch((err) => console.error(err));
}

function render(previewEl, schemeLabel, source) {
  const select = document.getElementById("sw-scheme");
  const name = schemeLabel || (select && select.value);
  if (!name) return;

  renderSwatches({ name, source }).then((image) => {
    if (image) previewEl.src = image;
  });
}

init();
