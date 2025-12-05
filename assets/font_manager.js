const state = {
  fonts: [],
  filter: "",
  selectedFontId: null,
  selectedStyle: null,
  sampleText: "Hamburgefonts . 0123",
  fontSize: 48,
  previewImage: "",
  error: "",
  previewTimeout: null,
  previewRequestId: 0,
};

const dom = {};

function initFontManager() {
  dom.root = document.getElementById("fonts-root");
  if (!dom.root) return;

  dom.root.innerHTML = layout();
  cacheDom();
  attachHandlers();
  hydrateInputs();
  loadFonts();
}

function layout() {
  return `
    <div class="font-manager">
      <header class="font-manager__header">
        <div>
          <h1>Font Manager</h1>
          <p>Lookup scanned fonts, find their file paths, and render a quick preview.</p>
        </div>
        <div class="font-manager__filters">
          <label class="sr-only" for="font-filter">Filter fonts</label>
          <input id="font-filter" type="text" placeholder="Filter by family" data-role="filter-input" />
        </div>
      </header>

      <div class="font-manager__layout">
        <section class="font-manager__list">
          <div class="font-manager__list-header">
            <h2>Fonts</h2>
            <span class="font-manager__count" data-role="font-count">0</span>
          </div>
          <div class="font-card-list" data-role="font-list"></div>
        </section>

        <section class="font-manager__preview">
          <div class="font-preview-card">
            <div class="font-preview-controls">
              <label class="control">
                <span>Sample text</span>
                <input type="text" data-role="sample-input" />
              </label>
              <label class="control control--size">
                <span>Size</span>
                <input type="number" min="8" max="120" step="2" data-role="size-input" />
              </label>
            </div>

            <div class="font-preview-variations">
              <label class="control">
                <span>Variation</span>
                <select data-role="variation-select"></select>
              </label>
            </div>

            <div class="font-preview-output">
              <img data-role="preview-img" alt="font preview" style="display:none" />
              <div class="font-preview-placeholder" data-role="preview-placeholder">
                Select a font to see its preview.
              </div>
            </div>

            <div class="font-preview-meta" data-role="preview-meta"></div>
            <div class="error-message" data-role="font-error" style="display:none"></div>
          </div>
        </section>
      </div>
    </div>
  `;
}

function cacheDom() {
  const root = dom.root;
  dom.fontList = root.querySelector('[data-role="font-list"]');
  dom.fontCount = root.querySelector('[data-role="font-count"]');
  dom.filterInput = root.querySelector('[data-role="filter-input"]');
  dom.sampleInput = root.querySelector('[data-role="sample-input"]');
  dom.sizeInput = root.querySelector('[data-role="size-input"]');
  dom.variationSelect = root.querySelector('[data-role="variation-select"]');
  dom.previewImg = root.querySelector('[data-role="preview-img"]');
  dom.previewPlaceholder = root.querySelector('[data-role="preview-placeholder"]');
  dom.previewMeta = root.querySelector('[data-role="preview-meta"]');
  dom.errorBox = root.querySelector('[data-role="font-error"]');
}

function attachHandlers() {
  dom.filterInput.addEventListener("input", (e) => {
    state.filter = e.target.value.toLowerCase();
    renderFontList();
  });

  dom.sampleInput.addEventListener("input", (e) => {
    state.sampleText = e.target.value;
    schedulePreview();
  });

  dom.sizeInput.addEventListener("input", (e) => {
    state.fontSize = Number(e.target.value) || 48;
    schedulePreview();
  });

  if (dom.variationSelect) {
    dom.variationSelect.addEventListener("change", (e) => {
      state.selectedStyle = e.target.value || null;
      const font = state.fonts.find((f) => f.id === state.selectedFontId);
      if (font) {
        renderVariations(font);
        renderMeta(font);
        renderPreview();
      }
    });
  }
}

function hydrateInputs() {
  if (dom.sampleInput) dom.sampleInput.value = state.sampleText;
  if (dom.sizeInput) dom.sizeInput.value = state.fontSize;
}

async function loadFonts() {
  try {
    const res = await fetch("/fonts/list");
    const data = await res.json();
    if (data.ok) {
      state.fonts = data.fonts || [];
      renderFontList();
    }
  } catch (err) {
    console.error("Failed to load fonts", err);
  }
}

function renderFontList() {
  if (!dom.fontList) return;
  const filter = state.filter || "";
  const filtered =
    filter.length === 0
      ? state.fonts
      : state.fonts.filter((font) =>
          font.family.toLowerCase().includes(filter),
        );

  dom.fontList.innerHTML = "";
  dom.fontCount.textContent = `${filtered.length}`;

  filtered.forEach((font) => {
    const card = document.createElement("button");
    card.className = "font-card";
    card.type = "button";
    card.dataset.fontId = font.id;
    card.innerHTML = `<div class="font-card__title">${font.family}</div>`;

    if (font.id === state.selectedFontId) {
      card.classList.add("font-card--active");
    }

    card.addEventListener("click", () => selectFont(font));
    dom.fontList.appendChild(card);
  });

  if (!state.selectedFontId && filtered.length > 0) {
    selectFont(filtered[0]);
  }
}

function selectFont(font) {
  if (!font) return;
  state.selectedFontId = font.id;
  state.selectedStyle = font.variations?.[0]?.style || null;
  state.previewImage = "";
  state.error = "";
  renderFontList();
  renderVariations(font);
  renderMeta(font);
  renderPreview();
}

function renderVariations(font) {
  if (!dom.variationSelect) return;
  dom.variationSelect.innerHTML = "";

  const variations = font.variations || [];
  variations.forEach((variation) => {
    const option = document.createElement("option");
    option.value = variation.style;
    option.textContent = `${variation.style} · ${variation.weight}`;
    option.selected = variation.style === state.selectedStyle;
    dom.variationSelect.appendChild(option);
  });

  if (variations.length === 0) {
    const placeholder = document.createElement("option");
    placeholder.textContent = "No variations found";
    placeholder.value = "";
    dom.variationSelect.appendChild(placeholder);
  }

  dom.variationSelect.disabled = variations.length === 0;
}

function renderMeta(font) {
  if (!dom.previewMeta) return;
  const variation =
    font.variations.find((v) => v.style === state.selectedStyle) ||
    font.variations[0];

  if (!variation) {
    dom.previewMeta.textContent = "";
    return;
  }

  dom.previewMeta.innerHTML = `
    <div><strong>Family:</strong> ${font.family}</div>
    <div><strong>Style:</strong> ${variation.style} (${variation.weight})</div>
    <div><strong>Path:</strong> ${variation.path}</div>
  `;
}

function renderPreviewPlaceholder(showImg) {
  if (!dom.previewImg || !dom.previewPlaceholder) return;
  dom.previewImg.style.display = showImg ? "block" : "none";
  dom.previewPlaceholder.style.display = showImg ? "none" : "flex";
  dom.previewPlaceholder.textContent = showImg
    ? ""
    : state.selectedFontId
      ? "Rendering preview…"
      : "Select a font to see its preview.";
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

async function renderPreview() {
  if (!state.selectedFontId) {
    state.previewImage = "";
    renderPreviewPlaceholder(false);
    return;
  }

  const myId = ++state.previewRequestId;
  renderPreviewPlaceholder(false);
  renderError();

  try {
    const res = await fetch("/fonts/preview", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        font_id: state.selectedFontId,
        style: state.selectedStyle,
        text: state.sampleText,
        size: state.fontSize,
      }),
    });

    const data = await res.json();
    if (myId !== state.previewRequestId) return;

    if (data.ok) {
      state.previewImage = data.image;
      state.error = "";
      if (dom.previewImg) {
        dom.previewImg.src = data.image;
      }
      renderPreviewPlaceholder(true);
      renderError();
    } else {
      state.previewImage = "";
      state.error = data.error || "Preview failed";
      renderPreviewPlaceholder(false);
      renderError();
    }
  } catch (err) {
    if (myId !== state.previewRequestId) return;
    state.previewImage = "";
    state.error = String(err);
    renderPreviewPlaceholder(false);
    renderError();
  }
}

function schedulePreview() {
  if (state.previewTimeout) {
    clearTimeout(state.previewTimeout);
    state.previewTimeout = null;
  }

  state.previewTimeout = setTimeout(() => renderPreview(), 200);
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", initFontManager);
} else {
  initFontManager();
}
